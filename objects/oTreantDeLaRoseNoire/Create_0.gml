event_inherited();  // Hérite des variables et comportement de oCardMonster

// Définit les stats spécifiques de ce monstre
name = "Tréant de la Rose noire"
attack = 1000;
defense = 1000;
star = 1; // Niveau 1 - pas de sacrifice requis pour l'invocation
lastTurnAttack = 0;
genre = "Elémentaire"
archetype = "Rose noire"
rarity = "commun"
is_player_card = true; // Définit explicitement cette carte comme appartenant au joueur
description = "Finalisation : Défausse une carte de votre main pour detruire un sort sur le terrain adverse"

// Effet: Finalisation — défausser 1 carte pour détruire 1 Magie adverse
if (!variable_instance_exists(id, "effects")) effects = [];
array_push(effects, {
    id: "treant_rose_noire_end_discard_destroy_spell",
    trigger: TRIGGER_END_TURN,
    effect_type: EFFECT_DISCARD,
    label: "fin de tour",
    conditions: {
        owner: "Hero",
        zone: "Field",
        owner_turn: true,
        once_per_turn: true,
        has_enemy_spell_on_field: true
    },
    // Enchaînement: si la défausse réussit, détruire une carte Magie ennemie
    flow: [
        {
            effect_type: EFFECT_DESTROY,
            owner: "enemy",
            target_zone: "Field",
            target_types: ["Magic"],
            random_select: true,
            destroy_count: 1
        }
    ],
    description: "Finalisation : défaussez 1 carte; puis détruisez 1 carte Magie adverse sur le terrain."
});