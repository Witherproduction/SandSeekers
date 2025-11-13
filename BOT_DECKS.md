# Decks des 4 Bots

Ce document récapitule les decks des quatre bots principaux tels que définis dans `scripts/sBotDecks/sBotDecks.gml`. Chaque deck comporte 40 cartes (max 3 copies par carte).

## Résumé
- `deck_id 1` — Rose noire
- `deck_id 2` — Dragon
- `deck_id 3` — Bête
- `deck_id 4` — Mort-vivant

---

## Bot 1 — Rose noire (`deck_id 1`)
Profil: Balanced. Booster: Chemin perdu. Ratio: 25 Monstres / 15 Magies.

Monstres (25):
- `oCorbeauDeLaRoseNoire` x2
- `oChevalDeLaRoseNoire` x2
- `oAraigneeDeLaRoseNoire` x2
- `oDragonnetBeniRoseNoire` x2
- `oChevalierSqueletteReanimeParLaRose` x2
- `oTreant` x2
- `oAraigneeSombreForet` x2
- `oPetiteSorciereDeLaRoseNoire` x2
- `oSorciereDeLaRoseNoire` x2
- `oSquelettePossedeParLaRoseNoire` x2
- `oEruditDeLaRoseNoire` x1
- `oDragonSacreRoseNoire` x1
- `oChevalierSqueletteReanime` x1
- `oChevalForet` x1
 - `oLacEnvahiParLaRoseNoire` x1

 Magies (15):
 - `oRoseNoire` x3
 - `oBaguetteRoseNoire` x3
 - `oBrumeRoseNoire` x2
 - `oMaledictionRoseNoire` x2
 - `oFloraisonRosePerdue` x2
 - `oRonceNoire` x2
 - `oMaladieRonceNoire` x1


---

## Bot 2 — Dragon (`deck_id 2`)
Profil: Stompy (invoque et protège les gros dragons). Booster: Chemin perdu. Ratio: 25 Monstres / 15 Magies.

Monstres (25):
- `oDragonSacreClairLune` x3
- `oDragonnetForet` x3
- `oDragonnetBeniRoseNoire` x3
- `oAncienDragonBeniForet` x3
 - `oDragonSacreRoseNoire` x1
 - `oChevalForet` x3
 - `oSorciereForet` x3
- `oTreant` x3
- `oEruditForet` x1
- `oLoupAlphaForet` x2

Magies (15):
- `oAileForet` x2
- `oEcailleForet` x2
- `oGriffeForet` x2
- `oRoseNoire` x2
 - `oClairLuneForetMaudite` x2
 - `oRonceNoire` x3
 - `oMaladieRonceNoire` x2

---

## Bot 3 — Bête (`deck_id 3`)
Profil: Aggro (meute). Ratio: 30 Monstres / 10 Magies.

Monstres (30):
- `oChevalForet` x3
- `oChevalDeLaRoseNoire` x3
- `oLoupAlphaForet` x3
- `oNueeCorbeaux` x3
- `oCorbeauDeLaRoseNoire` x3
- `oAraigneeSombreForet` x3
- `oAraigneeDeLaRoseNoire` x2
- `oDragonnetForet` x3
- `oTreant` x3
- `oEruditForet` x1
- `oSorciereForet` x3

Magies (10):
- `oSacrificeMeute` x3
- `oMaledictionClairLune` x2
- `oRoseNoire` x1
- `oEcailleForet` x1
- `oRonceNoire` x2
- `oMaladieRonceNoire` x1
---

## Bot 4 — Contrôle (Mort‑vivant & Humanoïde) (`deck_id 4`)
Profil: Control (invoque par les effets, prend le contrôle du terrain). Booster: Chemin perdu. Ratio: 25 Monstres / 15 Magies.

Monstres (25):
- `oChevalierSqueletteReanime` x3
- `oSqueletteReanime` x3
- `oChevalierSqueletteReanimeParLaRose` x3
- `oOmbreClairLune` x3
- `oEruditForet` x3
- `oSorciereForet` x3
- `oEruditDeLaRoseNoire` x3
- `oPetiteSorciereForet` x3
- `oCorbeauDeLaRoseNoire` x1

Magies (15):
- `oRonceNoire` x3
- `oMaladieRonceNoire` x2
- `oMaledictionRoseNoire` x2
- `oClairLuneForetMaudite` x3
- `oClairLuneBeni` x2
- `oBaguetteRoseNoire` x2
- `oTalismanPerdu` x1

---

## Bot 5 — Test Rose noire & Baguette (`deck_id 5`)
Profil: Contrôle (setup de test pour artefacts). Ce deck est utilisé pour tester des interactions de l’archétype Rose noire.

Sélection ciblée (15, complété automatiquement à 40):
- `oPetiteSorciereDeLaRoseNoire` x5
- `oBaguetteRoseNoire` x5
- `oRoseNoire` x5

---

## Notes
- Les decks sont automatiquement limités à 3 copies par carte (`cap_card_copies`).
- Exception: le Bot 5 accepte jusqu’à 5 copies par carte pour les tests.
- Si un deck avait moins de 40 cartes, il serait complété par des cartes génériques via `fill_to_size` (pool interne), mais ces 4 decks sont déjà à 40.
- Source: `scripts/sBotDecks/sBotDecks.gml`.