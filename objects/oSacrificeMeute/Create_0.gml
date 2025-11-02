event_inherited();  // Hérite des variables et comportement de oCardMagic

// Définit les stats spécifiques de ce sort
name = "Sacrifice pour la meute";
genre = "Direct";
archetype = "Neutre";
rarity = "commun";
booster = "Chemin perdu";
is_player_card = true;

description = "Détruit une bête alliée aléatoire puis un monstre ennemi aléatoire.";

// === EFFETS DE LA CARTE ===
if (!variable_instance_exists(id, "effects")) effects = [];

// Effet 1: Détruire une bête alliée aléatoire
effects[0] = {
    trigger: TRIGGER_MAIN_PHASE,
    effect_type: EFFECT_DESTROY,
    owner: "ally",
    criteria: {
        type: "Monster",
        genre: "Bête"
    },
    destroy_count: 1,
    random_select: true,
    description: "Détruit une bête alliée aléatoire",
    flow: {
        effect_type: EFFECT_DESTROY,
        owner: "enemy",
        criteria: {
            type: "Monster"
        },
        destroy_count: 1,
        random_select: true,
        description: "puis détruit un monstre ennemi aléatoire"
    }
};