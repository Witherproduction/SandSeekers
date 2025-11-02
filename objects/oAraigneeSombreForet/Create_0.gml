event_inherited();  // Hérite des variables et comportement de oCardMonster

// Définit les stats spécifiques de ce monstre
name = "Araignée sombre des forêts"
attack = 1000;
defense = 1000;
star = 1;
genre = "Insecte"
archetype = "Neutre"
booster = "Chemin perdu"
rarity = "commun"
lastTurnAttack = 0;
is_player_card = true; // Définit explicitement cette carte comme appartenant au joueur
description = "Tombe : Détruit le monstre attaquant."

effects = [
    {
        trigger: TRIGGER_ON_DESTROY,
        effect_type: EFFECT_DESTROY_TARGET,
        description: "Quand cette carte est détruite : détruisez le monstre attaquant."
    }
];
