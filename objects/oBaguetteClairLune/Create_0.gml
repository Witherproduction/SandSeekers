event_inherited();  // Hérite des variables et comportement de oCardMagic

// Définit les stats spécifiques de ce sort
name = "Baguette de Clair-de-lune"
genre = "Artéfact"
archetype = "Neutre"
rarity = "commun"
booster = "Chemin perdu"
is_player_card = true;

description = "Ne peut être équipé uniquement sur un Humanoïde ou une Bête. Le monstre équipé gagne 500/500"

effects = [];
array_push(effects, { trigger: TRIGGER_MAIN_PHASE, effect_type: EFFECT_EQUIP_SELECT_TARGET, allowed_genres: ["Humanoïde", "Bête"], ally_only: false, description: "Choisissez un Humanoïde ou une Bête à équiper; posez cette carte." });
array_push(effects, { trigger: TRIGGER_CONTINUOUS, effect_type: EFFECT_BUFF, scope: "equip", aggregate: true, atk: 500, def: 500, description: "Le monstre équipé gagne +500 ATK et +500 DEF." });
array_push(effects, { trigger: TRIGGER_ON_DESTROY, effect_type: EFFECT_EQUIP_CLEANUP, description: "Réinitialise le monstre équipé et détache la cible." });