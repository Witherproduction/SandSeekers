/// sSpellUtils.gml — Utilitaires pour la gestion des cartes Magie

/// @function consumeSpellIfNeeded(card, effect)
/// @description Si la carte est une Magie de genre "Direct" (non continue), l'envoyer au cimetière après la résolution de l'effet.
/// @returns {bool} - True si la carte a été envoyée au cimetière, sinon false
function consumeSpellIfNeeded(card, effect) {
    if (card == noone || !instance_exists(card)) return false;

    // Valider qu'il s'agit bien d'une carte Magie
    var isMagic = object_is_ancestor(card.object_index, oCardMagic) || (variable_instance_exists(card, "type") && string_lower(card.type) == "magic");
    if (!isMagic) return false;

    // Ne pas consommer les Magies continues ou les artefacts/équipements
    var isContinuous = (variable_instance_exists(card, "type") && string_lower(card.type) == "continuous") 
        || (is_struct(effect) && variable_struct_exists(effect, "trigger") && effect.trigger == TRIGGER_CONTINUOUS);
    var isArtifact = (variable_instance_exists(card, "genre") && string_lower(card.genre) == "artéfact");
    if (isContinuous || isArtifact) return false;

    // Consommer uniquement les sorts "Direct"
    var isDirect = (variable_instance_exists(card, "genre") && string_lower(card.genre) == "direct");
    if (!isDirect) return false;

    // Déterminer les instances utiles
    var ownerIsHero = (variable_instance_exists(card, "isHeroOwner") && card.isHeroOwner);
    var gyInst = ownerIsHero ? graveyardHero : graveyardEnemy;
    var handInst = ownerIsHero ? handHero : handEnemy;
    var fm = ownerIsHero ? fieldManagerHero : fieldManagerEnemy;

    // Retirer de la main si présent
    if (instance_exists(handInst)) {
        var idx = ds_list_find_index(handInst.cards, card);
        if (idx != -1) {
            ds_list_delete(handInst.cards, idx);
            if (variable_instance_exists(handInst, "updateDisplay")) { handInst.updateDisplay(); }
        }
    }

    // Retirer du terrain si nécessaire
    if (variable_instance_exists(card, "zone") && (card.zone == "Field" || card.zone == "FieldSelected")) {
        if (instance_exists(fm) && variable_instance_exists(card, "fieldPosition")) { fm.remove(card); }
    }

    // Ajouter au cimetière
    if (instance_exists(gyInst)) { gyInst.addToGraveyard(card); }
    if (instance_exists(card)) { card.zone = "Graveyard"; }

    // Déclencher l'événement d'entrée au cimetière
    if (instance_exists(card)) { registerTriggerEvent(TRIGGER_ENTER_GRAVEYARD, card, {}); }

    // Nettoyer les références de sélection si cette carte était sélectionnée
    if (instance_exists(oSelectManager) && oSelectManager.selected == card) {
        oSelectManager.unSelectAll();
    }

    // Ajouter l'animation de déchirure avant la destruction
    if (instance_exists(card)) {
        var fx = instance_create_layer(card.x, card.y, "Instances", FX_Destruction);
        if (fx != noone) {
            fx.spriteGhost   = card.sprite_index;
            fx.imageGhost    = card.image_index;
            fx.image_xscale  = card.image_xscale;
            fx.image_yscale  = card.image_yscale;
            fx.image_angle   = card.image_angle;
            fx.duration_ms   = 700;
            fx.sep_px        = 48;
            fx.strip_h       = 3;
            fx.ragged_amp_px = 6;
            fx.depth_override = -100000;
        }
    }

    // Détruire l'instance pour libérer les ressources (aligné sur la logique de défausse)
    if (instance_exists(card)) { instance_destroy(card); }

    return true;
}