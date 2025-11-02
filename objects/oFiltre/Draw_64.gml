// === oFiltre - Draw GUI Event ===

// Affiche uniquement dans la room rCollection
if (room == rCollection) {
    // Couleur de fond selon l'état du champ
    // Actif: utiliser le même brun que les boutons de tri cliqués
    var tri_active_fill = make_color_rgb(120, 90, 45);
    var currentBoxColor = isTyping ? tri_active_fill : boxColor;

    // Dessiner le fond de la barre de filtre avec le sprite sButton
    // Réduction de la HAUTEUR du sprite (85%), centré verticalement, largeur inchangée
    var spriteWidth = filterBarWidth * 0.97; // réduction très légère de la longueur
    var spriteHeight = filterBarHeight * 0.85;
    var spriteX = filterBarX + (filterBarWidth - spriteWidth) / 2; // centré horizontalement
    var spriteY = filterBarY + (filterBarHeight - spriteHeight) / 2;
    draw_sprite_stretched(sButton, 0, spriteX, spriteY, spriteWidth, spriteHeight);

    // Dessiner le champ de texte (centré dans la barre)
    draw_set_color(currentBoxColor);
    draw_rectangle(filterBoxX, filterBoxY, filterBoxX + filterBoxWidth, filterBoxY + filterBoxHeight, false);
    draw_set_color(borderColor);
    draw_rectangle(filterBoxX, filterBoxY, filterBoxX + filterBoxWidth, filterBoxY + filterBoxHeight, true);

    // Style du texte (ombre + crème dorée)
    var text_shadow_color = make_color_rgb(80, 50, 20);
    // Texte en crème dans tous les états (plus lisible sur fond brun actif)
    var text_main_color = textColor;
    var textScale = 0.85;

    // Préparer le rendu du texte dans le champ (placeholder si vide)
    draw_set_font(filterFont);
    draw_set_halign(fa_left);
    draw_set_valign(fa_middle);
    var textX = filterBoxX + 10;
    var textY = filterBoxY + filterBoxHeight/2;

    // Placeholder "Filtre" quand vide; sinon, afficher le texte saisi
    if (string_length(filterText) == 0) {
        if (isTyping) {
            // Champ sélectionné: sans ombre
            draw_set_color(text_main_color);
            draw_text_transformed(textX, textY, "Filtre", textScale, textScale, 0);
        } else {
            // Au repos: avec ombre
            draw_set_color(text_shadow_color);
            draw_text_transformed(textX + 2, textY + 2, "Filtre", textScale, textScale, 0);
            draw_set_color(text_main_color);
            draw_text_transformed(textX, textY, "Filtre", textScale, textScale, 0);
        }
    } else {
        var displayText = filterText;
        if (isTyping && (current_time % 1000 < 500)) {
            displayText += "|"; // Curseur clignotant
        }
        if (isTyping) {
            // Champ sélectionné: sans ombre
            draw_set_color(text_main_color);
            draw_text_transformed(textX, textY, displayText, textScale, textScale, 0);
        } else {
            // Au repos: avec ombre
            draw_set_color(text_shadow_color);
            draw_text_transformed(textX + 2, textY + 2, displayText, textScale, textScale, 0);
            draw_set_color(text_main_color);
            draw_text_transformed(textX, textY, displayText, textScale, textScale, 0);
        }
    }

    // Reset des paramètres de dessin
    draw_set_color(c_white);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
}