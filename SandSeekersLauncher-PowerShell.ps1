# SandSeekers Launcher - Version PowerShell avec interface graphique
# Alternative au lanceur C# WPF pour les systèmes sans .NET SDK

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
Add-Type -AssemblyName System.IO.Compression.FileSystem

# Configuration
$RepoOwner = "VotreNomUtilisateur"  # À modifier
$RepoName = "SandSeekers"           # À modifier
$GameExeName = "SandSeekers.exe"

# Chemins
$LocalAppData = [Environment]::GetFolderPath('LocalApplicationData')
$GameInstallPath = Join-Path $LocalAppData "SandSeekersGame"
$VersionFilePath = Join-Path $GameInstallPath "version.txt"

# Résolution dynamique du dossier AppData pour les datafiles (préférence SandSeekers)
function Resolve-SaveDir {
param([string]$preferred = 'SandSeekers')
    $root = [Environment]::GetFolderPath('LocalApplicationData')
    $candidates = @(
        (Join-Path $root 'SandSeekers\datafiles'),
        (Join-Path $root 'backup\datafiles'),
        (Join-Path $root 'SandSeekersGame\datafiles')
    )
    $preferredPath = if ($preferred) { Join-Path $root ("$preferred\datafiles") } else { $null }
    if ($preferredPath -and (Test-Path $preferredPath)) { return $preferredPath }
    foreach ($p in $candidates) { if (Test-Path $p) { return $p } }
    if ($preferredPath) {
        New-Item -ItemType Directory -Force -Path $preferredPath | Out-Null
        return $preferredPath
    }
    $fallback = Join-Path $root 'SandSeekers\datafiles'
    New-Item -ItemType Directory -Force -Path $fallback | Out-Null
    return $fallback
}
function Get-CardInfo {
    param([string]$path)
    if (-not (Test-Path $path)) { return $null }
    try {
        $json = Get-Content $path -Raw | ConvertFrom-Json
        $count = [int]$json.total_cards
        $hash = (Get-FileHash $path -Algorithm SHA256).Hash
        return [PSCustomObject]@{ Path=$path; Count=$count; Hash=$hash }
    } catch { return $null }
}
function Sync-CardsDatabase {
    param([string]$installDir, [string]$saveDir)
    $src = Join-Path $installDir 'datafiles\cards_database.json'
    $dst = Join-Path $saveDir 'cards_database.json'
    if (-not (Test-Path $src)) { return }
    New-Item -ItemType Directory -Force -Path $saveDir | Out-Null
    $srcInfo = Get-CardInfo -path $src
    $dstInfo = Get-CardInfo -path $dst
    if (-not $dstInfo -or $dstInfo.Count -lt $srcInfo.Count -or $dstInfo.Hash -ne $srcInfo.Hash) {
        Copy-Item $src $dst -Force
    }
}

# Variables globales
$CurrentVersion = "0.0.0"
$LatestVersion = "0.0.0"
$DownloadUrl = ""

# Fonctions
function Get-CurrentVersion {
    if (Test-Path $VersionFilePath) {
        try {
            return (Get-Content $VersionFilePath -Raw).Trim()
        } catch {
            return "0.0.0"
        }
    }
    return "0.0.0"
}

function Get-LatestVersionFromGitHub {
    try {
        $apiUrl = "https://api.github.com/repos/$RepoOwner/$RepoName/releases/latest"
        $headers = @{ 'User-Agent' = 'SandSeekers-Launcher-PowerShell/1.0' }
        
        $release = Invoke-RestMethod -Uri $apiUrl -Headers $headers -ErrorAction Stop
        $tagName = $release.tag_name
        
        # Chercher l'asset Windows
        foreach ($asset in $release.assets) {
            # Assouplir: accepter le premier .zip trouvé
            if ($asset.name -like "*.zip") {
                $script:DownloadUrl = $asset.browser_download_url
                break
            }
        }
        
        return $tagName -replace '^v', ''
    } catch {
        Write-Host "Erreur lors de la vérification: $($_.Exception.Message)"
        return $null
    }
}

function Test-UpdateAvailable {
    param($current, $latest)
    
    try {
        $currentVer = [Version]$current
        $latestVer = [Version]$latest
        return $latestVer -gt $currentVer
    } catch {
        return $current -ne $latest
    }
}

function Update-StatusLabel {
    param($text)
    $StatusLabel.Text = $text
    $Form.Refresh()
}

function Update-ProgressBar {
    param($value, $text = "")
    $ProgressBar.Value = [Math]::Min(100, [Math]::Max(0, $value))
    if ($text) { $ProgressLabel.Text = $text }
    $Form.Refresh()
}

function Download-AndInstallGame {
    try {
        $tempZip = Join-Path $env:TEMP "SandSeekers_Update.zip"
        
        Update-StatusLabel "📥 Téléchargement en cours..."
        Update-ProgressBar 0 "Connexion au serveur..."
        
        # Télécharger avec barre de progression
        $webClient = New-Object System.Net.WebClient
        $webClient.Headers.Add('User-Agent', 'SandSeekers-Launcher-PowerShell/1.0')
        
        # Événement de progression
        $webClient.add_DownloadProgressChanged({
            param($sender, $e)
            Update-ProgressBar $e.ProgressPercentage "$([Math]::Round($e.BytesReceived/1MB, 1)) MB / $([Math]::Round($e.TotalBytesToReceive/1MB, 1)) MB"
        })
        
        # Téléchargement synchrone avec événements
        $webClient.DownloadFile($DownloadUrl, $tempZip)
        $webClient.Dispose()
        
        Update-StatusLabel "📦 Installation en cours..."
        Update-ProgressBar 0 "Extraction des fichiers..."
        
        # Créer le dossier d'installation
        if (!(Test-Path $GameInstallPath)) {
            New-Item -ItemType Directory -Path $GameInstallPath -Force | Out-Null
        }
        
        # Extraire le ZIP
        [System.IO.Compression.ZipFile]::ExtractToDirectory($tempZip, $GameInstallPath, $true)

# Synchroniser la base de cartes vers AppData (SandSeekers\datafiles)
$saveDir = Resolve-SaveDir 'SandSeekers'
        Sync-CardsDatabase -installDir $GameInstallPath -saveDir $saveDir

        # Sauvegarder la version
        Set-Content -Path $VersionFilePath -Value $LatestVersion -Encoding UTF8
        
        Update-StatusLabel "✅ Installation terminée!"
        Update-ProgressBar 100 "Terminé"
        
        # Nettoyer
        Remove-Item $tempZip -ErrorAction SilentlyContinue
        
        return $true
    } catch {
        Update-StatusLabel "❌ Erreur: $($_.Exception.Message)"
        [System.Windows.Forms.MessageBox]::Show("Erreur lors de la mise à jour:`n$($_.Exception.Message)", "Erreur", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
        return $false
    }
}

function Start-Game {
    $gamePath = Join-Path $GameInstallPath $GameExeName
    
    if (!(Test-Path $gamePath)) {
        [System.Windows.Forms.MessageBox]::Show("Le jeu n'est pas installé. Veuillez d'abord télécharger une mise à jour.", "Jeu non trouvé", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Warning)
        return
    }
    
    try {
        # Vérifier et synchroniser la base de cartes avant lancement
$saveDir = Resolve-SaveDir 'SandSeekers'
        Sync-CardsDatabase -installDir $GameInstallPath -saveDir $saveDir
        Start-Process -FilePath $gamePath -WorkingDirectory $GameInstallPath
        $Form.Close()
    } catch {
        [System.Windows.Forms.MessageBox]::Show("Erreur lors du lancement du jeu:`n$($_.Exception.Message)", "Erreur", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
    }
}

# Créer l'interface graphique
$Form = New-Object System.Windows.Forms.Form
$Form.Text = "SandSeekers Launcher"
$Form.Size = New-Object System.Drawing.Size(600, 400)
$Form.StartPosition = "CenterScreen"
$Form.FormBorderStyle = "FixedSingle"
$Form.MaximizeBox = $false
$Form.BackColor = [System.Drawing.Color]::FromArgb(44, 62, 80)

# Header
$HeaderPanel = New-Object System.Windows.Forms.Panel
$HeaderPanel.Size = New-Object System.Drawing.Size(600, 80)
$HeaderPanel.Location = New-Object System.Drawing.Point(0, 0)
$HeaderPanel.BackColor = [System.Drawing.Color]::FromArgb(52, 73, 94)

$TitleLabel = New-Object System.Windows.Forms.Label
$TitleLabel.Text = "🎮 SandSeekers"
$TitleLabel.Font = New-Object System.Drawing.Font("Segoe UI", 18, [System.Drawing.FontStyle]::Bold)
$TitleLabel.ForeColor = [System.Drawing.Color]::White
$TitleLabel.Location = New-Object System.Drawing.Point(20, 20)
$TitleLabel.Size = New-Object System.Drawing.Size(300, 40)

$VersionLabel = New-Object System.Windows.Forms.Label
$VersionLabel.Text = "Version: Vérification..."
$VersionLabel.Font = New-Object System.Drawing.Font("Segoe UI", 9)
$VersionLabel.ForeColor = [System.Drawing.Color]::FromArgb(189, 195, 199)
$VersionLabel.Location = New-Object System.Drawing.Point(20, 50)
$VersionLabel.Size = New-Object System.Drawing.Size(300, 20)

# Status Area
$StatusLabel = New-Object System.Windows.Forms.Label
$StatusLabel.Text = "Vérification des mises à jour..."
$StatusLabel.Font = New-Object System.Drawing.Font("Segoe UI", 12)
$StatusLabel.ForeColor = [System.Drawing.Color]::White
$StatusLabel.Location = New-Object System.Drawing.Point(50, 120)
$StatusLabel.Size = New-Object System.Drawing.Size(500, 30)
$StatusLabel.TextAlign = "MiddleCenter"

$ProgressBar = New-Object System.Windows.Forms.ProgressBar
$ProgressBar.Location = New-Object System.Drawing.Point(50, 160)
$ProgressBar.Size = New-Object System.Drawing.Size(500, 20)
$ProgressBar.Style = "Continuous"
$ProgressBar.Visible = $false

$ProgressLabel = New-Object System.Windows.Forms.Label
$ProgressLabel.Text = ""
$ProgressLabel.Font = New-Object System.Drawing.Font("Segoe UI", 9)
$ProgressLabel.ForeColor = [System.Drawing.Color]::FromArgb(189, 195, 199)
$ProgressLabel.Location = New-Object System.Drawing.Point(50, 185)
$ProgressLabel.Size = New-Object System.Drawing.Size(500, 20)
$ProgressLabel.TextAlign = "MiddleCenter"

# Buttons
$PlayButton = New-Object System.Windows.Forms.Button
$PlayButton.Text = "🎮 JOUER"
$PlayButton.Font = New-Object System.Drawing.Font("Segoe UI", 12, [System.Drawing.FontStyle]::Bold)
$PlayButton.Size = New-Object System.Drawing.Size(150, 50)
$PlayButton.Location = New-Object System.Drawing.Point(150, 250)
$PlayButton.BackColor = [System.Drawing.Color]::FromArgb(74, 144, 226)
$PlayButton.ForeColor = [System.Drawing.Color]::White
$PlayButton.FlatStyle = "Flat"
$PlayButton.FlatAppearance.BorderSize = 0
$PlayButton.Enabled = $false
$PlayButton.Add_Click({ Start-Game })

$UpdateButton = New-Object System.Windows.Forms.Button
$UpdateButton.Text = "⬇️ METTRE À JOUR"
$UpdateButton.Font = New-Object System.Drawing.Font("Segoe UI", 12, [System.Drawing.FontStyle]::Bold)
$UpdateButton.Size = New-Object System.Drawing.Size(180, 50)
$UpdateButton.Location = New-Object System.Drawing.Point(320, 250)
$UpdateButton.BackColor = [System.Drawing.Color]::FromArgb(40, 167, 69)
$UpdateButton.ForeColor = [System.Drawing.Color]::White
$UpdateButton.FlatStyle = "Flat"
$UpdateButton.FlatAppearance.BorderSize = 0
$UpdateButton.Visible = $false
$UpdateButton.Add_Click({
    $UpdateButton.Enabled = $false
    $PlayButton.Enabled = $false
    $ProgressBar.Visible = $true
    
    if (Download-AndInstallGame) {
        $script:CurrentVersion = $LatestVersion
        $VersionLabel.Text = "Version installée: $CurrentVersion"
        $UpdateButton.Visible = $false
        $PlayButton.Enabled = $true
    }
    
    $UpdateButton.Enabled = $true
    $ProgressBar.Visible = $false
    $ProgressLabel.Text = ""
})

# Footer
$FooterLabel = New-Object System.Windows.Forms.Label
$FooterLabel.Text = "© 2025 SandSeekers Team | Installation: $GameInstallPath"
$FooterLabel.Font = New-Object System.Drawing.Font("Segoe UI", 8)
$FooterLabel.ForeColor = [System.Drawing.Color]::FromArgb(127, 140, 141)
$FooterLabel.Location = New-Object System.Drawing.Point(20, 330)
$FooterLabel.Size = New-Object System.Drawing.Size(560, 30)
$FooterLabel.TextAlign = "MiddleCenter"

# Ajouter les contrôles
$HeaderPanel.Controls.Add($TitleLabel)
$HeaderPanel.Controls.Add($VersionLabel)
$Form.Controls.Add($HeaderPanel)
$Form.Controls.Add($StatusLabel)
$Form.Controls.Add($ProgressBar)
$Form.Controls.Add($ProgressLabel)
$Form.Controls.Add($PlayButton)
$Form.Controls.Add($UpdateButton)
$Form.Controls.Add($FooterLabel)

# Vérification initiale au chargement
$Form.Add_Shown({
    $script:CurrentVersion = Get-CurrentVersion
    $VersionLabel.Text = "Version installée: $CurrentVersion"
    
    Update-StatusLabel "Vérification des mises à jour..."
    $script:LatestVersion = Get-LatestVersionFromGitHub
    
    if ($LatestVersion) {
        if (Test-UpdateAvailable $CurrentVersion $LatestVersion) {
            Update-StatusLabel "🆕 Nouvelle version disponible: $LatestVersion"
            $UpdateButton.Visible = $true
        } else {
            Update-StatusLabel "✅ Vous avez la dernière version"
            $UpdateButton.Visible = $false
        }
    } else {
        Update-StatusLabel "❌ Impossible de vérifier les mises à jour"
    }
    
    # Activer le bouton Jouer si le jeu est installé
    $gamePath = Join-Path $GameInstallPath $GameExeName
    $PlayButton.Enabled = Test-Path $gamePath
})

# Afficher la fenêtre
[System.Windows.Forms.Application]::Run($Form)