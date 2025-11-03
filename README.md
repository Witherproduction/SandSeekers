SandSeekers — Emplacement de la base de données des cartes

Résumé rapide
- Base de données la plus complète trouvée: `C:\Users\arckano\AppData\Local\SandSeekers\datafiles\cards_database.json`
- Taille: 32804 octets
- Cartes: 86 (champ `total_cards` = 86)
- Copie dans le projet: `C:\Users\arckano\Desktop\carte\SandSeekers\cards_database.json` (32804 octets)

Emplacements utiles
- AppData (source principale actuelle): `C:\Users\arckano\AppData\Local\SandSeekers\datafiles\cards_database.json`
- AppData export: `C:\Users\arckano\AppData\Local\SandSeekers\export\cards_database.json` (souvent synchronisé; observé: 32804 octets)
- Projet (copie prête à zipper): `C:\Users\arckano\Desktop\carte\SandSeekers\cards_database.json`

Anciennes versions observées (moins complètes)
- Projet / datafiles: `C:\Users\arckano\Desktop\carte\SandSeekers\datafiles\cards_database.json` (20810 octets, ~53 cartes)
- Temp GMS2: `C:\Users\arckano\AppData\Local\GameMakerStudio2\GMS2TEMP\SandSeekers_*_VM\cards_database.json` (souvent 20810 octets, ~53 cartes)

Vérifier rapidement le nombre de cartes (PowerShell)
```powershell
$p = 'C:\Users\arckano\AppData\Local\SandSeekers\datafiles\cards_database.json'
(Get-Content -Path $p -Raw | ConvertFrom-Json).cards.Count
```

Compresser la base de données (optionnel)
```powershell
Compress-Archive -Path 'C:\Users\arckano\Desktop\carte\SandSeekers\cards_database.json' `
  -DestinationPath 'C:\Users\arckano\Desktop\carte\SandSeekers\cards_database.zip' -Force
```

Notes
- Les chemins AppData sont utilisés par le jeu pour sauver/charger en priorité.
- Si une base plus récente est créée, elle apparaîtra d’abord sous `AppData\Local\SandSeekers\datafiles` et/ou `export`.