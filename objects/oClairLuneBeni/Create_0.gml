event_inherited();  // Hérite des variables et comportement de oCardMagic

// Définit les stats spécifiques de ce sort
name = "Clair de lune béni"
genre = "Direct"
archetype = "Neutre"
rarity = "commun"
booster = "Chemin perdu"
is_player_card = true;

description = "Pioche 2 cartes. Défausse tous les monstres piochés"

effects = [
    {
        id: 1,
        effect_type: EFFECT_DRAW_CARDS,
        value: 2,
        trigger: TRIGGER_MAIN_PHASE,
        show_aura: true,
        description: "Pioche 2 cartes.",
        flow: [
            {
                id: 2,
                effect_type: EFFECT_DISCARD,
                selection: { mode: "count", count: 2, allow_partial: true },
                target_filter: { type: "Monster" },
                description: "Défausse les monstres piochés par l'effet 1."
            }
        ]
    }
];

