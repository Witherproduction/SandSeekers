// === oChoixChallenge - Mouse Left Button Event ===
// Gestion du clic gauche de la souris

show_debug_message("### oChoixChallenge.Mouse_4 - Événement Mouse Left Button déclenché");

// Obtenir la position de la souris
var mouse_x_pos = mouse_x;
var mouse_y_pos = mouse_y;

// Calculer les limites du bouton
var button_left = x - button_width / 2;
var button_top = y - button_height / 2;
var button_right = x + button_width / 2;
var button_bottom = y + button_height / 2;

show_debug_message("### Position souris: (" + string(mouse_x_pos) + ", " + string(mouse_y_pos) + ")");
show_debug_message("### Zone bouton: (" + string(button_left) + ", " + string(button_top) + ") à (" + string(button_right) + ", " + string(button_bottom) + ")");

// Vérifier si le clic est dans la zone du bouton
if (mouse_x_pos >= button_left && mouse_x_pos <= button_right && 
    mouse_y_pos >= button_top && mouse_y_pos <= button_bottom) {
    
    show_debug_message("### Clic dans la zone du bouton - Navigation vers rChallenge");
    
    // Naviguer vers la room rChallenge
    room_goto(rChallenge);
} else {
    show_debug_message("### Clic en dehors de la zone du bouton");
}