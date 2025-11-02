// === oRetour1 - Mouse Left Button Event ===
// Bouton de retour vers le menu principal

// Vérifier si la souris est dans la zone du bouton
var mouse_x_pos = mouse_x;
var mouse_y_pos = mouse_y;

// Calculer les limites du bouton
var button_left = x - button_width / 2;
var button_top = y - button_height / 2;
var button_right = x + button_width / 2;
var button_bottom = y + button_height / 2;

// Vérifier si le clic est dans la zone du bouton
if (mouse_x_pos >= button_left && mouse_x_pos <= button_right && 
    mouse_y_pos >= button_top && mouse_y_pos <= button_bottom) {
    
    show_debug_message("### oRetour1.Mouse_4 - Clic détecté dans la zone du bouton");
    
    // Vérifier qu'on est dans une room appropriée et déterminer la destination
    if (room == rCollection || room == rHistoire || room == rMode || room == rOption || room == rPartieRapide || 
        room == rChallenge || room == rContreIa || room == rPuzzle || room == rDuel) {
        
        // Nettoyer les variables globales si on quitte rDuel
        if (room == rDuel) {
            clear_selected_decks();
            show_debug_message("### Navigation vers rMode depuis rDuel avec nettoyage des decks");
            room_goto(rMode);
        }
        // Déterminer la destination selon la room actuelle
        else if (room == rChallenge || room == rContreIa || room == rPuzzle) {
            show_debug_message("### Navigation vers rMode depuis " + string(room_get_name(room)));
            room_goto(rMode);
        } else {
            show_debug_message("### Navigation vers rAcceuil depuis " + string(room_get_name(room)));
            room_goto(rAcceuil);
        }
    } else {
        show_debug_message("### Pas dans une room appropriée, navigation ignorée");
    }
} else {
    show_debug_message("### Clic en dehors de la zone du bouton");
}