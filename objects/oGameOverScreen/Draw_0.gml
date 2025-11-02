// Définir le message selon le résultat (fait ici pour s'assurer que isVictory est correctement définie)
if (messageText == "") {
    if (isVictory) {
        messageText = "VICTOIRE !";
        messageColor = #00ff00; // Vert pour la victoire
    } else {
        messageText = "DÉFAITE...";
        messageColor = #ff0000; // Rouge pour la défaite
    }
}

// Animation d'apparition
if (alpha < targetAlpha) {
    alpha += animationSpeed;
    if (alpha > targetAlpha) {
        alpha = targetAlpha;
    }
}

// Dessiner l'assombrissement de l'écran
draw_set_alpha(alpha);
draw_set_color(c_black);
draw_rectangle(0, 0, room_width, room_height, false);

// Dessiner le message seulement si l'assombrissement est suffisant
if (alpha > 0.3) {
    // Calculer l'alpha du texte (apparition progressive)
    var textAlpha = (alpha - 0.3) / (targetAlpha - 0.3);
    if (textAlpha > 1) textAlpha = 1;
    
    draw_set_alpha(textAlpha);
    
    // Définir la police (utiliser une police existante ou par défaut)
    if (font_exists(fontLP)) {
        draw_set_font(fontLP);
    } else {
        draw_set_font(-1); // Police par défaut
    }
    
    // Centrer le texte
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    
    // Dessiner le texte avec un effet d'ombre
    draw_set_color(c_black);
    draw_text_transformed(messageX + 3, messageY + 3, messageText, 2, 2, 0); // Ombre
    
    draw_set_color(messageColor);
    draw_text_transformed(messageX, messageY, messageText, 2, 2, 0); // Texte principal
    
    // Dessiner le bouton "Continuer" seulement si l'animation est terminée
    if (alpha >= targetAlpha) {
        // Calculer les limites du bouton
        var button_left = buttonX - buttonWidth / 2;
        var button_top = buttonY - buttonHeight / 2;
        var button_right = buttonX + buttonWidth / 2;
        var button_bottom = buttonY + buttonHeight / 2;
        
        // Couleur du bouton selon le survol
        var current_button_color = buttonHover ? #66BB6A : buttonColor; // Plus clair au survol
        
        // Dessiner l'ombre du bouton
        draw_set_color(c_black);
        draw_set_alpha(0.3);
        draw_rectangle(button_left + 3, button_top + 3, button_right + 3, button_bottom + 3, false);
        
        // Dessiner le fond du bouton
        draw_set_alpha(1);
        draw_set_color(current_button_color);
        draw_rectangle(button_left, button_top, button_right, button_bottom, false);
        
        // Dessiner le contour du bouton
        draw_set_color(c_white);
        draw_rectangle(button_left, button_top, button_right, button_bottom, true);
        
        // Dessiner le texte du bouton
        draw_set_color(buttonTextColor);
        draw_set_halign(fa_center);
        draw_set_valign(fa_middle);
        draw_text(buttonX, buttonY, buttonText);
    }
    
    // Remettre l'alignement par défaut
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
}

// Remettre l'alpha à 1 pour les autres objets
draw_set_alpha(1);