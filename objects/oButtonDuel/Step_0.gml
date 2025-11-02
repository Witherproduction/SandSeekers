// === oButtonDuel - Step Event ===
// Détection manuelle des clics sur le bouton Duel

// Hériter de la garde de oButtonBlock
event_inherited();

// Garde directe pour bloquer les clics quand le panneau d'options est ouvert
if (instance_exists(oPanelOptions)) { exit; }

// Vérifier si on est dans la room d'accueil
if (room != rAcceuil) {
    exit; // Sortir si on n'est pas dans la bonne room
}

// Vérifier si le bouton gauche de la souris vient d'être pressé
if (mouse_check_button_pressed(mb_left)) {
    
    // Obtenir la position de la souris
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
        
        show_debug_message("### oButtonDuel.Step_0 - Clic détecté dans la zone du bouton!");
        show_debug_message("### Position souris: (" + string(mouse_x_pos) + ", " + string(mouse_y_pos) + ")");
        show_debug_message("### Zone bouton: (" + string(button_left) + ", " + string(button_top) + ") à (" + string(button_right) + ", " + string(button_bottom) + ")");
        show_debug_message("### Navigation vers rPartieRapide depuis rAcceuil");
        
        // Sauvegarder la room actuelle avant d'aller vers rPartieRapide
        global.previous_room_before_duel = room;
        show_debug_message("### Room précédente sauvegardée: " + string(room_get_name(room)));
        
        // Naviguer vers la room Choix Duel
        room_goto(rPartieRapide);
    }
}