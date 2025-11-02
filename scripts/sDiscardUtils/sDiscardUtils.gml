/// === sDiscardUtils ===
/// Utilitaires de défausse et cimetière

/// @function discardRandomFromHandToGraveyard(ownerIsHero)
/// @description Défausse une carte aléatoire de la main du propriétaire et l’envoie au cimetière
/// @param {bool} ownerIsHero - true pour héros, false pour ennemi
/// @returns {bool} - Succès
function discardRandomFromHandToGraveyard(ownerIsHero) {
    var handInst = ownerIsHero ? handHero : handEnemy;
    var gyInst = ownerIsHero ? graveyardHero : graveyardEnemy;

    if (!instance_exists(handInst) || !instance_exists(gyInst)) {
        show_debug_message("### discardRandomFromHandToGraveyard: instances introuvables");
        return false;
    }

    var nbCards = ds_list_size(handInst.cards);
    if (nbCards <= 0) {
        show_debug_message("### discardRandomFromHandToGraveyard: main vide, aucune défausse");
        return false;
    }

    // Choisir une carte aléatoire
    ds_list_shuffle(handInst.cards);
    var card = ds_list_find_value(handInst.cards, 0);
    if (card == noone || !instance_exists(card)) {
        show_debug_message("### discardRandomFromHandToGraveyard: carte invalide");
        return false;
    }

    var cname = (variable_instance_exists(card, "name") ? card.name : object_get_name(card.object_index));
    show_debug_message("### discardRandomFromHandToGraveyard: défausse " + cname + (ownerIsHero ? " (héros)" : " (ennemi)"));

    // Retirer de la main
    var idx = ds_list_find_index(handInst.cards, card);
    if (idx != -1) { ds_list_delete(handInst.cards, idx); }
    // NE PAS rafraîchir la main ici; on le fera à la fin de l’animation

    // FX: glissade fantôme vers le cimetière (sur le layer UI pour passer au-dessus de l'interface)
    var fx = instance_create_layer(card.x, card.y, "UI", oFX_Discard);
    if (fx != noone) {
        fx.spriteGhost   = card.sprite_index;
        fx.imageGhost    = card.image_index;
        fx.target_x      = gyInst.x;
        fx.target_y      = gyInst.y;
        fx.image_xscale  = card.image_xscale;
        fx.image_yscale  = card.image_yscale;
        fx.image_angle   = card.image_angle;
        fx.duration_ms   = 2100; // triple (~2.1s)
        fx.hand_to_update = handInst; // rafraîchir après animation
        fx.depth_override = -100000; // assure un ordre de dessin très au-dessus
    } else {
        // Fallback: si l’effet n’est pas créé, rafraîchir immédiatement
        if (variable_instance_exists(handInst, "updateDisplay")) { handInst.updateDisplay(); }
    }

    // Ajouter au cimetière et détruire l'instance
    gyInst.addToGraveyard(card);
    card.zone = "Graveyard";
    instance_destroy(card);

    return true;
}

/// @function discardFromHandToGraveyard(ownerIsHero, amount)
/// @description Défausse N cartes (droite de la main) du bon propriétaire vers son cimetière, avec FX.
/// @param {bool} ownerIsHero - true pour héros, false pour ennemi
/// @param {real} amount - nombre de cartes à défausser
/// @returns {bool} - Succès
function discardFromHandToGraveyard(ownerIsHero, amount) {
    var handInst = ownerIsHero ? handHero : handEnemy;
    var gyInst = ownerIsHero ? graveyardHero : graveyardEnemy;

    if (!instance_exists(handInst) || !instance_exists(gyInst)) {
        show_debug_message("### discardFromHandToGraveyard: instances introuvables");
        return false;
    }

    var nbCards = ds_list_size(handInst.cards);
    var toDiscard = min(amount, nbCards);
    if (toDiscard <= 0) {
        show_debug_message("### discardFromHandToGraveyard: main vide, aucune défausse");
        return false;
    }

    for (var i = 0; i < toDiscard; i++) {
        var idx = ds_list_size(handInst.cards) - 1;
        if (idx < 0) break;
        var card = ds_list_find_value(handInst.cards, idx);
        // Retirer immédiatement de la liste pour libérer la place
        ds_list_delete(handInst.cards, idx);
        if (card == noone || !instance_exists(card)) {
            continue;
        }

        // FX de défausse (comme discardRandom)
        var fx = instance_create_layer(card.x, card.y, "UI", oFX_Discard);
        if (fx != noone) {
            fx.spriteGhost   = card.sprite_index;
            fx.imageGhost    = card.image_index;
            fx.target_x      = gyInst.x;
            fx.target_y      = gyInst.y;
            fx.image_xscale  = card.image_xscale;
            fx.image_yscale  = card.image_yscale;
            fx.image_angle   = card.image_angle;
            fx.duration_ms   = 2100;
            fx.hand_to_update = handInst;
            fx.depth_override = -100000;
        } else {
            if (variable_instance_exists(handInst, "updateDisplay")) { handInst.updateDisplay(); }
        }

        // Mouvement logique vers le cimetière + trigger interne
        gyInst.addToGraveyard(card);
        card.zone = "Graveyard";
        instance_destroy(card);
    }

    return true;
}

function discardSpecificCardsToGraveyard(ownerIsHero, cardsList) {
    var handInst = ownerIsHero ? handHero : handEnemy;
    var gyInst = ownerIsHero ? graveyardHero : graveyardEnemy;

    if (!instance_exists(handInst) || !instance_exists(gyInst)) {
        show_debug_message("### discardSpecificCardsToGraveyard: instances introuvables");
        return false;
    }

    if (is_undefined(cardsList)) return false;

    var count = is_array(cardsList) ? array_length(cardsList) : ds_list_size(cardsList);
    for (var i = 0; i < count; i++) {
        var card = is_array(cardsList) ? cardsList[i] : ds_list_find_value(cardsList, i);
        if (card == noone || !instance_exists(card)) continue;

        var idx = ds_list_find_index(handInst.cards, card);
        if (idx == -1) continue;

        // Retirer immédiatement de la main pour libérer l'espace
        ds_list_delete(handInst.cards, idx);

        // FX de défausse
        var fx = instance_create_layer(card.x, card.y, "UI", oFX_Discard);
        if (fx != noone) {
            fx.spriteGhost   = card.sprite_index;
            fx.imageGhost    = card.image_index;
            fx.target_x      = gyInst.x;
            fx.target_y      = gyInst.y;
            fx.image_xscale  = card.image_xscale;
            fx.image_yscale  = card.image_yscale;
            fx.image_angle   = card.image_angle;
            fx.duration_ms   = 2100;
            fx.hand_to_update = handInst;
            fx.depth_override = -100000;
        } else {
            if (variable_instance_exists(handInst, "updateDisplay")) { handInst.updateDisplay(); }
        }

        // Mouvement logique vers le cimetière + triggers
        gyInst.addToGraveyard(card);
        card.zone = "Graveyard";
        instance_destroy(card);
    }

    return true;
}

/// @function discardFromHandToGraveyardExcludingCard(ownerIsHero, amount, excluded)
/// @description Défausse N cartes de la main du propriétaire vers son cimetière en excluant une carte précise (initiatrice), avec FX et triggers.
/// @param {real} amount - nombre de cartes à défausser
/// @param {instance} excluded - carte à ne pas défausser
/// @returns {bool} - Succès
function discardFromHandToGraveyardExcludingCard(ownerIsHero, amount, excluded) {
    var handInst = ownerIsHero ? handHero : handEnemy;
    var gyInst = ownerIsHero ? graveyardHero : graveyardEnemy;

    if (!instance_exists(handInst) || !instance_exists(gyInst)) {
        show_debug_message("### discardExcluding: instances introuvables");
        return false;
    }

    var nbCards = ds_list_size(handInst.cards);
    if (excluded != noone && instance_exists(excluded)) {
        // Compter sans la carte exclue
        var countWithoutExcluded = 0;
        for (var i = 0; i < nbCards; i++) {
            var c = ds_list_find_value(handInst.cards, i);
            if (c == noone || !instance_exists(c)) continue;
            if (c == excluded) continue;
            countWithoutExcluded++;
        }
        if (countWithoutExcluded <= 0) {
            show_debug_message("### discardExcluding: aucune carte à défausser en dehors de l’initiatrice");
            return false;
        }
    }

    var toDiscard = min(amount, nbCards);
    if (toDiscard <= 0) {
        show_debug_message("### discardExcluding: main vide, aucune défausse");
        return false;
    }

    // Parcours depuis la droite de la main; sauter la carte exclue
    var discarded = 0;
    var idx = ds_list_size(handInst.cards) - 1;
    while (discarded < toDiscard && idx >= 0) {
        var card = ds_list_find_value(handInst.cards, idx);
        idx--;
        if (card == noone || !instance_exists(card)) continue;
        if (excluded != noone && instance_exists(excluded) && card == excluded) continue;

        // Retirer immédiatement de la liste pour libérer la place
        var delIdx = ds_list_find_index(handInst.cards, card);
        if (delIdx != -1) { ds_list_delete(handInst.cards, delIdx); }

        // FX de défausse
        var fx = instance_create_layer(card.x, card.y, "UI", oFX_Discard);
        if (fx != noone) {
            fx.spriteGhost   = card.sprite_index;
            fx.imageGhost    = card.image_index;
            fx.target_x      = gyInst.x;
            fx.target_y      = gyInst.y;
            fx.image_xscale  = card.image_xscale;
            fx.image_yscale  = card.image_yscale;
            fx.image_angle   = card.image_angle;
            fx.duration_ms   = 2100;
            fx.hand_to_update = handInst;
            fx.depth_override = -100000;
        } else {
            if (variable_instance_exists(handInst, "updateDisplay")) { handInst.updateDisplay(); }
        }

        // Mouvement logique vers le cimetière + triggers
        gyInst.addToGraveyard(card);
        card.zone = "Graveyard";
        instance_destroy(card);
        discarded++;
    }

    return (discarded == toDiscard);
}