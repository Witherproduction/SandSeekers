event_inherited();  // Hérite des variables et comportement de oCardMonster

// Définit les stats spécifiques de ce monstre
name = "Jeton Rose noire"
attack = 1000;
defense = 1000;
star = 0; // Niveau 1 - pas de sacrifice requis pour l'invocation
lastTurnAttack = 0;
genre = "Jeton"
archetype = "Rose noire"
rarity = "commun"
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