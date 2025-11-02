event_inherited();  // Hérite des variables et comportement de oCardMagic

// Définit les stats spécifiques de ce sort
name = "Ecaille dans la forêt"
genre = "Secret"
archetype = "Neutre"
rarity = "commun"
booster = "Chemin perdu"
is_player_card = true;

description = "S'active lorsque votre adversaire attaque directement. Invoque un dragon de niveau 1 sur votre terrain depuis le deck. Il devient la nouvelle cible de l'attaque.";

// Effet : sur attaque directe adverse, invoque un Dragon niv.1 depuis le deck
// et redirige l'attaque vers ce monstre invoqué
effects = [
    {
        effect_type: EFFECT_SUMMON,
    summon_mode: "named",
        criteria: { type: "Monster", genre: "Dragon", star_eq: 1 },
        allowed_sources: ["Deck"],
        secret_activation: { direct_attack: true },
        redirect_attack_to_summoned: true,
        random_select: true
    }
];