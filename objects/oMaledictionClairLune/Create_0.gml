event_inherited();  // Hérite des variables et comportement de oCardMagic

// Définit les stats spécifiques de ce sort
name = "Malédiction de Clair-de-lune";
genre = "Continue";
archetype = "Neutre";
rarity = "commun";
booster = "Chemin perdu";
is_player_card = true;

description = "Réduit l'attaque de tous les monstres de 500. N'affecte pas les Bêtes. Tombe : Inflige 500 dégâts à votre adversaire pour chaque Bête allié sur le terrain.";

// === EFFETS DE LA CARTE ===
if (!variable_instance_exists(id, "effects")) effects = [];
effects[0] = {
    trigger: TRIGGER_CONTINUOUS,
    effect_type: EFFECT_AURA_ALL_MONSTERS_DEBUFF,
    atk: -500,
    def: 0,
    exclude_genres: ["Bête"],
    show_aura: true
};

effects[1] = {
    trigger: TRIGGER_LEAVE_FIELD,
    effect_type: EFFECT_AURA_CLEANUP_SOURCE
};

effects[2] = {
    trigger: TRIGGER_ON_DESTROY,
    effect_type: EFFECT_DAMAGE_OPP_PER_GENRE_ON_FIELD,
    genre: "Bête",
    damage_per_card: 500
};