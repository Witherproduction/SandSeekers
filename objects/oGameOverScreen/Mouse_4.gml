show_debug_message("### oGameOverScreen.Mouse_4 - Clic pour quitter")

// Attendre que l'animation soit terminée avant de permettre le clic
if (alpha >= targetAlpha) {
    // Retourner à la room précédente sauvegardée
    var target_room = global.previous_room_before_duel;
    show_debug_message("### oGameOverScreen.Mouse_4 - Navigation vers " + string(room_get_name(target_room)));
    room_goto(target_room);
    
    // Nettoyer les variables globales si nécessaire
    if (variable_global_exists("selected_player_deck")) {
        global.selected_player_deck = noone;
    }
    if (variable_global_exists("selected_bot_deck_id")) {
        global.selected_bot_deck_id = noone;
    }
    if (variable_global_exists("isGraveyardViewerOpen")) {
        global.isGraveyardViewerOpen = false;
    }
    
    show_debug_message("### Retour à la room précédente: " + string(room_get_name(target_room)));
}