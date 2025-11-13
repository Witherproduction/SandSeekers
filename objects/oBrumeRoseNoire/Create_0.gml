event_inherited();  // Hérite des variables et comportement de oCardMagic

// Définit les stats spécifiques de ce sort
name = "Brume de la Rose noire"
genre = "Continue"
archetype = "Rose noire"
rarity = "commun"
booster = "Chemin perdu"
is_player_card = true;

description = "Les monstres Rose noire gagne 500/500. Tombe : Envoie 2 cartes Rose noires de votre cimetière à votre deck puis pioche 1 carte."

// === EFFETS DE LA CARTE ===

// Effet continu: aura +500/+500 pour tous les monstres "Rose noire" sur le terrain
effects[0] = {
    trigger: TRIGGER_CONTINUOUS,
    effect_type: EFFECT_AURA_ARCHETYPE_BUFF,
    archetype: "Rose noire",
    atk: 500,
    def: 500
};

// Effet de nettoyage: retirer les contributions d'aura quand la carte quitte le terrain
effects[1] = {
    trigger: TRIGGER_LEAVE_FIELD,
    effect_type: EFFECT_AURA_CLEANUP_SOURCE
};

// Effet Tombe 1: Rechercher 2 cartes "Rose noire" dans le cimetière et les renvoyer au deck
effects[2] = {
    trigger: TRIGGER_ON_DESTROY,
    effect_type: EFFECT_SEARCH,
    search_location: "Graveyard", // Recherche dans le cimetière
    value: 2,
    search_criteria: {
        archetype: "Rose noire"
    },
    destination: "Deck", // Ajoute au deck
    shuffle_deck: true,
    flow: [
        { effect_type: EFFECT_TEMPO, ms: 1000 },
        { effect_type: EFFECT_DRAW_CARDS, value: 1 }
    ]
};

