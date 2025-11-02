event_inherited();  // Hérite des variables et comportement de oCardMonster

// Définit les stats spécifiques de ce monstre
name = "Sorcière de la forêt"
attack = 1000;
defense = 1000;
star = 1;
genre = "Humanoïde"
archetype = "Neutre"
booster = "Chemin perdu"
rarity = "commun"
lastTurnAttack = 0;
is_player_card = true; // Définit explicitement cette carte comme appartenant au joueur
description = "Initialisation : Ajoute un sort de votre deck à votre main."

// Effet d'initialisation : chercher un sort dans le deck
effects[0] = {
    trigger: TRIGGER_START_TURN,
    effect_type: EFFECT_SEARCH,
    search_type: "Magic",
    random_select: true
};
