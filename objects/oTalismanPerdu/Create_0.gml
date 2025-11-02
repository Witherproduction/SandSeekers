event_inherited();  // Hérite des variables et comportement de oCardMagic

// Définit les stats spécifiques de ce sort
name = "Talisman perdu"
genre = "Artéfact"
archetype = "Rose noire"
rarity = "commun"
booster = "Chemin perdu"
is_player_card = true;

description = "Le monstre équipé perd 500 ATK."

effects = [];
array_push(effects, { trigger: TRIGGER_MAIN_PHASE, effect_type: EFFECT_EQUIP_SELECT_TARGET, ally_only: false, description: "Choisissez un monstre à équiper; posez cette carte." });
array_push(effects, { trigger: TRIGGER_CONTINUOUS, effect_type: EFFECT_EQUIP_APPLY_BUFF, atk_buff: -500, def_buff: 0, description: "Le monstre équipé perd 500 ATK." });
array_push(effects, { trigger: TRIGGER_ON_DESTROY, effect_type: EFFECT_EQUIP_CLEANUP, description: "Réinitialise le monstre équipé et détache la cible." });