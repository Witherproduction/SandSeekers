// Left pressed (clic gauche)
// Vérifier si on est dans la room de duel
if (room != rDuel) {
    exit;
}

if (global.isGraveyardViewerOpen) exit;

// Vérifier si on est en mode attaque avec une carte sélectionnée
if (selectManager.attackMode && selectManager.selected != "") {
    var card = selectManager.selected;
    
    if (card != "" && instance_exists(game) && game.player[game.player_current] == "Hero" && game.phase[game.phase_current] == "Attack" 
        && card.zone == "FieldSelected" && card.lastTurnAttack < game.nbTurn) {
        // Règle: pas d'attaque directe au tour 1 du duel
        if (variable_instance_exists(game, "nbTurn") && game.nbTurn == 1) {
            show_debug_message("### oAttackDirectEnemy: Attaque directe interdite au tour 1 du duel");
            // Nettoyer l'UI et sortir du mode attaque
            image_alpha = 0;
            selectManager.attackMode = false;
            if (instance_exists(oAttack)) { instance_destroy(oAttack); }
            exit;
        }
        
        // Vérifier qu'il n'y a pas de monstres ennemis
        var enemyHasMonsters = false;
        var enemyMonsters = fieldMonsterEnemy.cards;
        
        for(var i = 0; i < array_length(enemyMonsters); i++) {
            if(enemyMonsters[i] != 0) {
                enemyHasMonsters = true;
                show_debug_message("### oAttackDirectEnemy: Monstre ennemi trouvé - attaque directe impossible");
                break;
            }
        }
        
        if(!enemyHasMonsters) {
            // Blocage générique: la carte ne peut pas attaquer directement si cannotAttackDirect
            if (variable_struct_exists(card, "cannotAttackDirect") && card.cannotAttackDirect) {
                show_debug_message("### oAttackDirectEnemy: Attaque directe impossible (cannotAttackDirect)");
                // Nettoyer l'UI et sortir du mode attaque
                image_alpha = 0;
                selectManager.attackMode = false;
                if (instance_exists(oAttack)) {
                    instance_destroy(oAttack);
                }
                exit;
            }
            // Si FX de combat activé: déclencher l'animation et laisser oDamageManager résoudre
            if (variable_global_exists("USE_COMBAT_FX") && global.USE_COMBAT_FX) {
                // Faire disparaître la flèche de ciblage avant l'animation de combat
                selectManager.destroyTargetingArrow();
                var fx = instance_create_layer(card.x, card.y, "Instances", FX_Combat);
                if (fx != noone) {
                    fx.attacker = card;
                    fx.defender = noone;
                    fx.mode = "direct";
                }
                // Nettoyer l'UI et sortir du mode attaque; la résolution (LP/lastTurnAttack/unselect) sera faite par FX_Combat -> oDamageManager
                image_alpha = 0; // cache le bouton après clic
                selectManager.attackMode = false; // sortir du mode attaque immédiatement comme pour les attaques vs monstre
                if (instance_exists(oAttack)) {
                    instance_destroy(oAttack);
                }
            } else {
                // Résolution directe sans FX
                var dm = instance_find(oDamageManager, 0);
                if (dm != noone) {
                    with (dm) resolveAttackDirect(card);
                }
                image_alpha = 0;
                selectManager.attackMode = false;
                if (instance_exists(oAttack)) {
                    instance_destroy(oAttack);
                }
            }
        } else {
            show_debug_message("### oAttackDirectEnemy: Attaque directe impossible - monstres ennemis présents");
        }
    }
} else {
    show_debug_message("### oAttackDirectEnemy: Pas en mode attaque ou aucune carte sélectionnée");
}