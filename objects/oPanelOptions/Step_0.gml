/// @description Logique du panneau d’options
// Se caler au centre de l’écran (détection de la vue visible)
var cam = noone;
// Activer le bouton Abandonner uniquement dans la room de duel
abandon_enabled = (room == rDuel);
if (view_enabled) {
    for (var i = 0; i < 8; i++) {
        if (view_visible[i]) { cam = view_camera[i]; break; }
    }
}

if (cam == noone) {
    // Fallback: centrer dans la room si les vues ne sont pas activées
    x = room_width * 0.5;
    y = room_height * 0.5;
} else {
    var cx = camera_get_view_x(cam) + camera_get_view_width(cam) * 0.5;
    var cy = camera_get_view_y(cam) + camera_get_view_height(cam) * 0.5;
    x = cx;
    y = cy;
}

// Bouton "Retour" interne (centré en bas du panneau) pour fermer le panel
var spr = asset_get_index("sFond");
if (spr != -1) {
    var sx = image_xscale;
    var sy = image_yscale;
    var w = sprite_get_width(spr);
    var h = sprite_get_height(spr);
    var ox = sprite_get_xoffset(spr);
    var oy = sprite_get_yoffset(spr);

    // Zone intérieure (contenu) basée sur le bbox du sprite centré
    var bboxL = sprite_get_bbox_left(spr);
    var bboxR = sprite_get_bbox_right(spr);
    var bboxT = sprite_get_bbox_top(spr);
    var bboxB = sprite_get_bbox_bottom(spr);
    var content_x1 = x - ox * sx + bboxL * sx;
    var content_y1 = y - oy * sy + bboxT * sy;
    var content_x2 = x - ox * sx + bboxR * sx;
    var content_y2 = y - oy * sy + bboxB * sy;
    var content_w = content_x2 - content_x1;
    var content_h = content_y2 - content_y1;

    // Dimensions et placement symétriques des boutons Retour et Abandonner
    var margin = 20;
    var raise_y = 20; // remonter légèrement pour éviter le bord
    var btn_w = 120;
    var btn_h = 40;
    var gap = 20; // "trou" au centre du cadre
    var content_center_x = (content_x1 + content_x2) * 0.5;
    var base_y1 = content_y2 - margin - btn_h - raise_y;
    var base_y2 = base_y1 + btn_h;

    // Bouton Retour (à gauche du centre)
    retour_btn_x2 = content_center_x - gap * 0.5;
    retour_btn_x1 = retour_btn_x2 - btn_w;
    retour_btn_y1 = base_y1;
    retour_btn_y2 = base_y2;

    // Bouton Abandonner (à droite du centre)
    abandon_btn_x1 = content_center_x + gap * 0.5;
    abandon_btn_x2 = abandon_btn_x1 + btn_w;
    abandon_btn_y1 = base_y1;
    abandon_btn_y2 = base_y2;

    // Clic pour fermer le panneau (bouton Retour)
    if (mouse_check_button_pressed(mb_left)) {
        if (point_in_rectangle(mouse_x, mouse_y, retour_btn_x1, retour_btn_y1, retour_btn_x2, retour_btn_y2)) {
            instance_destroy();
            exit;
        }
    }

    // ==========================
    // Slider Volume (0..100)
    // ==========================
    // Placement: en haut du cadre, longueur réduite de moitié
    var slider_margin_h = 40;     // marge latérale intérieure
    var slider_top = content_y1 + 170; // descendre encore plus (140 + 30)
    var offset_x = 20;            // petit décalage horizontal entre le label et la barre
    var label_w = 80;             // largeur réservée pour le libellé
    var slider_shift_x = 100;     // décalage vers la droite (+50 supplémentaire)
    var track_w = (content_w - slider_margin_h*2 - label_w - offset_x) * 0.6; // 60% dispo (indépendant du shift)
    var track_h = 6;
    var track_x1 = content_x1 + slider_margin_h + label_w + offset_x + slider_shift_x;
    var track_x2 = track_x1 + track_w;
    var track_y  = slider_top;

    // Conserver pour Draw
    vol_track_x1 = track_x1;
    vol_track_x2 = track_x2;
    vol_track_y  = track_y;
    vol_label_x  = content_x1 + slider_margin_h + slider_shift_x;
    vol_label_y  = track_y; // aligner au centre de la barre

    // Interaction: clic/drag sur la barre ou le curseur
    var knob_radius = 10;
    var knob_x = lerp(track_x1, track_x2, vol_value / 100);
    var knob_y = track_y;
    var over_track = point_in_rectangle(mouse_x, mouse_y, track_x1, track_y - 10, track_x2, track_y + 10);
    var over_knob  = point_distance(mouse_x, mouse_y, knob_x, knob_y) <= knob_radius + 3;

    // Démarrer le drag si clic sur la barre ou le knob
    if (mouse_check_button_pressed(mb_left)) {
        if (over_track || over_knob) {
            vol_dragging = true;
        }
    }
    // Mettre à jour pendant le drag
    if (vol_dragging && mouse_check_button(mb_left)) {
        var t = clamp((mouse_x - track_x1) / (track_x2 - track_x1), 0, 1);
        var new_val = round(t * 100);
        if (new_val != vol_value) {
            vol_value = new_val;
            global.volume_percent = vol_value;
            var _gain2 = vol_value / 100;
            audio_master_gain(_gain2);
        }
    }
    // Relâcher et persister la valeur
    if (vol_dragging && mouse_check_button_released(mb_left)) {
        vol_dragging = false;
        ini_open("options.ini");
        ini_write_real("audio", "volume_percent", vol_value);
        ini_close();
    }

    // ==========================
    // Bloc Plein écran (case à cocher)
    // ==========================
    var fs_pad = 8;
    var fs_top = track_y + 50; // placer sous le slider volume
    var fs_label_x_loc = content_x1 + slider_margin_h + slider_shift_x;
    var fs_label_y_loc = fs_top;
    var fs_check_size = 18;
    var fs_check_x1_loc = fs_label_x_loc + 150;
    var fs_check_y1_loc = fs_label_y_loc - fs_check_size * 0.5;
    var fs_check_x2_loc = fs_check_x1_loc + fs_check_size;
    var fs_check_y2_loc = fs_check_y1_loc + fs_check_size;

    // Conserver pour Draw
    fs_label_x = fs_label_x_loc;
    fs_label_y = fs_label_y_loc;
    fs_check_x1 = fs_check_x1_loc;
    fs_check_y1 = fs_check_y1_loc;
    fs_check_x2 = fs_check_x2_loc;
    fs_check_y2 = fs_check_y2_loc;
    fs_box_x1 = fs_label_x - fs_pad;
    fs_box_y1 = fs_check_y1 - fs_pad;
    fs_box_x2 = fs_check_x2 + fs_pad;
    fs_box_y2 = fs_check_y2 + fs_pad;

    // Interaction: clic sur la case à cocher (ou n'importe où dans l'encadré)
    if (mouse_check_button_pressed(mb_left)) {
        var over_check = point_in_rectangle(mouse_x, mouse_y, fs_check_x1, fs_check_y1, fs_check_x2, fs_check_y2);
        var over_box   = point_in_rectangle(mouse_x, mouse_y, fs_box_x1, fs_box_y1, fs_box_x2, fs_box_y2);
        if (over_check || over_box) {
            fs_enabled = !fs_enabled;
            window_set_fullscreen(fs_enabled);
            // Si on passe en mode fenêtré, définir une taille raisonnable et centrer
            if (!fs_enabled) {
                var ww = max(800, min(display_get_width(), 1280));
                var wh = max(600, min(display_get_height(), 720));
                window_set_size(ww, wh);
                window_center();
            }
            ini_open("options.ini");
            ini_write_real("display", "fullscreen", fs_enabled ? 1 : 0);
            ini_close();
        }
    }

    // ==========================
    // Menu déroulant Résolution
    // ==========================
    var res_pad = 8;
    var res_top = fs_box_y2 + 30; // placer sous le bloc plein écran
    var res_label_x_loc = content_x1 + slider_margin_h + slider_shift_x;
    var res_label_y_loc = res_top;
    var res_dropdown_w = 200;
    var res_dropdown_h = 25;
    var res_dropdown_x1_loc = res_label_x_loc + 120;
    var res_dropdown_y1_loc = res_top - res_dropdown_h * 0.5;
    var res_dropdown_x2_loc = res_dropdown_x1_loc + res_dropdown_w;
    var res_dropdown_y2_loc = res_dropdown_y1_loc + res_dropdown_h;

    // Conserver pour Draw
    res_label_x = res_label_x_loc;
    res_label_y = res_label_y_loc;
    res_dropdown_x1 = res_dropdown_x1_loc;
    res_dropdown_y1 = res_dropdown_y1_loc;
    res_dropdown_x2 = res_dropdown_x2_loc;
    res_dropdown_y2 = res_dropdown_y2_loc;
    res_box_x1 = res_label_x - res_pad;
    res_box_y1 = res_dropdown_y1 - res_pad;
    res_box_x2 = res_dropdown_x2 + res_pad;
    res_box_y2 = res_dropdown_y2 + res_pad;

    // Géométrie de la liste déroulante (quand ouverte)
    var res_item_h = 22;
    var res_list_h = array_length(resolution_list) * res_item_h;
    var res_list_x1 = res_dropdown_x1;
    var res_list_y1 = res_dropdown_y2;
    var res_list_x2 = res_dropdown_x2;
    var res_list_y2 = res_list_y1 + res_list_h;

    // Interaction: clic sur le menu déroulant principal
    if (mouse_check_button_pressed(mb_left)) {
        var over_dropdown = point_in_rectangle(mouse_x, mouse_y, res_dropdown_x1, res_dropdown_y1, res_dropdown_x2, res_dropdown_y2);
        
        if (over_dropdown) {
            // Basculer l'état ouvert/fermé
            resolution_dropdown_open = !resolution_dropdown_open;
        } else if (resolution_dropdown_open) {
            // Vérifier si on clique sur un élément de la liste
            var over_list = point_in_rectangle(mouse_x, mouse_y, res_list_x1, res_list_y1, res_list_x2, res_list_y2);
            if (over_list) {
                // Calculer quel élément est cliqué
                var clicked_index = floor((mouse_y - res_list_y1) / res_item_h);
                if (clicked_index >= 0 && clicked_index < array_length(resolution_list)) {
                    // Sélectionner cette résolution
                    resolution_selected = clicked_index;
                    resolution_dropdown_open = false;
                    
                    // Appliquer la nouvelle résolution
                    var res_str = resolution_list[resolution_selected];
                    var x_pos = string_pos("x", res_str);
                    if (x_pos > 0) {
                        var new_w = real(string_copy(res_str, 1, x_pos - 1));
                        var new_h = real(string_copy(res_str, x_pos + 1, string_length(res_str) - x_pos));
                        
                        // Appliquer la résolution seulement si on n'est pas en plein écran
                        if (!fs_enabled) {
                            window_set_size(new_w, new_h);
                            window_center();
                        }
                        
                        // Persister dans options.ini
                        ini_open("options.ini");
                        ini_write_string("display", "resolution", res_str);
                        ini_close();
                    }
                }
            } else {
                // Clic en dehors de la liste, fermer le menu
                resolution_dropdown_open = false;
            }
        }
    }

    // Gestion du survol pour la liste déroulante
    resolution_hover_index = -1;
    if (resolution_dropdown_open) {
        var over_list = point_in_rectangle(mouse_x, mouse_y, res_list_x1, res_list_y1, res_list_x2, res_list_y2);
        if (over_list) {
            resolution_hover_index = floor((mouse_y - res_list_y1) / res_item_h);
            if (resolution_hover_index < 0 || resolution_hover_index >= array_length(resolution_list)) {
                resolution_hover_index = -1;
            }
        }
    }

    // ==========================
    // Bouton Abandonner (à côté du bouton Retour, seulement en duel)
    // ==========================
    if (abandon_enabled) {
        // Géométrie déjà calculée ci-dessus pour la symétrie autour du centre

        // Ouvrir la confirmation si clic sur le bouton
        if (!abandon_confirm_open && mouse_check_button_pressed(mb_left)) {
            if (point_in_rectangle(mouse_x, mouse_y, abandon_btn_x1, abandon_btn_y1, abandon_btn_x2, abandon_btn_y2)) {
                abandon_confirm_open = true;
                abandon_confirm_block = true; // empêche le clic courant de fermer immédiatement

                // Définir la géométrie de la pop-up de confirmation
                var box_w = 360;
                var box_h = 120;
                var box_x1 = x - box_w * 0.5;
                var box_y1 = y - box_h * 0.5;
                var box_x2 = box_x1 + box_w;
                var box_y2 = box_y1 + box_h;

                // Conserver pour Draw
                confirm_box_x1 = box_x1;
                confirm_box_y1 = box_y1;
                confirm_box_x2 = box_x2;
                confirm_box_y2 = box_y2;

                // Boutons Oui / Non
                var cbtn_w = 120;
                var cbtn_h = 32;
                var pad = 30;
                var yes_x1 = box_x1 + pad;
                var yes_y1 = box_y2 - pad - cbtn_h;
                var yes_x2 = yes_x1 + cbtn_w;
                var yes_y2 = yes_y1 + cbtn_h;
                var no_x2 = box_x2 - pad;
                var no_x1 = no_x2 - cbtn_w;
                var no_y1 = yes_y1;
                var no_y2 = yes_y2;

                confirm_yes_x1 = yes_x1;
                confirm_yes_y1 = yes_y1;
                confirm_yes_x2 = yes_x2;
                confirm_yes_y2 = yes_y2;
                confirm_no_x1 = no_x1;
                confirm_no_y1 = no_y1;
                confirm_no_x2 = no_x2;
                confirm_no_y2 = no_y2;
            }
        }

        // Pop-up de confirmation
        if (abandon_confirm_open) {
            // Lever le blocage après relâchement du clic d'ouverture
            if (abandon_confirm_block) {
                if (mouse_check_button_released(mb_left)) {
                    abandon_confirm_block = false;
                }
            }
            // Gestion des clics dans la pop-up (uniquement quand non bloqué)
            if (!abandon_confirm_block && mouse_check_button_pressed(mb_left)) {
                var clickYes = point_in_rectangle(mouse_x, mouse_y, confirm_yes_x1, confirm_yes_y1, confirm_yes_x2, confirm_yes_y2);
                var clickNo  = point_in_rectangle(mouse_x, mouse_y, confirm_no_x1, confirm_no_y1, confirm_no_x2, confirm_no_y2);
                if (clickYes) {
                    // Mettre les LP du héros à 0 pour provoquer la défaite, puis fermer le panneau
                    var lpInst = instance_find(oLP_Hero, 0);
                    if (lpInst != noone) {
                        loseLP(lpInst.nbLP);
                    }
                    instance_destroy();
                } else if (clickNo) {
                    abandon_confirm_open = false;
                } else {
                    // Clic hors de la boîte = fermer
                    var outside = !point_in_rectangle(mouse_x, mouse_y, confirm_box_x1, confirm_box_y1, confirm_box_x2, confirm_box_y2);
                    if (outside) abandon_confirm_open = false;
                }
            }
        }
    }
}