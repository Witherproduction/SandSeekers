event_inherited();  // Hérite des variables et comportement de oCardMonster

// Définit les stats spécifiques de ce monstre
name = "Sorcière de la Rose noire"
attack = 1000;
defense = 1000;
star = 2; // Niveau 1 - pas de sacrifice requis pour l'invocation
lastTurnAttack = 0;
genre = "Humanoïde"
archetype = "Rose noire"
rarity = "commun"
is_player_card = true; // Définit explicitement cette carte comme appartenant au joueur
description = "Finalisation : ajoutez aléatoirement un sort Rose noire depuis votre deck à votre main"

// Effet: à la fin du tour (finalisation), ajouter aléatoirement une Magie "Rose noire" depuis le deck à la main
if (!variable_instance_exists(id, "effects")) effects = [];
array_push(effects, {
    id: "sorciere_end_turn_search_spell",
    trigger: TRIGGER_END_TURN,
    effect_type: EFFECT_SEARCH,
    search_criteria: { archetype: "Rose noire", type: "Magic" },
    random_select: true,
    conditions: { once_per_turn: true }
});