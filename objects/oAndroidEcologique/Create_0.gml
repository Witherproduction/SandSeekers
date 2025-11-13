event_inherited();  // Hérite des variables et comportement de oCardMonster

// Définit les stats spécifiques de ce monstre
name = "Androïd écologique"
attack = 500;
defense = 500;
star = 1;
genre = "Méca"
archetype = "Robot d'assaut"
booster = "Usine robotique"
rarity = "commun"
lastTurnAttack = 0;
is_player_card = true; // Définit explicitement cette carte comme appartenant au joueur
description = "Finalisation : Ajoute un Méca de votre cimetière à votre main"

if (!variable_instance_exists(id, "effects")) effects = [];
array_push(effects, {
    id: "android_end_turn_recover_meca",
    trigger: TRIGGER_END_TURN,
    effect_type: EFFECT_SEARCH,
    search_sources: ["Graveyard"],
    destination: "Hand",
    search_criteria: { type: "Monster", genre: "Méca" },
    conditions: { once_per_turn: true }
});
