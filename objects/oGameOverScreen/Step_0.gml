// === oGameOverScreen - Step Event ===
// Gestion du survol du bouton et blocage des clics

// Vérifier si l'animation est terminée
if (alpha >= targetAlpha) {
    // Calculer les limites du bouton
    var button_left = buttonX - buttonWidth / 2;
    var button_top = buttonY - buttonHeight / 2;
    var button_right = buttonX + buttonWidth / 2;
    var button_bottom = buttonY + buttonHeight / 2;
    
    // Vérifier si la souris survole le bouton
    if (mouse_x >= button_left && mouse_x <= button_right && 
        mouse_y >= button_top && mouse_y <= button_bottom) {
        buttonHover = true;
    } else {
        buttonHover = false;
    }
    
    // Bloquer tous les clics en consommant l'événement de clic
    // Ceci empêche les autres objets de recevoir les clics
    if (mouse_check_button_pressed(mb_left)) {
        // Si le clic est sur le bouton, gérer la navigation
        if (buttonHover) {
            show_debug_message("### oGameOverScreen - Bouton Continuer cliqué");
            
            // Retourner à la room précédente sauvegardée
            var target_room = global.previous_room_before_duel;
            show_debug_message("### Navigation vers " + string(room_get_name(target_room)));
            
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
            
            room_goto(target_room);
        } else {
            // Clic en dehors du bouton - ne rien faire mais bloquer le clic
            show_debug_message("### oGameOverScreen - Clic bloqué (en dehors du bouton)");
        }
    }
}