// === oChoixContreIA - Step Event ===
// Détection manuelle des clics sur le bouton

// Hériter de la garde de oButtonBlock et bloquer sous le panneau d'options
event_inherited();
if (instance_exists(oPanelOptions)) { exit; }

// Déclencher sur relâchement pour éviter le clic persistant après changement de room
if (mouse_check_button_released(mb_left)) {
    
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
        
        show_debug_message("### oChoixContreIA.Step_0 - Clic détecté dans la zone du bouton!");
        show_debug_message("### Position souris: (" + string(mouse_x_pos) + ", " + string(mouse_y_pos) + ")");
        show_debug_message("### Zone bouton: (" + string(button_left) + ", " + string(button_top) + ") à (" + string(button_right) + ", " + string(button_bottom) + ")");
        show_debug_message("### Navigation vers rContreIa depuis " + string(room_get_name(room)));
        
        // Naviguer vers la room rContreIa après relâchement
        room_goto(rContreIa);
    }
}