show_debug_message("### oHand.create");

///////////////////////////////////////////////////////////////////////
// Attributs
///////////////////////////////////////////////////////////////////////

cards = ds_list_create();

///////////////////////////////////////////////////////////////////////
// Methodes
///////////////////////////////////////////////////////////////////////

#region Function updateDisplay
updateDisplay = function() {
    show_debug_message("### oHand.updateDisplay");
    
    var cardWidth = 122.93;
    var spaceBetweenCards = 20;
    var nbCards = ds_list_size(cards);
    
    if(nbCards <= 5) {
        var contentWidth = nbCards * cardWidth + (nbCards - 1) * spaceBetweenCards;
        var offset = cardWidth / 2 + contentWidth / -2;
    }
    else {
        var posXStart = 613;
        var posXEnd = 1307;
        var contentWidth = posXEnd - posXStart;
        var distanceBetweenCards = contentWidth / (nbCards - 1);
    }
    
    for (var i = 0; i < nbCards; i++) {
        var card = ds_list_find_value(cards, i);
        
        // Verifier que la carte est valide
        if (card == noone || !instance_exists(card)) {
            show_debug_message("### oHand.updateDisplay - Error: Invalid card at index " + string(i));
            continue;
        }
        
        card.zone = "Hand";
        card.image_angle = 0;
        if(nbCards <= 5)
            card.x = x + offset + i * cardWidth + i * spaceBetweenCards;
        else {
            card.x = posXStart + distanceBetweenCards * i;
        }
        card.y = y;
        card.image_index = !isHeroOwner;  // Affiche dos de la carte si ennemi
    }
}
#endregion

#region Function summon
summon = function(card, XYPos, desiredOrientation = "") {
    show_debug_message("### oHand.summon");
	show_debug_message("SummonMode: " + string(UIManager.selectedSummonOrSet));
    show_debug_message("Card type: " + card.type);

    // Résoudre le mode d'invocation même côté IA (UIManager peut être vide)
    var mode_resolved = UIManager.selectedSummonOrSet;
    var isSecret = (!is_undefined(card.genre) && card.genre == "Secret");
    if (is_undefined(mode_resolved) || string(mode_resolved) == "") {
        if (isHeroOwner) {
            // Côté joueur: fallback simple si vide
            if (card.type == "Monster") {
                mode_resolved = (desiredOrientation == "Defense") ? "Set" : "Summon";
            } else if (card.type == "Magic") {
                mode_resolved = isSecret ? "Set" : "Summon";
            } else {
                mode_resolved = "Summon";
            }
        } else {
            // Côté IA: déduire le mode d'après le type et desiredOrientation
            if (card.type == "Monster") {
                mode_resolved = (desiredOrientation == "Defense") ? "Set" : "Summon";
            } else if (card.type == "Magic") {
                mode_resolved = isSecret ? "Set" : "Summon";
            } else {
                mode_resolved = "Summon";
            }
        }
    }
    show_debug_message("SummonMode (resolved): " + string(mode_resolved));

    // Cible
    var target_x = XYPos[0];
    var target_y = XYPos[1];
    var target_pos = XYPos[2];

    // Vérification du terrain et réservation immédiate du slot pour éviter les empilements
    var fieldMgrSummon = isHeroOwner ? fieldManagerHero : fieldManagerEnemy;
    if (fieldMgrSummon == noone || !instance_exists(fieldMgrSummon)) {
        show_debug_message("### oHand.summon - Erreur: fieldManager introuvable");
        return false;
    }
    var fieldTarget = fieldMgrSummon.getField(card.type);
    if (fieldTarget == noone || !instance_exists(fieldTarget) || !variable_struct_exists(fieldTarget, "cards")) {
        show_debug_message("### oHand.summon - Erreur: champ introuvable pour type=" + string(card.type));
        return false;
    }
    if (target_pos < 0 || target_pos >= array_length(fieldTarget.cards)) {
        show_debug_message("### oHand.summon - Erreur: position cible hors limites: " + string(target_pos));
        return false;
    }
    if (fieldTarget.cards[target_pos] != 0) {
        show_debug_message("### oHand.summon - Slot déjà occupé, annulation de la pose");
        return false;
    }
    // Réserver le slot tout de suite pour bloquer les poses simultanées sur la même case
    card.fieldPosition = target_pos;
    fieldMgrSummon.add(card);

    // Retire la carte de la main du joueur (immédiat pour libérer l'espace visuel)
    var idx = ds_list_find_index(cards, card);
    if (idx != -1) {
        ds_list_delete(cards, idx);
    }
    updateDisplay();

    // Cache la carte réelle pendant l'animation
    card.visible = false;

    // Déterminer l'orientation/face du fantôme selon le mode et le camp
    var ghost_angle = 0;
    var ghost_index = card.image_index;
    if (isHeroOwner) {
        if (card.type == "Monster" && mode_resolved == "Set") {
            ghost_angle = -90;
            ghost_index = 1; // face cachée
        }
        else if (card.type == "Monster" && (mode_resolved == "Summon" || mode_resolved == "SpecialSummon")) {
            ghost_angle = 0;
            ghost_index = 0; // face visible
        }
        else if (card.type == "Magic" && mode_resolved == "Set") {
            ghost_angle = 0;
            ghost_index = 1; // face cachée
        }
        else if (card.type == "Magic" && mode_resolved == "Summon") {
            ghost_angle = 0;
            ghost_index = 0; // face visible
        }
    } else {
        if (desiredOrientation == "Defense") {
            ghost_angle = 270; // 180° (retourne) + 90° (défense)
            ghost_index = 1; // face cachée
        } else if (card.type == "Magic" && isSecret && mode_resolved == "Set") {
            // Secret ennemi posé face cachée
            ghost_angle = 180; // rangée magie ennemi
            ghost_index = 1; // face cachée
        } else {
            ghost_angle = 180; // attaque côté ennemi
            ghost_index = 0; // face visible
        }
    }

    // Crée l'effet d'invocation (glissade vers le terrain) sur le layer UI
    var fx = instance_create_layer(card.x, card.y, "UI", FX_Invocation);
    if (fx != noone) {
        fx.spriteGhost         = card.sprite_index;
        fx.imageGhost          = ghost_index;
        fx.image_angle         = ghost_angle;
        fx.image_xscale        = card.image_xscale;
        fx.image_yscale        = card.image_yscale;
        fx.target_x            = target_x;
        fx.target_y            = target_y;
        fx.field_position      = target_pos;
        fx.duration_ms         = 200;   // 0,2s de déplacement
        fx.post_fx_duration_ms = 400;   // 0,4s de post-effet (total ~0,6s)
        fx.card_real           = card;
        fx.owner_is_hero       = isHeroOwner;
        fx.summon_mode         = mode_resolved;
        fx.card_type           = card.type;
        fx.desired_orientation = desiredOrientation;
        // Surcharges d'apparence (doré brillant + lignes plus fines + nœuds réduits)
         fx.col_main            = make_color_rgb(255, 215, 0);
         fx.trace_thickness     = 2;
         fx.node_radius         = 4;
        // Démarrage réussi: retourner true immédiatement
        return true;
    } else {
        // Fallback en cas d'échec de création de l'effet: placement instantané
        card.x = target_x;
        card.y = target_y;
        // Le slot a déjà été réservé ci-dessus; réaffectation prudente
        card.fieldPosition = target_pos;
        fieldMgrSummon.add(card);

        // Mise à l'échelle/zone
        card.image_xscale = 0.275;
        card.image_yscale = 0.275;
        card.zone = "Field";
        card.depth = 0;

        // Orientation/face selon camp et mode
        if (isHeroOwner) {
            if (card.type == "Monster" && mode_resolved == "Set") {
                card.orientation = "Defense";
                card.image_angle = -90;
                card.image_index = 1;
                card.isFaceDown = true;
            }
            else if (card.type == "Monster" && (mode_resolved == "Summon" || mode_resolved == "SpecialSummon")) {
                card.orientation = "Attack";
                card.image_angle = 0;
                card.image_index = 0;
                card.isFaceDown = false;
            }
            else if (card.type == "Magic" && mode_resolved == "Set") {
                card.orientation = "Attack";
                card.image_angle = 0;
                card.image_index = 1;
                card.isFaceDown = true;
            }
            else if (card.type == "Magic" && mode_resolved == "Summon") {
                card.orientation = "Attack";
                card.image_angle = 0;
                card.image_index = 0;
                card.isFaceDown = false;
            }
        } else {
            if (desiredOrientation == "Defense") {
                card.orientation = "Defense";
                card.image_angle = 270;
                card.image_index = 1;
                card.isFaceDown = true;
            } else if (card.type == "Magic" && isSecret && mode_resolved == "Set") {
                // Secret ennemi posé face cachée
                card.orientation = "Attack";
                card.image_angle = 180;
                card.image_index = 1;
                card.isFaceDown = true;
            } else {
                card.orientation = "Attack";
                card.image_angle = 180;
                card.image_index = 0;
                card.isFaceDown = false;
            }
        }

        card.visible = true;

        // Verrou: un monstre invoqué ne peut pas changer de position ce tour
        if (card.type == "Monster") {
            card.orientationChangedThisTurn = true;
            // Émettre l’événement d’invocation de monstre en fallback sans FX
            var ctxSummon = { summon_mode: mode_resolved, owner_is_hero: isHeroOwner };
            if (mode_resolved == "Summon" || mode_resolved == "SpecialSummon") {
                registerTriggerEvent(TRIGGER_ON_MONSTER_SUMMON, card, ctxSummon);
            }
        }
        // Fallback réussi: retourner true
        return true;
    }
    // Si on atteint ce point, considérer l'opération comme réussie
    return true;
}
#endregion

#region Function addCard
addCard = function(card, suppress_update) {
    show_debug_message("### oHand.addCard");
    
    if (is_undefined(suppress_update)) suppress_update = false;

    // Verifier que la carte est valide
    if (card == noone || !instance_exists(card)) {
        show_debug_message("### oHand.addCard - Error: Invalid card instance");
        return;
    }
    
    ds_list_add(cards, card);
    if (!suppress_update) {
        updateDisplay();
    }	
}
#endregion

#region Function chooseCardIA
chooseCardIA = function() {
    show_debug_message("### oHand.chooseCardIA");
    
    ds_list_shuffle(cards);
    
    for(var i = 0; i < ds_list_size(cards); i++) {
        var item = ds_list_find_value(cards, i);
        if(item.type == "Monster")
            return item;
    }
    return noone;
}
#endregion
