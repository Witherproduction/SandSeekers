event_inherited();  // Hérite des variables et comportement de oCardMonster

// Définit les stats spécifiques de ce monstre
name = "Androïd nucléaire"
attack = 1000;
defense = 1000;
star = 2;
genre = "Méca"
archetype = "Robot d'assaut"
booster = "Usine robotique"
rarity = "commun"
lastTurnAttack = 0;
is_player_card = true; // Définit explicitement cette carte comme appartenant au joueur
description = "Empoisonneur. Perdu : Défausse une carte de votre adversaire."
isPoisoner = true;

if (!variable_instance_exists(id, "effects")) effects = [];
array_push(effects, {
    id: "android_nucleaire_perdu_discard_enemy",
    trigger: TRIGGER_ENTER_GRAVEYARD,
    effect_type: EFFECT_DISCARD,
    owner: "enemy",
    selection: { mode: "random", count: 1 }
});
