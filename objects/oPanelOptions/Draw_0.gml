/// @description Dessin du panneau d’options (cadre sFond centré)
var spr = asset_get_index("sFond");
if (spr != -1) {
    var sx = image_xscale;
    var sy = image_yscale;
    var w = sprite_get_width(spr);
    var h = sprite_get_height(spr);
    var ox = sprite_get_xoffset(spr);
    var oy = sprite_get_yoffset(spr);
    // Calculer la position de dessin pour que le centre visuel soit à (x,y)
    var draw_x = x - (w * 0.5 - ox) * sx;
    var draw_y = y - (h * 0.5 - oy) * sy;
    draw_sprite_ext(spr, 0, draw_x, draw_y, sx, sy, 0, image_blend, image_alpha);

    // Police UI et échelle visuelle réduite
    draw_set_font(fontStep);
    var ui_text_scale = 0.5;

    // Dimensions visuelles du panneau (utilisées pour le slider)
    var panel_w = w * sx;
    var panel_h = h * sy;

    // Dessiner le bouton "Retour" centré en bas de la zone intérieure (bbox basé sur origine centrée)
    var xoff = sprite_get_xoffset(spr);
    var yoff = sprite_get_yoffset(spr);
    var bboxL = sprite_get_bbox_left(spr);
    var bboxR = sprite_get_bbox_right(spr);
    var bboxT = sprite_get_bbox_top(spr);
    var bboxB = sprite_get_bbox_bottom(spr);
    var content_x1 = x - xoff * sx + bboxL * sx;
    var content_y1 = y - yoff * sy + bboxT * sy;
    var content_x2 = x - xoff * sx + bboxR * sx;
    var content_y2 = y - yoff * sy + bboxB * sy;
    var content_w = content_x2 - content_x1;
    // Utiliser la géométrie calculée dans Step pour le bouton Retour
    var btn_x1 = retour_btn_x1;
    var btn_y1 = retour_btn_y1;
    var btn_x2 = retour_btn_x2;
    var btn_y2 = retour_btn_y2;

    // Fond du bouton Retour
    draw_set_alpha(0.95);
    draw_set_color(make_color_rgb(40, 40, 40));
    draw_roundrect(btn_x1, btn_y1, btn_x2, btn_y2, false);
    
    // Bouton Abandonner (à côté du bouton Retour, uniquement en duel)
    if (abandon_enabled) {
        // Fond du bouton Abandonner (utilise la géométrie calculée dans Step)
        draw_set_alpha(0.95);
        draw_set_color(make_color_rgb(40, 40, 40));
        draw_roundrect(abandon_btn_x1, abandon_btn_y1, abandon_btn_x2, abandon_btn_y2, false);

        // Bordure rouge pour Abandonner
        draw_set_color(c_red);
        draw_roundrect(abandon_btn_x1, abandon_btn_y1, abandon_btn_x2, abandon_btn_y2, true);
    }

    // Bordure du bouton Retour
    draw_set_alpha(1);
    draw_set_color(make_color_rgb(220, 200, 120));
    draw_roundrect(btn_x1, btn_y1, btn_x2, btn_y2, true);

    // Libellé
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_set_color(c_white);
    draw_text_transformed((btn_x1 + btn_x2) * 0.5, (btn_y1 + btn_y2) * 0.5, "Retour", ui_text_scale, ui_text_scale, 0);
    
    // Texte du bouton Abandonner
    if (abandon_enabled) {
        var abandon_btn_center_x = (abandon_btn_x1 + abandon_btn_x2) * 0.5;
        var abandon_btn_center_y = (abandon_btn_y1 + abandon_btn_y2) * 0.5;
        draw_text_transformed(abandon_btn_center_x, abandon_btn_center_y, "Abandonner", ui_text_scale, ui_text_scale, 0);

        // Pop-up de confirmation
        if (abandon_confirm_open) {
            // Overlay semi-transparent
            draw_set_alpha(0.7);
            draw_set_color(c_black);
            draw_rectangle(0, 0, room_width, room_height, false);
            
            // Cadre de la pop-up
            draw_set_alpha(1);
            draw_set_color(make_color_rgb(40, 40, 40));
            draw_rectangle(confirm_box_x1, confirm_box_y1, confirm_box_x2, confirm_box_y2, false);
            
            // Bordure rouge
            draw_set_color(c_red);
            draw_rectangle(confirm_box_x1, confirm_box_y1, confirm_box_x2, confirm_box_y2, true);
            
            // Texte de confirmation
            draw_set_color(c_white);
            draw_set_halign(fa_center);
            draw_set_valign(fa_middle);
            draw_text_transformed(x, y - 20, "Voulez-vous abandonner ?", ui_text_scale, ui_text_scale, 0);
            
            // Bouton Oui (avec bordure rouge)
            draw_set_color(make_color_rgb(40, 40, 40));
            draw_rectangle(confirm_yes_x1, confirm_yes_y1, confirm_yes_x2, confirm_yes_y2, false);
            draw_set_color(c_red);
            draw_rectangle(confirm_yes_x1, confirm_yes_y1, confirm_yes_x2, confirm_yes_y2, true);
            draw_set_color(c_white);
            draw_text_transformed((confirm_yes_x1 + confirm_yes_x2) / 2, (confirm_yes_y1 + confirm_yes_y2) / 2, "Oui", ui_text_scale, ui_text_scale, 0);
            
            // Bouton Non
            draw_set_color(make_color_rgb(40, 40, 40));
            draw_rectangle(confirm_no_x1, confirm_no_y1, confirm_no_x2, confirm_no_y2, false);
            draw_set_color(make_color_rgb(220, 200, 120));
            draw_rectangle(confirm_no_x1, confirm_no_y1, confirm_no_x2, confirm_no_y2, true);
            draw_set_color(c_white);
            draw_text_transformed((confirm_no_x1 + confirm_no_x2) / 2, (confirm_no_y1 + confirm_no_y2) / 2, "Non", ui_text_scale, ui_text_scale, 0);
            
            // Réinitialiser les paramètres de dessin
            draw_set_halign(fa_left);
            draw_set_valign(fa_top);
            draw_set_alpha(1);
        }
    }
    
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);

    // ==========================
    // Slider Volume (0..100)
    // ==========================
    // Utilise les coordonnées calculées en Step pour aligner Draw et Step
    var track_x1 = vol_track_x1;
    var track_x2 = vol_track_x2;
    var track_y  = vol_track_y;
    var label_x  = vol_label_x;
    var label_y  = vol_label_y;

    // Encadré autour du libellé et de la barre (style du bouton Retour)
    var txt = "Volume";
    var sh = string_height(txt) * ui_text_scale;
    var label_top = label_y - sh * 0.5;
    var label_bottom = label_y + sh * 0.5;
    var track_top = track_y - 10;
    var track_bottom = track_y + 10;
    var pad = 8;
    var box_x1 = label_x - pad;
    var box_y1 = min(label_top, track_top) - pad;
    var box_x2 = track_x2 + 60; // inclure valeur numérique + 10px
    var box_y2 = max(label_bottom, track_bottom) + pad;

    // Fond
    draw_set_alpha(0.95);
    draw_set_color(make_color_rgb(40, 40, 40));
    draw_roundrect(box_x1, box_y1, box_x2, box_y2, false);
    // Bordure
    draw_set_alpha(1);
    draw_set_color(make_color_rgb(220, 200, 120));
    draw_roundrect(box_x1, box_y1, box_x2, box_y2, true);

    // Libellé à gauche
    draw_set_color(c_white);
    draw_set_halign(fa_left);
    draw_set_valign(fa_middle);
    draw_text_transformed(label_x, label_y, txt, ui_text_scale, ui_text_scale, 0);

    // Barre de fond
    draw_set_color(make_color_rgb(80, 80, 80));
    draw_set_alpha(0.9);
    draw_line_width(track_x1, track_y, track_x2, track_y, 8);

    // Remplissage jusqu'à la valeur
    var t = clamp((vol_value) / 100, 0, 1);
    var fill_x = lerp(track_x1, track_x2, t);
    draw_set_color(make_color_rgb(220, 200, 120));
    draw_line_width(track_x1, track_y, fill_x, track_y, 8);

    // Graduations tous les 10
    draw_set_color(c_white);
    draw_set_alpha(0.7);
    var steps = 10;
    for (var i = 0; i <= steps; i++) {
        var gx = lerp(track_x1, track_x2, i / steps);
        var gy1 = track_y - 10;
        var gy2 = track_y + 10;
        draw_line(gx, gy1, gx, gy2);
    }
    draw_set_alpha(1);

    // Curseur (knob)
    var knob_x = fill_x;
    var knob_y = track_y;
    draw_set_color(c_white);
    draw_circle(knob_x, knob_y, 10, false);
    draw_set_color(make_color_rgb(220, 200, 120));
    draw_circle(knob_x, knob_y, 8, false);

    // Valeur numérique (0-100) à droite du knob
    draw_set_color(c_white);
    draw_set_halign(fa_left);
    draw_set_valign(fa_middle);
    draw_text_transformed(knob_x + 12, knob_y, string(vol_value), ui_text_scale, ui_text_scale, 0);

    // ==========================
    // Encadré Plein écran + case à cocher
    // ==========================
    var fs_label_x_loc = fs_label_x;
    var fs_label_y_loc = fs_label_y;
    var fs_check_x1_loc = fs_check_x1;
    var fs_check_y1_loc = fs_check_y1;
    var fs_check_x2_loc = fs_check_x2;
    var fs_check_y2_loc = fs_check_y2;
    var fs_box_x1_loc = fs_box_x1;
    var fs_box_y1_loc = fs_box_y1;
    var fs_box_x2_loc = fs_box_x2;
    var fs_box_y2_loc = fs_box_y2;

    // Adapter la hauteur de l'encadré à la taille du texte
    var fs_label_h = string_height("Plein écran") * ui_text_scale;
    var fs_label_top = fs_label_y_loc - fs_label_h * 0.5;
    var fs_label_bottom = fs_label_y_loc + fs_label_h * 0.5;
    var fs_pad_draw = 8;
    var fs_box_y1_draw = min(fs_label_top, fs_check_y1_loc) - fs_pad_draw;
    var fs_box_y2_draw = max(fs_label_bottom, fs_check_y2_loc) + fs_pad_draw;

    // Fond et bordure (style identique au bouton Retour et Volume)
    draw_set_alpha(0.95);
    draw_set_color(make_color_rgb(40, 40, 40));
    draw_roundrect(fs_box_x1_loc, fs_box_y1_draw, fs_box_x2_loc, fs_box_y2_draw, false);
    draw_set_alpha(1);
    draw_set_color(make_color_rgb(220, 200, 120));
    draw_roundrect(fs_box_x1_loc, fs_box_y1_draw, fs_box_x2_loc, fs_box_y2_draw, true);

    // Libellé
    draw_set_color(c_white);
    draw_set_halign(fa_left);
    draw_set_valign(fa_middle);
    draw_text_transformed(fs_label_x_loc, fs_label_y_loc, "Plein écran", ui_text_scale, ui_text_scale, 0);

    // Case à cocher
    draw_set_color(c_white);
    draw_roundrect(fs_check_x1_loc, fs_check_y1_loc, fs_check_x2_loc, fs_check_y2_loc, false);
    draw_set_color(make_color_rgb(220, 200, 120));
    draw_roundrect(fs_check_x1_loc, fs_check_y1_loc, fs_check_x2_loc, fs_check_y2_loc, true);
    if (fs_enabled) {
        draw_set_color(make_color_rgb(220, 200, 120));
        var cx = (fs_check_x1_loc + fs_check_x2_loc) * 0.5;
        var cy = (fs_check_y1_loc + fs_check_y2_loc) * 0.5;
        draw_line(fs_check_x1_loc + 4, cy, cx - 2, fs_check_y2_loc - 4);
        draw_line(cx - 2, fs_check_y2_loc - 4, fs_check_x2_loc - 4, fs_check_y1_loc + 4);
    }

    // ==========================
    // Menu déroulant Résolution
    // ==========================
    var res_label_x_loc = res_label_x;
    var res_label_y_loc = res_label_y;
    var res_dropdown_x1_loc = res_dropdown_x1;
    var res_dropdown_y1_loc = res_dropdown_y1;
    var res_dropdown_x2_loc = res_dropdown_x2;
    var res_dropdown_y2_loc = res_dropdown_y2;
    var res_box_x1_loc = res_box_x1;
    var res_box_y1_loc = res_box_y1;
    var res_box_x2_loc = res_box_x2;
    var res_box_y2_loc = res_box_y2;

    // Adapter la hauteur de l'encadré à la taille du texte et du dropdown
    var res_label_h = string_height("Résolution") * ui_text_scale;
    var res_label_top = res_label_y_loc - res_label_h * 0.5;
    var res_label_bottom = res_label_y_loc + res_label_h * 0.5;
    var res_pad_draw = 8;
    var res_box_y1_draw = min(res_label_top, res_dropdown_y1_loc) - res_pad_draw;
    var res_box_y2_draw = max(res_label_bottom, res_dropdown_y2_loc) + res_pad_draw;

    // Fond et bordure du bloc principal (style identique aux autres)
    draw_set_alpha(0.95);
    draw_set_color(make_color_rgb(40, 40, 40));
    draw_roundrect(res_box_x1_loc, res_box_y1_draw, res_box_x2_loc, res_box_y2_draw, false);
    draw_set_alpha(1);
    draw_set_color(make_color_rgb(220, 200, 120));
    draw_roundrect(res_box_x1_loc, res_box_y1_draw, res_box_x2_loc, res_box_y2_draw, true);

    // Libellé
    draw_set_color(c_white);
    draw_set_halign(fa_left);
    draw_set_valign(fa_middle);
    draw_text_transformed(res_label_x_loc, res_label_y_loc, "Résolution", ui_text_scale, ui_text_scale, 0);

    // Menu déroulant principal
    draw_set_color(make_color_rgb(60, 60, 60));
    draw_roundrect(res_dropdown_x1_loc, res_dropdown_y1_loc, res_dropdown_x2_loc, res_dropdown_y2_loc, false);
    draw_set_color(make_color_rgb(220, 200, 120));
    draw_roundrect(res_dropdown_x1_loc, res_dropdown_y1_loc, res_dropdown_x2_loc, res_dropdown_y2_loc, true);

    // Texte de la résolution sélectionnée
    draw_set_color(c_white);
    draw_set_halign(fa_left);
    draw_set_valign(fa_middle);
    var selected_text = (resolution_selected >= 0 && resolution_selected < array_length(resolution_list)) ? 
                        resolution_list[resolution_selected] : "Inconnue";
    draw_text_transformed(res_dropdown_x1_loc + 8, (res_dropdown_y1_loc + res_dropdown_y2_loc) * 0.5, selected_text, ui_text_scale, ui_text_scale, 0);

    // Flèche déroulante
    draw_set_color(c_white);
    var arrow_x = res_dropdown_x2_loc - 15;
    var arrow_y = (res_dropdown_y1_loc + res_dropdown_y2_loc) * 0.5;
    if (resolution_dropdown_open) {
        // Flèche vers le haut
        draw_triangle(arrow_x - 4, arrow_y + 2, arrow_x + 4, arrow_y + 2, arrow_x, arrow_y - 3, false);
    } else {
        // Flèche vers le bas
        draw_triangle(arrow_x - 4, arrow_y - 2, arrow_x + 4, arrow_y - 2, arrow_x, arrow_y + 3, false);
    }

    // Liste déroulante (si ouverte)
    if (resolution_dropdown_open) {
        var res_item_h = 22;
        var res_list_h = array_length(resolution_list) * res_item_h;
        var res_list_x1 = res_dropdown_x1_loc;
        var res_list_y1 = res_dropdown_y2_loc;
        var res_list_x2 = res_dropdown_x2_loc;
        var res_list_y2 = res_list_y1 + res_list_h;

        // Fond de la liste
        draw_set_alpha(0.95);
        draw_set_color(make_color_rgb(50, 50, 50));
        draw_roundrect(res_list_x1, res_list_y1, res_list_x2, res_list_y2, false);
        draw_set_alpha(1);
        draw_set_color(make_color_rgb(220, 200, 120));
        draw_roundrect(res_list_x1, res_list_y1, res_list_x2, res_list_y2, true);

        // Éléments de la liste
        for (var i = 0; i < array_length(resolution_list); i++) {
            var item_y1 = res_list_y1 + i * res_item_h;
            var item_y2 = item_y1 + res_item_h;
            var item_center_y = (item_y1 + item_y2) * 0.5;

            // Surlignage si survolé
            if (resolution_hover_index == i) {
                draw_set_alpha(0.3);
                draw_set_color(make_color_rgb(220, 200, 120));
                draw_roundrect(res_list_x1 + 2, item_y1 + 1, res_list_x2 - 2, item_y2 - 1, false);
                draw_set_alpha(1);
            }

            // Surlignage si sélectionné
            if (resolution_selected == i) {
                draw_set_alpha(0.5);
                draw_set_color(make_color_rgb(120, 200, 120));
                draw_roundrect(res_list_x1 + 2, item_y1 + 1, res_list_x2 - 2, item_y2 - 1, false);
                draw_set_alpha(1);
            }

            // Texte de l'élément
            draw_set_color(c_white);
            draw_set_halign(fa_left);
            draw_set_valign(fa_middle);
            draw_text_transformed(res_list_x1 + 8, item_center_y, resolution_list[i], ui_text_scale, ui_text_scale, 0);

            // Ligne de séparation (sauf pour le dernier élément)
            if (i < array_length(resolution_list) - 1) {
                draw_set_alpha(0.3);
                draw_set_color(make_color_rgb(220, 200, 120));
                draw_line(res_list_x1 + 4, item_y2, res_list_x2 - 4, item_y2);
                draw_set_alpha(1);
            }
        }
    }

    // ==========================
    // Bouton Abandonner (room Duel uniquement)
    // ==========================
    if (abandon_enabled) {
        // Bouton principal
        var ab_x1 = abandon_btn_x1;
        var ab_y1 = abandon_btn_y1;
        var ab_x2 = abandon_btn_x2;
        var ab_y2 = abandon_btn_y2;

        // Fond
        draw_set_alpha(0.95);
        draw_set_color(make_color_rgb(30, 20, 20));
        draw_roundrect(ab_x1, ab_y1, ab_x2, ab_y2, false);
        // Bordure rouge
        draw_set_alpha(1);
        draw_set_color(c_red);
        draw_roundrect(ab_x1, ab_y1, ab_x2, ab_y2, true);

        // Libellé
        draw_set_color(c_white);
        draw_set_halign(fa_center);
        draw_set_valign(fa_middle);
        draw_text_transformed((ab_x1 + ab_x2) * 0.5, (ab_y1 + ab_y2) * 0.5, "Abandonner", ui_text_scale, ui_text_scale, 0);
        draw_set_halign(fa_left);
        draw_set_valign(fa_top);

        // Pop-up de confirmation
        if (abandon_confirm_open) {
            // Assombrir l'arrière-plan
            draw_set_alpha(0.5);
            draw_set_color(c_black);
            draw_rectangle(content_x1, content_y1, content_x2, content_y2, false);
            draw_set_alpha(1);

            var box_x1 = confirm_box_x1;
            var box_y1 = confirm_box_y1;
            var box_x2 = confirm_box_x2;
            var box_y2 = confirm_box_y2;

            // Fond de la boîte
            draw_set_alpha(0.95);
            draw_set_color(make_color_rgb(35, 35, 35));
            draw_roundrect(box_x1, box_y1, box_x2, box_y2, false);
            // Bordure rouge
            draw_set_alpha(1);
            draw_set_color(c_red);
            draw_roundrect(box_x1, box_y1, box_x2, box_y2, true);

            // Message de confirmation
            draw_set_color(c_white);
            draw_set_halign(fa_center);
            draw_set_valign(fa_middle);
            var msg_y = box_y1 + 30;
            draw_text_transformed((box_x1 + box_x2) * 0.5, msg_y, "Voulez-vous abandonner ?", ui_text_scale, ui_text_scale, 0);
            draw_set_halign(fa_left);
            draw_set_valign(fa_top);

            // Bouton Oui
            var yes_x1 = confirm_yes_x1;
            var yes_y1 = confirm_yes_y1;
            var yes_x2 = confirm_yes_x2;
            var yes_y2 = confirm_yes_y2;
            draw_set_alpha(0.95);
            draw_set_color(make_color_rgb(50, 30, 30));
            draw_roundrect(yes_x1, yes_y1, yes_x2, yes_y2, false);
            draw_set_alpha(1);
            draw_set_color(c_red);
            draw_roundrect(yes_x1, yes_y1, yes_x2, yes_y2, true);
            draw_set_color(c_white);
            draw_set_halign(fa_center);
            draw_set_valign(fa_middle);
            draw_text_transformed((yes_x1 + yes_x2) * 0.5, (yes_y1 + yes_y2) * 0.5, "Oui", ui_text_scale, ui_text_scale, 0);
            draw_set_halign(fa_left);
            draw_set_valign(fa_top);

            // Bouton Non
            var no_x1 = confirm_no_x1;
            var no_y1 = confirm_no_y1;
            var no_x2 = confirm_no_x2;
            var no_y2 = confirm_no_y2;
            draw_set_alpha(0.95);
            draw_set_color(make_color_rgb(40, 40, 40));
            draw_roundrect(no_x1, no_y1, no_x2, no_y2, false);
            draw_set_alpha(1);
            draw_set_color(make_color_rgb(220, 200, 120));
            draw_roundrect(no_x1, no_y1, no_x2, no_y2, true);
            draw_set_color(c_white);
            draw_set_halign(fa_center);
            draw_set_valign(fa_middle);
            draw_text_transformed((no_x1 + no_x2) * 0.5, (no_y1 + no_y2) * 0.5, "Non", ui_text_scale, ui_text_scale, 0);
            draw_set_halign(fa_left);
            draw_set_valign(fa_top);
        }
    }
}