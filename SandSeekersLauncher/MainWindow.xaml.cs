using System;
using System.Diagnostics;
using System.IO;
using System.IO.Compression;
using System.Net.Http;
using System.Threading.Tasks;
using System.Windows;
using Newtonsoft.Json.Linq;
using Newtonsoft.Json;

namespace SandSeekersLauncher
{
    public class LauncherConfig
    {
        public string InstallPath { get; set; }
        public string RepoOwner { get; set; }
        public string RepoName { get; set; }
    }

    public partial class MainWindow : Window
    {
        private readonly string REPO_OWNER = "Witherproduction"; // défaut
        private readonly string REPO_NAME = "SandSeekers";       // défaut
        private string repoOwner;
        private string repoName;
        private readonly string GAME_EXE_NAME = "SandSeekers.exe";

        private string GAME_INSTALL_PATH;
        private string VERSION_FILE_PATH;
        private LauncherConfig config;
        private readonly HttpClient httpClient;
        private string currentVersion = "0.0.0";
        private string latestVersion = "0.0.0";
        private string downloadUrl = "";

        public MainWindow()
        {
            InitializeComponent();
            
            // Charger la configuration et définir les chemins
            config = LoadConfig();
            string localAppData = Environment.GetFolderPath(Environment.SpecialFolder.LocalApplicationData);
            GAME_INSTALL_PATH = string.IsNullOrWhiteSpace(config.InstallPath)
                ? Path.Combine(localAppData, "SandSeekersGame")
                : config.InstallPath.Trim();
            VERSION_FILE_PATH = Path.Combine(GAME_INSTALL_PATH, "version.txt");
            repoOwner = string.IsNullOrWhiteSpace(config.RepoOwner) ? REPO_OWNER : config.RepoOwner.Trim();
            repoName  = string.IsNullOrWhiteSpace(config.RepoName)  ? REPO_NAME  : config.RepoName.Trim();
            
            httpClient = new HttpClient();
            httpClient.DefaultRequestHeaders.Add("User-Agent", "SandSeekers-Launcher/1.0");
            
            InstallPathLabel.Text = $"Installation: {GAME_INSTALL_PATH}";
            try { InstallPathBox.Text = GAME_INSTALL_PATH; } catch { }
            
            // Démarrer la vérification après affichage de la fenêtre
            this.Loaded += async (_, __) => await CheckForUpdatesAsync();
        }

        private string GetConfigPath()
        {
            string localAppData = Environment.GetFolderPath(Environment.SpecialFolder.LocalApplicationData);
            string dir = Path.Combine(localAppData, "SandSeekersLauncher");
            Directory.CreateDirectory(dir);
            return Path.Combine(dir, "config.json");
        }

        private LauncherConfig LoadConfig()
        {
            try
            {
                string path = GetConfigPath();
                if (File.Exists(path))
                {
                    var json = File.ReadAllText(path);
                    return JsonConvert.DeserializeObject<LauncherConfig>(json) ?? new LauncherConfig();
                }
            }
            catch { }
            return new LauncherConfig();
        }

        private void SaveConfig(LauncherConfig cfg)
        {
            try
            {
                var json = JsonConvert.SerializeObject(cfg, Formatting.Indented);
                File.WriteAllText(GetConfigPath(), json);
            }
            catch (Exception ex)
            {
                Log($"Erreur sauvegarde config: {ex.Message}");
            }
        }

        private void Log(string message)
        {
            try
            {
                Directory.CreateDirectory(GAME_INSTALL_PATH);
                File.AppendAllText(Path.Combine(GAME_INSTALL_PATH, "launcher.log"), $"{DateTime.Now:O} | {message}\n");
            }
            catch { }
        }

        private async Task CheckForUpdatesAsync()
        {
            try
            {
                StatusLabel.Text = "Vérification des mises à jour...";
                
                // Lire la version actuelle
                currentVersion = GetCurrentVersion();
                VersionLabel.Text = $"Version installée: {currentVersion}";
                
                // Vérifier la dernière version sur GitHub
                latestVersion = await GetLatestVersionFromGitHubAsync();
                
                if (string.IsNullOrEmpty(latestVersion))
                {
                    StatusLabel.Text = "❌ Impossible de vérifier les mises à jour";
                    PlayButton.IsEnabled = File.Exists(GetGameExePath());
                    return;
                }
                
                // Comparer les versions
                if (IsUpdateAvailable())
                {
                    StatusLabel.Text = $"🏆 Nouvelle version disponible: {latestVersion}";
                    UpdateButton.Visibility = Visibility.Visible;
                    PlayButton.IsEnabled = File.Exists(GetGameExePath());
                }
                else
                {
                    StatusLabel.Text = "✅ Vous avez la dernière version";
                    UpdateButton.Visibility = Visibility.Collapsed;
                    PlayButton.IsEnabled = File.Exists(GetGameExePath());
                }
            }
            catch (Exception ex)
            {
                StatusLabel.Text = $"❌ Erreur: {ex.Message}";
                PlayButton.IsEnabled = File.Exists(GetGameExePath());
                Log($"Erreur CheckForUpdatesAsync: {ex}");
            }
        }

        private string GetCurrentVersion()
        {
            try
            {
                if (File.Exists(VERSION_FILE_PATH))
                {
                    return File.ReadAllText(VERSION_FILE_PATH).Trim();
                }
            }
            catch { }
            
            return "0.0.0";
        }

        private async Task<string> GetLatestVersionFromGitHubAsync()
        {
            try
            {
                // Tenter d'abord /releases/latest
                string latestUrl = $"https://api.github.com/repos/{repoOwner}/{repoName}/releases/latest";
                using (var latestResponse = await httpClient.GetAsync(latestUrl))
                {
                    if (latestResponse.StatusCode == System.Net.HttpStatusCode.NotFound)
                    {
                        // Fallback: lister toutes les releases et prendre la première non draft
                        string listUrl = $"https://api.github.com/repos/{repoOwner}/{repoName}/releases";
                        using (var listResponse = await httpClient.GetAsync(listUrl))
                        {
                            if (!listResponse.IsSuccessStatusCode)
                            {
                                Log($"GitHub releases error: {(int)listResponse.StatusCode} {listResponse.ReasonPhrase}");
                                return null;
                            }
                            string listContent = await listResponse.Content.ReadAsStringAsync();
                            JArray releases = JArray.Parse(listContent);
                            foreach (JObject rel in releases)
                            {
                                bool draft = rel["draft"]?.ToObject<bool>() ?? false;
                                // On accepte les pré-releases si présent
                                if (draft) continue;
                                string tag = rel["tag_name"]?.ToString();
                                JArray assets = (JArray)rel["assets"];
                                if (assets != null)
                                {
                                    foreach (JObject asset in assets)
                                    {
                                        string assetName = asset["name"]?.ToString();
                                        if (!string.IsNullOrEmpty(assetName) && assetName.EndsWith(".zip", StringComparison.OrdinalIgnoreCase))
                                        {
                                            downloadUrl = asset["browser_download_url"]?.ToString();
                                            break;
                                        }
                                    }
                                }
                                return tag?.TrimStart('v');
                            }
                            // Pas de releases publiées
                            return null;
                        }
                    }
                    else
                    {
                        latestResponse.EnsureSuccessStatusCode();
                        string content = await latestResponse.Content.ReadAsStringAsync();
                        JObject release = JObject.Parse(content);
                        string tagName = release["tag_name"]?.ToString();
                        JArray assets = (JArray)release["assets"];
                        if (assets != null)
                        {
                            foreach (JObject asset in assets)
                            {
                                string assetName = asset["name"]?.ToString();
                                if (!string.IsNullOrEmpty(assetName) && assetName.EndsWith(".zip", StringComparison.OrdinalIgnoreCase))
                                {
                                    downloadUrl = asset["browser_download_url"]?.ToString();
                                    break;
                                }
                            }
                        }
                        return tagName?.TrimStart('v');
                    }
                }
            }
            catch (Exception ex)
            {
                // Pas de pop-up bloquante : consigner et retourner null
                Log($"Erreur GitHub API: {ex.Message}");
                return null;
            }
        }

        private bool IsUpdateAvailable()
        {
            try
            {
                Version current = new Version(currentVersion);
                Version latest = new Version(latestVersion);
                return latest > current;
            }
            catch
            {
                return !string.Equals(currentVersion, latestVersion, StringComparison.OrdinalIgnoreCase);
            }
        }

        private string GetGameExePath()
        {
            return Path.Combine(GAME_INSTALL_PATH, GAME_EXE_NAME);
        }

        private async void UpdateButton_Click(object sender, RoutedEventArgs e)
        {
            if (string.IsNullOrEmpty(downloadUrl))
            {
                MessageBox.Show("URL de téléchargement non trouvée.", "Erreur", MessageBoxButton.OK, MessageBoxImage.Error);
                return;
            }

            try
            {
                UpdateButton.IsEnabled = false;
                PlayButton.IsEnabled = false;
                ProgressBar.Visibility = Visibility.Visible;
                
                await DownloadAndInstallAsync();
                
                StatusLabel.Text = "✅ Mise à jour terminée!";
                VersionLabel.Text = $"Version installée: {latestVersion}";
                currentVersion = latestVersion;
                
                UpdateButton.Visibility = Visibility.Collapsed;
                PlayButton.IsEnabled = true;
            }
            catch (Exception ex)
            {
                StatusLabel.Text = $"❌ Erreur de mise à jour: {ex.Message}";
                MessageBox.Show($"Erreur lors de la mise à jour:\n{ex.Message}", "Erreur", MessageBoxButton.OK, MessageBoxImage.Error);
            }
            finally
            {
                UpdateButton.IsEnabled = true;
                ProgressBar.Visibility = Visibility.Collapsed;
                ProgressLabel.Text = "";
            }
        }
        private async Task DownloadAndInstallAsync()
        {
            StopRunningGame();
string tempZipPath = Path.Combine(Path.GetTempPath(), "SandSeekers_Update.zip");
            
            try
            {
                // Télécharger
                StatusLabel.Text = "📥 Téléchargement en cours...";
                ProgressLabel.Text = "Connexion au serveur...";
                
                using (var response = await httpClient.GetAsync(downloadUrl, HttpCompletionOption.ResponseHeadersRead))
                {
                    response.EnsureSuccessStatusCode();
                    
                    long totalBytes = response.Content.Headers.ContentLength ?? 0;
                    using (var contentStream = await response.Content.ReadAsStreamAsync())
                    using (var fileStream = new FileStream(tempZipPath, FileMode.Create, FileAccess.Write, FileShare.None, 8192, true))
                    {
                        byte[] buffer = new byte[8192];
                        long downloadedBytes = 0;
                        int bytesRead;
                        
                        while ((bytesRead = await contentStream.ReadAsync(buffer, 0, buffer.Length)) > 0)
                        {
                            await fileStream.WriteAsync(buffer, 0, bytesRead);
                            downloadedBytes += bytesRead;
                            
                            if (totalBytes > 0)
                            {
                                double progress = (double)downloadedBytes / totalBytes * 100;
                                ProgressBar.Value = progress;
                                ProgressLabel.Text = $"{downloadedBytes / 1024 / 1024:F1} MB / {totalBytes / 1024 / 1024:F1} MB";
                            }
                        }
                    }
                }
                
                // Installation
                StatusLabel.Text = "📦 Installation en cours...";
                ProgressLabel.Text = "Extraction des fichiers...";
                ProgressBar.Value = 0;
                
                // Créer le dossier d'installation
                Directory.CreateDirectory(GAME_INSTALL_PATH);
                
                // Extraire le ZIP
                using (var archive = ZipFile.OpenRead(tempZipPath))
                {
                    int totalEntries = archive.Entries.Count;
                    int extractedEntries = 0;
                    
                    foreach (var entry in archive.Entries)
                    {
                        string destinationPath = Path.Combine(GAME_INSTALL_PATH, entry.FullName);
                        
                        if (entry.Name == "")
                        {
                            // C'est un dossier
                            Directory.CreateDirectory(destinationPath);
                        }
                        else
                        {
                            // C'est un fichier
                            Directory.CreateDirectory(Path.GetDirectoryName(destinationPath));
                            entry.ExtractToFile(destinationPath, true);
                        }
                        
                        extractedEntries++;
                        double progress = (double)extractedEntries / totalEntries * 100;
                        ProgressBar.Value = progress;
                        ProgressLabel.Text = $"Extraction: {extractedEntries}/{totalEntries} fichiers";
                    }
                }
                
                // Sauvegarder la version
                File.WriteAllText(VERSION_FILE_PATH, latestVersion);
                SyncCardsDatabase(); SyncAuxFiles(); MigrateBackupToSandSeekers();
                
                StatusLabel.Text = "✅ Installation terminée!";
            }
            finally
            {
                // Nettoyer le fichier temporaire
                try
                {
                    if (File.Exists(tempZipPath))
                        File.Delete(tempZipPath);
                }
                catch { }
            }
        }

        private void PlayButton_Click(object sender, RoutedEventArgs e)
        {
            try
            {
                string gamePath = GetGameExePath();
                
                if (!File.Exists(gamePath))
                {
                    MessageBox.Show("Le jeu n'est pas installé. Veuillez d'abord télécharger une mise à jour.", 
                                  "Jeu non trouvé", MessageBoxButton.OK, MessageBoxImage.Warning);
                    return;
                }
                
                // Lancer le jeu
                ProcessStartInfo startInfo = new ProcessStartInfo
                {
                    FileName = gamePath,
                    WorkingDirectory = GAME_INSTALL_PATH,
                    UseShellExecute = true
                };
                
                SyncCardsDatabase(); SyncAuxFiles(); MigrateBackupToSandSeekers();
                Process.Start(startInfo);
                
                // Fermer le lanceur
                Application.Current.Shutdown();
            }
            catch (Exception ex)
            {
                MessageBox.Show($"Erreur lors du lancement du jeu:\n{ex.Message}", 
                              "Erreur", MessageBoxButton.OK, MessageBoxImage.Error);
            }
        }

        private void BrowseInstallPath_Click(object sender, RoutedEventArgs e)
        {
            try
            {
                using (var dialog = new System.Windows.Forms.FolderBrowserDialog())
                {
                    dialog.Description = "Choisissez le dossier d’installation du jeu";
                    dialog.UseDescriptionForTitle = true;
                    dialog.ShowNewFolderButton = true;
                    if (!string.IsNullOrWhiteSpace(InstallPathBox.Text) && System.IO.Directory.Exists(InstallPathBox.Text))
                        dialog.SelectedPath = InstallPathBox.Text;
                    var result = dialog.ShowDialog();
                    if (result == System.Windows.Forms.DialogResult.OK)
                    {
                        string selected = dialog.SelectedPath;
                        InstallPathBox.Text = selected;
                        // Appliquer immédiatement
                        GAME_INSTALL_PATH = selected.Trim();
                        VERSION_FILE_PATH = System.IO.Path.Combine(GAME_INSTALL_PATH, "version.txt");
                        InstallPathLabel.Text = $"Installation: {GAME_INSTALL_PATH}";
                        // Sauvegarder config
                        config.InstallPath = GAME_INSTALL_PATH;
                        SaveConfig(config);
                        // Relancer la vérification sur le nouveau chemin
                        _ = CheckForUpdatesAsync();
                    }
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show($"Impossible de sélectionner le dossier:\n{ex.Message}", "Erreur", MessageBoxButton.OK, MessageBoxImage.Error);
            }
        }

        private string ResolveSaveDir()
        {
            try
            {
                string root = Environment.GetFolderPath(Environment.SpecialFolder.LocalApplicationData);
                string preferred = Path.Combine(root, "SandSeekers", "datafiles");
                if (Directory.Exists(preferred)) return preferred;
                string[] candidates = new[] { preferred, Path.Combine(root, "backup", "datafiles"), Path.Combine(root, "SandSeekersGame", "datafiles") };
                foreach (var c in candidates)
                {
                    if (Directory.Exists(c)) return c;
                }
                Directory.CreateDirectory(preferred);
                return preferred;
            }
            catch
            {
                return Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.LocalApplicationData), "SandSeekers", "datafiles");
            }
        }

        private int ReadTotalCards(string jsonPath)
        {
            try
            {
                var text = File.ReadAllText(jsonPath);
                var obj = JObject.Parse(text);
                var token = obj["total_cards"];
                if (token == null) return -1;
                return token.Value<int>();
            }
            catch { return -1; }
        }

        private void SyncCardsDatabase()
        {
            try
            {
                string src = Path.Combine(GAME_INSTALL_PATH, "datafiles", "cards_database.json");
                if (!File.Exists(src)) { Log("cards_database.json source introuvable dans l'installation."); return; }
                string saveDir = ResolveSaveDir();
                Directory.CreateDirectory(saveDir);
                string dst = Path.Combine(saveDir, "cards_database.json");
                int srcCount = ReadTotalCards(src);
                int dstCount = File.Exists(dst) ? ReadTotalCards(dst) : -1;
                if (dstCount < srcCount || dstCount == -1)
                {
                    File.Copy(src, dst, true);
                    Log($"Mise à jour des cartes: dst {dstCount} -> src {srcCount} ({dst})");
                }
                else
                {
                    Log("Base de cartes déjà à jour dans AppData.");
                }
            }
            catch (Exception ex) { Log($"SyncCardsDatabase erreur: {ex.Message}"); }
        }
        private void StopRunningGame()
        {
            try
            {
                foreach (var p in Process.GetProcessesByName("SandSeekers"))
                {
                    try { p.Kill(); p.WaitForExit(500); } catch { }
                }
            }
            catch (Exception ex) { Log($"StopRunningGame erreur: {ex.Message}"); }
        }
        private void SyncAuxFiles()
        {
            try
            {
                string srcDir = Path.Combine(GAME_INSTALL_PATH, "datafiles");
                string saveDir = ResolveSaveDir();
                foreach (var file in new[] { "favorite_cards.json", "saved_decks.json" })
                {
                    string src = Path.Combine(srcDir, file);
                    string dst = Path.Combine(saveDir, file);
                    if (File.Exists(src))
                    {
                        Directory.CreateDirectory(saveDir);
                        if (!File.Exists(dst) || new FileInfo(src).Length > new FileInfo(dst).Length)
                        {
                            File.Copy(src, dst, true);
                            Log($"Sync {file} -> {dst}");
                        }
                    }
                }
            }
            catch (Exception ex) { Log($"SyncAuxFiles erreur: {ex.Message}"); }
        }
        private void MigrateBackupToSandSeekers()
        {
            try
            {
                string root = Environment.GetFolderPath(Environment.SpecialFolder.LocalApplicationData);
                string backup = Path.Combine(root, "backup", "datafiles");
                string target = Path.Combine(root, "SandSeekers", "datafiles");
                if (Directory.Exists(backup))
                {
                    if (!Directory.Exists(target)) Directory.CreateDirectory(target);
                    foreach (var file in new[] { "cards_database.json", "favorite_cards.json", "saved_decks.json" })
                    {
                        string src = Path.Combine(backup, file);
                        string dst = Path.Combine(target, file);
                        if (File.Exists(src))
                        {
                            if (!File.Exists(dst))
                            {
                                File.Copy(src, dst, true);
                                Log($"Migration {file} depuis backup vers {dst}");
                            }
                            else
                            {
                                if (file == "cards_database.json")
                                {
                                    int srcCount = ReadTotalCards(src);
                                    int dstCount = ReadTotalCards(dst);
                                    if (dstCount < srcCount)
                                    {
                                        File.Copy(src, dst, true);
                                        Log($"Migration cartes: dst {dstCount} -> src {srcCount} ({dst})");
                                    }
                                }
                                else
                                {
                                    var srcLen = new FileInfo(src).Length;
                                    var dstLen = new FileInfo(dst).Length;
                                    if (dstLen < srcLen)
                                    {
                                        File.Copy(src, dst, true);
                                        Log($"Migration {file}: taille {dstLen} -> {srcLen} ({dst})");
                                    }
                                }
                            }
                        }
                    }
                }
            }
            catch (Exception ex) { Log($"Migration backup->SandSeekers erreur: {ex.Message}"); }
        }
        protected override void OnClosed(EventArgs e)
        {
            httpClient?.Dispose();
            base.OnClosed(e);
        }
    }
}


