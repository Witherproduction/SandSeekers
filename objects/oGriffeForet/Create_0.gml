event_inherited();  // Hérite des variables et comportement de oCardMagic

// Définit les stats spécifiques de ce sort
name = "Griffe de la forêt"
genre = "Artéfact"
archetype = "Neutre"
rarity = "commun"
booster = "Chemin perdu"
is_player_card = true;

description = "Ne peut être équiper uniquement sur un Dragon. Il gagne 100ATK pour chaque Dragon dans votre cimetière."

effects = [];
array_push(effects, { trigger: TRIGGER_MAIN_PHASE, effect_type: EFFECT_EQUIP_SELECT_TARGET, allowed_genres: ["Dragon"], ally_only: false, description: "Choisissez un Dragon à équiper; posez cette carte." });
array_push(effects, { trigger: TRIGGER_CONTINUOUS, effect_type: EFFECT_BOOST_ATK_PER_GRAVEYARD_GENRE, genre: "Dragon", boost_per_card: 100, description: "Le Dragon équipé gagne +100 ATK pour chaque Dragon dans votre cimetière." });
array_push(effects, { trigger: TRIGGER_ON_DESTROY, effect_type: EFFECT_EQUIP_CLEANUP, description: "Réinitialise le monstre équipé et détache la cible." });