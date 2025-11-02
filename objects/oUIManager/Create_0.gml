show_debug_message("### oUIManager.create")

// Initialiser le flag global d'overlay d'action
global.isActionMenuOpen = false;

///////////////////////////////////////////////////////////////////////
// Attributs
///////////////////////////////////////////////////////////////////////

//selected = "";
selectedSummonOrSet = "";
instanceSummon = "";
instanceSet = "";
instancePositionButton = "";
instanceAttackButton = "";
instanceEffectButton = "";


///////////////////////////////////////////////////////////////////////
// Méthodes
///////////////////////////////////////////////////////////////////////

//----------------------------------
// Summon et Set
//----------------------------------

#region Function displaySummonSetAction
displaySummonSetAction = function(card) {show_debug_message("### oUIManager.displaySummonSetAction")

    // Nettoyer tout ancien bouton avant de créer de nouveaux
    if (instanceSummon != "" && instance_exists(instanceSummon)) { instance_destroy(instanceSummon); instanceSummon = ""; }
    if (instanceSet != "" && instance_exists(instanceSet)) { instance_destroy(instanceSet); instanceSet = ""; }
    if (instanceEffectButton != "" && instance_exists(instanceEffectButton)) { instance_destroy(instanceEffectButton); instanceEffectButton = ""; }

    // Montrer Summon/Set uniquement pour les monstres et si l'invocation normale est possible
    var canNormalSummon = false;
    if (card != noone && instance_exists(card)) {
        if (card.type == "Monster") {
            canNormalSummon = (game.phase[game.phase_current] == "Summon"
                               && game.player[game.player_current] == "Hero"
                               && !game.hasSummonedThisTurn[0]);
        }
    }

    if (canNormalSummon) {
        instanceSummon = instance_create_layer(card.x - 100, card.y - 280, layer_get_id("Instances"), oSummon);
        instanceSummon.depth = -2000;
        instanceSet = instance_create_layer(card.x - 10, card.y - 280, layer_get_id("Instances"), oSet);
        instanceSet.depth = -2000;
        instanceSummon.image_xscale = 0.5;
        instanceSummon.image_yscale = 0.5;
        instanceSet.image_xscale = 0.5;
        instanceSet.image_yscale = 0.5;
    }

    // Actions pour les cartes Magie en main (Set + Effet)
    if (card != noone && instance_exists(card) && card.type == "Magic") {
        var canSetSpell = (game.phase[game.phase_current] == "Summon" && game.player[game.player_current] == "Hero");
        if (canSetSpell) {
            instanceSet = instance_create_layer(card.x - 10, card.y - 280, layer_get_id("Instances"), oSet);
            instanceSet.depth = -2000;
            instanceSet.image_xscale = 0.5;
            instanceSet.image_yscale = 0.5;
        }
        // Centraliser l'affichage du bouton effet selon les règles courantes
        UIManager.displayEffectButton(card);
    }

    // Bouton effet pour cartes non-Magie en main si disponible
    if (card != noone && instance_exists(card) && card.type != "Magic") {
        var effectOther = getAvailableEffect(card);
        if (effectOther != noone) {
            instanceEffectButton = instance_create_layer(card.x + 80, card.y - 280, layer_get_id("Instances"), oEffectButton);
            instanceEffectButton.parentCard = card;
            instanceEffectButton.depth = -2000;
            instanceEffectButton.image_xscale = 0.6;
            instanceEffectButton.image_yscale = 0.6;
        }
    }
    
    // Activer le blocage des clics sur le terrain tant que des boutons sont visibles
    if (instanceSummon != "" || instanceSet != "" || instanceEffectButton != "") {
        global.isActionMenuOpen = true;
    }
}
#endregion


#region Function hideSummonAndSet
hideSummonAndSet = function() {show_debug_message("### oUIManager.hideSummonAndSet")

    // Cache le bouton Summon
    if(instanceSummon != "") {
        instance_destroy(instanceSummon);
        instanceSummon = "";
    }
    // Cache le bouton Set
    if(instanceSet != "") {
        instance_destroy(instanceSet);
        instanceSet = "";
    }
    // Cache le bouton d'effet
    if(instanceEffectButton != "") {
        instance_destroy(instanceEffectButton);
        instanceEffectButton = "";
    }

    // Déverrouillage différé: géré dans Step_0 (évite le clic traversant)
    // Ne pas modifier global.isActionMenuOpen ici
}
#endregion

#region Function displayPositionButton
displayPositionButton = function(card) {show_debug_message("### oUIManager.displayPositionButton")
	
	instancePositionButton = instance_create_layer(card.x + 10, card.y - 175, layer_get_id("Instances"), oPositionButton);
	instancePositionButton.parentCard = card;
	instancePositionButton.depth = -2000;
	
	// Activer le blocage pendant l'affichage du bouton de position
	global.isActionMenuOpen = true;
}
#endregion

#region Function hidePositionButton
hidePositionButton = function() {show_debug_message("### oUIManager.hidePositionButton")
	
	// Cache le bouton Position
	if(instancePositionButton != "") {
		instance_destroy(instancePositionButton);
		instancePositionButton = "";
	}
	
	// Déverrouillage différé: géré dans Step_0
	// Ne pas modifier global.isActionMenuOpen ici
}
#endregion

#region Function displayAttackButton
displayAttackButton = function(card) {show_debug_message("### oUIManager.displayAttackButton")
    // Garde phase/joueur/type/zone/orientation pour éviter l'affichage sur des cartes non éligibles
    if (!(instance_exists(game) && game.player[game.player_current] == "Hero" && game.phase[game.phase_current] == "Attack")) {
        show_debug_message("### UIManager.displayAttackButton: hors phase Attack ou pas tour du héros");
        return;
    }
    // Règle: pas d'attaque au tour 1 du duel
    if (variable_instance_exists(game, "nbTurn") && game.nbTurn == 1) {
        show_debug_message("### UIManager.displayAttackButton: Attaque interdite au tour 1 -> bouton non affiché");
        return;
    }
    if (card == noone || !instance_exists(card)) {
        show_debug_message("### UIManager.displayAttackButton: carte invalide");
        return;
    }
    if (!(variable_instance_exists(card, "type") && card.type == "Monster")) {
        show_debug_message("### UIManager.displayAttackButton: carte non-monstre -> bouton non affiché");
        return;
    }
    if (!(variable_instance_exists(card, "isHeroOwner") && card.isHeroOwner)) {
        show_debug_message("### UIManager.displayAttackButton: carte non-héros -> bouton non affiché");
        return;
    }
    if (!(variable_instance_exists(card, "zone") && (card.zone == "Field" || card.zone == "FieldSelected"))) {
        show_debug_message("### UIManager.displayAttackButton: carte hors terrain -> bouton non affiché");
        return;
    }
    if (!(variable_instance_exists(card, "orientation") && card.orientation == "Attack")) {
        show_debug_message("### UIManager.displayAttackButton: carte non orientée en Attaque -> bouton non affiché");
        return;
    }

    // Ne pas afficher si le monstre a déjà attaqué ce tour
    if (instance_exists(game) && variable_instance_exists(game, "nbTurn") && variable_instance_exists(card, "lastTurnAttack")) {
        if (card.lastTurnAttack >= game.nbTurn) {
            show_debug_message("### UIManager.displayAttackButton: monstre a déjà attaqué ce tour -> bouton non affiché");
            return;
        }
    }

    // Cache le bouton précédent s'il existe
    if(instanceAttackButton != "") {
        instance_destroy(instanceAttackButton);
    }
    
    // Calcule la hauteur de la carte sur le terrain pour positionner le bouton au-dessus
    var sprite_h = sprite_get_height(card.sprite_index) * card.image_yscale;
    
    // Place le bouton au-dessus de la carte sur le terrain
    instanceAttackButton = instance_create_layer(card.x, card.y - sprite_h/2 - 60, layer_get_id("Instances"), oAttack);
    instanceAttackButton.parentCard = card;
    instanceAttackButton.depth = -2000;
    instanceAttackButton.visible = true;
    instanceAttackButton.image_alpha = 1.0;
    
    // Activer le blocage pendant l'affichage du bouton d'attaque
    global.isActionMenuOpen = true;
    
}
#endregion

#region Function displayEffectButton
// Affiche le bouton effet uniquement si un effet manuel disponible
// et nettoie tout bouton résiduel si aucun effet n’est disponible
displayEffectButton = function(card) {show_debug_message("### oUIManager.displayEffectButton")
    // Nettoyer tout ancien bouton effet
    if (instanceEffectButton != "" && instance_exists(instanceEffectButton)) {
        instance_destroy(instanceEffectButton);
        instanceEffectButton = "";
    }

    // Vérifier la disponibilité d'un effet manuel
    if (card != noone && instance_exists(card)) {
        // Règle UI: les cartes de genre "Secret" n'affichent jamais le bouton effet
        if (variable_instance_exists(card, "genre") && string_lower(card.genre) == string_lower("Secret")) {
            show_debug_message("### oUIManager.displayEffectButton: carte Secret -> bouton effet masqué");
            return;
        }

        // États utiles
        var isFD = (variable_instance_exists(card, "isFaceDown") && card.isFaceDown);
        var isOnField = (variable_instance_exists(card, "zone") && (card.zone == "Field" || card.zone == "FieldSelected"));
        var isInHand = (variable_instance_exists(card, "zone") && (card.zone == "Hand" || card.zone == "HandSelected"));
        var isOwnerHero = (variable_instance_exists(card, "isHeroOwner") && card.isHeroOwner);
        var isArtifact = (variable_instance_exists(card, "genre") && card.genre == "Artéfact");
        // Détection d'au moins un effet continu
        var hasContinuous = false;
        if (variable_struct_exists(card, "effects")) {
            for (var ci = 0; ci < array_length(card.effects); ci++) {
                var ce = card.effects[ci];
                if (is_struct(ce) && variable_struct_exists(ce, "trigger") && ce.trigger == TRIGGER_CONTINUOUS) { hasContinuous = true; break; }
            }
        }

        // NOUVELLE RÈGLE: n'afficher le bouton que si au moins 1 monstre face visible est présent
        if (isArtifact && !has_any_monster_on_field()) {
            show_debug_message("### oUIManager.displayEffectButton: aucun monstre face visible -> bouton masqué (Artéfact)");
            return;
        }

        // Cas spécial: carte face cachée sur le terrain du héros
        // Afficher le bouton si une cible valide existe pour un effet manuel OU si la carte possède un effet continu (pour permettre le retournement)
        if (isFD && isOnField && isOwnerHero) {
            var effectFD = getAvailableEffect(card);
            var allowFD = false;
            if (effectFD != noone && hasValidTargetForEffect(card, effectFD)) {
                allowFD = true;
            } else if (hasContinuous) {
                allowFD = true;
            }
            if (allowFD) {
                var sprite_h_fd = sprite_get_height(card.sprite_index) * card.image_yscale;
                instanceEffectButton = instance_create_layer(card.x + 40, card.y - sprite_h_fd/2 - 40, layer_get_id("Instances"), oEffectButton);
                instanceEffectButton.parentCard = card;
                instanceEffectButton.depth = -2000;
                instanceEffectButton.image_xscale = 0.6;
                instanceEffectButton.image_yscale = 0.6;
                global.isActionMenuOpen = true;
            } else {
                show_debug_message("### oUIManager.displayEffectButton: aucune cible valide pour carte face cachée (et pas d'effet continu)");
            }
            return;
        }

        // Nouveau: carte Magie en main avec effet continu -> afficher un bouton pour poser face visible
        if (card.type == "Magic" && isInHand && isOwnerHero && hasContinuous) {
            var sprite_h_c = sprite_get_height(card.sprite_index) * card.image_yscale;
            instanceEffectButton = instance_create_layer(card.x + 40, card.y - sprite_h_c/2 - 40, layer_get_id("Instances"), oEffectButton);
            instanceEffectButton.parentCard = card;
            instanceEffectButton.depth = -2000;
            instanceEffectButton.image_xscale = 0.6;
            instanceEffectButton.image_yscale = 0.6;
            global.isActionMenuOpen = true;
            return;
        }

        // Affichage standard si un effet est disponible ET au moins une cible valide
        var effect = getAvailableEffect(card);
        if (effect != noone && hasValidTargetForEffect(card, effect)) {
            var sprite_h = sprite_get_height(card.sprite_index) * card.image_yscale;
            instanceEffectButton = instance_create_layer(card.x + 40, card.y - sprite_h/2 - 40, layer_get_id("Instances"), oEffectButton);
            instanceEffectButton.parentCard = card;
            instanceEffectButton.depth = -2000;
            instanceEffectButton.image_xscale = 0.6;
            instanceEffectButton.image_yscale = 0.6;

            global.isActionMenuOpen = true;
        } else {
            show_debug_message("### oUIManager.displayEffectButton: effet indisponible ou aucune cible valide pour cette carte");
        }
    }
}
#endregion

#region Function hideEffectButton
hideEffectButton = function() {show_debug_message("### oUIManager.hideEffectButton")
    if (instanceEffectButton != "") {
        instance_destroy(instanceEffectButton);
        instanceEffectButton = "";
    }
    // Déverrouillage différé: géré dans Step_0
    // Ne pas modifier global.isActionMenuOpen ici
}
#endregion


#region Function hideAttackButton
hideAttackButton = function() {show_debug_message("### oUIManager.hideAttackButton")
    if (instanceAttackButton != "") {
        instance_destroy(instanceAttackButton);
        instanceAttackButton = "";
    }
    
    // Déverrouillage différé: géré dans Step_0
    // Ne pas modifier global.isActionMenuOpen ici
}
#endregion

#region Function displayIndicator
displayIndicator = function(cardToDisplay = noone) {show_debug_message("### oUIManager.displayIndicator")
	
	var card = (cardToDisplay != noone) ? cardToDisplay : selectManager.selected;
	if (card == noone) {
		show_debug_message("Erreur: Aucune carte à afficher pour les indicateurs");
		return;
	}
	
	hideSummonAndSet(); // Cache les boutons d'actions
	// Sécuriser l'accès au fieldManagerHero pour restaurer le flux d'avant
	var fm = instance_exists(fieldManagerHero) ? fieldManagerHero : instance_find(oFieldManagerHero, 0);
	if (fm != noone && instance_exists(fm)) {
		fm.addIndicators(card.type); // Ajoute les indicateurs au sol (côté Monstre ou Magique/Piège suivant la carte)
	} else {
		show_debug_message("Erreur: fieldManagerHero introuvable ou détruit pour addIndicators");
		return;
	}
	// Ajuste la position prévue selon le mode
	if (card.type == "Magic" && selectedSummonOrSet == "Set") {
		card.position = "Attack"; // Set Magie: face cachée mais en position Attaque
	} else {
		card.position = selectedSummonOrSet == "Summon" ? "Attack" : "Defense";
	}
	selectManager.unSelect(card); // Replace la carte sélectionnée
	selectManager.set(card); // Conserver la sélection pour retrouver la carte à invoquer
}
#endregion

// Vérifie si le Cheval de la Rose Noire peut être invoqué spécialement depuis la main
canSpecialSummonRoseCheval = function(card) {
    if (card == noone || !instance_exists(card)) return false;
    if (card.zone != "Hand" || !card.isHeroOwner) return false;
    if (game.phase[game.phase_current] != "Summon" || game.player[game.player_current] != "Hero") return false;
    // S'assure qu'on cible bien le Cheval de la Rose Noire
    if (object_get_name(card.object_index) != "oChevalDeLaRoseNoire") return false;
    // Condition: contrôler un monstre "Rose noire" sur notre terrain
    return has_archetype_monster_on_field(true, "Rose noire");
}


#region Function stopIndicator
stopIndicator = function() {show_debug_message("### oUIManager.stopIndicator")
	
	// La carte n'est plus en cours de traitement
	selectedSummonOrSet = "";
	
	// Détruit tous les indicateurs
	var nbInstance = instance_number(oIndicatorParent);
	for(var i = 0; i < nbInstance; ++i;)
	    instance_destroy(instance_find(oIndicatorParent, 0));
}
#endregion
