event_inherited();  // Hérite des variables et comportement de oCardMagic

// Définit les stats spécifiques de ce sort
name = "Baguette de la Rose noire"
genre = "Artéfact"
archetype = "Rose noire"
rarity = "commun"
booster = "Chemin perdu"
is_player_card = true;

description = "Le monstre équipé gagne 500/500. S'il s'agit d'une Petite sorcière, sorcière, ou érudit de la Rose noire, alors gagne 500/500 supplémentaire."

effects = [];
array_push(effects, { trigger: TRIGGER_MAIN_PHASE, effect_type: EFFECT_EQUIP_SELECT_TARGET, ally_only: false, description: "Choisissez un monstre à équiper; posez cette carte." });
array_push(effects, { trigger: TRIGGER_CONTINUOUS, effect_type: EFFECT_BUFF, scope: "equip", aggregate: true, atk: 500, def: 500, extra_buff: 500, bonus_if_names: ["oPetiteSorciereDeLaRoseNoire", "oSorciereDeLaRoseNoire", "oEruditDeLaRoseNoire"], description: "Le monstre équipé gagne 500/500 (+500/500 si Rose noire)." });
array_push(effects, { trigger: TRIGGER_ON_DESTROY, effect_type: EFFECT_EQUIP_CLEANUP, description: "Réinitialise le monstre équipé et détache la cible." });

