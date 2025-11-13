show_debug_message("### oSelectManager.create");

///////////////////////////////////////////////////////////////////////
// Attributs
///////////////////////////////////////////////////////////////////////

selected = "";
targetingEffect = false;        // indique si on est en mode ciblage d'effet
targetingEffectId = noone;      // instance de la carte magique ou oEffectManager qui cible
attackMode = false;             // indique si on est en mode attaque (monstre sélectionné, en attente de cible)
targetingArrow = noone;         // instance de la flèche de ciblage

// Nouvel état: effet différé après placement (magies Artéfact)
pendingEffectCard = noone;      // carte dont l’effet a été demandé avant placement
pendingEffect = noone;          // struct d’effet à exécuter après la pose

// Position du bouton "attaque directe" (à ajuster selon ta scène)
attackDirectX = handEnemy.x;
attackDirectY = handEnemy.y;

attackDirectInstance = noone;
// attackButtonInstance géré maintenant par oUIManager

///////////////////////////////////////////////////////////////////////
// Méthodes
///////////////////////////////////////////////////////////////////////

// Initialise la référence à l'instance du bouton oAttackDirectEnemy
initAttackDirectInstance = function() {
    attackDirectInstance = instance_find(oAttackDirectEnemy, 0);
    if (attackDirectInstance == noone) {
        show_debug_message("### WARNING: Aucun instance de oAttackDirectEnemy trouvée !");
    }
}
initAttackDirectInstance();

// Initialise la référence à l'instance du bouton oAttack
// Les boutons d'attaque sont maintenant gérés par UIManager

// Définit la carte sélectionnée
set = function(card) {
    show_debug_message("### selectManager.set pour carte: " + string(card));
    show_debug_message("### Type de card: " + string(typeof(card)));
    show_debug_message("### Avant set, selected = " + string(selected));
    selected = card;
    show_debug_message("### Après set, selected = " + string(selected));
    // Vérification que la variable a bien été mise à jour
    if (selected == card) {
        show_debug_message("### La variable selected a été correctement mise à jour");
    } else {
        show_debug_message("### ERREUR: La variable selected n'a pas été mise à jour correctement");
    }
}

// Crée la flèche de ciblage
createTargetingArrow = function(card) {
    show_debug_message("### selectManager.createTargetingArrow");
    if (targetingArrow != noone) {
        instance_destroy(targetingArrow);
    }
    targetingArrow = instance_create_layer(0, 0, "Instances", oTargetingArrow);
    targetingArrow.setSourceCard(card);
}

// Détruit la flèche de ciblage
destroyTargetingArrow = function() {
    show_debug_message("### selectManager.destroyTargetingArrow");
    if (targetingArrow != noone && instance_exists(targetingArrow)) {
        instance_destroy(targetingArrow);
        targetingArrow = noone;
    }
}

// Affiche une flèche d'équipement depuis l'artéfact vers son monstre ciblé
showEquipLinkArrowFor = function(artifactCard) {
    if (!instance_exists(artifactCard)) return;
    // Vérifier qu'il s'agit bien d'un Artéfact et qu'une cible est reliée
    var isArtifact = (variable_instance_exists(artifactCard, "genre") && string_lower(artifactCard.genre) == string_lower("Artéfact"));
    var tgt = (variable_instance_exists(artifactCard, "equipped_target")) ? artifactCard.equipped_target : noone;
    if (isArtifact && tgt != noone && instance_exists(tgt)) {
        // Créer une flèche dédiée qui pointe vers la cible fixe
        if (targetingArrow != noone) {
            instance_destroy(targetingArrow);
        }
        targetingArrow = instance_create_layer(0, 0, "Instances", oTargetingArrow);
        targetingArrow.setSourceCard(artifactCard);
        targetingArrow.setFixedTarget(tgt);
        show_debug_message("### Flèche d'équipement affichée: " + string(artifactCard.name) + " -> " + string(tgt.name));
    } else {
        // Nettoyer si pas de cible
        destroyTargetingArrow();
    }
}

// Enlève la sélection
remove = function() {
    show_debug_message("### selectManager.remove");
    selected = "";
    targetingEffect = false;
    targetingEffectId = noone;
    attackMode = false; // Réinitialise le mode attaque
    destroyTargetingArrow(); // Détruit la flèche de ciblage
    // Nettoyer les marqueurs de ciblage pour Floraison
    if (script_exists(clearTargetingMarkers)) {
        clearTargetingMarkers();
    }
}

// Tente de sélectionner une carte
trySelect = function(card) {
    // Blocage global si le menu d'action est ouvert
    // Autoriser le switch direct vers une autre carte même si le menu est ouvert
    // Sinon, conserver le comportement viewer-only
    if (variable_global_exists("isActionMenuOpen") && global.isActionMenuOpen) {
        if (selected != "" && selected != card && instance_exists(selected) && (selected.zone == "HandSelected" || selected.zone == "FieldSelected")) {
            show_debug_message("### Action menu ouvert: switch direct vers nouvelle carte");
            // Désélectionner proprement l'ancienne carte et masquer les UI
            unSelectAll();
            UIManager.hideSummonAndSet();
            UIManager.hidePositionButton();
            UIManager.hideEffectButton();
            if (attackDirectInstance != noone) attackDirectInstance.image_alpha = 0;
            UIManager.hideAttackButton();
            attackMode = false;
            destroyTargetingArrow();
            // Continuer vers la sélection normale pour la nouvelle carte (ne pas retourner)
        } else {
            // Carte du héros: autoriser viewer-only
            if (card.isHeroOwner) {
                // Si la carte est déjà en état sélectionné, déléguer à tryUnselect
                if (selected == card && (card.zone == "HandSelected" || card.zone == "FieldSelected")) {
                    show_debug_message("### Action menu ouvert: carte déjà sélectionnée -> déléguer à tryUnselect");
                    return false;
                }
                show_debug_message("### Action menu ouvert: soft-select pour viewer (carte héros)");
                // Ne pas modifier la zone/échelle/position de la carte, juste mettre à jour le viewer
                set(card);
                var preview = instance_find(oSelectedCardDisplay, 0);
                if (preview != noone) {
                    preview.selected = card;
                } else {
                    var newPreview = instance_create_layer(150, 250, "Instances", oSelectedCardDisplay);
                    newPreview.selected = card;
                    newPreview.depth = -100000;
                }
                // Afficher la flèche d'équipement en mode viewer-only si applicable
                if (card.type == "Magic" && variable_instance_exists(card, "genre") && string_lower(card.genre) == string_lower("Artéfact")) {
                    showEquipLinkArrowFor(card);
                } else {
                    destroyTargetingArrow();
                }
                // Afficher le bouton effet même en mode viewer-only si carte FD héros sur terrain
                if (card.isHeroOwner && card.isFaceDown && (card.zone == "Field" || card.zone == "FieldSelected")) {
                    UIManager.displayEffectButton(card);
                }
                return true;
            }
            // Carte adverse: autoriser viewer-only si sur le terrain et face visible
            if (!card.isHeroOwner && card.zone == "Field" && !card.isFaceDown) {
                show_debug_message("### Action menu ouvert: soft-select pour viewer (carte adverse visible)");
                set(card);
                var preview_enemy = instance_find(oSelectedCardDisplay, 0);
                if (preview_enemy != noone) {
                    preview_enemy.selected = card;
                } else {
                    var newPreviewEnemy = instance_create_layer(150, 250, "Instances", oSelectedCardDisplay);
                    newPreviewEnemy.selected = card;
                    newPreviewEnemy.depth = -100000;
                }
                // Afficher la flèche d'équipement en mode viewer-only si applicable
                if (card.type == "Magic" && variable_instance_exists(card, "genre") && string_lower(card.genre) == string_lower("Artéfact")) {
                    showEquipLinkArrowFor(card);
                } else {
                    destroyTargetingArrow();
                }
                return true;
            }
            show_debug_message("### Action menu ouvert: blocage de trySelect (carte non autorisée)");
            return false;
        }
    }
    show_debug_message("### selectManager.trySelect pour carte: " + string(card));
    // Si le sélecteur de sacrifice est ouvert, empêcher tout changement de sélection
    if (variable_global_exists("isSacrificeSelectorOpen") && global.isSacrificeSelectorOpen) {
        show_debug_message("### Sélecteur de sacrifice ouvert: blocage du changement de sélection");
        return false;
    }
    
    // === Gestion ciblage effet magique ===
    if(targetingEffect) {
        show_debug_message("### Mode ciblage d'effet actif");
        if(targetingEffectId != noone) {
            // Vérifie que la carte est bien sur le terrain (Field ou FieldSelected)
            if(card.zone == "Field" || card.zone == "FieldSelected") {
                // Applique l'effet sur la carte ciblée (quel que soit le propriétaire)
                targetingEffectId.onTargetSelected(card);

                // Désactive le mode ciblage après activation
                targetingEffect = false;
                targetingEffectId = noone;

                // Enlève la sélection courante
                remove();
                show_debug_message("### Carte ciblée avec succès pour effet");
                return true;
            } else {
                show_debug_message("### selectManager.trySelect : cible invalide, doit être sur le terrain");
                return false;
            }
        }
    }
    
    // === Sélection normale ===
    show_debug_message("### Vérification conditions de sélection: isHeroOwner=" + string(card.isHeroOwner) + ", joueur actuel=" + game.player[game.player_current] + ", phase=" + game.phase[game.phase_current]);
    
    // Autoriser la sélection des cartes du héros pour l'affichage du viewer,
    // même si ce n'est pas son tour (les UI ne s'affichent que quand c'est pertinent).
    if(card.isHeroOwner) {
        
        if(game.phase[game.phase_current] == "Attack") {
            show_debug_message("### Phase d'attaque, zone=" + card.zone + ", orientation=" + card.orientation);
            if(card.zone == "Field") {
                // Toujours autoriser la sélection pour afficher le viewer
                unSelectAll();
                select(card);

                // UI d'attaque uniquement si c'est le tour du héros et que la carte est un monstre en Attaque
                if (game.player[game.player_current] == "Hero" && card.type == "Monster" && card.orientation == "Attack") {
                    // Affiche le bouton d'attaque via UIManager (sécurisé côté UIManager)
                    UIManager.displayAttackButton(card);

                    // Vérifie si l'adversaire a des monstres pour l'attaque directe
                    var enemyHasMonsters = false;
                    var enemyMonsterField = fieldManagerEnemy.getField("Monster");
                    for (var i = 0; i < array_length(enemyMonsterField.cards); i++) {
                        var em = enemyMonsterField.cards[i];
                        if (em != 0 && instance_exists(em)) {
                            enemyHasMonsters = true;
                            break;
                        }
                    }

                    show_debug_message("### L'adversaire a des monstres: " + string(enemyHasMonsters));
                    // Le bouton d'attaque directe n'est visible que si le mode attaque est activé ET qu'il n'y a pas de monstres ennemis
                    if(!enemyHasMonsters && attackMode && attackDirectInstance != noone) {
                        attackDirectInstance.x = attackDirectX;
                        attackDirectInstance.y = attackDirectY;
                        attackDirectInstance.image_alpha = 1; // bouton visible
                        show_debug_message("### Bouton d'attaque directe affiché (mode attaque activé)");
                    } else if (attackDirectInstance != noone) {
                        attackDirectInstance.image_alpha = 0; // bouton caché
                        show_debug_message("### Bouton d'attaque directe caché (pas en mode attaque ou monstres présents)");
                    }

                    // Créer la flèche de ciblage si le mode attaque est activé
                    if(attackMode) {
                        createTargetingArrow(card);
                    }
                } else {
                    // Orientation défensive ou tour adverse: cacher les UI d'attaque
                    if (attackDirectInstance != noone) attackDirectInstance.image_alpha = 0;
                    UIManager.hideAttackButton();
                    attackMode = false;
                    destroyTargetingArrow();
                }

                show_debug_message("### Sélection effectuée en phase d'attaque (viewer visible)");
                return true;
            }
        }
        
        if(game.phase[game.phase_current] == "Summon") {
            show_debug_message("### Phase d'invocation, zone=" + card.zone);
            if(card.zone == "Hand") {
                unSelectAll();
                select(card);
                
                // UI d'invocation uniquement si c'est le tour du héros
                if (game.player[game.player_current] == "Hero") {
                    UIManager.displaySummonSetAction(card);
                } else {
                    UIManager.hideSummonAndSet();
                }

                if (attackDirectInstance != noone) {
                    attackDirectInstance.image_alpha = 0; // cacher bouton en phase summon
                }
                show_debug_message("### Carte de la main sélectionnée (viewer visible) en phase d'invocation");
                return true;
            }
            // Permettre la sélection des monstres sur le terrain pour viewer
            if(card.zone == "Field" && card.type == "Monster") {
                show_debug_message("### Sélection d'un monstre sur le terrain (viewer visible)");
                unSelectAll();
                select(card);
                if (attackDirectInstance != noone) {
                    attackDirectInstance.image_alpha = 0; // masquer le bouton d'attaque
                }
                UIManager.hideSummonAndSet();
                show_debug_message("### Viewer mis à jour (phase Summon)");
                return true;
            }
            // Permettre la sélection des cartes face cachée du héros sur le terrain
            if(card.zone == "Field" && card.isHeroOwner && card.isFaceDown) {
                show_debug_message("### Sélection d'une carte face cachée du héros");
                unSelectAll();
                select(card);
                if (attackDirectInstance != noone) {
                    attackDirectInstance.image_alpha = 0; // masquer le bouton d'attaque
                }
                // UIManager.hideSummonAndSet(); // ne pas cacher le bouton effet juste après
                show_debug_message("### Carte face cachée sélectionnée (bouton effet disponible)");
                return true;
            }
            // NEW: Permettre la sélection des cartes visibles du héros sur le terrain (non-monstres)
            if(card.zone == "Field" && card.isHeroOwner && !card.isFaceDown && card.type != "Monster") {
                show_debug_message("### Sélection d'une carte visible du héros sur le terrain (non-monstre)");
                unSelectAll();
                select(card);
                if (attackDirectInstance != noone) {
                    attackDirectInstance.image_alpha = 0; // masquer le bouton d'attaque
                }
                // UIManager.hideSummonAndSet(); // ne pas cacher le bouton effet juste après
                show_debug_message("### Carte visible du héros sélectionnée (bouton effet potentiellement disponible)");
                return true;
            }
        }
    }

    // Sélection côté ennemi: autoriser le viewer-only si la carte est visible
    if(!card.isHeroOwner && card.zone == "Field" && !card.isFaceDown) {
        show_debug_message("### Sélection d'une carte ennemie visible (viewer-only)");
        unSelectAll();
        select(card);
        UIManager.hideSummonAndSet();
        if (attackDirectInstance != noone) attackDirectInstance.image_alpha = 0;
        show_debug_message("### Viewer mis à jour pour carte ennemie visible");
        return true;
    }

    // Autoriser à toutes les phases la sélection des cartes face cachée du héros sur le terrain
    // afin d'afficher le bouton d'effet pour retournement/activation
    if(card.isHeroOwner && card.zone == "Field" && card.isFaceDown) {
        show_debug_message("### Sélection d'une carte face cachée du héros (toutes phases)");
        unSelectAll();
        select(card);
        // UIManager.hideSummonAndSet(); // ne pas cacher le bouton effet juste après
        if (attackDirectInstance != noone) attackDirectInstance.image_alpha = 0;
        show_debug_message("### Carte face cachée sélectionnée (bouton effet disponible)");
        return true;
    }

    show_debug_message("### trySelect: aucune condition remplie, sélection ignorée");
    return false;
}

// Sélectionne une carte
select = function(card) {
    show_debug_message("### selectManager.select pour carte: " + string(card));
    set(card);
    if (!instance_exists(card)) return;
    if(card.zone == "Field") {
        card.zone = "FieldSelected";
        card.image_xscale = 0.3;
        card.image_yscale = 0.3;
        card.y -= 10;
        if(card.type == "Monster" && card.isHeroOwner && game.phase[game.phase_current] == "Summon" && game.player[game.player_current] == "Hero" && !card.orientationChangedThisTurn) {
            UIManager.displayPositionButton(card);
            UIManager.displayEffectButton(card);
        }
        // Afficher le bouton effet pour les cartes face cachée du héros (toutes phases)
        if(card.isHeroOwner && card.isFaceDown) {
            UIManager.displayEffectButton(card);
        }
        // NEW: Afficher le bouton effet pour les cartes visibles du héros sur le terrain
        if(card.isHeroOwner && !card.isFaceDown && game.player[game.player_current] == "Hero") {
            UIManager.displayEffectButton(card);
        }
        // Indicateur visuel: si carte Artéfact équipée, afficher la flèche vers sa cible
        if (card.type == "Magic" && variable_instance_exists(card, "genre") && string_lower(card.genre) == string_lower("Artéfact")) {
            showEquipLinkArrowFor(card);
        } else {
            // Pas un artéfact: s'assurer qu'on n'affiche pas une flèche d'équipement résiduelle
            destroyTargetingArrow();
        }
    } else if(card.zone == "Hand") {
        card.zone = "HandSelected";
        card.image_xscale = 0.5;
        card.image_yscale = 0.5;
        card.y -= 80;
    }
    var preview = instance_find(oSelectedCardDisplay, 0);
    if (preview != noone) {
        preview.selected = card;
    } else {
        var newPreview = instance_create_layer(150, 250, "Instances", oSelectedCardDisplay);
        newPreview.selected = card;
        newPreview.depth = -100000;
    }
}

// Tente de désélectionner une carte
tryUnselect = function(card) {
    show_debug_message("### selectManager.tryUnselect");
    if (!instance_exists(card)) return;
    if (card.zone == "HandSelected" || card.zone == "FieldSelected") {
        unSelect(card);
        UIManager.hideSummonAndSet();
        UIManager.hidePositionButton();
        UIManager.hideEffectButton();
        UIManager.hideAttackButton();
        if (attackDirectInstance != noone) attackDirectInstance.image_alpha = 0;
        attackMode = false;
        destroyTargetingArrow();
    }
}

// Désélectionne une carte
unSelect = function(card) {
    show_debug_message("### selectManager.unSelect");
    remove();
    if (!instance_exists(card)) return;
    if(card.zone == "FieldSelected") {
        card.zone = "Field";
        card.image_xscale = 0.275;
        card.image_yscale = 0.275;
        UIManager.hidePositionButton();
        UIManager.hideEffectButton();
        card.y += 10;
    } else if(card.zone == "HandSelected") {
        card.zone = "Hand";
        card.image_xscale = 0.275;
        card.image_yscale = 0.275;
        card.y += 80;
    }
}

// Désélectionne toutes les cartes
unSelectAll = function() {
    show_debug_message("### selectManager.unSelectAll");
    var nbCards = instance_number(oCardParent);
    for(var i = 0; i < nbCards; i++) {
        var c = instance_find(oCardParent, i);
        if (c.zone == "HandSelected" || c.zone == "FieldSelected") {
            unSelect(c);
        }
    }
    selected = ""; // Nettoyer la référence selected
    UIManager.hideSummonAndSet();
    UIManager.hideAttackButton();
    if (attackDirectInstance != noone) attackDirectInstance.image_alpha = 0;
    attackMode = false;
    destroyTargetingArrow();
    // Nettoyer les marqueurs de ciblage pour Floraison
    if (script_exists(clearTargetingMarkers)) {
        clearTargetingMarkers();
    }
}

// Active le mode ciblage d’effet
startTargeting = function(effectInstance) {
    show_debug_message("### selectManager.startTargeting");
    // Important: nettoyer d’abord, puis activer le mode ciblage
    unSelectAll();
    targetingEffect = true;
    targetingEffectId = effectInstance;
}
