event_inherited();  // Hérite des variables et comportement de oCardMagic

// Définit les stats spécifiques de ce sort
name = "Clair de lune dans la forêt maudite"
genre = "Direct"
archetype = "Rose noire"
rarity = "commun"
booster = "Chemin perdu"
is_player_card = true;

description = "Pioche 3 cartes. Défausse les monstres piochés."

effects = [
    {
        id: 1,
        effect_type: EFFECT_DRAW_CARDS,
        value: 3,
        trigger: TRIGGER_MAIN_PHASE,
        show_aura: true,
        description: "Pioche 3 cartes.",
        flow: [
            { effect_type: EFFECT_TEMPO, ms: 1000 },
            {
                id: 2,
                effect_type: EFFECT_DISCARD,
                selection: { mode: "count", count: 3, allow_partial: true },
                target_filter: { type: "Monster" },
                description: "Défausse les monstres piochés par l'effet 1."
            }
        ]
    }
];

