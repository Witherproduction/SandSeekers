event_inherited();  // Hérite des variables et comportement de oCardMonster

// Définit les stats spécifiques de ce monstre
name = "Araignée de la Rose noire"
attack = 1000;
defense = 1000;
star = 1;
genre = "Insecte"
archetype = "Rose noire"
rarity = "commun"
booster = "Chemin perdu"
lastTurnAttack = 0;
is_player_card = true; // Définit explicitement cette carte comme appartenant au joueur
// Marqueur de capacité: empoisonneur
isPoisoner = true;
description = "Empoisonneur."

// Définition des effets via sTriggers/sEffects
effects = [];
array_push(effects, {
    id: 1,
    trigger: TRIGGER_AFTER_ATTACK,
    effect_type: EFFECT_DESTROY,
    // Label d'effet pour l'UI
    label: "empoisonneur",
    // Conditions: carte du héros sur le terrain, cible est un monstre et l'attaque est initiée par cette carte
    conditions: {
        owner: "Hero",
        zone: "Field",
        target_type: "Monster",
        attacker_is_self: true
    },
    // Destruction explicite de la cible survivante après combat
    select_mode: "target",
    target_zone: "Field",
    target_types: ["Monster"],
    // Demande une animation poison avant la destruction différée
    visual_fx: "poison",
});