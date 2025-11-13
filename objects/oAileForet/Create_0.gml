event_inherited();  // Hérite des variables et comportement de oCardMagic

// Définit les stats spécifiques de ce sort
name = "Ailes dans la forêt"
genre = "Direct"
archetype = "Neutre"
rarity = "commun"
booster = "Chemin perdu"
is_player_card = true;

description = "Défausse 2 cartes de votre main, puis ajoute un Dragon de votre deck à votre main (enchaîné en une seule activation)."

effects = [];

// Activation unique — enchaîne défausse (2) puis recherche Dragon
array_push(
    effects,
    {
        trigger: TRIGGER_MAIN_PHASE,
        effect_type: EFFECT_DISCARD,
        selection: { mode: "count", count: 2 },
        flow: [
            { effect_type: EFFECT_TEMPO, ms: 1000 },
            {
                effect_type: EFFECT_SEARCH,
                search_sources: ["Deck"],
                destination: "Hand",
                search_criteria: { type: "Monster", genre: "Dragon" },
                random_select: true
            }
        ],
        description: "Défaussez 2 cartes, puis ajoutez un Dragon du deck à la main."
    }
);

