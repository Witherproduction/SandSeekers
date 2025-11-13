// === oCardViewer - Draw Event ===
// Afficher un badge numérique pour les cartes limitées à 1 ou 2

// Dessiner les badges au-dessus des cartes
if (is_array(cardInstances)) {
    for (var i = 0; i < array_length(cardInstances); i++) {
        var inst = cardInstances[i];
        if (inst == noone || !instance_exists(inst)) continue;

        // Lire la limite depuis l'instance
        var lim = 3;
        if (variable_instance_exists(inst, "limited")) {
            lim = real(inst.limited);
        }
        var show_badge = (is_real(lim) && lim < 3);

        // Couleur selon la limite
        var badge_color = c_red; // 1 -> rouge
        if (lim == 2) {
            badge_color = make_color_rgb(255, 128, 0); // 2 -> orange
        }

        // Calcul de la position (coin haut-gauche de la carte)
        var spr = inst.sprite_index;
        var w = (spr != -1) ? sprite_get_width(spr) * inst.image_xscale : 100;
        var h = (spr != -1) ? sprite_get_height(spr) * inst.image_yscale : 150;
        var tlx = inst.x - w * 0.5;
        var tly = inst.y - h * 0.5;

        if (show_badge) {
            // Dimensions et position du badge (rond)
            var margin = 6;
            var radius = 10; // plus petit qu'avant
            var cx = tlx + margin + radius;
            var cy = tly + margin + radius;

            // Dessiner le badge rond (rempli puis contour)
            draw_set_alpha(0.85);
            draw_set_color(badge_color);
            draw_circle(cx, cy, radius, false);

            draw_set_alpha(1);
            draw_set_color(c_black);
            draw_circle(cx, cy, radius, true);

            // Dessiner le chiffre plus petit au centre
            var prev_font = -1;
            var font_idx = asset_get_index("fontStep");
            if (font_idx != -1) {
                prev_font = draw_get_font();
                draw_set_font(font_idx);
            }
            draw_set_halign(fa_center);
            draw_set_valign(fa_middle);
            draw_set_color(c_white);
            // réduire la taille via transformation (moitié de la taille)
            draw_text_transformed(cx, cy, string(lim), 0.5, 0.5, 0);
            if (prev_font != -1) { draw_set_font(prev_font); }
        }

        // === Cadres verts + textes sur chaque carte (adaptés à l'échelle de l'instance) ===
        // Échelle proportionnelle au sprite de la carte dans la grille
        var s = min(inst.image_xscale, inst.image_yscale);
        if (spr != -1 && s > 0) {
            // Coordonnées de référence à l'échelle 1.0 (mêmes que le panneau détaillé)
            var name_x1 = 24,  name_y1 = 16;  var name_x2 = 387, name_y2 = 59;
            var star_x1 = 388, star_y1 = 16;  var star_x2 = 438, star_y2 = 60;
            var genre_x1 = 29, genre_y1 = 394; var genre_x2 = 223, genre_y2 = 419;
            var arch_x1  = 228, arch_y1  = 394; var arch_x2  = 422, arch_y2  = 419;
            var desc_x1  = 23,  desc_y1  = 438; var desc_x2  = 421, desc_y2  = 592;
            var atk_x1   = 303, atk_y1   = 594; var atk_x2   = 348, atk_y2   = 609;
            var def_x1   = 383, def_y1   = 594; var def_x2   = 421, def_y2   = 608;

            // Dessiner les cadres verts (contours) uniquement si le flag global est actif
            var show_frames = variable_global_exists("show_green_frames") && global.show_green_frames;
            if (show_frames) {
                draw_set_alpha(1);
                draw_set_color(c_lime);
                // name
                draw_rectangle(tlx + name_x1 * s, tly + name_y1 * s, tlx + name_x2 * s, tly + name_y2 * s, false);
                // star
                draw_rectangle(tlx + star_x1 * s, tly + star_y1 * s, tlx + star_x2 * s, tly + star_y2 * s, false);
                // genre
                draw_rectangle(tlx + genre_x1 * s, tly + genre_y1 * s, tlx + genre_x2 * s, tly + genre_y2 * s, false);
                // archetype
                draw_rectangle(tlx + arch_x1 * s, tly + arch_y1 * s, tlx + arch_x2 * s, tly + arch_y2 * s, false);
                // description
                draw_rectangle(tlx + desc_x1 * s, tly + desc_y1 * s, tlx + desc_x2 * s, tly + desc_y2 * s, false);
                // ATK
                draw_rectangle(tlx + atk_x1 * s, tly + atk_y1 * s, tlx + atk_x2 * s, tly + atk_y2 * s, false);
                // DEF
                draw_rectangle(tlx + def_x1 * s, tly + def_y1 * s, tlx + def_x2 * s, tly + def_y2 * s, false);
            }

            // Texte dans les cadres (ajusté à la zone)
            if (font_exists(fontCardText)) draw_set_font(fontCardText);
            draw_set_color(c_black);
            draw_set_halign(fa_left);
            draw_set_valign(fa_top);

            // Helpers de fit simples
            var fit_line = function(text, base_px, rw, rh) {
                var base_h = string_height("Ag");
                var w0 = string_width(text);
                var s_max = (base_h > 0) ? base_px / base_h : 1;
                var s_w = (w0 > 0) ? rw / w0 : s_max;
                var s_h = (base_h > 0) ? rh / base_h : s_max;
                return min(s_max, s_w, s_h);
            };

            var draw_block = function(text, base_px, rw, rh, left, top) {
                var base_h = string_height("Ag");
                var s_max = (base_h > 0) ? base_px / base_h : 1;
                var scale_t = s_max;
                var space_w = string_width(" ") * scale_t;
                var dy = top;
                var words = string_split(text, " ");
                var i = 0;
                while (i < array_length(words)) {
                    var line_w = 0;
                    var line_txt = "";
                    var count = 0;
                    while (i < array_length(words)) {
                        var wtxt = words[i];
                        var ww = string_width(wtxt) * scale_t;
                        var plus_space = (count > 0) ? space_w : 0;
                        if (line_w + plus_space + ww <= rw) {
                            line_txt = (count > 0) ? (line_txt + " " + wtxt) : wtxt;
                            line_w += plus_space + ww;
                            count += 1;
                            i += 1;
                        } else { break; }
                    }
                    draw_text_transformed(left, dy, line_txt, scale_t, scale_t, 0);
                    dy += string_height("Ag") * scale_t;
                    if (dy > top + rh) break;
                }
            };

            var pad = 2;
            var mar = 4;
            // Adapter l'échelle du texte à celle des cartes par rapport au panneau détaillé (0.6)
            var ref_display_scale = 0.6;
            var rel = (ref_display_scale != 0) ? (s / ref_display_scale) : s;
            var pad_s = pad * s;
            var mar_s = mar * s;
            // Détection carte magique pour masquer coût (star) et ATK/DEF
    var is_magic = object_is_ancestor(inst.object_index, oCardMagic) || (variable_instance_exists(inst, "type") && string_lower(string(inst.type)) == "magic");

            // NAME
            if (variable_instance_exists(inst, "name")) {
                var tx = string(inst.name);
                var rw = (name_x2 - name_x1) * s - pad_s * 2 - mar_s * 2;
                var rh = (name_y2 - name_y1) * s - pad_s * 2;
                var scale_t = fit_line(tx, 16 * rel, rw, rh);
                scale_t = round(scale_t * 20) / 20;
                var left = tlx + name_x1 * s + pad_s + mar_s;
                var top  = tly + name_y1 * s + pad_s;
                left = round(left);
                top  = round(top);
                draw_text_transformed(left, top + 2, tx, scale_t, scale_t, 0);
            }

            // STAR (coût) — ne pas afficher pour les cartes magiques
            if (!is_magic && variable_instance_exists(inst, "star")) {
                var tx = string(inst.star);
                var rw = (star_x2 - star_x1) * s - pad_s * 2;
                var rh = (star_y2 - star_y1) * s - pad_s * 2;
                var scale_t = fit_line(tx, 14 * rel, rw, rh);
                scale_t = round(scale_t * 20) / 20;
                var left = tlx + star_x1 * s + pad_s;
                var top  = tly + star_y1 * s + pad_s;
                var wsc  = string_width(tx) * scale_t;
                var cx   = left + max(0, (rw - wsc) * 0.5);
                cx = round(cx);
                top = round(top);
                draw_text_transformed(cx, top + 2, tx, scale_t, scale_t, 0);
            }

            // GENRE
            if (variable_instance_exists(inst, "genre")) {
                var tx = string(inst.genre);
                var rw = (genre_x2 - genre_x1) * s - pad_s * 2 - mar_s * 2;
                var rh = (genre_y2 - genre_y1) * s - pad_s * 2;
                var scale_t = fit_line(tx, 12 * rel, rw, rh);
                scale_t = round(scale_t * 20) / 20;
                var gx = tlx + genre_x1 * s + pad_s + mar_s;
                var gy = tly + genre_y1 * s + pad_s;
                gx = round(gx);
                gy = round(gy);
                draw_text_transformed(gx, gy + 2, tx, scale_t, scale_t, 0);
            }

            // ARCHETYPE
            if (variable_instance_exists(inst, "archetype")) {
                var tx = string(inst.archetype);
                var rw = (arch_x2 - arch_x1) * s - pad_s * 2 - mar_s * 2;
                var rh = (arch_y2 - arch_y1) * s - pad_s * 2;
                var scale_t = fit_line(tx, 12 * rel, rw, rh);
                scale_t = round(scale_t * 20) / 20;
                var ax = tlx + arch_x1 * s + pad_s + mar_s;
                var ay = tly + arch_y1 * s + pad_s;
                ax = round(ax);
                ay = round(ay);
                draw_text_transformed(ax, ay + 2, tx, scale_t, scale_t, 0);
            }

            // DESCRIPTION
            if (variable_instance_exists(inst, "description")) {
                var tx = string(inst.description);
                var rw = (desc_x2 - desc_x1) * s - pad_s * 2 - mar_s * 2;
                var rh = (desc_y2 - desc_y1) * s - pad_s * 2;
                var left = tlx + desc_x1 * s + pad_s + mar_s;
                var top  = tly + desc_y1 * s + pad_s;
                // Remplacer par wrap natif avec quantification et arrondi
                var base_h = string_height("Ag");
                var sc0 = (base_h > 0) ? (12 * rel) / base_h : 1;
                var sc = sc0;
                for (var ii = 0; ii < 5; ii++) {
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
                draw_text_ext_transformed(left, top + 2, tx, base_h, w_eff, sc, sc, 0);
            }

            // ATK/DEF — valeurs séparées, centrées H/V, taille réduite
            if (!is_magic) {
                var base_line_h = string_height("Ag");
                var scale_num = (base_line_h > 0) ? (12 * rel) / base_line_h : 1;
                scale_num = round(scale_num * 20) / 20;

                if (variable_instance_exists(inst, "attack")) {
                    var txa = string(inst.attack);
                    var rw_a = (atk_x2 - atk_x1) * s - pad_s * 2;
                    var rh_a = (atk_y2 - atk_y1) * s - pad_s * 2;
                    var left_a = tlx + atk_x1 * s + pad_s;
                    var top_a  = tly + atk_y1 * s + pad_s;
                    var wsc_a  = string_width(txa) * scale_num;
                    var hsc_a  = base_line_h * scale_num;
                    var cx_a   = left_a + max(0, (rw_a - wsc_a) * 0.5);
                    var cy_a   = top_a  + max(0, (rh_a - hsc_a) * 0.5);
                    cx_a = round(cx_a);
                    cy_a = round(cy_a);
                    draw_text_transformed(cx_a, cy_a, txa, scale_num, scale_num, 0);
                }

                if (variable_instance_exists(inst, "defense")) {
                    var txd = string(inst.defense);
                    var rw_d = (def_x2 - def_x1) * s - pad_s * 2;
                    var rh_d = (def_y2 - def_y1) * s - pad_s * 2;
                    var left_d = tlx + def_x1 * s + pad_s;
                    var top_d  = tly + def_y1 * s + pad_s;
                    var wsc_d  = string_width(txd) * scale_num;
                    var hsc_d  = base_line_h * scale_num;
                    var cx_d   = left_d + max(0, (rw_d - wsc_d) * 0.5);
                    var cy_d   = top_d  + max(0, (rh_d - hsc_d) * 0.5);
                    cx_d = round(cx_d);
                    cy_d = round(cy_d);
                    draw_text_transformed(cx_d, cy_d, txd, scale_num, scale_num, 0);
                }
            }
        }
    }
}