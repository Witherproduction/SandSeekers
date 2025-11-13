// Affiche uniquement la dernière carte du cimetière, si elle existe
if (array_length(cards) > 0) {
    var lastCardData = cards[array_length(cards) - 1];
    
    if (is_struct(lastCardData)) {
        var ang = isHeroOwner ? 0 : 180;
        draw_sprite_ext(lastCardData.sprite_index, lastCardData.image_index, x, y, 0.25, 0.25, ang, c_white, 1);
        var s = 0.25;
        var spr = lastCardData.sprite_index;
        var cw = sprite_get_width(spr) * s;
        var ch = sprite_get_height(spr) * s;
        var name_x1 = 24,  name_y1 = 16;  var name_x2 = 387, name_y2 = 59;
        var star_x1 = 388, star_y1 = 16;  var star_x2 = 438, star_y2 = 60;
        var genre_x1 = 29, genre_y1 = 394; var genre_x2 = 223, genre_y2 = 419;
        var arch_x1  = 228, arch_y1  = 394; var arch_x2  = 422, arch_y2  = 419;
        var desc_x1  = 23,  desc_y1  = 438; var desc_x2  = 421, desc_y2  = 592;
        var is_magic = (variable_struct_exists(lastCardData, "cardType") && string_lower(string(lastCardData.cardType)) == "magic");
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
        var prev_world = matrix_get(matrix_world);
        var mat = matrix_build(x, y, 0, 0, 0, ang, 1, 1, 1);
        matrix_set(matrix_world, mat);
        var tlx = -cw * 0.5;
        var tly = -ch * 0.5;
        if (variable_struct_exists(lastCardData, "name")) {
            var tx = string(lastCardData.name);
            var rw = (name_x2 - name_x1) * s - pad * 2 - mar * 2;
            var rh = (name_y2 - name_y1) * s - pad * 2;
            var sc = fit_line(tx, 20 * rel, rw, rh);
            var left = tlx + name_x1 * s + pad + mar;
            var top  = tly + name_y1 * s + pad;
            draw_text_transformed(left, top + 2, tx, sc, sc, 0);
        }
        if (!is_magic && variable_struct_exists(lastCardData, "star")) {
            var tx = string(lastCardData.star);
            var rw = (star_x2 - star_x1) * s - pad * 2;
            var rh = (star_y2 - star_y1) * s - pad * 2;
            var sc = fit_line(tx, 20 * rel, rw, rh);
            var left = tlx + star_x1 * s + pad;
            var top  = tly + star_y1 * s + pad;
            var wsc  = string_width(tx) * sc;
            var cx   = left + max(0, (rw - wsc) * 0.5);
            draw_text_transformed(cx, top + 2, tx, sc, sc, 0);
        }
        if (variable_struct_exists(lastCardData, "genre")) {
            var tx = string(lastCardData.genre);
            var rw = (genre_x2 - genre_x1) * s - pad * 2 - mar * 2;
            var rh = (genre_y2 - genre_y1) * s - pad * 2;
            var sc = fit_line(tx, 16 * rel, rw, rh);
            var left_g = tlx + genre_x1 * s + pad + mar;
            var top_g  = tly + genre_y1 * s + pad;
            draw_text_transformed(left_g, top_g + 0, tx, sc, sc, 0);
        }
        if (variable_struct_exists(lastCardData, "archetype")) {
            var tx = string(lastCardData.archetype);
            var rw = (arch_x2 - arch_x1) * s - pad * 2 - mar * 2;
            var rh = (arch_y2 - arch_y1) * s - pad * 2;
            var sc = fit_line(tx, 16 * rel, rw, rh);
            var left_a = tlx + arch_x1 * s + pad + mar;
            var top_a  = tly + arch_y1 * s + pad;
            draw_text_transformed(left_a, top_a + 0, tx, sc, sc, 0);
        }
        if (variable_struct_exists(lastCardData, "description")) {
            var tx = string(lastCardData.description);
            var rw = (desc_x2 - desc_x1) * s - pad * 2 - mar * 2;
            var rh = (desc_y2 - desc_y1) * s - pad * 2;
            var sc = fit_block(tx, 24 * rel, rw, rh);
            var left = tlx + desc_x1 * s + pad + mar;
            var top  = tly + desc_y1 * s + pad;
            var base_h = string_height("Ag");
            var line_h = base_h * sc;
            var space_w = string_width(" ") * sc;
            var dy = top + 2;
            var paragraphs = string_split(tx, "\n");
            for (var p_i = 0; p_i < array_length(paragraphs); p_i++) {
                var words = string_split(paragraphs[p_i], " ");
                var i = 0;
                while (i < array_length(words)) {
                    var line_words = [];
                    var count = 0;
                    var line_w = 0;
                    while (i < array_length(words)) {
                        var w = words[i];
                        var ww = string_width(w) * sc;
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
                        extra_gap = min(extra_raw, string_width(" ") * sc * max_extra_ratio);
                    }
                    var dx = left;
                    for (var j = 0; j < count; j++) {
                        var wj = line_words[j];
                        draw_text_transformed(dx, dy, wj, sc, sc, 0);
                        var wjw = string_width(wj) * sc;
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
        matrix_set(matrix_world, prev_world);
    } else if (instance_exists(lastCardData)) {
        // Compatibilité avec anciennes entrées poussées comme instance
        var ang2 = isHeroOwner ? 0 : 180;
        draw_sprite_ext(lastCardData.sprite_index, lastCardData.image_index, x, y, 0.25, 0.25, ang2, c_white, 1);
    } else {
        // Instance invalide: ne rien dessiner pour éviter les erreurs
    }
}
