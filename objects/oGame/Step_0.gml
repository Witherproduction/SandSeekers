// Initialiser les cimetières une seule fois au début du jeu
if (!variable_instance_exists(id, "graveyardsInitialized") || !graveyardsInitialized) {
    if (instance_exists(oGraveyard)) {
        initializeGraveyards();
        graveyardsInitialized = true;
    }
}

// Vérifier les points de vie pour déclencher la fin de partie
if (instance_exists(LP_Hero) && instance_exists(LP_Enemy)) {
    var heroLP = LP_Hero.nbLP;
    var enemyLP = LP_Enemy.nbLP;
    
    // Vérifier si quelqu'un a perdu (points de vie <= 0)
    if (heroLP <= 0 || enemyLP <= 0) {
        // Éviter de déclencher plusieurs fois la fin de partie
        if (!variable_instance_exists(id, "gameEnded") || !gameEnded) {
            gameEnded = true;
            
            // Déterminer le gagnant
            var isVictory = false;
            if (heroLP <= 0 && enemyLP <= 0) {
                // Égalité - considérer comme défaite
                isVictory = false;
            } else if (heroLP <= 0) {
                // Le héros a perdu
                isVictory = false;
            } else if (enemyLP <= 0) {
                // L'ennemi a perdu, le héros gagne
                isVictory = true;
            }
            
            // Créer l'écran de fin de partie
            var gameOverScreen = instance_create_layer(0, 0, "UI", oGameOverScreen);
            
            // Déterminer si c'est une victoire ou une défaite
            gameOverScreen.isVictory = isVictory;
            
            // Arrêter le jeu
            return;
        }
        
        // Arrêter le traitement du jeu si la partie est terminée
        return;
    }
}

if(timerPick > 0 && timerEnabledPick) {
	timerPick -= 1/room_speed;
}
else if(timerEnabledPick) {
	// Piocher pour le héros seulement s'il a moins de 5 cartes
	if(ds_list_size(handHero.cards) < 5) {
		deckHero.pick();
	}
	
	// Piocher pour l'ennemi seulement s'il a moins de 5 cartes
	if(ds_list_size(handEnemy.cards) < 5) {
		IA.pick();
	}
	
	// Continuer la pioche tant que l'un des joueurs n'a pas 5 cartes
	if(ds_list_size(handHero.cards) < 5 || ds_list_size(handEnemy.cards) < 5) {
		timerPick = 0.5;
	} else {
		timerEnabledPick = false;
		game.nextPhase();
		nextStep.image_alpha = 1;
	}
}


if(timerIA > 0 && timerEnabledIA) {
	timerIA -= 1/room_speed;
}
else if(timerEnabledIA) {
	
	timerEnabledIA = false;
	switch (phase[phase_current])
	{
		case "Pick": IA.pick();
		break;
		case "Summon": IA.summon();
		break;
		case "Attack": IA.attack();
		break;
	}
}

// === GESTION DES EFFETS CONTINUS ===
// Traiter tous les effets continus des cartes sur le terrain
with (oCardParent) {
    if (zone == "Field" && variable_struct_exists(self, "effects")) {
        for (var i = 0; i < array_length(effects); i++) {
            var effect = effects[i];
            if (variable_struct_exists(effect, "trigger") && effect.trigger == TRIGGER_CONTINUOUS) {
                // Vérifier les conditions du trigger continu
                if (checkTriggerConditions(self, effect)) {
                    // Exécuter l'effet continu
                    executeEffect(self, effect, {});
                }
            }
        }
    }
}
