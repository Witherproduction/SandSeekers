event_inherited();  // Hérite des variables et comportement de oCardMonster

// Définit les stats spécifiques de ce monstre
name = "Petite sorcière de la forêt"
attack = 500;
defense = 500;
star = 1;
genre = "Humanoïde"
archetype = "Neutre"
booster = "Chemin perdu"
rarity = "commun"
lastTurnAttack = 0;
is_player_card = true; // Définit explicitement cette carte comme appartenant au jouneur
description = "Initialisation : Ajoute une Bête de votre deck à votre main."

// Effet de début de tour : chercher une Bête dans le deck
effects[0] = {
    trigger: TRIGGER_START_TURN,
    effect_type: EFFECT_SEARCH,
    search_genre: "Bête",
    random_select: true
};
