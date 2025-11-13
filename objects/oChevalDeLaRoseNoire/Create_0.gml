event_inherited();  // Hérite des variables et comportement de oCardMonster

// Définit les stats spécifiques de ce monstre
name = "Cheval de la Rose Noire"
attack = 1000;
defense = 1000;
star = 1;
genre = "Bête"
archetype = "Rose noire"
rarity = "commun"
lastTurnAttack = 0;
is_player_card = true; // Définit explicitement cette carte comme appartenant au joueur
description = "Si vous avez un monstre Rose noire sur le terrain, vous pouvez invoquer cette carte depuis votre main."

// Effet : invocation spéciale depuis la main pendant la phase principale si un monstre "Rose noire" est contrôlé
effects = [
    {
        id: 1,
        trigger: TRIGGER_MAIN_PHASE,
        effect_type: EFFECT_SUMMON,
    summon_mode: "self",
        conditions: {
            owner: "Hero",
            zone: "Hand",
            has_archetype_on_field: "Rose noire"
        }
    }
];