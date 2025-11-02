// === oCardViewer - Draw GUI Event ===

// Affiche les boutons uniquement dans la room rCollection
if (room == rCollection) {
    // --- Menu déroulant filtre booster ---
    draw_set_font(fontStep);
    draw_set_halign(fa_left);
    draw_set_valign(fa_middle);
    var drop_x = dropdown_x;
    var drop_y = dropdown_y;
    var drop_w = dropdown_w;
    var drop_h = dropdown_h;
    
    // Cadre
    draw_set_color(c_dkgray);
    draw_rectangle(drop_x, drop_y, drop_x + drop_w, drop_y + drop_h, false);
    draw_set_color(c_black);
    draw_rectangle(drop_x, drop_y, drop_x + drop_w, drop_y + drop_h, true);
    draw_set_color(c_white);
    var current_label = dropdown_items[dropdown_selected_index];
    draw_text(drop_x + 8, drop_y + drop_h/2, "Booster: " + current_label);
    
    // Flèche
    var ax = drop_x + drop_w - 16;
    var ay = drop_y + drop_h/2;
    draw_triangle(ax - 6, ay - 3, ax + 6, ay - 3, ax, ay + 5, false);
    
    // Liste déroulante
    if (dropdown_open) {
        var item_h = drop_h;
        var list_h = array_length(dropdown_items) * item_h;
        var list_x1 = drop_x;
        var list_y1 = drop_y + drop_h + 2;
        var list_x2 = drop_x + drop_w;
        var list_y2 = list_y1 + list_h;
        draw_set_color(c_dkgray);
        draw_rectangle(list_x1, list_y1, list_x2, list_y2, false);
        draw_set_color(c_black);
        draw_rectangle(list_x1, list_y1, list_x2, list_y2, true);
        
        for (var i = 0; i < array_length(dropdown_items); i++) {
            var iy = list_y1 + i * item_h;
            // séparateurs
            draw_set_color(c_gray);
            draw_line(list_x1 + 2, iy, list_x2 - 2, iy);
            draw_set_color(c_white);
            draw_text(list_x1 + 8, iy + item_h/2, dropdown_items[i]);
        }
    }

    // --- Pagination: flèches et label Page X centrés sous les cartes ---
    var grid_center_x = startX + ((cardsPerRow - 1) * cardSpacing) / 2; // centre horizontal de la grille
    var btn_w = 28;
    var btn_h = drop_h;
    var gui_h = display_get_gui_height();
    var last_row_y = startY + (maxRows - 1) * cardSpacingVertical; // position de la dernière ligne
    var page_y = min(last_row_y + cardSpacingVertical - 20, gui_h - btn_h - 20); // bien sous les cartes

    var left_x1 = grid_center_x - 100 - btn_w;
    var left_y1 = page_y;
    var left_x2 = left_x1 + btn_w;
    var left_y2 = left_y1 + btn_h;
    var right_x1 = grid_center_x + 100;
    var right_y1 = page_y;
    var right_x2 = right_x1 + btn_w;
    var right_y2 = right_y1 + btn_h;

    // Bouton gauche
    draw_set_color(c_dkgray);
    draw_rectangle(left_x1, left_y1, left_x2, left_y2, false);
    draw_set_color(c_black);
    draw_rectangle(left_x1, left_y1, left_x2, left_y2, true);
    draw_set_color(c_white);
    draw_set_halign(fa_center);
    draw_text((left_x1 + left_x2)/2, (left_y1 + left_y2)/2, "<");

    // Bouton droit
    draw_set_color(c_dkgray);
    draw_rectangle(right_x1, right_y1, right_x2, right_y2, false);
    draw_set_color(c_black);
    draw_rectangle(right_x1, right_y1, right_x2, right_y2, true);
    draw_set_color(c_white);
    draw_set_halign(fa_center);
    draw_text((right_x1 + right_x2)/2, (right_y1 + right_y2)/2, ">");

    // Label Page X au centre
    draw_set_halign(fa_center);
    draw_set_color(c_white);
    draw_text(grid_center_x, page_y + btn_h/2, "Page " + string(currentPage));
    draw_set_halign(fa_left);

    // === AFFICHAGE DES 3 BOUTONS ===
    // Afficher uniquement quand une carte est selectionnee
    if (instance_exists(oCollectionCardDisplay) && 
        oCollectionCardDisplay.selectedCard != noone && 
        instance_exists(oCollectionCardDisplay.selectedCard)) {
        
        // Position du viewer de carte
        var viewer_x = oCollectionCardDisplay.x;
        var viewer_y = oCollectionCardDisplay.y;
        var display_scale = 0.6;
        var card_width = sprite_get_width(oCollectionCardDisplay.selectedCard.sprite_index) * display_scale;
        var card_height = sprite_get_height(oCollectionCardDisplay.selectedCard.sprite_index) * display_scale;
        
        // Position des cadres a gauche du viewer
    var frames_x = viewer_x - card_width/2 - 60; // 60 pixels a gauche du viewer
        var frames_start_y = viewer_y - card_height/2; // Commencer du haut de la carte
        
        // Espacement vertical entre les cadres
        var spacing = 50;
        
        // Premier cadre (en haut) avec un "+" vert
        draw_set_color(c_gray);
        draw_set_alpha(1);
        draw_rectangle(frames_x - 20, frames_start_y - 20, frames_x + 20, frames_start_y + 20, false);
        
        // Dessiner le "+" vert dans le premier cadre
        draw_set_color(c_lime);
        draw_set_alpha(1);
        // Ligne horizontale du "+"
        draw_line_width(frames_x - 10, frames_start_y, frames_x + 10, frames_start_y, 3);
        // Ligne verticale du "+"
        draw_line_width(frames_x, frames_start_y - 10, frames_x, frames_start_y + 10, 3);
        
        // Deuxieme cadre (au milieu) avec un "-" rouge
        draw_set_color(c_gray);
        draw_rectangle(frames_x - 20, frames_start_y + spacing - 20, frames_x + 20, frames_start_y + spacing + 20, false);
        
        // Dessiner le "-" rouge dans le deuxieme cadre
        draw_set_color(c_red);
        draw_set_alpha(1);
        // Ligne horizontale du "-"
        draw_line_width(frames_x - 10, frames_start_y + spacing, frames_x + 10, frames_start_y + spacing, 3);
        
        // Troisieme cadre (en bas) avec une etoile jaune
        draw_set_color(c_gray);
        draw_rectangle(frames_x - 20, frames_start_y + spacing * 2 - 20, frames_x + 20, frames_start_y + spacing * 2 + 20, false);
        
        // Dessiner l'etoile jaune dans le troisieme cadre
        draw_set_color(c_yellow);
        draw_set_alpha(1);
        var star_x = frames_x;
        var star_y = frames_start_y + spacing * 2;
        var star_size = 12;
        
        // Dessiner une etoile a 5 branches
         // Points exterieurs et interieurs de l'etoile
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
        
        // Dessiner l'etoile pleine en utilisant des triangles
        for (var i = 0; i < 5; i++) {
            var next_i = (i + 1) % 5;
            
            // Triangle du centre vers chaque branche de l'etoile
            draw_triangle(star_x, star_y, 
                         outer_points_x[i], outer_points_y[i], 
                         inner_points_x[i], inner_points_y[i], false);
            draw_triangle(star_x, star_y, 
                         inner_points_x[i], inner_points_y[i], 
                         outer_points_x[next_i], outer_points_y[next_i], false);
        }
    }
}