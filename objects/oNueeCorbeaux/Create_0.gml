event_inherited();  // Hérite des variables et comportement de oCardMonster

// Définit les stats spécifiques de ce monstre
name = "Nuée de corbeaux"
attack = 500;
defense = 500;
star = 1;
genre = "Bête"
archetype = "Neutre"
booster = "Chemin perdu"
rarity = "commun"
lastTurnAttack = 0;
is_player_card = true; // Définit explicitement cette carte comme appartenant au joueur
// Description mise à jour et ajout de l'effet cimetière
description = "Tombe : défaussez au hasard 1 carte de votre main.";

effects = [
    {
        trigger: TRIGGER_ENTER_GRAVEYARD,
        effect_type: EFFECT_DISCARD,
        selection: { mode: "random", count: 1 },
        description: "Quand cette carte entre au cimetière : défaussez au hasard 1 carte de votre main."
    }
];
