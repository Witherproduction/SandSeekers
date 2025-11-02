Param(
    [switch]$Force
)

# ===============================
# SandSeekers Windows Update Launcher
# - Télécharge la dernière version depuis GitHub Releases
# - Installe le jeu dans %LOCALAPPDATA%\SandSeekersGame
# - Préserve les sauvegardes dans %LOCALAPPDATA%\SandSeekers\datafiles
# ===============================

$ErrorActionPreference = 'Stop'

# ---- CONFIG ----
# Modifie ces deux variables si besoin (utilisateur/organisation et nom du dépôt)
$RepoOwner = 'arckano'           # Ajuste si ton compte GitHub est différent
$RepoName  = 'SandSeekers'       # Ajuste si le dépôt a un autre nom

# Nom (ou motif) de l'asset Windows zip dans les Releases (facultatif)
$WindowsAssetPattern = 'windows.*\.zip|win.*\.zip|SandSeekers.*\.zip'

# Répertoires d'installation et de sauvegarde
$InstallDir = Join-Path $env:LOCALAPPDATA 'SandSeekersGame'
$VersionFile = Join-Path $InstallDir 'version.txt'
# Par défaut, le jeu utilise %LOCALAPPDATA%\SandSeekers\datafiles
# Nous résolvons dynamiquement le dossier de sauvegarde pour éviter les incohérences
$SaveDirPreferred = 'SandSeekers'
function Resolve-SaveDir {
    param(
        [string]$preferred = 'SandSeekers'
    )
    $root = $env:LOCALAPPDATA
    $candidates = @(
        (Join-Path $root 'SandSeekers\datafiles'),
        (Join-Path $root 'backup\datafiles'),
        (Join-Path $root 'SandSeekersGame\datafiles')
    )
    # Si le préféré existe déjà, le prendre
    $preferredPath = if ($preferred -and $preferred -ne '') { Join-Path $root ("$preferred\datafiles") } else { $null }
    if ($preferredPath -and (Test-Path $preferredPath)) { return $preferredPath }
    # Sinon, choisir le premier contenant cards_database.json, ou créer le préféré
    foreach ($p in $candidates) { if (Test-Path $p) { return $p } }
    if ($preferredPath) {
        New-Item -ItemType Directory -Force -Path $preferredPath | Out-Null
        return $preferredPath
    }
    # Fallback: créer SandSeekers\datafiles
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
    if (-not $dstInfo) {
        Write-Info "Copie initiale du cards_database.json vers $saveDir"
        Copy-Item $src $dst -Force
        return
    }
    if ($dstInfo.Count -lt $srcInfo.Count -or $dstInfo.Hash -ne $srcInfo.Hash) {
        Write-Info "Mise à jour du cards_database.json (dst: $($dstInfo.Count) -> src: $($srcInfo.Count))"
        Copy-Item $src $dst -Force
    } else {
        Write-Ok 'Base de cartes déjà à jour dans AppData'
    }
}

# Création des répertoires nécessaires
New-Item -ItemType Directory -Force -Path $InstallDir | Out-Null
# $SaveDir sera résolu dynamiquement plus bas

# ---- UTILITAIRES ----
function Write-Info($msg)  { Write-Host "[INFO]  $msg" -ForegroundColor Cyan }
function Write-Ok($msg)    { Write-Host "[OK]    $msg" -ForegroundColor Green }
function Write-Warn($msg)  { Write-Host "[WARN]  $msg" -ForegroundColor Yellow }
function Write-Err($msg)   { Write-Host "[ERROR] $msg" -ForegroundColor Red }

function Get-InstalledVersion {
    if (Test-Path $VersionFile) {
        return (Get-Content $VersionFile -ErrorAction SilentlyContinue | Select-Object -First 1)
    }
    return ''
}

function Save-InstalledVersion($version) {
    Set-Content -Path $VersionFile -Value $version -Encoding UTF8 -Force
}

function Get-LatestRelease {
    $uri = "https://api.github.com/repos/$RepoOwner/$RepoName/releases/latest"
    Write-Info "Interroge GitHub: $uri"
    $headers = @{ 'User-Agent' = 'SandSeekersLauncher' }
    try {
        return Invoke-RestMethod -Uri $uri -Headers $headers -TimeoutSec 30
    } catch {
        Write-Warn "Impossible de récupérer la dernière release: $($_.Exception.Message)"
        return $null
    }
}

function Select-WindowsAsset($release) {
    if (-not $release -or -not $release.assets) { return $null }
    # Essayer par nom
    $byName = $release.assets | Where-Object { $_.name -match $WindowsAssetPattern }
    if ($byName -and $byName.Count -gt 0) { return $byName[0] }
    # Sinon, premier zip
    $zip = $release.assets | Where-Object { $_.content_type -eq 'application/zip' -or $_.name -like '*.zip' }
    if ($zip -and $zip.Count -gt 0) { return $zip[0] }
    return $null
}

function Download-File($url, $dest) {
    Write-Info "Téléchargement: $url"
    $headers = @{ 'User-Agent' = 'SandSeekersLauncher' }
    try {
        Invoke-WebRequest -Uri $url -Headers $headers -OutFile $dest -TimeoutSec 300
        Write-Ok "Téléchargé: $dest"
        return $true
    } catch {
        Write-Err "Échec du téléchargement: $($_.Exception.Message)"
        return $false
    }
}

function Stop-RunningGame {
    $proc = Get-Process -Name 'SandSeekers' -ErrorAction SilentlyContinue
    if ($proc) {
        Write-Warn 'Jeu en cours d’exécution, arrêt…'
        $proc | Stop-Process -Force
        Start-Sleep -Milliseconds 500
    }
}

function Clear-InstallDir {
    if (Test-Path $InstallDir) {
        Write-Info "Nettoyage: $InstallDir"
        Get-ChildItem -Path $InstallDir -Force | ForEach-Object {
            try { Remove-Item $_.FullName -Recurse -Force -ErrorAction Stop } catch {}
        }
    }
}

function Expand-Zip-Flatten($zipPath, $destDir) {
    Write-Info "Extraction: $zipPath -> $destDir"
    Expand-Archive -Path $zipPath -DestinationPath $destDir -Force
    # Si extraction dans un sous-dossier unique, aplatir
    $entries = Get-ChildItem -Path $destDir -Force
    if ($entries.Count -eq 1 -and $entries[0].PSIsContainer) {
        $inner = $entries[0].FullName
        Write-Info "Aplatissement du dossier: $inner"
        Get-ChildItem -Path $inner -Force | ForEach-Object {
            Move-Item -Path $_.FullName -Destination $destDir -Force
        }
        Remove-Item -Path $inner -Recurse -Force
    }
    Write-Ok 'Extraction terminée'
}

function Find-GameExe {
    $exe = Get-ChildItem -Path $InstallDir -Recurse -Filter 'SandSeekers.exe' -ErrorAction SilentlyContinue | Select-Object -First 1
    return $exe ? $exe.FullName : $null
}

function Launch-Game($exePath) {
    if (-not $exePath) { Write-Err 'Executable introuvable.'; return }
    Write-Ok "Lancement du jeu: $exePath"
    Start-Process -FilePath $exePath -WorkingDirectory (Split-Path $exePath)
}

# ---- LOGIQUE PRINCIPALE ----
try {
    $installedVersion = Get-InstalledVersion
    Write-Info ("Version installée: " + ($installedVersion -ne '' ? $installedVersion : '(aucune)'))

    $release = Get-LatestRelease
    $latestVersion = $release ? $release.tag_name : ''
    Write-Info ("Dernière version GitHub: " + ($latestVersion -ne '' ? $latestVersion : '(inconnue)'))

    $needUpdate = $Force -or ($latestVersion -ne '' -and $latestVersion -ne $installedVersion)
    $zipPath = Join-Path $env:TEMP "SandSeekers-update.zip"

    if ($needUpdate) {
        Write-Info 'Mise à jour requise.'
        Stop-RunningGame

        $asset = Select-WindowsAsset $release
        $downloadOk = $false
        if ($asset -and $asset.browser_download_url) {
            $downloadOk = Download-File -url $asset.browser_download_url -dest $zipPath
        } else {
            Write-Warn 'Aucun asset ZIP spécifique Windows trouvé; tentative sur archive main.'
            $fallbackUrl = "https://github.com/$RepoOwner/$RepoName/archive/refs/heads/main.zip"
            $downloadOk = Download-File -url $fallbackUrl -dest $zipPath
        }

        if (-not $downloadOk) { throw 'Téléchargement impossible.' }

        Clear-InstallDir
        Expand-Zip-Flatten -zipPath $zipPath -destDir $InstallDir

        # Synchroniser la base de cartes vers AppData (SandSeekers\datafiles)
        $SaveDir = Resolve-SaveDir -preferred $SaveDirPreferred
        Sync-CardsDatabase -installDir $InstallDir -saveDir $SaveDir

        if ($latestVersion -ne '') { Save-InstalledVersion $latestVersion }
    } else {
        Write-Ok 'Aucune mise à jour nécessaire.'
        # Vérifier et synchroniser quand même la base de cartes
        $SaveDir = Resolve-SaveDir -preferred $SaveDirPreferred
        Sync-CardsDatabase -installDir $InstallDir -saveDir $SaveDir
    }

    $exe = Find-GameExe
    if (-not $exe) {
        Write-Warn 'SandSeekers.exe introuvable; tentative de détection générique.'
        $exeGeneric = Get-ChildItem -Path $InstallDir -Recurse -Filter '*.exe' -ErrorAction SilentlyContinue | Select-Object -First 1
        $exe = $exeGeneric ? $exeGeneric.FullName : $null
    }

    Launch-Game -exePath $exe
    Write-Ok 'Terminé.'
} catch {
    Write-Err $_
    Write-Err 'Mise à jour ou lancement échoué.'
}