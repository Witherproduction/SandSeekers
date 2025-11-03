# SandSeekers Launcher

Lanceur graphique officiel pour SandSeekers avec mise à jour automatique depuis GitHub.

## Fonctionnalités

- ✅ Interface graphique moderne et intuitive
- 🔄 Vérification automatique des mises à jour depuis GitHub Releases
- 📥 Téléchargement et installation automatique des nouvelles versions
- 🎮 Lancement direct du jeu
- 📊 Barre de progression pour les téléchargements
- 💾 Installation dans `%LOCALAPPDATA%\SandSeekersGame`

## Configuration

Avant de compiler, modifiez les variables dans `MainWindow.xaml.cs` :

```csharp
private readonly string REPO_OWNER = "VotreNomUtilisateur"; // Votre nom d'utilisateur GitHub
private readonly string REPO_NAME = "SandSeekers"; // Nom de votre repository
```

## Compilation

### Prérequis
- .NET 6.0 SDK ou plus récent
- Visual Studio 2022 ou VS Code avec extension C#

### Commandes
```bash
# Restaurer les packages
dotnet restore

# Compiler en mode Release
dotnet build --configuration Release

# Publier un exécutable autonome
dotnet publish --configuration Release --runtime win-x64 --self-contained true --output ./publish
```

## Structure des Releases GitHub

Le lanceur recherche automatiquement un fichier `.zip` contenant "windows" dans son nom parmi les assets de la dernière release.

Exemple de structure attendue :
```
SandSeekers-Windows-v1.2.0.zip
├── SandSeekers.exe
├── datafiles/
│   └── cards_database.json
└── autres fichiers...
```

## Utilisation

1. **Premier lancement** : Le lanceur vérifie s'il y a une version disponible sur GitHub
2. **Mise à jour disponible** : Un bouton "METTRE À JOUR" apparaît
3. **Jeu installé** : Le bouton "JOUER" devient actif
4. **Lancement** : Cliquer sur "JOUER" lance le jeu et ferme le lanceur

## Gestion des versions

- Le lanceur sauvegarde la version installée dans `version.txt`
- Les sauvegardes du joueur restent dans `%LOCALAPPDATA%\SandSeekers\datafiles\`
- Seuls les fichiers du jeu sont mis à jour, pas les sauvegardes

## Dépannage

### Le lanceur ne trouve pas de mise à jour
- Vérifiez que `REPO_OWNER` et `REPO_NAME` sont corrects
- Assurez-vous qu'il y a au moins une release publique sur GitHub
- Vérifiez qu'un asset `.zip` contenant "windows" existe dans la release

### Erreur de téléchargement
- Vérifiez votre connexion internet
- Le fichier peut être temporairement indisponible sur GitHub

### Le jeu ne se lance pas
- Vérifiez que `SandSeekers.exe` existe dans le dossier d'installation
- Assurez-vous que tous les fichiers ont été extraits correctement

## Personnalisation

Vous pouvez modifier :
- Les couleurs et styles dans `App.xaml`
- L'interface utilisateur dans `MainWindow.xaml`
- La logique de mise à jour dans `MainWindow.xaml.cs`
- Le nom de l'exécutable du jeu (`GAME_EXE_NAME`)