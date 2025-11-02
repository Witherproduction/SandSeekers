# Documentation des Effets Disponibles

## Vue d'ensemble

Le système d'effets définit **ce qui se passe** quand un déclencheur s'active. Chaque effet a un type spécifique, une valeur, et peut avoir des conditions ou des filtres pour déterminer ses cibles.

## Types d'Effets

### 📚 Effets de Base

| Effet | Constante | Description | Paramètres | Exemple |
|-------|-----------|-------------|------------|---------|
| Piocher des cartes | `EFFECT_DRAW_CARDS` | Fait piocher des cartes | `value` : nombre de cartes | Piochez 2 cartes |
| Défausser des cartes | `EFFECT_DISCARD` | Défausse unifiée paramétrable | `selection` : critères de sélection | Défaussez selon critères |
| Gagner des LP | `EFFECT_GAIN_LP` | Augmente les LP | `value` : montant de LP | Gagnez 500 LP |
| Perdre des LP | `EFFECT_LOSE_LP` | Diminue les LP | `value` : montant de LP | Perdez 300 LP |
| Se soigner | `EFFECT_HEAL_SELF` | Soigne la carte | `value` : montant de soins | Cette carte gagne 200 HP |
| Se blesser | `EFFECT_DAMAGE_SELF` | Blesse la carte | `value` : montant de dégâts | Cette carte perd 100 HP |

### ⚔️ Effets de Combat

| Effet | Constante | Description | Paramètres | Durée |
|-------|-----------|-------------|------------|-------|
| Gagner de l'ATK | `EFFECT_GAIN_ATTACK` | Augmente l'attaque | `value` : bonus ATK | Selon `temporary` |
| Perdre de l'ATK | `EFFECT_LOSE_ATTACK` | Diminue l'attaque | `value` : malus ATK | Selon `temporary` |
| Gagner de la DEF | `EFFECT_GAIN_DEFENSE` | Augmente la défense | `value` : bonus DEF | Selon `temporary` |
| Perdre de la DEF | `EFFECT_LOSE_DEFENSE` | Diminue la défense | `value` : malus DEF | Selon `temporary` |
| Définir l'ATK | `EFFECT_SET_ATTACK` | Fixe l'attaque | `value` : nouvelle ATK | Permanent |
| Définir la DEF | `EFFECT_SET_DEFENSE` | Fixe la défense | `value` : nouvelle DEF | Permanent |

### 🎯 Effets de Ciblage

| Effet | Constante | Description | Cible Requise | Effet |
|-------|-----------|-------------|---------------|-------|
| Dégâts à une cible | `EFFECT_DAMAGE_TARGET` | Inflige des dégâts | Oui | Dégâts directs |
| Soigner une cible | `EFFECT_HEAL_TARGET` | Soigne une cible | Oui | Soins directs |
| Détruire une cible | `EFFECT_DESTROY_TARGET` | Détruit une cible | Oui | Destruction |
| Détruire par filtre | `EFFECT_DESTROY` | Détruit selon filtres | Non | Destruction générique |
| Bannir une cible | `EFFECT_BANISH_TARGET` | Bannit une cible | Oui | Retrait du jeu |
| Renvoyer en main | `EFFECT_RETURN_TO_HAND` | Renvoie en main | Oui | Retour en main |

### 🌊 Effets de Zone

| Effet | Constante | Description | Filtres | Portée |
|-------|-----------|-------------|---------|--------|
| Dégâts à tous | `EFFECT_DAMAGE_ALL` | Dégâts de zone | `target_owner`, `target_type` | Tous les monstres |
| Soigner tous | `EFFECT_HEAL_ALL` | Soins de zone | `target_owner`, `target_type` | Tous les monstres |
| Détruire tous | `EFFECT_DESTROY_ALL` | Destruction de zone | `target_owner`, `target_type` | Tous les monstres |
| Booster les alliés | `EFFECT_BOOST_ALL` | Améliore les alliés | `value` : bonus | Monstres alliés |
| Affaiblir les ennemis | `EFFECT_WEAKEN_ALL` | Affaiblit les ennemis | `value` : malus | Monstres ennemis |

### 📖 Effets de Manipulation de Deck

| Effet | Constante | Description | Paramètres | Utilisation |
|-------|-----------|-------------|------------|-------------|
| Recherche générique | `EFFECT_SEARCH` | Recherche unifiée multi-zones | `search_sources`, `destination`, `search_criteria` | Tuteur avancé |
| Recherche (par défaut Deck→Main) | `EFFECT_SEARCH` | Cherche une carte | `search_sources` (défaut `Deck`), `destination` (défaut `Hand`), `search_criteria` | Tuteur |
| Mélanger le deck | `EFFECT_SHUFFLE_DECK` | Mélange le deck | Aucun | Réorganisation |
| Meuler le deck | `EFFECT_MILL_DECK` | Envoie au cimetière | `value` : nombre | Mill |
| Ajouter au deck | `EFFECT_ADD_TO_DECK` | Ajoute une carte | `card_data` | Génération |

### ⚰️ Effets de Manipulation de Cimetière

| Effet | Constante | Description | Paramètres | Utilisation |
|-------|-----------|-------------|------------|-------------|
| Ressusciter | `EFFECT_REVIVE` | Ramène du cimetière | `target_criteria` | Résurrection |
| Bannir du cimetière | `EFFECT_BANISH_FROM_GRAVEYARD` | Bannit du cimetière | `target_criteria` | Exil |
| Mélanger le cimetière | `EFFECT_SHUFFLE_GRAVEYARD` | Remet dans le deck | Aucun | Recyclage |

### ✨ Effets Spéciaux

| Effet | Constante | Description | Paramètres | Complexité |
|-------|-----------|-------------|------------|------------|
| Invocation générique | `EFFECT_SUMMON` | Invocation/activation unifiée | `summon_mode`, `token_data`, `allowed_sources`, `criteria`, `context_criteria` | Élevée |
| Token (via mode) | `EFFECT_SUMMON` | Crée un jeton | `summon_mode: "token"`, `token_data` | Moyenne |
| Changer le type | `EFFECT_CHANGE_TYPE` | Modifie le type | `new_type` | Faible |
| Changer l'attribut | `EFFECT_CHANGE_ATTRIBUTE` | Modifie l'attribut | `new_attribute` | Faible |
| Annuler un effet | `EFFECT_NEGATE_EFFECT` | Annule un effet | `target_effect` | Élevée |
| Copier un effet | `EFFECT_COPY_EFFECT` | Copie un effet | `source_effect` | Élevée |

### 🎮 Effets de Contrôle

| Effet | Constante | Description | Impact | Rareté |
|-------|-----------|-------------|--------|--------|
| Passer le tour | `EFFECT_SKIP_TURN` | Fait passer le tour | Majeur | Rare |
| Tour supplémentaire | `EFFECT_EXTRA_TURN` | Donne un tour extra | Majeur | Très rare |
| Changer de phase | `EFFECT_CHANGE_PHASE` | Force un changement | Moyen | Rare |
| Terminer le combat | `EFFECT_END_BATTLE` | Termine la phase | Moyen | Rare |

### 🛡️ Effets de Protection

| Effet | Constante | Description | Durée | Puissance |
|-------|-----------|-------------|-------|-----------|
| Immunité | `EFFECT_IMMUNITY` | Immunité totale | Variable | Très forte |
| Protection | `EFFECT_PROTECTION` | Protection partielle | Variable | Forte |
| Indestructible | `EFFECT_INDESTRUCTIBLE` | Ne peut être détruit | Variable | Forte |
| Non-ciblable | `EFFECT_UNTARGETABLE` | Ne peut être ciblé | Variable | Moyenne |

## Structure d'un Effet Complet

```gml
{
    "id": 1,
    "effect_type": "damage_target",
    "value": 500,
    "target_type": "monster",
    "target_owner": "enemy",
    "conditions": {
        "min_lp": 2000,
        "phase": "battle_phase"
    },
    "description": "Infligez 500 dégâts à un monstre ennemi si vous avez au moins 2000 LP."
}
```

## Paramètres et Filtres

### Paramètres de Base
- `value` : Valeur numérique de l'effet (dégâts, soins, bonus, etc.)
- `duration` : Durée de l'effet ("permanent", "turn", "battle", etc.)
- `temporary` : Si l'effet est temporaire (booléen)

### Filtres de Ciblage
- `target_type` : Type de cible ("monster", "magic", "any")
- `target_owner` : Propriétaire ("ally", "enemy", "all")
- `target_zone` : Zone ciblée ("field", "hand", "graveyard", "all")
- `monster_type` : Type spécifique de monstre
- `attribute` : Attribut spécifique requis

### Conditions d'Activation
- `min_lp` / `max_lp` : Conditions de LP
- `hand_size` : Taille de main requise
- `field_count` : Nombre de cartes sur le terrain
- `phase` : Phase spécifique requise

## Exemples d'Utilisation

### Effet Simple : Piocher des Cartes
```gml
{
    "effect_type": "draw_cards",
    "value": 1,
    "description": "Piochez 1 carte."
}
```

### Effet Conditionnel : Boost si LP faibles
```gml
{
    "effect_type": "gain_attack",
    "value": 300,
    "temporary": true,
    "conditions": {
        "max_lp": 1000
    },
    "description": "Si vous avez 1000 LP ou moins : Cette carte gagne 300 ATK jusqu'à la fin du tour."
}
```

### Effet de Zone : Dégâts aux Ennemis
```gml
{
    "effect_type": "damage_all",
    "value": 200,
    "target_owner": "enemy",
    "target_type": "monster",
    "description": "Infligez 200 dégâts à tous les monstres ennemis."
}
```

### Effet Complexe : Invocation de Jeton
```gml
{
    "effect_type": "summon_token",
    "token_data": {
        "name": "Jeton Guerrier",
        "attack": 100,
        "defense": 100,
        "type": "Guerrier",
        "attribute": "Terre"
    },
    "description": "Invoquez 1 Jeton Guerrier (100/100)."
}
```

### Effet Générique : Invocation Unifiée
Exemples d’utilisation de `EFFECT_SUMMON` avec différents modes:

```gml
// 1) Invoquer un jeton
{ effect_id: EFFECT_SUMMON, summon_mode: "token", token_data: { name: "Token", attack: 500, defense: 500, type: "Monster", star: 1 } }

// 2) Invocation spéciale de soi
{ effect_id: EFFECT_SUMMON, summon_mode: "self" }

// 3) Invocation nommée (Deck > Cimetière > Main) avec critères
{ effect_id: EFFECT_SUMMON, summon_mode: "named", target_name: "Dragon Blanc", allowed_sources: ["Deck", "Graveyard", "Hand"], criteria: { genre: "dragon", star_gte: 4 } }

// 4) Invocation de la source depuis la main si critères OK
{ effect_id: EFFECT_SUMMON, summon_mode: "source_from_hand", criteria: { type: "monster", star_eq: 1 } }

// 5) Activer une carte Magie par critères
{ effect_id: EFFECT_SUMMON, summon_mode: "activate_spell", criteria: { name: "Orage Noir" } }
```

### Recherche Générique (`EFFECT_SEARCH`)

L'effet `EFFECT_SEARCH` unifie toutes les opérations de recherche de cartes dans différentes zones vers différentes destinations.

#### Paramètres supportés:
- `search_sources`: Array des zones sources `["Deck", "Graveyard", "Hand", "Field"]` (défaut: `["Deck"]`)
- `destination`: Zone de destination `"Hand" | "Deck" | "Graveyard"` (défaut: `"Hand"`)
- `search_criteria`: Objet avec critères de recherche (optionnel)
  - `archetype`: Nom de l'archétype recherché
  - `name`: Nom exact de la carte recherchée
  - `type`: Type de carte `"Magic" | "Monster"`
  - `genre`: Genre de monstre (ex: "Dragon", "Warrior")
  - `level_exact`: Niveau exact du monstre
- `max_targets`: Nombre maximum de cartes à sélectionner (défaut: 1)
- `random_select`: Sélection aléatoire parmi les correspondances (défaut: false)
- `shuffle_deck`: Mélanger le deck après ajout (défaut: true si destination = "Deck")

#### Exemples d'utilisation:

```gml
// 1) Recherche classique dans le deck vers la main
{ effect_type: EFFECT_SEARCH, search_criteria: { archetype: "Dragon" } }

// 2) Recherche multi-zones (deck + cimetière) vers la main
{ 
  effect_type: EFFECT_SEARCH, 
  search_sources: ["Deck", "Graveyard"], 
  search_criteria: { type: "Monster", genre: "Dragon" } 
}

// 3) Récupération du cimetière vers le deck
{ 
  effect_type: EFFECT_SEARCH, 
  search_sources: ["Graveyard"], 
  destination: "Deck", 
  search_criteria: { name: "Dragon Noir aux Yeux Rouges" } 
}

// 4) Recherche multiple avec sélection aléatoire
{ 
  effect_type: EFFECT_SEARCH, 
  max_targets: 2, 
  random_select: true, 
  search_criteria: { archetype: "Héros Élémentaire" } 
}

// 5) Recherche par niveau exact
{ 
  effect_type: EFFECT_SEARCH, 
  search_criteria: { type: "Monster", level_exact: 4 } 
}
```

## Intégration avec les Déclencheurs

### Exemple Complet : Carte avec Effet
```gml
// Structure d'une carte avec effet
{
    "id": "dragon_rouge",
    "name": "Dragon Rouge",
    "attack": 800,
    "defense": 600,
    "effects": [
        {
            "id": 1,
            "trigger": "on_summon",
            "effect_type": "damage_all",
            "value": 200,
            "target_owner": "enemy",
            "target_type": "monster",
            "description": "À l'invocation : Infligez 200 dégâts à tous les monstres ennemis."
        },
        {
            "id": 2,
            "trigger": "on_destroy",
            "effect_type": "draw_cards",
            "value": 1,
            "description": "Quand cette carte est détruite : Piochez 1 carte."
        }
    ]
}
```

## Fonctions Utilitaires

### Exécution d'Effet
```gml
// Exécuter un effet
executeEffect(card, effect, context);
```

### Description Automatique
```gml
// Obtenir la description d'un effet
var description = getEffectDescription(effect);
```

### Filtrage de Cibles
```gml
// Obtenir les cibles selon les filtres
var targets = getTargetsByFilter(effect);
```

### Réinitialisation
```gml
// Remettre à zéro les effets temporaires
resetTemporaryEffects();
```

## Conseils d'Implémentation

### Performance
1. **Filtrage efficace** : Utilisez des filtres précis pour limiter les cibles
2. **Cache des effets** : Stockez les effets actifs pour éviter les recalculs
3. **Batch processing** : Groupez les effets similaires

### Équilibrage
1. **Valeurs cohérentes** : Maintenez des ratios équilibrés entre les effets
2. **Conditions appropriées** : Ajoutez des conditions pour les effets puissants
3. **Coût vs Bénéfice** : Équilibrez la puissance avec les restrictions

### Debugging
1. **Logs détaillés** : Utilisez `show_debug_message()` pour tracer les effets
2. **Validation** : Vérifiez toujours l'existence des cibles
3. **Gestion d'erreurs** : Prévoyez les cas d'échec

## Notes Importantes

- **Ordre d'exécution** : Les effets s'exécutent dans l'ordre de leur déclenchement
- **Chaînage** : Un effet peut déclencher d'autres effets
- **Annulation** : Certains effets peuvent être annulés par d'autres
- **Persistance** : Les effets temporaires sont automatiquement nettoyés
- **Compatibilité** : Le système est conçu pour être extensible

## Ajout dans GameMaker

⚠️ **Important** : Ces scripts doivent être ajoutés manuellement dans GameMaker :

1. Créer un nouveau script `sEffects` dans GameMaker
2. Copier le contenu du fichier `sEffects.gml`
3. Sauvegarder et compiler le projet
4. Tester les effets avec des cartes d'exemple
### Destruction Générique (`EFFECT_DESTROY`)

Paramètres supportés:
- `target_owner`: `ally` | `enemy` | `any` (défaut: `enemy`)
- `target_type`: `monster` | `spell` (défaut: `monster`)
- `zone`: `Field` | `FieldSelected` (défaut: `Field`)
- `selection`: `{ mode: "random" | "first", count: <int> }` (défaut: `{ mode: "random", count: 1 }`)
- critères optionnels: `genre`, `archetype`

Exemple:
```gml
{
  effect_type: EFFECT_DESTROY,
  target_owner: "enemy",
  target_type: "monster",
  selection: { mode: "random", count: 1 },
  description: "Détruisez aléatoirement 1 monstre ennemi sur le terrain."
}
```