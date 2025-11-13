event_inherited();  // Hérite des variables et comportement de oCardMonster

// Définit les stats spécifiques de ce monstre
name = "Petite sorcière de la Rose noire"
attack = 500;
defense = 1000;
star = 1; // Niveau 1 - pas de sacrifice requis pour l'invocation
lastTurnAttack = 0;
genre = "Humanoïde"
archetype = "Rose noire"
is_player_card = true; // Définit explicitement cette carte comme appartenant au joueur
description = "Finalisation : ajoutez aléatoirement un monstre Rose noire depuis votre deck à votre main."

// Effet: à la fin du tour, ajouter aléatoirement un monstre Rose noire depuis le deck à la main
if (!variable_instance_exists(id, "effects")) effects = [];
array_push(effects, {
    id: "petite_sorciere_end_turn_search",
    trigger: TRIGGER_END_TURN,
    effect_type: EFFECT_SEARCH,
    search_criteria: { archetype: "Rose noire", type: "Monster" },
    random_select: true,
    
});