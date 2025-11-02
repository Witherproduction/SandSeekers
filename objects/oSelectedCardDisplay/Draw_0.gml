var card = noone;
if (variable_instance_exists(self, "selected")) {
    var sel = selected;
    // Aucune sélection: "" ou noone
    if (sel == "" || sel == noone) {
        // show_debug_message("### oSelectedCardDisplay.Draw - aucune sélection"); // désactivé pour éviter le spam
        exit;
    }
    // Accepter les références d'instance (type "ref") et ids numériques
    if (is_undefined(sel) || sel == noone) {
        // show_debug_message("### oSelectedCardDisplay.Draw - sélection undefined/noone, type=" + string(typeof(sel)) + ", valeur=" + string(sel));
        exit;
    }
    if (instance_exists(sel)) {
        card = sel;
        // show_debug_message("### oSelectedCardDisplay.Draw - carte sélectionnée id=" + string(card) + ", type=" + string(typeof(sel)));
    } else {
        // show_debug_message("### oSelectedCardDisplay.Draw - l'instance sélectionnée n'existe plus, type=" + string(typeof(sel)) + ", valeur=" + string(sel));
        exit;
    }
} else {
    // show_debug_message("### oSelectedCardDisplay.Draw - variable 'selected' absente sur l'instance");
    exit;
}
    // Initialisation du scroll pour la description
    if (!variable_instance_exists(self, "textScrollY")) textScrollY = 0;
    if (!variable_instance_exists(self, "scrollSpeed")) scrollSpeed = 20;
    if (!variable_instance_exists(self, "prev_card")) prev_card = noone;
    if (prev_card != card) {
        textScrollY = 0;
        prev_card = card;
    }

    var draw_x = 150;
    var draw_y = 250;
    var scale = 0.50;

    // Taille réelle du sprite affiché
    var sprite_w = sprite_get_width(card.sprite_index) * scale;
    var sprite_h = sprite_get_height(card.sprite_index) * scale;

    // Bord bas de la carte (pour positionner le texte en-dessous)
    var image_bottom = draw_y + sprite_h * 0.5;

    // --- Position du texte et du cadre ---
    var margin_top = 10;
    var margin_side = 10;
    var margin_bottom = 10;
    var text_x = draw_x - sprite_w * 0.5 + margin_side;
    var text_y = image_bottom + margin_top;
    var text_width = sprite_w - margin_side * 2;
    var line_height = 20;

    draw_set_font(fontCardDisplay);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);

    // --- Infos carte sous la carte (style rCollection) ---
    var margin = 8;
    var info_x = draw_x - sprite_w * 0.5 + margin;
    var info_y = draw_y + sprite_h * 0.5 + margin;
    var line_height = 20;

    // En-tête: nom, niveau, genre, archetype
    var info_head_lines = array_create(0);
    var display_name = "";
    if (variable_instance_exists(card, "name") && string_length(string_trim(card.name)) > 0) {
        display_name = card.name;
    } else {
        display_name = object_get_name(card.object_index);
    }
    array_push(info_head_lines, "Nom: " + string(display_name));
    if (variable_instance_exists(card, "star")) {
        array_push(info_head_lines, "Niveau: " + string(card.star));
    }
    if (variable_instance_exists(card, "genre") && string_length(string_trim(card.genre)) > 0) {
        array_push(info_head_lines, "Genre: " + string(card.genre));
    }
    if (variable_instance_exists(card, "archetype") && string_length(string_trim(card.archetype)) > 0) {
        array_push(info_head_lines, "Archetype: " + string(card.archetype));
    }

    // Description (wrapped)
    var desc_lines = array_create(0);
    if (variable_instance_exists(card, "description") && string_length(string_trim(card.description)) > 0) {
        array_push(desc_lines, "Description:");
        var desc_full = string(card.description);
        var max_width_info = sprite_w - margin * 2;
        var words_info = string_split(desc_full, " ");
        var line_info = "";
        for (var wi = 0; wi < array_length(words_info); wi++) {
            var try_line_info = line_info + words_info[wi] + " ";
            if (string_width(try_line_info) > max_width_info && string_length(line_info) > 0) {
                array_push(desc_lines, string_trim(line_info));
                line_info = words_info[wi] + " ";
            } else {
                line_info = try_line_info;
            }
        }
        if (string_length(line_info) > 0) {
            array_push(desc_lines, string_trim(line_info));
        }
    }

    // Rareté: intercalée entre archetype et description
    var rarity_present = variable_instance_exists(card, "rarity");
    
    // ATK/DEF: à placer entre rareté et description pour les monstres
    var is_monster = variable_instance_exists(card, "type") && card.type == "Monster";
    var has_attack_defense = is_monster && variable_instance_exists(card, "attack") && variable_instance_exists(card, "defense");

    // Cadre pour infos (largeur = carte + cadre rareté si présent) avec scroll pour la description
    var extra_border = 0;
    if (rarity_present) {
        var glow_intensity2 = getRarityGlowIntensity(card.rarity);
        if (glow_intensity2 > 0) extra_border = 6;
    }
    var frame_pad = 5;
    var rect_x1 = draw_x - sprite_w * 0.5 - extra_border;
    var rect_y1 = info_y - frame_pad;
    var rect_x2 = draw_x + sprite_w * 0.5 + extra_border;

    // Hauteur max: jusqu'au bas de l'écran (marge 10px)
    var frame_max_height = max(40, (room_height - 10) - rect_y1);
    var line_height = 20;
    var header_lines = array_length(info_head_lines) + (rarity_present ? 1 : 0) + (has_attack_defense ? 1 : 0);
    // Nombre max de lignes totales dans le cadre
    var max_lines = floor((frame_max_height - frame_pad * 2) / line_height);
    max_lines = max(max_lines, header_lines);

    var rect_y2 = rect_y1 + max_lines * line_height + frame_pad;

    // Dessiner le cadre
    draw_set_alpha(0.8);
    draw_set_color(c_black);
    draw_rectangle(rect_x1, rect_y1, rect_x2, rect_y2, false);
    draw_set_alpha(1);
    draw_set_color(c_white);

    // Position de l'aire de description (viewport)
    var info_start_y = info_y;
    var desc_view_y1 = info_start_y + header_lines * line_height;
    var desc_view_y2 = info_start_y + max_lines * line_height;
    var desc_view_h = max(0, desc_view_y2 - desc_view_y1);

    // Gestion du scroll (molette dans le viewport)
    var desc_total_h = array_length(desc_lines) * line_height;
    var maxScrollY = max(0, desc_total_h - desc_view_h);
    if (maxScrollY <= 0) textScrollY = 0;

    var mx = mouse_x;
    var my = mouse_y;
    var hover_desc = (mx >= rect_x1 && mx <= rect_x2 && my >= desc_view_y1 && my <= desc_view_y2);

    if (hover_desc) {
        if (mouse_wheel_down()) textScrollY = min(textScrollY + scrollSpeed, maxScrollY);
        if (mouse_wheel_up())   textScrollY = max(textScrollY - scrollSpeed, 0);
    }

    // Dessin de l'en-tête (non scrollé)
    var y_cursor = info_start_y;
    for (var i = 0; i < array_length(info_head_lines); i++) {
        draw_text(info_x, y_cursor, info_head_lines[i]);
        y_cursor += line_height;
    }
    if (rarity_present) {
        var rarity_color = getRarityColor(card.rarity);
        var rarity_name = getRarityDisplayName(card.rarity);
        draw_set_color(c_white);
        draw_text(info_x, y_cursor, "Rareté: ");
        var rarity_text_x = info_x + string_width("Rareté: ");
        draw_set_color(rarity_color);
        draw_text(rarity_text_x, y_cursor, rarity_name);
        draw_set_color(c_white);
        y_cursor += line_height;
    }
    
    // Dessin des stats ATK/DEF pour les monstres
    if (has_attack_defense) {
        draw_set_color(c_white);
        draw_text(info_x, y_cursor, "ATK: " + string(card.attack) + " / DEF: " + string(card.defense));
        y_cursor += line_height;
    }

    // Clipping et dessin de la description (scrollable)
    if (desc_view_h > 0) {
        gpu_set_scissor(rect_x1 + 1, desc_view_y1, (rect_x2 - rect_x1) - 2, desc_view_h);
        var base_y = desc_view_y1 - textScrollY;
        for (var j = 0; j < array_length(desc_lines); j++) {
            draw_text(info_x, base_y + j * line_height, desc_lines[j]);
        }
        gpu_set_scissor(0, 0, room_width, room_height);
    }

    // --- Affiche la carte en grand (après pour qu’elle soit toujours visible) ---
    if (card.isFaceDown && card.isHeroOwner) {
        draw_sprite_ext(card.sprite_index, 0, draw_x, draw_y, scale, scale, 0, c_white, 1);
    } else {
        draw_sprite_ext(card.sprite_index, card.image_index, draw_x, draw_y, scale, scale, 0, c_white, 1);
    }

    // === Panneau latéral droit pour les effets ===
    var side_width = 320;
    var side_x1 = draw_x + sprite_w * 0.5 + 20;
    var side_y1 = draw_y - sprite_h * 0.5;
    var side_x2 = side_x1 + side_width;
    var side_y2 = draw_y + sprite_h * 0.5;

    // Clamp pour rester dans l'écran
    if (side_x2 > room_width - 10) {
        side_x2 = room_width - 10;
        side_x1 = side_x2 - side_width;
    }
    if (side_x1 < 10) {
        side_x1 = 10;
        side_x2 = side_x1 + side_width;
    }
    if (side_y1 < 10) side_y1 = 10;
    if (side_y2 > room_height - 10) side_y2 = room_height - 10;

    draw_set_font(fontCardDisplay);
    draw_set_color(c_white);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);

    var eff_x = side_x1 + 10;
    var eff_y = side_y1 + 10;

    // Bloc 2 (rDuel) avec la même logique d'affichage que rCollection, mais à droite
    var has_named_effect = false;
    var named_index = -1;
    var selected_label = "";
    if (variable_instance_exists(card, "effects") && is_array(card.effects) && array_length(card.effects) > 0) {
        var fr_labels2 = array_create(10);
        fr_labels2[0] = "appel"; fr_labels2[1] = "appel spécialisé"; fr_labels2[2] = "perdu";
        fr_labels2[3] = "tombe"; fr_labels2[4] = "initialisation"; fr_labels2[5] = "finalisation"; fr_labels2[6] = "défenseur"; fr_labels2[7] = "empoisonneur"; fr_labels2[8] = "protecteur"; fr_labels2[9] = "Protecteur";
        for (var e = 0; e < array_length(card.effects); e++) {
            var effn = card.effects[e];
            var lbl2 = getEffectLabel(effn);
            var ok2 = false;
            for (var w2 = 0; w2 < array_length(fr_labels2); w2++) {
                if (lbl2 == fr_labels2[w2]) { ok2 = true; break; }
            }
            if (ok2) {
                has_named_effect = true;
                named_index = e;
                selected_label = lbl2;
                break;
            }
        }
    }

    if (has_named_effect) {
        // Construire la phrase: "<label> = ..." selon le trigger du premier effet correspondant
        var effd = card.effects[named_index];
        var label = selected_label;
        var desc_text = label + " = ";
        if (variable_instance_exists(effd, "trigger")) {
            desc_text += getTriggerDetailedDescription(effd.trigger);
        } else {
            desc_text += "activation manuelle";
        }
    
        // Dimensions: même logique de largeur que rCollection, adaptées au panneau droit
        var desc_width = max(100, floor(min(sprite_w, max(200, side_width - 20)) * 0.5));
        var wrap_width = desc_width; // largeur de retour à la ligne
        
        // Préparer les lignes pour connaître la hauteur
        var words = string_split(desc_text, " ");
        var current_line = "";
        var desc_lines2 = array_create(0);
        for (var j2 = 0; j2 < array_length(words); j2++) {
            var try_line2 = current_line + words[j2] + " ";
            if (string_width(try_line2) > wrap_width && string_length(current_line) > 0) {
                array_push(desc_lines2, string_trim(current_line));
                current_line = words[j2] + " ";
            } else {
                current_line = try_line2;
            }
        }
        if (string_length(current_line) > 0) {
            array_push(desc_lines2, string_trim(current_line));
        }
        
        // Cadre autour du bloc 2 (même style que rCollection)
        var frame_pad2 = 5;
        var rect2_x1 = eff_x - frame_pad2;
        var rect2_y1 = eff_y - frame_pad2;
        var rect2_x2 = eff_x + wrap_width + frame_pad2;
        var rect2_y2 = eff_y + array_length(desc_lines2) * line_height + frame_pad2;
        draw_set_alpha(0.8);
        draw_set_color(c_black);
        draw_rectangle(rect2_x1, rect2_y1, rect2_x2, rect2_y2, false);
        draw_set_alpha(1);
        draw_set_color(c_white);
        
        // Affichage des lignes
        for (var i2 = 0; i2 < array_length(desc_lines2); i2++) {
            draw_text(eff_x, eff_y + i2 * line_height, desc_lines2[i2]);
        }
    } else {
        draw_set_color(c_gray);
        draw_text(eff_x, eff_y, "Aucun effet");
        draw_set_color(c_white);
    }

    // --- Bloc 1: infos principales (nom, niveau, genre, archetype) ---
    // var right_panel_x = x + 260; // panneau à droite
    // var panel_margin = 12;
    // var line_height = 20;
    // var info_y = y - 120; // zone info sous le titre
    // 
    // var info_lines = array_create(0);
    // array_push(info_lines, "Nom: " + string(card.name));
    // if (variable_instance_exists(card, "star")) {
    //     array_push(info_lines, "Niveau: " + string(card.star));
    // }
    // if (variable_instance_exists(card, "genre") && string_length(string_trim(card.genre)) > 0) {
    //     array_push(info_lines, "Genre: " + string(card.genre));
    // }
    // if (variable_instance_exists(card, "archetype") && string_length(string_trim(card.archetype)) > 0) {
    //     array_push(info_lines, "Archetype: " + string(card.archetype));
    // }
    // 
    // // Affichage des infos
    // for (var i = 0; i < array_length(info_lines); i++) {
    //     draw_text(right_panel_x + panel_margin, info_y + i * line_height, info_lines[i]);
    // }
    
    // --- Bloc 2: description rapprochée de la carte --- (désactivé)
    // Supprimé pour éviter le cadre long à droite
