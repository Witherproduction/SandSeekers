using System;
using System.IO;
using System.Windows;
using System.Windows.Forms;
using Newtonsoft.Json;

namespace SandSeekersLauncher
{
    public partial class SettingsWindow : Window
    {
        private readonly LauncherConfig _config;
        private readonly Action<LauncherConfig> _onSave;

        public SettingsWindow(LauncherConfig config, Action<LauncherConfig> onSave)
        {
            InitializeComponent();
            _config = config ?? new LauncherConfig();
            _onSave = onSave;
            LoadToUi();
        }

        private void LoadToUi()
        {
            InstallPathText.Text = _config.InstallPath ?? string.Empty;
            RepoOwnerText.Text = _config.RepoOwner ?? string.Empty;
            RepoNameText.Text = _config.RepoName ?? string.Empty;
        }

        private void BrowseInstallPath_Click(object sender, RoutedEventArgs e)
        {
            using (var dialog = new FolderBrowserDialog())
            {
                dialog.Description = "Choisissez le dossier d’installation du jeu";
                dialog.UseDescriptionForTitle = true;
                dialog.ShowNewFolderButton = true;
                if (Directory.Exists(InstallPathText.Text)) dialog.SelectedPath = InstallPathText.Text;
                var result = dialog.ShowDialog();
                if (result == System.Windows.Forms.DialogResult.OK)
                {
                    InstallPathText.Text = dialog.SelectedPath;
                }
            }
        }

        private void SaveButton_Click(object sender, RoutedEventArgs e)
        {
            _config.InstallPath = string.IsNullOrWhiteSpace(InstallPathText.Text) ? null : InstallPathText.Text.Trim();
            _config.RepoOwner = string.IsNullOrWhiteSpace(RepoOwnerText.Text) ? null : RepoOwnerText.Text.Trim();
            _config.RepoName = string.IsNullOrWhiteSpace(RepoNameText.Text) ? null : RepoNameText.Text.Trim();

            try
            {
                _onSave?.Invoke(_config);
                DialogResult = true;
                Close();
            }
            catch (Exception ex)
            {
                System.Windows.MessageBox.Show($"Erreur lors de l’enregistrement des paramètres:\n{ex.Message}", "Erreur", MessageBoxButton.OK, MessageBoxImage.Error);
            }
        }
    }
}