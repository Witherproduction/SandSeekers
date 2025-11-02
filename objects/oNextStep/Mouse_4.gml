show_debug_message("### oNextStep.clic")

// Permet au parent (oButtonBlock) de bloquer si nécessaire
event_inherited();

// Vérifier si on est dans la room de duel
if (room != rDuel) {
    exit;
}

if (global.isGraveyardViewerOpen) exit;

// Si le bouton est activé
if(image_alpha == 1) {
	
	// Repose toutes les cartes sélectionnées
	selectManager.unSelectAll();
	game.nextPhase();
}
