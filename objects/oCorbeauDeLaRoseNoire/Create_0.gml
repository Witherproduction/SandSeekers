event_inherited();  // Hérite des variables et comportement de oCardMonster

// Définit les stats spécifiques de ce monstre
name = "Corbeau de la rose noire"
attack = 500;
defense = 500;
star = 1; // Niveau 1 - pas de sacrifice requis pour l'invocation
lastTurnAttack = 0;
genre = "Bête"
archetype = "Rose noire"
booster = "Chemin perdu"
rarity = "commun"
is_player_card = true; // Définit explicitement cette carte comme appartenant au joueur
description = "Perdu :  défaussez 1 carte aléatoire de votre main et envoyez-la au cimetière.";

effects = [
    {
        trigger: TRIGGER_ENTER_GRAVEYARD,
        effect_type: EFFECT_DISCARD,
        selection: { mode: "random", count: 1 },
        description: "Quand cette carte entre au cimetière : défaussez au hasard 1 carte de votre main."
    }
];
