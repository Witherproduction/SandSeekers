// Clic sur l'ennemi pour attaque directe
show_debug_message("### oLP_Enemy.Click - Clic sur l'ennemi");

// Vérifier si on est dans la room de duel
if (room != rDuel) {
    exit;
}

if (global.isGraveyardViewerOpen) exit;

// Vérifier si on est en mode attaque avec une carte sélectionnée
// IMPORTANT: L'attaque directe n'est possible QUE si le mode attaque a été activé via le bouton
if (selectManager.attackMode && selectManager.selected != "") {
    var selectedCard = selectManager.selected;
    
    // Vérifier les conditions pour l'attaque directe
    if (selectedCard.isHeroOwner && selectedCard.type == "Monster" && selectedCard.zone == "FieldSelected" 
        && selectedCard.orientation == "Attack" && selectedCard.lastTurnAttack < game.nbTurn
        && instance_exists(game) && game.player[game.player_current] == "Hero" && game.phase[game.phase_current] == "Attack") {
        
        // Vérifier qu'il n'y a pas de monstres ennemis
        var enemyHasMonsters = false;
        var enemyMonsters = fieldMonsterEnemy.cards;
        
        for (var i = 0; i < array_length(enemyMonsters); i++) {
            var em = enemyMonsters[i];
            if (em != 0 && instance_exists(em)) {
                enemyHasMonsters = true;
                var emName = (instance_exists(em) && variable_instance_exists(em, "name")) ? em.name : "Unknown";
                show_debug_message("### Monstre ennemi trouvé: " + emName + " - attaque directe impossible");
                break;
            }
        }
        
        if(!enemyHasMonsters) {
            // Interdiction d'attaquer au tour 1 du duel
            if (game.nbTurn == 1) {
                show_debug_message("### oLP_Enemy: Attaque directe interdite au tour 1 du duel");
                exit;
            }
            show_debug_message("### Attaque directe sur l'ennemi - dégâts infligés: " + string(selectedCard.attack));
            nbLP -= selectedCard.attack;
            selectManager.unSelect(selectedCard);
            selectedCard.lastTurnAttack = game.nbTurn;
            selectManager.attackMode = false; // Sortir du mode attaque
        } else {
            show_debug_message("### Attaque directe impossible : monstres ennemis présents");
        }
    } else {
        show_debug_message("### Conditions non remplies pour l'attaque directe");
    }
} else {
    show_debug_message("### Pas en mode attaque ou aucune carte sélectionnée");
}
