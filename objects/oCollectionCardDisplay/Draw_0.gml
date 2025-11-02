// === oCollectionCardDisplay - Draw Event ===

// Affiche la carte sélectionnée uniquement dans rCollection
if (room == rCollection && selectedCard != noone && instance_exists(selectedCard)) {
    // Position pour l'affichage agrandi (utilise la position de l'instance)
    var display_x = x;
    var display_y = y;
    var display_scale = 0.6;
    
    // Fond semi-transparent derrière la carte
    draw_set_alpha(0.8);
    draw_set_color(c_black);
    var card_width = sprite_get_width(selectedCard.sprite_index) * display_scale;
    var card_height = sprite_get_height(selectedCard.sprite_index) * display_scale;
    draw_rectangle(display_x - card_width/2 - 10, display_y - card_height/2 - 10, 
                   display_x + card_width/2 + 10, display_y + card_height/2 + 10, false);
    draw_set_alpha(1);
    
    // Affichage de la carte
    draw_sprite_ext(selectedCard.sprite_index, selectedCard.image_index, 
                    display_x, display_y, display_scale, display_scale, 0, c_white, 1);
    
    // --- Bordure de rareté ---
    if (variable_instance_exists(selectedCard, "rarity")) {
        var rarity_color = getRarityColor(selectedCard.rarity);
        var glow_intensity = getRarityGlowIntensity(selectedCard.rarity);
        
        if (glow_intensity > 0) {
            // Dessiner une bordure colorée selon la rareté
            draw_set_color(rarity_color);
            draw_set_alpha(glow_intensity);
            
            var border_thickness = 6;
            for (var i = 1; i <= border_thickness; i++) {
                draw_rectangle(display_x - card_width/2 - i, display_y - card_height/2 - i, 
                              display_x + card_width/2 + i, display_y + card_height/2 + i, true);
            }
            
            draw_set_alpha(1);
            draw_set_color(c_white);
        }
    }
    
    // --- Affichage de l'étoile de favori ---
    // Vérifier si la carte est en favoris
    var card_id = selectedCard.name;
    
    if (is_card_favorite(card_id)) {
            // Position de l'étoile en haut à gauche de la carte
            var star_x = display_x - card_width/2 + 15;
            var star_y = display_y - card_height/2 + 15;
            var star_size = 12;
            
            // Dessiner l'étoile jaune (même méthode que le bouton)
            draw_set_color(c_yellow);
            draw_set_alpha(1);
            
            // Points extérieurs et intérieurs de l'étoile
            var points = 5;
            var outer_radius = star_size;
            var inner_radius = star_size * 0.5;
            var angle = -pi/2; // départ en haut

            var verts = array_create(points * 2);
            for (var p = 0; p < points * 2; p++) {
                var radius = (p % 2 == 0) ? outer_radius : inner_radius;
                var vx = star_x + lengthdir_x(radius, radtodeg(angle + p * pi / points));
                var vy = star_y + lengthdir_y(radius, radtodeg(angle + p * pi / points));
                verts[p] = [vx, vy];
            }

            // Tracer les triangles de l'étoile
            for (var t = 1; t < array_length(verts) - 1; t++) {
                draw_triangle(verts[0][0], verts[0][1], verts[t][0], verts[t][1], verts[t+1][0], verts[t+1][1], false);
            }

            draw_set_color(c_white);
    }

    // --- Infos carte sous la carte ---
    var margin = 8;
    var info_x = display_x - card_width * 0.5 + margin;
    var info_y = display_y + card_height * 0.5 + margin;
    var line_height = 20;
    
    // En-tête: nom, niveau (si Monstre), genre, archetype
    var info_head_lines = array_create(0);
    var display_name = variable_instance_exists(selectedCard, "name") ? string(selectedCard.name) : object_get_name(selectedCard.object_index);
    array_push(info_head_lines, "Nom: " + display_name);
    if (variable_instance_exists(selectedCard, "type") && selectedCard.type == "Monster" && variable_instance_exists(selectedCard, "star")) {
        array_push(info_head_lines, "Niveau: " + string(selectedCard.star));
    }
    if (variable_instance_exists(selectedCard, "genre") && string_length(string_trim(selectedCard.genre)) > 0) {
        array_push(info_head_lines, "Genre: " + string(selectedCard.genre));
    }
    if (variable_instance_exists(selectedCard, "archetype") && string_length(string_trim(selectedCard.archetype)) > 0) {
        array_push(info_head_lines, "Archetype: " + string(selectedCard.archetype));
    }
    
    // Description (wrapped)
    var desc_lines = array_create(0);
    if (variable_instance_exists(selectedCard, "description") && string_length(string_trim(selectedCard.description)) > 0) {
        array_push(desc_lines, "Description:");
        var desc_full = string(selectedCard.description);
        var max_width_info = card_width - 10;
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
    
    // Rareté: à placer entre archetype et description
    var rarity_present = variable_instance_exists(selectedCard, "rarity");
    
    // ATK/DEF: à placer entre rareté et description pour les monstres
    var is_monster = variable_instance_exists(selectedCard, "type") && selectedCard.type == "Monster";
    var has_attack_defense = is_monster && variable_instance_exists(selectedCard, "attack") && variable_instance_exists(selectedCard, "defense");
    
    // Calcul hauteur cadre
    var total_lines = array_length(info_head_lines) + (rarity_present ? 1 : 0) + (has_attack_defense ? 1 : 0) + array_length(desc_lines);
    
    // Cadre pour infos (largeur = carte + cadre rareté si présent)
    var extra_border = 0;
    if (variable_instance_exists(selectedCard, "rarity")) {
        var glow_intensity2 = getRarityGlowIntensity(selectedCard.rarity);
        if (glow_intensity2 > 0) extra_border = 6; // même valeur que la bordure dessinée
    }
    var frame_pad = 5;
    var rect_x1 = display_x - card_width * 0.5 - extra_border;
    var rect_y1 = info_y - frame_pad;
    var rect_x2 = display_x + card_width * 0.5 + extra_border;
    var rect_y2 = info_y + total_lines * line_height + frame_pad;
     draw_set_alpha(0.8);
     draw_set_color(c_black);
     draw_rectangle(rect_x1, rect_y1, rect_x2, rect_y2, false);
     draw_set_alpha(1);
     draw_set_color(c_white);
    
    // Dessin des lignes d'en-tête
    for (var i = 0; i < array_length(info_head_lines); i++) {
        draw_text(info_x, info_y + i * line_height, info_head_lines[i]);
    }
    
    // Dessin de la rareté intercalée
    var current_y_index = array_length(info_head_lines);
    if (rarity_present) {
        var rarity_color = getRarityColor(selectedCard.rarity);
        var rarity_name = getRarityDisplayName(selectedCard.rarity);
        var ry = info_y + current_y_index * line_height;
        draw_set_color(c_white);
        draw_text(info_x, ry, "Rareté: ");
        var rarity_text_x = info_x + string_width("Rareté: ");
        draw_set_color(rarity_color);
        draw_text(rarity_text_x, ry, rarity_name);
        draw_set_color(c_white);
        current_y_index += 1;
    }
    
    // Dessin des stats ATK/DEF pour les monstres
    if (has_attack_defense) {
        var stats_y = info_y + current_y_index * line_height;
        draw_set_color(c_white);
        draw_text(info_x, stats_y, "ATK: " + string(selectedCard.attack) + " / DEF: " + string(selectedCard.defense));
        current_y_index += 1;
    }
    
    // Dessin des lignes de description
    for (var j = 0; j < array_length(desc_lines); j++) {
        draw_text(info_x, info_y + (current_y_index + j) * line_height, desc_lines[j]);
    }
    // Supprimé: doublon de rareté basé sur info_lines (bloc hérité)
    // if (rarity_present) {
    //     var rarity_color = getRarityColor(selectedCard.rarity);
    //     var rarity_name = getRarityDisplayName(selectedCard.rarity);
    //     var ry = info_y + array_length(info_lines) * line_height;
    //     draw_set_color(c_white);
    //     draw_text(info_x, ry, "Rareté: ");
    //     var rarity_text_x = info_x + string_width("Rareté: ");
    //     draw_set_color(rarity_color);
    //     draw_text(rarity_text_x, ry, rarity_name);
    //     draw_set_color(c_white);
    }

    // Bloc 2: Description simplifiée (appel = ...), à gauche de la carte (sous +, -, favoris)
    if (room == rCollection && selectedCard != noone && instance_exists(selectedCard)) {
        var display_scale2 = 0.6;
        var card_width2 = sprite_get_width(selectedCard.sprite_index) * display_scale2;
        var card_height2 = sprite_get_height(selectedCard.sprite_index) * display_scale2;
        var left_margin = 10;
        var buttons_area_height = 50; // hauteur estimée des 3 boutons
        var gap_to_card = 15; // espace entre le bloc et la carte
        var margin = 8;
        var line_height = 20;
    
        var card_left = x - card_width2 * 0.5;
        var left_space = card_left - left_margin;
    
        // Largeur égale à la carte + cadre de rareté
        var border_thickness2 = 0;
        if (variable_instance_exists(selectedCard, "rarity")) {
            var glow2 = getRarityGlowIntensity(selectedCard.rarity);
            if (glow2 > 0) border_thickness2 = 6; // même valeur que le dessin du cadre
        }
        var desc_width = (card_width2 + border_thickness2 * 2) / 2;
        var desc_height = maxTextHeight;
    
        var desc_x = card_left - desc_width - gap_to_card;
        if (desc_x < left_margin) desc_x = left_margin;
        // Sécurité: garantir que le bloc reste à gauche de la carte
        if (desc_x >= card_left - 5) desc_x = card_left - desc_width - gap_to_card;
        var desc_y = y - card_height2 * 0.5 + buttons_area_height + 10 + 70;
    
        // Clamp bas de l'écran
        if (desc_y + desc_height + margin > room_height - 10) {
            desc_height = max(50, room_height - 10 - desc_y - margin);
        }
    
        // Afficher le bloc 2 uniquement si un effet avec label FR existe
        var has_named_effect = false;
        var named_index = -1;
        var selected_label = "";
        if (variable_instance_exists(selectedCard, "effects") && is_array(selectedCard.effects)) {
        var fr_labels2 = array_create(10);
        fr_labels2[0] = "appel"; fr_labels2[1] = "appel spécialisé"; fr_labels2[2] = "perdu";
        fr_labels2[3] = "tombe"; fr_labels2[4] = "initialisation"; fr_labels2[5] = "finalisation"; fr_labels2[6] = "défenseur"; fr_labels2[7] = "empoisonneur"; fr_labels2[8] = "protecteur"; fr_labels2[9] = "Protecteur";
            for (var e = 0; e < array_length(selectedCard.effects); e++) {
                var effn = selectedCard.effects[e];
                var lbl2 = getEffectLabel(effn);
                // Vérifier que le label renvoyé fait partie des 7 labels FR
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
            draw_set_alpha(0.8);
            draw_set_color(c_black);
            draw_rectangle(desc_x - margin, desc_y - margin, desc_x + desc_width + margin, desc_y + desc_height, false);
            draw_set_alpha(1);
            draw_set_color(c_white);
    
            // Clipping pour le bloc description
            gpu_set_scissor(desc_x - margin, desc_y - margin, desc_width + margin*2, desc_height + margin*2);
    
            var text_offset_y = -textScrollY;
            var current_line_desc = 0;
    
            // Construire la phrase: "<label> = ..." selon le trigger du premier effet correspondant
            var effd = selectedCard.effects[named_index];
            var label = selected_label;
            var desc_text = label + " = ";
            if (variable_instance_exists(effd, "trigger")) {
                desc_text += getTriggerDetailedDescription(effd.trigger);
            } else {
                desc_text += "activation manuelle";
            }
    
            var max_width = desc_width - 10;
            var words = string_split(desc_text, " ");
            var current_desc_line = "";
            for (var w = 0; w < array_length(words); w++) {
                var try_line = current_desc_line + words[w] + " ";
                if (string_width(try_line) > max_width && string_length(current_desc_line) > 0) {
                    draw_text(desc_x, desc_y + text_offset_y + current_line_desc * line_height, string_trim(current_desc_line));
                    current_line_desc += 1;
                    current_desc_line = words[w] + " ";
                } else {
                    current_desc_line = try_line;
                }
            }
            if (string_length(current_desc_line) > 0) {
                draw_text(desc_x, desc_y + text_offset_y + current_line_desc * line_height, string_trim(current_desc_line));
                current_line_desc += 1;
            }
    
            gpu_set_scissor(0, 0, room_width, room_height);
        }
    }