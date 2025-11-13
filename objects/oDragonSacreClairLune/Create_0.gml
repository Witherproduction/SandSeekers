event_inherited();  // Hérite des variables et comportement de oCardMonster

// Définit les stats spécifiques de ce monstre
name = "Dragon sacré de Claire-de-lune"
attack = 1500;
defense = 1000;
star = 2;
genre = "Dragon"
archetype = "Neutre"
booster = "Chemin perdu"
rarity = "commun"
lastTurnAttack = 0;
is_player_card = true; // Définit explicitement cette carte comme appartenant au joueur
description = "Lorsqu'un monstre dragon est perdu, invoque ce monstre depuis votre main.";

// Effet : depuis la main, quand un Dragon est envoyé au cimetière, invoque spécialement cette carte
effects = [
    {
        id: 1,
        trigger: TRIGGER_ON_MONSTER_SENT_TO_GRAVEYARD,
        effect_type: EFFECT_SUMMON,
        summon_mode: "self",
        auto_select_leftmost: true,
        description: "Quand un Dragon est envoyé au cimetière : Invoquez spécialement cette carte depuis votre main.",
        conditions: {
            zone: "Hand",
            target_type: "Monster",
            target_genre: "Dragon",
            ignore_when_sacrifice: true,
            ignore_when_discard: true
        }
    }
];
