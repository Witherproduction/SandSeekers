event_inherited();  // Hérite des variables et comportement de oCardMonster

// Définition des stats spécifiques de ce monstre
name = "Loup béni par la Rose noire"
attack = 500;
defense = 500;
 star = 1; // Niveau 1 - pas de sacrifice requis pour l'invocation
lastTurnAttack = 0;
genre = "Bête"
archetype = "Rose noire"
rarity = "commun"
is_player_card = true; // Définit explicitement cette carte comme appartenant au joueur

// Description de la carte
// Lors de son invocation, invoque un autre "Loup béni par la Rose noire" depuis la main ou le deck.
description = "Appel : Invoquez spécialement un autre 'Loup béni par la Rose noire' depuis la main ou le deck (1 seul).";

// Effet: à l'invocation normale uniquement, invoque spécialement 1 autre exemplaire depuis main ou deck
effects = [
    {
        trigger: TRIGGER_ON_SUMMON,
        effect_type: EFFECT_SUMMON,
    summon_mode: "named",
        target_name: "Loup béni par la Rose noire",
        allowed_sources: ["Deck", "Hand"],
        conditions: {
            owner: "Hero",
            zone: "Field",
            summon_mode: "Summon" // ne se déclenche pas sur l'invocation spéciale issue de cet effet
        },
        description: "À l'invocation: invoquez spécialement un autre 'Loup béni par la Rose noire' depuis la main ou le deck."
    }
];