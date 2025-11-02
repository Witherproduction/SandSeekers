event_inherited();  // Hérite des variables et comportement de oCardMonster

// Définit les stats spécifiques de ce monstre
name = "Lac illuminé par Clair-de-lune"
attack = 0;
defense = 1500;
star = 2;
genre = "Sacré"
archetype = "Neutre"
rarity = "commun"
lastTurnAttack = 0;
is_player_card = true; // Définit explicitement cette carte comme appartenant au joueur
description = "Défenseur : détruisez le monstre attaquant"

effects = [
    {
        trigger: TRIGGER_ON_DEFENSE,
        effect_type: EFFECT_DESTROY_TARGET,
        conditions: {
            owner: "Hero",
            zone: "Field",
            target_type: "Monster"
        },
        description: "Après avoir été attaqué: détruisez le monstre attaquant."
    }
];
