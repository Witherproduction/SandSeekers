event_inherited();  // Hérite des variables et comportement de oCardMonster

// Définit les stats spécifiques de ce monstre
name = "Cheval des forêts"
attack = 1000;
defense = 1000;
star = 1;
genre = "Bête"
archetype = "Neutre"
booster = "Chemin perdu"
rarity = "commun"
lastTurnAttack = 0;
is_player_card = true; // Définit explicitement cette carte comme appartenant au joueur
description = "Si vous avez un monstre bête sur le terrain, vous pouvez invoquez cette carte depuis votre main."

// Ajout de l'effet d'invocation spéciale depuis la main si une Bête est sur le terrain
effects = [
    {
        effect_type: EFFECT_SUMMON,
        summon_mode: "self",
        trigger: TRIGGER_MAIN_PHASE,
        description: "Si vous avez une Bête sur le terrain : Invoquez spécialement cette carte depuis votre main.",
        conditions: {
            zone: "Hand",
            has_genre_on_field: "Bête"
        }
    }
];
