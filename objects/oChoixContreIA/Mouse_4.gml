// === oChoixContreIA - Mouse Left Button Event ===
// Bouton de navigation vers rContreIa

// Bloquer le clic si le panneau d'options est ouvert
if (instance_exists(oPanelOptions)) { exit; }

// Vérifier si la souris est dans la zone du bouton
var mouse_x_pos = mouse_x;
var mouse_y_pos = mouse_y;

// Calculer les limites du bouton
var button_left = x - button_width / 2;
var button_top = y - button_height / 2;
var button_right = x + button_width / 2;
var button_bottom = y + button_height / 2;

// Vérifier si le clic est dans la zone du bouton et déclencher sur relâchement
if (mouse_x_pos >= button_left && mouse_x_pos <= button_right && 
    mouse_y_pos >= button_top && mouse_y_pos <= button_bottom && mouse_check_button_released(mb_left)) {
    
    show_debug_message("### oChoixContreIA.Mouse_4 - Clic détecté dans la zone du bouton");
    show_debug_message("### Navigation vers rContreIa depuis " + string(room_get_name(room)));
    room_goto(rContreIa);
}