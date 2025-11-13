event_inherited();  // Hérite des variables et comportement de oCardMagic

// Définit les stats spécifiques de ce sort
name = "La Rose noire"
genre = "Artéfact"
archetype = "Rose noire"
rarity = "commun"
booster = "Chemin perdu"
is_player_card = true;

description = "Le monstre équipé gagne +1000 ATK. Tombe : Ajoute une carte 'La Rose noire' depuis votre deck.";
effects = [];
array_push(effects, { trigger: TRIGGER_MAIN_PHASE, effect_type: EFFECT_EQUIP_SELECT_TARGET, ally_only: false, description: "Choisissez un monstre à équiper; posez cette carte." });
array_push(effects, { trigger: TRIGGER_CONTINUOUS, effect_type: EFFECT_EQUIP_APPLY_BUFF, atk_buff: 1000, def_buff: 0, description: "Le monstre équipé gagne +1000 ATK et 0 DEF." });
array_push(effects, { trigger: TRIGGER_ON_DESTROY, effect_type: EFFECT_EQUIP_CLEANUP, description: "Réinitialise le monstre équipé et détache la cible." });
// Tombe: le propriétaire cherche une autre "La Rose noire" dans son deck et l'ajoute à sa main
array_push(effects, {
    trigger: TRIGGER_ON_DESTROY,
    effect_type: EFFECT_SEARCH,
    conditions: { zone: "Field" },
    search_sources: ["Deck"],
    destination: "Hand",
    search_criteria: { name: "La Rose noire" },
    max_targets: 1,
    shuffle_deck: true,
    
});
