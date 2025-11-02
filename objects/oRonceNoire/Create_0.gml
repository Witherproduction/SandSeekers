event_inherited();  // Hérite des variables et comportement de oCardMagic

// Définit les stats spécifiques de ce sort
name = "La Ronce noire"
genre = "Secret"
archetype = "Rose noire"
rarity = "commun"
booster = "Chemin perdu"
is_player_card = true;

description = "S'active lorsque votre adversaire invoque un monstre. Réduit de 500 l'attaque du monstre invoqué."

// Effets
effects = [
    {
        // Activation automatique face cachée à l’invocation d’un monstre adverse
        secret_activation: { on_summon: true },
        // Cible: le monstre invoqué
        target_source: "summoned",
        // Type d’effet: perte permanente d’attaque
        effect_type: EFFECT_LOSE_ATTACK_PERMANENT,
        value: 500,
        // Texte court pour debug/clarification
        text: "Réduit de 500 l'attaque du monstre invoqué"
    }
];