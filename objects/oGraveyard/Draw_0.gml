// Affiche uniquement la dernière carte du cimetière, si elle existe
if (array_length(cards) > 0) {
    var lastCardData = cards[array_length(cards) - 1];
    
    if (is_struct(lastCardData)) {
        draw_sprite_ext(
            lastCardData.sprite_index,
            lastCardData.image_index,
            x, y,
            0.25,
            0.25,
            0,
            c_white,
            1
        );
    } else if (instance_exists(lastCardData)) {
        // Compatibilité avec anciennes entrées poussées comme instance
        draw_sprite_ext(
            lastCardData.sprite_index,
            lastCardData.image_index,
            x, y,
            0.25,
            0.25,
            0,
            c_white,
            1
        );
    } else {
        // Instance invalide: ne rien dessiner pour éviter les erreurs
    }
}
