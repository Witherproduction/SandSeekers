event_inherited();  // Hérite des variables et comportement de oCardMonster

// Définit les stats spécifiques de ce monstre
name = "Ombre de la Rose noire"
attack = 0;
defense = 0;
star = 1; // Niveau 1 - pas de sacrifice requis pour l'invocation
lastTurnAttack = 0;
genre = "Mort-vivant"
archetype = "Rose noire"
rarity = "commun"
is_player_card = true; // Définit explicitement cette carte comme appartenant au joueur
description = "Perdu : piochez 2 cartes puis defaussez une carte de votre main."

// Ajout des effets : à l'entrée au cimetière → pioche 2 puis défausse 1 au hasard
effects = [
    {
        trigger: TRIGGER_ENTER_GRAVEYARD,
        effect_type: EFFECT_DRAW_CARDS,
        value: 2,
        description: "Quand cette carte entre au cimetière : piochez 2 cartes."
    },
    {
        trigger: TRIGGER_ENTER_GRAVEYARD,
        effect_type: EFFECT_DISCARD,
        selection: { mode: "random", count: 1 },
        description: "Puis défaussez au hasard 1 carte de votre main."
    }
];