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
    // Échelle du viewer en duel (revenue à 0.50 comme demandé)
    var scale = 0.50;
    // Échelle relative par rapport à la référence de la collection (0.6)
    var rel = scale / 0.6;

    // Taille réelle du sprite affiché
    var sprite_w = sprite_get_width(card.sprite_index) * scale;
    var sprite_h = sprite_get_height(card.sprite_index) * scale;

    // Bord bas de la carte (pour positionner le texte en-dessous)
    var image_bottom = draw_y + sprite_h * 0.5;

    // --- Position du texte et du cadre ---
    var margin_top = round(10 * rel);
    var margin_side = round(10 * rel);
    var margin_bottom = round(10 * rel);
    var text_x = draw_x - sprite_w * 0.5 + margin_side;
    var text_y = image_bottom + margin_top;
    var text_width = sprite_w - margin_side * 2;
    // Police et mise à l’échelle cohérentes avec la collection
    draw_set_font(fontCardText);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);

    // Échelle de ligne basée sur 20px à la référence 0.6
    var base_line_h0 = string_height("Ag");
    var line_scale = (base_line_h0 > 0) ? (20 * rel) / base_line_h0 : 1;
    var line_height = base_line_h0 * line_scale;

    // --- Infos carte sous la carte (style rCollection) ---
    var margin = round(8 * rel);
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
    var is_magic = object_is_ancestor(card.object_index, oCardMagic) || (variable_instance_exists(card, "type") && string_lower(string(card.type)) == "magic");
    if (!is_magic && variable_instance_exists(card, "star")) {
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
        // Adapter la largeur max au texte transformé (compense l’échelle de ligne)
        var max_width_info = (sprite_w - margin * 2) / line_scale;
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
    var is_monster = object_is_ancestor(card.object_index, oCardMonster) || (variable_instance_exists(card, "type") && string_lower(string(card.type)) == "monster");
    var has_attack_defense = is_monster && variable_instance_exists(card, "attack") && variable_instance_exists(card, "defense");

    // Cadre pour infos (largeur = carte + cadre rareté si présent) avec scroll pour la description
    var extra_border = 0;
    if (rarity_present) {
        var glow_intensity2 = getRarityGlowIntensity(card.rarity);
        if (glow_intensity2 > 0) extra_border = 6;
    }
    var frame_pad = round(5 * rel);
    var rect_x1 = draw_x - sprite_w * 0.5 - extra_border;
    var rect_y1 = info_y - frame_pad;
    var rect_x2 = draw_x + sprite_w * 0.5 + extra_border;

    // Hauteur max: jusqu'au bas de l'écran (marge 10px)
    var frame_max_height = max(round(40 * rel), (room_height - 10) - rect_y1);
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
        draw_text_transformed(info_x, y_cursor + 2, info_head_lines[i], line_scale, line_scale, 0);
        y_cursor += line_height;
    }
    if (rarity_present) {
        var rarity_color = getRarityColor(card.rarity);
        var rarity_name = getRarityDisplayName(card.rarity);
        draw_set_color(c_white);
        var rarity_label = "Rareté: ";
        draw_text_transformed(info_x, y_cursor + 2, rarity_label, line_scale, line_scale, 0);
        var rarity_text_x = info_x + string_width(rarity_label) * line_scale;
        draw_set_color(rarity_color);
        draw_text_transformed(rarity_text_x, y_cursor + 2, rarity_name, line_scale, line_scale, 0);
        draw_set_color(c_white);
        y_cursor += line_height;
    }
    
    // Dessin des stats ATK/DEF pour les monstres
    if (has_attack_defense) {
        draw_set_color(c_white);
        var atkdef_line = "ATK: " + string(card.attack) + " / DEF: " + string(card.defense);
        draw_text_transformed(info_x, y_cursor + 2, atkdef_line, line_scale, line_scale, 0);
        y_cursor += line_height;
    }

    // Clipping et dessin de la description (scrollable)
    if (desc_view_h > 0) {
        gpu_set_scissor(rect_x1 + 1, desc_view_y1, (rect_x2 - rect_x1) - 2, desc_view_h);
        var base_y = desc_view_y1 - textScrollY + 2;
        for (var j = 0; j < array_length(desc_lines); j++) {
            draw_text_transformed(info_x, base_y + j * line_height, desc_lines[j], line_scale, line_scale, 0);
        }
        gpu_set_scissor(0, 0, room_width, room_height);
    }

    // --- Affiche la carte en grand (après pour qu’elle soit toujours visible) ---
    if (card.isFaceDown && card.isHeroOwner) {
        draw_sprite_ext(card.sprite_index, 0, draw_x, draw_y, scale, scale, 0, c_white, 1);
    } else {
        draw_sprite_ext(card.sprite_index, card.image_index, draw_x, draw_y, scale, scale, 0, c_white, 1);
    }

    // --- Overlay texte sur la carte (zones précises, aligné Collection) ---
    {
        var spr = card.sprite_index;
        // Utiliser la même échelle que la carte pour l'overlay texte
        var s = scale;
        var cw = sprite_get_width(spr) * s;
        var ch = sprite_get_height(spr) * s;
        var tlx = draw_x - cw * 0.5;
        var tly = draw_y - ch * 0.5;

        // Détection carte magique pour masquer coût et ATK/DEF
        var is_magic = object_is_ancestor(card.object_index, oCardMagic) || (variable_instance_exists(card, "type") && string_lower(string(card.type)) == "magic");

        // Coordonnées des zones (référence scale 1.0)
        var name_x1 = 24,  name_y1 = 16;  var name_x2 = 387, name_y2 = 59;
        var star_x1 = 388, star_y1 = 16;  var star_x2 = 438, star_y2 = 60;
        var genre_x1 = 29, genre_y1 = 394; var genre_x2 = 223, genre_y2 = 419;
        var arch_x1  = 228, arch_y1  = 394; var arch_x2  = 422, arch_y2  = 419;
        var desc_x1  = 23,  desc_y1  = 438; var desc_x2  = 421, desc_y2  = 592;
        var atk_x1   = 303, atk_y1   = 594; var atk_x2   = 348, atk_y2   = 609;
        var def_x1   = 383, def_y1   = 594; var def_x2   = 421, def_y2   = 608;

        // Police et couleur
        if (font_exists(fontCardText)) draw_set_font(fontCardText);
        draw_set_color(c_black);

        // Helpers d’échelle
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
            var s = (base_line_h > 0) ? max_px / base_line_h : 1;
            for (var it = 0; it < 3; it++) {
                var sep = base_line_h;               // séparation à l'échelle 1
                var w_eff = (s > 0) ? (rw / s) : rw; // largeur efficace à scale 1
                var h = string_height_ext(text, sep, w_eff);
                if (h <= 0) break;
                var s_h = rh / h;                    // cible: h*s <= rh
                s = min(s, s_h);
            }
            return s;
        };

        var pad = 0;

        // NAME (centré verticalement dans sa zone, avec décalage +2px)
        if (variable_instance_exists(card, "name")) {
            var tx = string(card.name);
            var mar = 7;
            var rw = (name_x2 - name_x1) * s - pad * 2 - mar * 2;
            var rh = (name_y2 - name_y1) * s - pad * 2;
            var scale_tx = fit_line(tx, 20, rw, rh);
            var left = tlx + name_x1 * s + pad + mar;
            var top  = tly + name_y1 * s + pad;
            var base_line_h = string_height("Ag");
            var hsc = base_line_h * scale_tx;
            var cy = top + max(0, (rh - hsc) * 0.5) + 2;
            draw_text_transformed(left, cy, tx, scale_tx, scale_tx, 0);
        }

        // STAR (coût)
        if (!is_magic && variable_instance_exists(card, "star")) {
            var tx = string(card.star);
            var rw = (star_x2 - star_x1) * s - pad * 2;
            var rh = (star_y2 - star_y1) * s - pad * 2;
            var scale_tx = fit_line(tx, 20, rw, rh);
            var left = tlx + star_x1 * s + pad;
            var top  = tly + star_y1 * s + pad;
            var wsc  = string_width(tx) * scale_tx;
            var cx   = left + max(0, (rw - wsc) * 0.5);
            draw_text_transformed(cx, top + 2, tx, scale_tx, scale_tx, 0);
        }

        // GENRE
        if (variable_instance_exists(card, "genre")) {
            var tx = string(card.genre);
            var mar = 7;
            var rw = (genre_x2 - genre_x1) * s - pad * 2 - mar * 2;
            var rh = (genre_y2 - genre_y1) * s - pad * 2;
            var scale_tx = fit_line(tx, 16, rw, rh);
            draw_text_transformed(tlx + genre_x1 * s + pad + mar, tly + genre_y1 * s + pad + 2, tx, scale_tx, scale_tx, 0);
        }

        // ARCHETYPE
        if (variable_instance_exists(card, "archetype")) {
            var tx = string(card.archetype);
            var mar = 7;
            var rw = (arch_x2 - arch_x1) * s - pad * 2 - mar * 2;
            var rh = (arch_y2 - arch_y1) * s - pad * 2;
            var scale_tx = fit_line(tx, 16, rw, rh);
            draw_text_transformed(tlx + arch_x1 * s + pad + mar, tly + arch_y1 * s + pad + 2, tx, scale_tx, scale_tx, 0);
        }

        // DESCRIPTION (justifiée)
        if (variable_instance_exists(card, "description")) {
            var tx = string(card.description);
            var mar = 7;
            var rw = (desc_x2 - desc_x1) * s - pad * 2 - mar * 2;
            var rh = (desc_y2 - desc_y1) * s - pad * 2;
            // Cap à 24px avec ajustement largeur/hauteur (meilleure lisibilité sans couper)
            var base_h = string_height("Ag");
            var scale_tx = fit_block(tx, 20, rw, rh);
            var left = tlx + desc_x1 * s + pad + mar;
            var top  = tly + desc_y1 * s + pad;
            var line_h = base_h * scale_tx;
            var space_w = string_width(" ") * scale_tx;
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
                        var ww = string_width(w) * scale_tx;
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
                    // Justification contrôlée: limiter l'espace ajouté pour éviter les trous
                    var gaps = max(0, count - 1);
                    var extra_gap = 0;
                    if (gaps > 0 && i < array_length(words)) {
                        var extra = rw - line_w;
                        var extra_raw = (extra > 0) ? (extra / gaps) : 0;
                        var max_extra_ratio = 0.5; // au plus +50% de l'espace normal
                        extra_gap = min(extra_raw, string_width(" ") * scale_tx * max_extra_ratio);
                    }
                    var dx = left;
                    for (var j = 0; j < count; j++) {
                        var wj = line_words[j];
                        draw_text_transformed(dx, dy, wj, scale_tx, scale_tx, 0);
                        var wjw = string_width(wj) * scale_tx;
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

        // ATK
        if (!is_magic && variable_instance_exists(card, "attack")) {
            var tx = string(card.attack);
            var rw = (atk_x2 - atk_x1) * s - pad * 2;
            var rh = (atk_y2 - atk_y1) * s - pad * 2;
            var base_line_h = string_height("Ag");
            var scale_tx = (base_line_h > 0) ? 10 / base_line_h : 1;
            var left = tlx + atk_x1 * s + pad;
            var top  = tly + atk_y1 * s + pad;
            var wsc  = string_width(tx) * scale_tx;
            var hsc  = base_line_h * scale_tx;
            var cx   = left + max(0, (rw - wsc) * 0.5);
            var cy   = top  + max(0, (rh - hsc) * 0.5) - 1;
            draw_text_transformed(cx, cy, tx, scale_tx, scale_tx, 0);
        }

        // DEF
        if (!is_magic && variable_instance_exists(card, "defense")) {
            var tx = string(card.defense);
            var rw = (def_x2 - def_x1) * s - pad * 2;
            var rh = (def_y2 - def_y1) * s - pad * 2;
            var base_line_h = string_height("Ag");
            var scale_tx = (base_line_h > 0) ? 10 / base_line_h : 1;
            var left = tlx + def_x1 * s + pad;
            var top  = tly + def_y1 * s + pad;
            var wsc  = string_width(tx) * scale_tx;
            var hsc  = base_line_h * scale_tx;
            var cx   = left + max(0, (rw - wsc) * 0.5);
            var cy   = top  + max(0, (rh - hsc) * 0.5) - 1;
            draw_text_transformed(cx, cy, tx, scale_tx, scale_tx, 0);
        }
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
