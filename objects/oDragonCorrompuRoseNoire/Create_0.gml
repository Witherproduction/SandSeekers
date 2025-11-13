event_inherited();  // Hérite des variables et comportement de oCardMonster

// Définit les stats spécifiques de ce monstre
name = "Dragon Corrompu par la Rose noire"
attack = 2500;
defense = 0;
star = 2; // Niveau 1 - pas de sacrifice requis pour l'invocation
lastTurnAttack = 0;
genre = "Dragon"
archetype = "Rose noire"
rarity = "commun"
is_player_card = true; // Définit explicitement cette carte comme appartenant au joueur
description = "Tombe : Invoque un Dragon sacré par la Rose noire depuis  votre deck si c'est le tour de votre adversaire."

// Effet déclenché : À la destruction, invoquer spécialement le Dragon sacré par la Rose noire depuis le deck
effects = [
    {
        trigger: TRIGGER_ON_DESTROY,
        effect_type: EFFECT_SUMMON,
    summon_mode: "named",
        target_object: "oDragonSacreRoseNoire",
        from_deck_only: true,
        conditions: { opponent_turn: true },
    }
];