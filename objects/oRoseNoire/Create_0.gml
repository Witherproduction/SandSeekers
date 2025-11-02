event_inherited();  // Hérite des variables et comportement de oCardMagic

// Définit les stats spécifiques de ce sort
name = "La Rose noire"
genre = "Artéfact"
archetype = "Rose noire"
rarity = "commun"
booster = "Chemin perdu"
is_player_card = true;

description = "Le monstre équipé gagne 1000ATK. Tombe : Ajoute une carte La Rose noire depuis votre deck à votre main."

effects = [];
array_push(effects, { trigger: TRIGGER_MAIN_PHASE, effect_type: EFFECT_EQUIP_SELECT_TARGET, ally_only: false, description: "Choisissez un monstre à équiper; posez cette carte." });
array_push(effects, { trigger: TRIGGER_CONTINUOUS, effect_type: EFFECT_EQUIP_APPLY_BUFF, atk_buff: 1000, def_buff: 0, description: "Le monstre équipé gagne 1000 ATK." });
array_push(effects, { trigger: TRIGGER_ON_DESTROY, effect_type: EFFECT_EQUIP_CLEANUP, description: "Réinitialise le monstre équipé et détache la cible." });
array_push(effects, { trigger: TRIGGER_ON_DESTROY, effect_type: EFFECT_SEARCH, search_criteria: { name: "La Rose noire", type: "Magic" }, description: "Ajoute 'La Rose noire' du deck à la main." });