event_inherited();  // Hérite des variables et comportement de oCardMagic

// Définit les stats spécifiques de ce sort
name = "Maladie de la Ronce noire"
genre = "Secret"
archetype = "Rose noire"
rarity = "commun"
booster = "Chemin perdu"
is_player_card = true;

description = "S'active lorsque l'adversaire declenche une attaque. Le monstre attaquant perd 1000 ATK (permanent).";

// === EFFETS DE LA CARTE ===
// Secret: s'active sur toute attaque déclarée par l'adversaire; applique -1000 ATK permanent à l'attaquant
effects[0] = {
    effect_type: EFFECT_LOSE_ATTACK_PERMANENT,
    value: 1000,
    secret_activation: { on_attack: true },
    target_source: "attacker"
};