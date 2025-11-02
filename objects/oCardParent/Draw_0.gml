// === oCardParent - Draw Event ===

// Dessiner la carte à sa position
draw_sprite_ext(sprite_index, image_index, x, y, image_xscale, image_yscale, image_angle, image_blend, image_alpha);

// --- Bordure de rareté pour les petites cartes ---
if (room == rCollection && variable_instance_exists(self, "rarity")) {
    var rarity_color = getRarityColor(rarity);
    var glow_intensity = getRarityGlowIntensity(rarity);
    
    if (glow_intensity > 0) {
        // Dessiner une bordure colorée selon la rareté
        draw_set_color(rarity_color);
        draw_set_alpha(glow_intensity * 0.7); // Moins intense pour les petites cartes
        
        // Bordure épaisse pour les petites cartes
        var border_thickness = 4;
        var card_w = sprite_get_width(sprite_index) * image_xscale;
        var card_h = sprite_get_height(sprite_index) * image_yscale;
        
        for (var i = 1; i <= border_thickness; i++) {
            draw_rectangle(x - card_w/2 - i, y - card_h/2 - i, 
                          x + card_w/2 + i, y + card_h/2 + i, true);
        }
        
        draw_set_alpha(1);
        draw_set_color(c_white);
    }
}

// Afficher l'étoile de favori si la carte est dans la collection et en favoris
if (room == rCollection && zone == "Collection") {
    var card_id = name;
    
    if (is_card_favorite(card_id)) {
        // Position de l'étoile en haut à gauche de la petite carte
        var star_x = x - (sprite_get_width(sprite_index) * image_xscale)/2 + 8;
        var star_y = y - (sprite_get_height(sprite_index) * image_yscale)/2 + 8;
        var star_size = 8;
        
        // Dessiner l'étoile jaune (même méthode que le bouton)
        draw_set_color(c_yellow);
        draw_set_alpha(1);
        
        // Points extérieurs et intérieurs de l'étoile
        var outer_points_x = [];
        var outer_points_y = [];
        var inner_points_x = [];
        var inner_points_y = [];
        
        for (var i = 0; i < 5; i++) {
            var angle_outer = (i * 72 - 90) * pi / 180; // -90 pour commencer par le haut
            var angle_inner = ((i * 72 + 36) - 90) * pi / 180;
            
            outer_points_x[i] = star_x + cos(angle_outer) * star_size;
            outer_points_y[i] = star_y + sin(angle_outer) * star_size;
            inner_points_x[i] = star_x + cos(angle_inner) * (star_size * 0.4);
            inner_points_y[i] = star_y + sin(angle_inner) * (star_size * 0.4);
        }
        
        // Dessiner l'étoile pleine en utilisant des triangles
        for (var i = 0; i < 5; i++) {
            var next_i = (i + 1) % 5;
            
            // Triangle du centre vers chaque branche de l'étoile
            draw_triangle(star_x, star_y, 
                         outer_points_x[i], outer_points_y[i], 
                         inner_points_x[i], inner_points_y[i], false);
            draw_triangle(star_x, star_y, 
                         inner_points_x[i], inner_points_y[i], 
                         outer_points_x[next_i], outer_points_y[next_i], false);
        }
        
        draw_set_alpha(1);
        draw_set_color(c_white);
    }
}

// Si la carte est sélectionnée, dessiner un contour
if (isSelected) {
    draw_set_color(c_yellow);
    draw_set_alpha(0.8);
    draw_rectangle(x - sprite_width/2, y - sprite_height/2, x + sprite_width/2, y + sprite_height/2, true);
    draw_set_alpha(1);
    draw_set_color(c_white);
}
// Si la carte est ciblable pour Floraison, dessiner un contour jaune
else if (isTargetableForFloraison) {
    draw_set_color(c_yellow);
    draw_set_alpha(0.6);
    // Dessiner un contour plus épais pour bien le distinguer
    for (var i = 0; i < 3; i++) {
        draw_rectangle(x - sprite_width/2 - i, y - sprite_height/2 - i, 
                      x + sprite_width/2 + i, y + sprite_height/2 + i, true);
    }
    draw_set_alpha(1);
    draw_set_color(c_white);
}
// Si la carte est survolée (mais pas sélectionnée), dessiner un contour plus subtil
else if (isHovered) {
    draw_set_color(c_white);
    draw_set_alpha(0.5);
    draw_rectangle(x - sprite_width/2, y - sprite_height/2, x + sprite_width/2, y + sprite_height/2, true);
    draw_set_alpha(1);
}