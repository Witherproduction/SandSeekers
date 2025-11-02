event_inherited();  // Hérite des variables et comportement de oCardMagic

// Définit les stats spécifiques de ce sort
name = "Blessure infectée"
genre = "Secret"
archetype = "Neutre"
rarity = "commun"
booster = "Chemin perdu"
is_player_card = true;

description = "S'active lorsque votre adversaire attaque un monstre allié. Inflige des dégâts à votre adversaire égaux à la moitié de l'ATK du serviteur adverse.";

// Effet: sur attaque adverse contre un monstre allié, inflige moitié de l'ATK de l’attaquant
if (!variable_instance_exists(id, "effects")) effects = [];
array_push(effects, {
    id: 1,
    trigger: TRIGGER_ON_ATTACK,
    effect_type: EFFECT_LOSE_LP,
    secret_activation: { on_attack: true },
    use_attacker_attack_as_value: true,
    attack_value_divisor: 2,
    affect_opponent_lp: true,
    description: "Secret: quand l’adversaire attaque un allié, inflige moitié de l’ATK de l’attaquant."
});