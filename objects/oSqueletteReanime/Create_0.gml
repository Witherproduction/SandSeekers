event_inherited();  // Hérite des variables et comportement de oCardMonster

// Définit les stats spécifiques de ce monstre
name = "Squelette réanimé"
attack = 500;
defense = 500;
star = 1;
genre = "Mort-vivant"
archetype = "Neutre"
booster = "Chemin perdu"
rarity = "commun"
lastTurnAttack = 0;
is_player_card = true; // Définit explicitement cette carte comme appartenant au joueur
description = "Tombe : Invoque un jeton squelette qui est détruit à la fin du tour."

// Effet Tombe : Invoque un jeton squelette quand détruit
if (!variable_instance_exists(id, "effects")) effects = [];
array_push(effects, {
    id: "squelette_token_on_destroy",
    trigger: TRIGGER_ON_DESTROY,
    effect_type: EFFECT_SUMMON,
    summon_mode: "token",
    token_data: { token_object: "oJetonSquelette", name: "Jeton Squelette", archetype: "Neutre" },
    description: "Quand cette carte est détruite : Invoquez spécialement 1 Jeton Squelette en mode Attaque sur votre Terrain."
});
