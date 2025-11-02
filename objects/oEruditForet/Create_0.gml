event_inherited();  // Hérite des variables et comportement de oCardMonster

// Définit les stats spécifiques de ce monstre
name = "Erudit de la forêt"
attack = 1500;
defense = 2000;
star = 2;
genre = "Humanoïde"
archetype = "Neutre"
booster = "Chemin perdu"
rarity = "commun"
lastTurnAttack = 0;
is_player_card = true; // Définit explicitement cette carte comme appartenant au joueur
description = "Invoqué : Invoque une Bête sur votre terrain et joue un sort secret depuis votre main, deck ou cimetière."

effects = [
    {
        trigger: TRIGGER_ON_SUMMON,
        effect_type: EFFECT_SUMMON,
        summon_mode: "named",
        criteria: { type: "Monster", genre: "Bête" },
        allowed_sources: ["Hand", "Deck", "Graveyard"],
        description: "À l'invocation : Invoquez spécialement une Bête depuis la main, le deck ou le cimetière."
    },
    {
        trigger: TRIGGER_ON_SUMMON,
        effect_type: EFFECT_SUMMON,
        summon_mode: "activate_spell",
        criteria: { type: "Magic", genre: "Secret" },
        allowed_sources: ["Hand", "Deck", "Graveyard"],
        description: "À l'invocation : Activez une carte Magie de genre 'Secret' depuis la main, le deck ou le cimetière."
    }
];
