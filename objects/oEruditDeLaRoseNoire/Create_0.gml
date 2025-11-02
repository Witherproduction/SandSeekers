event_inherited();  // Hérite des variables et comportement de oCardMonster

// Définit les stats spécifiques de ce monstre
name = "Erudit de la Rose noire"
attack = 2000;
defense = 2000;
star = 3; // Niveau 1 - pas de sacrifice requis pour l'invocation
lastTurnAttack = 0;
genre = "Humanoïde"
archetype = "Rose noire"
booster = "Chemin perdu"
rarity = "commun"
is_player_card = true; // Définit explicitement cette carte comme appartenant au joueur
description = "Appel : vous pouvez invoquer une Petite sorciere de la Rose noire et une Sorciere de la rose noire sur le terrain depuis votre main, deck ou cimetiere. Tombe : ajoutez une carte Rose noire depuis votre deck a votre main."

effects = [
    {
        trigger: TRIGGER_ON_SUMMON,
        effect_type: EFFECT_SUMMON,
        summon_mode: "named",
        target_object: "oPetiteSorciereDeLaRoseNoire",
        description: "À l'invocation : Invoquez spécialement une Petite Sorcière de la Rose noire depuis la main, le deck ou le cimetière."
    },
    {
        trigger: TRIGGER_ON_SUMMON,
        effect_type: EFFECT_SUMMON,
        summon_mode: "named",
        target_object: "oSorciereDeLaRoseNoire",
        description: "À l'invocation : Invoquez spécialement une Sorcière de la Rose noire depuis la main, le deck ou le cimetière."
    },
    {
        trigger: TRIGGER_ENTER_GRAVEYARD,
        effect_type: EFFECT_SEARCH,
        search_archetype: "Rose noire",
        description: "Tombe : Ajoutez une carte 'Rose noire' depuis votre deck à votre main."
    }
];
