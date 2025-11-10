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

// --- Overlay texte (Hand & Field) : nom, star, genre, archetype, description, ATK/DEF ---
if (variable_instance_exists(self, "zone") && (zone == "Hand" || zone == "Field" || zone == "HandSelected" || zone == "FieldSelected")) {
    // Visibilité stricte par zone
    var can_show = true;
    if (zone == "Hand" || zone == "HandSelected") {
        can_show = (variable_instance_exists(self, "isHeroOwner") && isHeroOwner);
    } else if (zone == "Field" || zone == "FieldSelected") {
        // Sur le terrain, ne jamais afficher si face cachée (peu importe le propriétaire)
        var face_down = variable_instance_exists(self, "isFaceDown") && isFaceDown;
        can_show = !face_down;
    }

    if (can_show) {
        // Mise en place de l'overlay à l'échelle de la carte
        var spr = sprite_index;
        // Imposer une police et des alignements stables pour l'overlay
        if (font_exists(fontCardText)) draw_set_font(fontCardText);
        draw_set_halign(fa_left);
        draw_set_valign(fa_top);

        // Stabiliser l'overlay pendant les animations (flip/rotation)
        var s_layout = image_xscale;
        if (variable_instance_exists(self, "position_anim_active") && position_anim_active) {
            if (variable_instance_exists(self, "anim_flip_orig_scale")) {
                s_layout = anim_flip_orig_scale;
            }
        }
        var s = s_layout; // on suppose xscale == yscale
        var rel = s / 0.6;    // facteur relatif à la référence Collection (0.6)
        var mar_base = 7;
        var mar_s = mar_base * s; // marge proportionnelle à l'échelle
        var cw = sprite_get_width(spr) * s;
        var ch = sprite_get_height(spr) * s;
        var tlx = x - cw * 0.5;
        var tly = y - ch * 0.5;

        // Zones (coordonnées de référence basées sur la mise en page Collection)
        var name_x1 = 24,  name_y1 = 16;  var name_x2 = 387, name_y2 = 59;
        var star_x1 = 388, star_y1 = 16;  var star_x2 = 438, star_y2 = 60;
        var genre_x1 = 29, genre_y1 = 394; var genre_x2 = 223, genre_y2 = 419;
        var arch_x1  = 228, arch_y1  = 394; var arch_x2  = 422, arch_y2  = 419;
        var desc_x1  = 23,  desc_y1  = 438; var desc_x2  = 421, desc_y2  = 592;
        var atk_x1   = 303, atk_y1   = 594; var atk_x2   = 348, atk_y2   = 609;
        var def_x1   = 383, def_y1   = 594; var def_x2   = 421, def_y2   = 608;

        // Détection carte magique (masque STAR et ATK/DEF)
        var is_magic = object_is_ancestor(object_index, oCardMagic) || (variable_instance_exists(self, "type") && string_lower(string(type)) == "magic");

        // Police & couleur
        if (font_exists(fontCardText)) draw_set_font(fontCardText);
        draw_set_color(c_black);

        // Helpers
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
            var sc = (base_line_h > 0) ? max_px / base_line_h : 1; // cap max
            for (var it = 0; it < 3; it++) {
                var sep = base_line_h;               // séparation à l'échelle 1
                var w_eff = (sc > 0) ? (rw / sc) : rw; // largeur efficace à scale 1
                var h = string_height_ext(text, sep, w_eff); // hauteur à scale 1
                if (h <= 0) break;
                var s_h = rh / h;                    // sc pour que h*sc <= rh
                sc = min(sc, s_h);
            }
            return sc;
        };

        // Marges internes
        var pad = 0;

        // Masquer l'overlay pendant toute animation (flip/rotation/changement de position)
        var overlay_enabled = true;
        if (variable_instance_exists(self, "position_anim_active") && position_anim_active) {
            overlay_enabled = false;
        }

        // Orientation du texte: suivre l'angle de la carte sur le terrain
        // Attaque: 0° (héros) / 180° (adverse), Défense: 90° (héros) / 270° (adverse)
        var ang_overlay = 0;
        var face_down_f = (variable_instance_exists(self, "isFaceDown") && isFaceDown);
        if ((zone == "Field" || zone == "FieldSelected") && !face_down_f) {
            ang_overlay = image_angle;
        }
        // Préparer une rotation de groupe autour du centre de la carte
        var cos_overlay = dcos(ang_overlay);
        var sin_overlay = dsin(ang_overlay);
        var rotate_point = function(px, py, ang, c, s) {
            if (ang == 0) return [px, py];
            var dx = px - x;
            var dy = py - y;
            return [x + dx * c - dy * s, y + dx * s + dy * c];
        };

        // NAME (aligné à gauche, en haut)
        if (variable_instance_exists(self, "name")) {
            if (!overlay_enabled) {
                // ne rien dessiner pendant le flip
            } else {
            var tx = string(name);
            var rw = (name_x2 - name_x1) * s - pad * 2 - mar_s * 2;
            var rh = (name_y2 - name_y1) * s - pad * 2;
            var scale_t = fit_line(tx, 20 * rel, rw, rh);
            var left = tlx + name_x1 * s + pad + mar_s;
            var top  = tly + name_y1 * s + pad;
            var p_name = rotate_point(left, top + 2, ang_overlay, cos_overlay, sin_overlay);
            draw_text_transformed(p_name[0], p_name[1], tx, scale_t, scale_t, ang_overlay);
            }
        }

        // STAR (coût) — centré H/V
        if (!is_magic && variable_instance_exists(self, "star")) {
            if (!overlay_enabled) {
                // ne rien dessiner pendant le flip
            } else {
            var tx = string(star);
            var rw = (star_x2 - star_x1) * s - pad * 2;
            var rh = (star_y2 - star_y1) * s - pad * 2;
            var scale_t = fit_line(tx, 20 * rel, rw, rh);
            var left = tlx + star_x1 * s + pad;
            var top  = tly + star_y1 * s + pad;
            var base_line_h = string_height("Ag");
            var wsc  = string_width(tx) * scale_t;
            var hsc  = base_line_h * scale_t;
            var cx   = left + max(0, (rw - wsc) * 0.5);
            var cy   = top  + max(0, (rh - hsc) * 0.5);
            var p_star = rotate_point(cx, cy + 2, ang_overlay, cos_overlay, sin_overlay);
            draw_text_transformed(p_star[0], p_star[1], tx, scale_t, scale_t, ang_overlay);
            }
        }

        // GENRE (aligné à gauche, en haut)
        if (variable_instance_exists(self, "genre")) {
            if (!overlay_enabled) {
                // ne rien dessiner pendant le flip
            } else {
            var tx = string(genre);
            var rw = (genre_x2 - genre_x1) * s - pad * 2 - mar_s * 2;
            var rh = (genre_y2 - genre_y1) * s - pad * 2;
            var scale_t = fit_line(tx, 16 * rel, rw, rh);
            var left = tlx + genre_x1 * s + pad + mar_s;
            var top  = tly + genre_y1 * s + pad;
            var p_genre = rotate_point(left, top + 2, ang_overlay, cos_overlay, sin_overlay);
            draw_text_transformed(p_genre[0], p_genre[1], tx, scale_t, scale_t, ang_overlay);
            }
        }

        // ARCHETYPE (aligné à gauche, en haut)
        if (variable_instance_exists(self, "archetype")) {
            if (!overlay_enabled) {
                // ne rien dessiner pendant le flip
            } else {
            var tx = string(archetype);
            var rw = (arch_x2 - arch_x1) * s - pad * 2 - mar_s * 2;
            var rh = (arch_y2 - arch_y1) * s - pad * 2;
            var scale_t = fit_line(tx, 16 * rel, rw, rh);
            var left = tlx + arch_x1 * s + pad + mar_s;
            var top  = tly + arch_y1 * s + pad;
            var p_arch = rotate_point(left, top + 2, ang_overlay, cos_overlay, sin_overlay);
            draw_text_transformed(p_arch[0], p_arch[1], tx, scale_t, scale_t, ang_overlay);
            }
        }

        // DESCRIPTION (justifiée)
        if (variable_instance_exists(self, "description")) {
            var tx = string(description);
            var mar = 7;
            var rw = (desc_x2 - desc_x1) * s - pad * 2 - mar * 2;
            var rh = (desc_y2 - desc_y1) * s - pad * 2;
            var scale_t = fit_block(tx, 24 * rel, rw, rh);
            var left = tlx + desc_x1 * s + pad + mar;
            var top  = tly + desc_y1 * s + pad;
            var base_h = string_height("Ag");
            var line_h = base_h * scale_t;
            var space_w = string_width(" ") * scale_t;
            var dy = top + 2;

            var paragraphs = string_split(tx, "\n");
            for (var p = 0; p < array_length(paragraphs); p++) {
                var words = string_split(paragraphs[p], " ");
                var i = 0;
                while (i < array_length(words)) {
                    var line_words = [];
                    var count = 0;
                    var line_w = 0;
                    while (i < array_length(words)) {
                        var w = words[i];
                        var ww = string_width(w) * scale_t;
                        var plus_space = (count > 0) ? space_w : 0;
                        if (line_w + plus_space + ww <= rw) {
                            line_words[count] = w;
                            count += 1;
                            line_w += plus_space + ww;
                            i += 1;
                        } else {
                            break;
                        }
                    }

                    var gaps = max(0, count - 1);
                    var extra_gap = 0;
                    if (gaps > 0 && i < array_length(words)) {
                        var extra = rw - line_w;
                        var extra_raw = (extra > 0) ? (extra / gaps) : 0;
                        var max_extra_ratio = 0.5;
                        extra_gap = min(extra_raw, string_width(" ") * scale_t * max_extra_ratio);
                    }

                    var dx = left;
                    for (var j = 0; j < count; j++) {
                        var wj = line_words[j];
                        var p_desc = rotate_point(dx, dy, ang_overlay, cos_overlay, sin_overlay);
                        draw_text_transformed(p_desc[0], p_desc[1], wj, scale_t, scale_t, ang_overlay);
                        var wjw = string_width(wj) * scale_t;
                        if (j < count - 1) {
                            dx += wjw + space_w + extra_gap;
                        } else {
                            dx += wjw;
                        }
                    }

                    dy += line_h;
                    if (dy + line_h > top + rh) break;
                }
            }
        }

        // ATK/DEF (centrés H/V, 12px * rel)
        if (!is_magic && variable_instance_exists(self, "attack")) {
            var txa = string(attack);
            var rw_a = (atk_x2 - atk_x1) * s - pad * 2;
            var rh_a = (atk_y2 - atk_y1) * s - pad * 2;
            var left_a = tlx + atk_x1 * s + pad;
            var top_a  = tly + atk_y1 * s + pad - 2;
            var base_line_h = string_height("Ag");
            var scale_num = (base_line_h > 0) ? (12 * rel) / base_line_h : 1;
            var wsc_a  = string_width(txa) * scale_num;
            var hsc_a  = base_line_h * scale_num;
            var cx_a   = left_a + max(0, (rw_a - wsc_a) * 0.5);
            var cy_a   = top_a  + max(0, (rh_a - hsc_a) * 0.5);
            var p_atk = rotate_point(cx_a, cy_a, ang_overlay, cos_overlay, sin_overlay);
            draw_text_transformed(p_atk[0], p_atk[1], txa, scale_num, scale_num, ang_overlay);
        }
        if (!is_magic && variable_instance_exists(self, "defense")) {
            var txd = string(defense);
            var rw_d = (def_x2 - def_x1) * s - pad * 2;
            var rh_d = (def_y2 - def_y1) * s - pad * 2;
            var left_d = tlx + def_x1 * s + pad;
            var top_d  = tly + def_y1 * s + pad - 2;
            var base_line_h = string_height("Ag");
            var scale_num = (base_line_h > 0) ? (12 * rel) / base_line_h : 1;
            var wsc_d  = string_width(txd) * scale_num;
            var hsc_d  = base_line_h * scale_num;
            var cx_d   = left_d + max(0, (rw_d - wsc_d) * 0.5);
            var cy_d   = top_d  + max(0, (rh_d - hsc_d) * 0.5);
            var p_def = rotate_point(cx_d, cy_d, ang_overlay, cos_overlay, sin_overlay);
            draw_text_transformed(p_def[0], p_def[1], txd, scale_num, scale_num, ang_overlay);
        }
    }
}