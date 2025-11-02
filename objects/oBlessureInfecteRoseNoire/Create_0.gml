event_inherited();  // Hérite des variables et comportement de oCardMagic

// Définit les stats spécifiques de ce sort
name = "Blessure infecté par la Rose noire"
genre = "Secret"
archetype = "Rose noire"
rarity = "commun"
booster = "Chemin perdu"
is_player_card = true;

description = "S'active lorsque votre adversaire attaque directement. Inflige à votre adversaire un montant de dégâts égal à l'ATK du monstre.";

// Déclare l'effet spécifique, lu par sMagicSecret
effects = [
    {
        id: 1,
        trigger: TRIGGER_ON_ATTACK,
        effect_type: EFFECT_LOSE_LP,
        secret_activation: { direct_attack: true },
        use_attacker_attack_as_value: true,
        affect_opponent_lp: true,
        description: "Secret: sur attaque directe adverse, inflige des dégâts égaux à l'ATK de l'attaquant."
    }
];

