event_inherited();  // Hérite des variables et comportement de oCardMonster

// Définit les stats spécifiques de ce monstre
name = "Chien d'opération de soutien"
attack = 500;
defense = 500;
star = 1;
genre = "Méca"
archetype = "Robot d'assaut"
booster = "Usine robotique"
rarity = "commun"
lastTurnAttack = 0;
is_player_card = true; // Définit explicitement cette carte comme appartenant au joueur
description = "Appel : Augmente de 500 l'ATK et la DEF d'un Méca allié."

if (!variable_instance_exists(id, "effects")) effects = [];
array_push(effects, {
    id: "chien_soutien_buff_meca_on_summon",
    trigger: TRIGGER_ON_SUMMON,
    effect_type: EFFECT_BUFF,
    scope: "single",
    owner: "ally",
    criteria: { type: "Monster", genre: "Méca" },
    atk: 500,
    def: 500
});
