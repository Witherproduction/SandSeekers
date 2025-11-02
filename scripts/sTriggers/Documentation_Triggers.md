# Documentation des Déclencheurs d'Effets

## Vue d'ensemble

Le système de déclencheurs permet d'activer automatiquement les effets des cartes en réponse à différents événements du jeu. Chaque carte peut avoir plusieurs effets avec des déclencheurs différents.

## Types de Déclencheurs

### 🎯 Déclencheurs de Base

| Déclencheur | Constante | Description | Exemple d'usage |
|-------------|-----------|-------------|-----------------|
| À l'invocation | `TRIGGER_ON_SUMMON` | Se déclenche quand la carte est invoquée | Piocher une carte à l'invocation |
| À la destruction | `TRIGGER_ON_DESTROY` | Se déclenche quand la carte est détruite | Infliger des dégâts à l'adversaire |
| À l'attaque | `TRIGGER_ON_ATTACK` | Se déclenche quand la carte attaque | Gagner de l'ATK temporairement |
| À la défense | `TRIGGER_ON_DEFENSE` | Se déclenche quand la carte se défend | Réduire les dégâts subis |
| Quand subit des dégâts | `TRIGGER_ON_DAMAGE` | Se déclenche quand la carte subit des dégâts | Se soigner de la moitié des dégâts |
| Quand soigné | `TRIGGER_ON_HEAL` | Se déclenche quand la carte est soignée | Doubler les soins reçus |

### ⏰ Déclencheurs de Phase

| Déclencheur | Constante | Description | Moment d'activation |
|-------------|-----------|-------------|-------------------|
| Début du tour | `TRIGGER_START_TURN` | Au début de chaque tour | Avant la phase de pioche |
| Fin du tour | `TRIGGER_END_TURN` | À la fin de chaque tour | Après la phase de fin |
| Phase de pioche | `TRIGGER_DRAW_PHASE` | Pendant la phase de pioche | Quand on pioche |
| Phase principale | `TRIGGER_MAIN_PHASE` | Pendant la phase principale | Quand on peut jouer des cartes |
| Phase de combat | `TRIGGER_BATTLE_PHASE` | Pendant la phase de combat | Quand on peut attaquer |
| Phase de fin | `TRIGGER_END_PHASE` | Pendant la phase de fin | Avant de finir le tour |

### 🎮 Déclencheurs d'Interaction

| Déclencheur | Constante | Description | Contexte |
|-------------|-----------|-------------|----------|
| Quand ciblé | `TRIGGER_ON_TARGET` | Quand la carte devient une cible | Par un sort ou un effet |
| Quand équipé | `TRIGGER_ON_EQUIP` | Quand un équipement est attaché | Cartes d'équipement |
| Quand déséquipé | `TRIGGER_ON_UNEQUIP` | Quand un équipement est retiré | Fin d'effet d'équipement |
| Quand retourné | `TRIGGER_ON_FLIP` | Quand la carte est retournée | Cartes face cachée |

### 🏟️ Déclencheurs de Zone

| Déclencheur | Constante | Description | Changement de zone |
|-------------|-----------|-------------|-------------------|
| Entre sur le terrain | `TRIGGER_ENTER_FIELD` | Quand la carte arrive sur le terrain | Main → Terrain |
| Quitte le terrain | `TRIGGER_LEAVE_FIELD` | Quand la carte quitte le terrain | Terrain → Autre zone |
| Entre dans la main | `TRIGGER_ENTER_HAND` | Quand la carte arrive en main | Deck/Terrain → Main |
| Quitte la main | `TRIGGER_LEAVE_HAND` | Quand la carte quitte la main | Main → Autre zone |
| Entre au cimetière | `TRIGGER_ENTER_GRAVEYARD` | Quand la carte va au cimetière | Toute zone → Cimetière |
| Quitte le cimetière | `TRIGGER_LEAVE_GRAVEYARD` | Quand la carte quitte le cimetière | Cimetière → Autre zone |

### 🔄 Déclencheurs Conditionnels

| Déclencheur | Constante | Description | Condition |
|-------------|-----------|-------------|-----------|
| Quand les LP changent | `TRIGGER_ON_LP_CHANGE` | Quand les points de vie changent | Gain ou perte de LP |
| Quand une carte est piochée | `TRIGGER_ON_CARD_DRAW` | Quand n'importe quelle carte est piochée | Par n'importe quel joueur |
| Quand un sort est lancé | `TRIGGER_ON_SPELL_CAST` | Quand un sort/magie est activé | Cartes magiques |
| Quand un monstre est invoqué | `TRIGGER_ON_MONSTER_SUMMON` | Quand n'importe quel monstre est invoqué | Par n'importe quel joueur |

### ⚡ Déclencheurs Spéciaux

| Déclencheur | Constante | Description | Particularité |
|-------------|-----------|-------------|---------------|
| Une fois par tour | `TRIGGER_ONCE_PER_TURN` | Limitation d'usage | Modificateur de condition |
| Effet continu | `TRIGGER_CONTINUOUS` | Effet permanent | Tant que la carte est sur le terrain |
| Effet rapide | `TRIGGER_QUICK_EFFECT` | Peut être activé à tout moment | Pendant le tour adverse aussi |
| Effet de contre | `TRIGGER_COUNTER` | Réaction à un autre effet | Peut annuler ou modifier |

## Structure d'un Effet avec Déclencheur

```gml
// Exemple d'effet dans une carte
{
    "id": 1,
    "trigger": "on_summon",
    "effect_type": "draw_cards",
    "value": 1,
    "conditions": {
        "once_per_turn": true,
        "min_lp": 1000
    },
    "description": "À l'invocation : Piochez 1 carte si vous avez au moins 1000 LP."
}
```

## Conditions Disponibles

### Conditions de Base
- `once_per_turn` : L'effet ne peut être utilisé qu'une fois par tour
- `min_lp` : LP minimum requis pour activer l'effet
- `max_lp` : LP maximum requis pour activer l'effet
- `hand_size` : Nombre exact de cartes en main requis
- `target_type` : Type de carte ciblée requis
- `phase` : Phase spécifique requise pour l'activation

### Conditions Avancées
- `field_count` : Nombre de cartes sur le terrain
- `graveyard_count` : Nombre de cartes au cimetière
- `deck_count` : Nombre de cartes dans le deck
- `monster_type` : Type de monstre spécifique
- `attribute` : Attribut spécifique requis

## Utilisation dans le Code

### Vérifier un Déclencheur
```gml
// Vérifier si une carte a un déclencheur spécifique
if (checkTrigger(card, TRIGGER_ON_SUMMON, context)) {
    // Le déclencheur peut être activé
}
```

### Activer un Déclencheur
```gml
// Activer tous les déclencheurs d'un type pour une carte
activateTrigger(card, TRIGGER_ON_SUMMON, context);
```

### Enregistrer un Événement Global
```gml
// Déclencher un événement pour toutes les cartes sur le terrain
registerTriggerEvent(TRIGGER_ON_MONSTER_SUMMON, sourceCard, context);
```

## Exemples Pratiques

### Monstre qui pioche à l'invocation
```gml
{
    "trigger": "on_summon",
    "effect_type": "draw_cards",
    "value": 1,
    "description": "À l'invocation : Piochez 1 carte."
}
```

### Monstre qui se soigne en début de tour
```gml
{
    "trigger": "start_turn",
    "effect_type": "heal_self",
    "value": 200,
    "conditions": {
        "once_per_turn": true
    },
    "description": "Une fois par tour, au début de votre tour : Cette carte gagne 200 LP."
}
```

### Monstre qui réagit à la destruction d'autres monstres
```gml
{
    "trigger": "on_monster_destroy",
    "effect_type": "gain_attack",
    "value": 100,
    "description": "Quand un monstre est détruit : Cette carte gagne 100 ATK."
}
```

## Notes Importantes

1. **Ordre d'activation** : Les déclencheurs s'activent dans l'ordre où les cartes ont été placées sur le terrain
2. **Chaînage** : Les effets peuvent se déclencher en chaîne les uns après les autres
3. **Conditions** : Toutes les conditions doivent être remplies pour qu'un déclencheur s'active
4. **Performance** : Le système vérifie automatiquement tous les déclencheurs pertinents
5. **Debugging** : Utilisez `getTriggerName()` pour afficher le nom lisible d'un déclencheur

## Intégration avec le Système d'Effets

Ce système de déclencheurs fonctionne en tandem avec le système d'effets (sEffects). Les déclencheurs déterminent **quand** un effet s'active, tandis que le système d'effets détermine **ce qui** se passe.