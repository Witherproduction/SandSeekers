event_inherited();  // Hérite des variables et comportement de oCardMonster

// Définit les stats spécifiques de ce monstre
name = "Squelette possédé par la Rose noire"
attack = 1000;
defense = 1000;
star = 1; // Niveau 1 - pas de sacrifice requis pour l'invocation
lastTurnAttack = 0;
genre = "Mort-vivant"
archetype = "Rose noire"
rarity = "commun"
is_player_card = true; // Définit explicitement cette carte comme appartenant au joueur

// Description de la carte
// Quand cette carte est envoyée au Cimetière, Invoquez un Jeton Rose noire en Attaque.
description = "Tombe : Invoquez un Jeton 'Rose noire'."

// Effet Tombe : Invoque un Jeton Rose noire quand détruit
if (!variable_instance_exists(id, "effects")) effects = [];
array_push(effects, {
    id: "squelette_rose_token_on_destroy",
    trigger: TRIGGER_ON_DESTROY,
    effect_type: EFFECT_SUMMON,
    summon_mode: "token",
    token_data: { token_object: "oJetonRoseNoire", name: "Jeton Rose noire", archetype: "Rose noire" },
    description: "Quand cette carte est détruite : Invoquez spécialement 1 Jeton 'Rose noire' en mode Attaque sur votre Terrain."
});