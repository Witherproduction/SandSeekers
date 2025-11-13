event_inherited();  // Hérite des variables et comportement de oCardMonster

// Définit les stats spécifiques de ce monstre
name = "Tréant"
attack = 700;
defense = 1000;
star = 1;
genre = "Elémentaire"
archetype = "Neutre"
booster = "Chemin perdu"
rarity = "commun"
lastTurnAttack = 0;
is_player_card = true; // Définit explicitement cette carte comme appartenant au joueur
description = "Initialisation : Défaussez 1 carte, puis détruisez un sort sur le terrain adverse (si possible)."

// Effet d'initialisation : défausser 1 carte puis détruire un sort ennemi (avec prérequis)
if (!variable_instance_exists(id, "effects")) effects = [];
array_push(effects, {
    id: "treant_discard_destroy_spell",
    trigger: TRIGGER_START_TURN,
    conditions: { has_enemy_spell_on_field: true, min_hand_size: 1 },
    effect_type: EFFECT_DISCARD,
    selection: { mode: "count", count: 1 },
    flow: [
        { effect_type: EFFECT_TEMPO, ms: 1000 },
        {
            effect_type: EFFECT_DESTROY,
            owner: "enemy",
            target_zone: "Field",
            target_types: ["Magic"],
            random_select: true,
            destroy_count: 1
        }
    ],
    description: "Initialisation : Défaussez 1 carte, puis détruisez un sort sur le terrain adverse."
});
