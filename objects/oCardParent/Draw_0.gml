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

// Si la carte est survolée (mais pas sélectionnée), dessiner un contour plus subtil
else if (isHovered) {
    draw_set_color(c_white);
    draw_set_alpha(0.5);
    draw_rectangle(x - sprite_width/2, y - sprite_height/2, x + sprite_width/2, y + sprite_height/2, true);
    draw_set_alpha(1);
}

 

// (overlay texte Hand/Field supprimé)

if (variable_instance_exists(self, "zone") && (zone == "Hand" || zone == "HandSelected" || zone == "Field" || zone == "FieldSelected")) {
    var face_down = (variable_instance_exists(self, "isFaceDown") && isFaceDown);
    var can_show = true;
    if (zone == "Hand" || zone == "HandSelected") {
        can_show = (variable_instance_exists(self, "isHeroOwner") && isHeroOwner);
    } else if (zone == "Field" || zone == "FieldSelected") {
        can_show = !face_down;
    }
    if (can_show) {
        var spr = sprite_index;
        var s = image_xscale;
        var cw = sprite_get_width(spr) * s;
        var ch = sprite_get_height(spr) * s;
        var tlx = x - cw * 0.5;
        var tly = y - ch * 0.5;
        var name_x1 = 24,  name_y1 = 16;  var name_x2 = 387, name_y2 = 59;
        var star_x1 = 388, star_y1 = 16;  var star_x2 = 438, star_y2 = 60;
        var genre_x1 = 29, genre_y1 = 394; var genre_x2 = 223, genre_y2 = 419;
        var arch_x1  = 228, arch_y1  = 394; var arch_x2  = 422, arch_y2  = 419;
        var desc_x1  = 23,  desc_y1  = 438; var desc_x2  = 421, desc_y2  = 592;
        var is_magic = object_is_ancestor(object_index, oCardMagic) || (variable_instance_exists(self, "type") && string_lower(string(type)) == "magic");
        if (font_exists(fontCardText)) draw_set_font(fontCardText);
        draw_set_halign(fa_left);
        draw_set_valign(fa_top);
        draw_set_color(c_black);
        var fit_line = function(text, max_px, rw, rh) {
            var base_line_h = string_height("Ag");
            var w0 = string_width(text);
            var h0 = base_line_h;
            var s_max = (h0 > 0) ? max_px / h0 : 1;
            var s_w = (w0 > 0) ? rw / w0 : s_max;
            var s_h = (h0 > 0) ? rh / h0 : s_max;
            return min(s_max, s_w, s_h);
        };
        var fit_block = function(text, max_px, rw, rh) {
            var base_line_h = string_height("Ag");
            var sc = (base_line_h > 0) ? max_px / base_line_h : 1;
            for (var it = 0; it < 3; it++) {
                var sep = base_line_h;
                var w_eff = (sc > 0) ? (rw / sc) : rw;
                var h = string_height_ext(text, sep, w_eff);
                if (h <= 0) break;
                var s_h2 = rh / h;
                sc = min(sc, s_h2);
            }
            return sc;
        };
        var pad = 0;
        var rel = s / 0.6;
        var mar = 7;
        var ang_overlay = 0;
        if ((zone == "Field" || zone == "FieldSelected") && !face_down) {
            if (variable_instance_exists(self, "orientation") && orientation == "DefenseVisible") {
                ang_overlay = image_angle;
            } else {
                var owner_hero = (variable_instance_exists(self, "isHeroOwner") && isHeroOwner);
                var a_norm = ((image_angle % 360) + 360) % 360;
                if (a_norm == 0 || a_norm == 90 || a_norm == 180 || a_norm == 270) {
                    ang_overlay = owner_hero ? image_angle : -image_angle;
                }
            }
        }
        var use_matrix = (ang_overlay != 0);
        var prev_world;
        if (use_matrix) {
            prev_world = matrix_get(matrix_world);
            var mat = matrix_build(x, y, 0, 0, 0, ang_overlay, 1, 1, 1);
            matrix_set(matrix_world, mat);
            tlx = -cw * 0.5;
            tly = -ch * 0.5;
        }
        var angle_draw = use_matrix ? 0 : ang_overlay;
        // Toujours aligner comme en Collection
        draw_set_halign(fa_left);
        draw_set_valign(fa_top);
        if (variable_instance_exists(self, "name")) {
            var tx = string(name);
            var rw = (name_x2 - name_x1) * s - pad * 2 - mar * 2;
            var rh = (name_y2 - name_y1) * s - pad * 2;
            var sc = fit_line(tx, 20 * rel, rw, rh);
            sc = round(sc * 20) / 20;
            var left = tlx + name_x1 * s + pad + mar;
            var top  = tly + name_y1 * s + pad;
            left = round(left);
            top  = round(top);
            draw_text_transformed(left, top + 2, tx, sc, sc, angle_draw);
        }
        if (!is_magic && variable_instance_exists(self, "star")) {
            var tx = string(star);
            var rw = (star_x2 - star_x1) * s - pad * 2;
            var rh = (star_y2 - star_y1) * s - pad * 2;
            var sc = fit_line(tx, 20 * rel, rw, rh);
            sc = round(sc * 20) / 20;
            var left = tlx + star_x1 * s + pad;
            var top  = tly + star_y1 * s + pad;
            var wsc  = string_width(tx) * sc;
            var cx   = left + max(0, (rw - wsc) * 0.5);
            cx = round(cx);
            top = round(top);
            draw_text_transformed(cx, top + 2, tx, sc, sc, angle_draw);
        }
        if (variable_instance_exists(self, "genre")) {
            var tx = string(genre);
            var rw = (genre_x2 - genre_x1) * s - pad * 2 - mar * 2;
            var rh = (genre_y2 - genre_y1) * s - pad * 2;
            var sc = fit_line(tx, 16 * rel, rw, rh);
            sc = round(sc * 20) / 20;
            var left_g = tlx + genre_x1 * s + pad + mar;
            var top_g  = tly + genre_y1 * s + pad;
            left_g = round(left_g);
            top_g  = round(top_g);
            draw_text_transformed(left_g, top_g + 2, tx, sc, sc, angle_draw);
        }
        if (variable_instance_exists(self, "archetype")) {
            var tx = string(archetype);
            var rw = (arch_x2 - arch_x1) * s - pad * 2 - mar * 2;
            var rh = (arch_y2 - arch_y1) * s - pad * 2;
            var sc = fit_line(tx, 16 * rel, rw, rh);
            sc = round(sc * 20) / 20;
            var left_a = tlx + arch_x1 * s + pad + mar;
            var top_a  = tly + arch_y1 * s + pad;
            left_a = round(left_a);
            top_a  = round(top_a);
            draw_text_transformed(left_a, top_a + 2, tx, sc, sc, angle_draw);
        }
        if (variable_instance_exists(self, "description")) {
            var tx = string(description);
            var rw = (desc_x2 - desc_x1) * s - pad * 2 - mar * 2;
            var rh = (desc_y2 - desc_y1) * s - pad * 2;
            var left = tlx + desc_x1 * s + pad + mar;
            var top  = tly + desc_y1 * s + pad;
            var base_h = string_height("Ag");
            var sc0 = (base_h > 0) ? (20 * rel) / base_h : 1;
            var sc = sc0;
            for (var ii = 0; ii < 8; ii++) {
                var w_pre = (sc > 0) ? (rw / sc) : rw;
                var h_un = string_height_ext(tx, base_h, w_pre);
                var h_sc = h_un * sc;
                if (h_sc <= rh) break;
                var k = rh / max(1, h_sc);
                sc *= max(0.6, min(0.95, k));
                sc = min(sc, sc0);
            }
            sc = round(sc * 20) / 20;
            left = round(left);
            top  = round(top);
            var w_eff = round(rw / sc);
            draw_text_ext_transformed(left, top + 2, tx, base_h, w_eff, sc, sc, angle_draw);
        }
        if (use_matrix) {
            matrix_set(matrix_world, prev_world);
        }
    }
}
