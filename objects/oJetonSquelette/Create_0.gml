event_inherited();  // Hérite des variables et comportement de oCardMonster

// Définit les stats spécifiques de ce monstre
name = "Jeton Squelette"
attack = 500;
defense = 500;
star = 0;
genre = "Jeton"
archetype = "Neutre"
booster = "Chemin perdu"
rarity = "commun"
lastTurnAttack = 0;
is_player_card = true; // Définit explicitement cette carte comme appartenant au joueur
description = "Finalisation : Ce jeton est détruit"

effects = [
    {
        trigger: TRIGGER_END_TURN,
        effect_type: EFFECT_DESTROY_SELF,
        description: "Fin du tour : Ce jeton se détruit.",
        conditions: {
            zone: "Field",
            owner_turn: true
        }
    }
];
