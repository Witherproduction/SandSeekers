// === oButtonCardCreator - Step Event ===

// Garde directe pour bloquer les clics quand le panneau d'options est ouvert
if (instance_exists(oPanelOptions)) { exit; }

// Détection des clics alignée sur les dimensions étirées du bouton (button_width/height)
// Vérifier si on est dans la room d'accueil
if (room != rAcceuil) {
    exit; // Sortir si on n'est pas dans la bonne room
}

// Vérifier si le bouton gauche de la souris vient d'être pressé
if (mouse_check_button_pressed(mb_left)) {
    // Obtenir la position de la souris
    var mouse_x_pos = mouse_x;
    var mouse_y_pos = mouse_y;

    // Calculer les limites du bouton basées sur button_width et button_height
    var button_left = x - button_width / 2;
    var button_top = y - button_height / 2;
    var button_right = x + button_width / 2;
    var button_bottom = y + button_height / 2;

    // Vérifier si le clic est dans la zone du bouton
    if (mouse_x_pos >= button_left && mouse_x_pos <= button_right && 
        mouse_y_pos >= button_top && mouse_y_pos <= button_bottom) {
        // Naviguer vers la room de création de cartes
        room_goto(rCardCreator);
    }
}