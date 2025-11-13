event_inherited();  // Hérite des variables et comportement de oCardMonster

// Définit les stats spécifiques de ce monstre
name = "Dragonnet béni par la Rose noire"
attack = 0;
defense = 1000;
star = 1; // Niveau 1 - pas de sacrifice requis pour l'invocation
lastTurnAttack = 0;
genre = "Dragon"
archetype = "Rose noire"
booster = "Chemin perdu"
rarity = "commun"
is_player_card = true; // Définit explicitement cette carte comme appartenant au joueur
description = "Vous pouvez défaussez cette carte de votre main pour ajouter une carte Rose noire de votre deck à votre main."
effects = [
    {
        id: 1,
        effect_type: EFFECT_DISCARD,        
        selection: { mode: "self" },
        flow: [
            { effect_type: EFFECT_TEMPO, ms: 1000 },
            {
                effect_type: EFFECT_SEARCH,
                search_archetype: "Rose noire"
            }
        ],
        conditions: {
            owner: "Hero",
            zone: "Hand",
            once_per_turn: true
        }
    }
];