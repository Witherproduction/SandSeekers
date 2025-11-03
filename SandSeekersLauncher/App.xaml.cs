using System;
using System.IO;
using System.Threading.Tasks;
using System.Windows;

namespace SandSeekersLauncher
{
    public partial class App : Application
    {
        private string LogPath => Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.LocalApplicationData), "SandSeekersGame", "launcher.log");

        protected override void OnStartup(StartupEventArgs e)
        {
            base.OnStartup(e);

            this.DispatcherUnhandledException += App_DispatcherUnhandledException;
            AppDomain.CurrentDomain.UnhandledException += CurrentDomain_UnhandledException;
            TaskScheduler.UnobservedTaskException += TaskScheduler_UnobservedTaskException;

            try
            {
                var w = new MainWindow();
                w.Show();
            }
            catch (Exception ex)
            {
                SafeLog($"Startup exception: {ex}");
                MessageBox.Show($"Erreur au démarrage:\n{ex}", "SandSeekers Launcher", MessageBoxButton.OK, MessageBoxImage.Error);
                Shutdown(-1);
            }
        }

        private void App_DispatcherUnhandledException(object sender, System.Windows.Threading.DispatcherUnhandledExceptionEventArgs e)
        {
            SafeLog($"Dispatcher exception: {e.Exception}");
            MessageBox.Show($"Erreur non gérée:\n{e.Exception}", "SandSeekers Launcher", MessageBoxButton.OK, MessageBoxImage.Error);
            e.Handled = true; // Empêche la fermeture immédiate
        }

        private void CurrentDomain_UnhandledException(object sender, UnhandledExceptionEventArgs e)
        {
            SafeLog($"Domain exception: {e.ExceptionObject}");
        }

        private void TaskScheduler_UnobservedTaskException(object sender, UnobservedTaskExceptionEventArgs e)
        {
            SafeLog($"Task exception: {e.Exception}");
            e.SetObserved();
        }

        private void SafeLog(string msg)
        {
            try
            {
                Directory.CreateDirectory(Path.GetDirectoryName(LogPath));
                File.AppendAllText(LogPath, $"{DateTime.Now:O} | {msg}\n");
            }
            catch { /* ignore logging errors */ }
        }
    }
}