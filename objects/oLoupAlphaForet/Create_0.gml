event_inherited();  // Hérite des variables et comportement de oCardMonster

// Définit les stats spécifiques de ce monstre
name = "Loup alpha des forêts"
attack = 500;
defense = 500;
star = 1;
genre = "Bête"
archetype = "Neutre"
booster = "Chemin perdu"
rarity = "commun"
lastTurnAttack = 0;
is_player_card = true; // Définit explicitement cette carte comme appartenant au joueur
description = "Invoqué : Invoque un autre Loup alpha des forêts depuis votre main ou deck."

// Effet: à l'invocation normale uniquement, invoque spécialement 1 autre exemplaire depuis main ou deck
effects = [
    {
        trigger: TRIGGER_ON_SUMMON,
        effect_type: EFFECT_SUMMON,
    summon_mode: "named",
        target_name: "Loup alpha des forêts",
        allowed_sources: ["Deck", "Hand"],
        conditions: {
            owner: "Hero",
            zone: "Field",
            summon_mode: "Summon" // ne se déclenche pas sur l'invocation spéciale issue de cet effet
        },
        description: "À l'invocation: invoquez spécialement un autre 'Loup alpha des forêts' depuis la main ou le deck."
    }
];
