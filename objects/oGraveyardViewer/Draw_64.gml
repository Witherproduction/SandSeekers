// === Paramètres ===
var columns = 4;              // Nombre de colonnes affichées (réduit de 5 à 4)
var rows = 3;                 // Nombre de lignes affichées
var spacing = 20;             // Espace horizontal/vertical entre les cartes
var scale = 0.25;             // Échelle d'affichage des cartes (remise comme avant)

// Taille d'une carte (par défaut)
var card_w = 100 * scale;
var card_h = 140 * scale;

// Adapter selon la première carte si disponible
if (array_length(linkedGraveyard.cards) > 0) {
    var first_cardData = linkedGraveyard.cards[0];
    card_w = sprite_get_width(first_cardData.sprite_index) * scale;
    card_h = sprite_get_height(first_cardData.sprite_index) * scale;
}

// === Géométrie du cadre sFond (origine centrée) ===
var sprFond = sFond;
var fondW = sprite_get_width(sprFond);
var fondH = sprite_get_height(sprFond);
var centerX = room_width * 0.5;
var centerY = room_height * 0.5;
// Échelle du viewer augmentée de 10%
var frameScale = 1.1;
var scaledW = fondW * frameScale;
var scaledH = fondH * frameScale;
var frame_left = centerX - scaledW * 0.5;
var frame_top = centerY - scaledH * 0.5;
var frame_right = centerX + scaledW * 0.5;
var frame_bottom = centerY + scaledH * 0.5;

// === Position des cartes ===
// Démarrer dans la zone intérieure du cadre avec une marge
var inner_margin = 40;
var start_x = frame_left + inner_margin;
var start_y = frame_top + inner_margin;

// === Affiche le fond ===
// Dessine sFond centré avec échelle 110%
draw_sprite_ext(sFond, 0, centerX, centerY, frameScale, frameScale, 0, c_white, 1);

// === Vérification de sécurité ===
if (linkedGraveyard == noone || !instance_exists(linkedGraveyard)) {
    draw_set_color(c_white);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_text(960, 540, "Erreur: Cimetière non trouvé"); // Centré dans le nouveau cadre
    return;
}

// === Dessiner les cartes ===
var list = linkedGraveyard.cards;   // Récupère la liste des cartes
var total = array_length(list);     // Nombre total de cartes
var visible_cards = columns * rows; // Nombre max de cartes affichables

// Si le cimetière est vide, afficher un message
if (total == 0) {
    draw_set_color(c_white);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_text(960, 540, "Cimetière vide"); // Centré dans le nouveau cadre
    return;
}

var maxScroll = max(0, total - visible_cards);
scrollIndex = clamp(scrollIndex, 0, maxScroll);
var avail = max(0, total - scrollIndex);
var count = min(avail, visible_cards);

for (var i = 0; i < count; i++) {
    var cardData = list[total - 1 - (i + scrollIndex)]; // On parcourt depuis la dernière carte ajoutée
    
    // Vérifier que les données de carte existent
    if (cardData != undefined) {
        var col = i mod columns;  // Colonne
        var row = i div columns;  // Ligne

        var draw_x_top_left = start_x + col * (card_w + spacing); // Position X du coin supérieur gauche
        var draw_y_top_left = start_y + row * (card_h + spacing); // Position Y du coin supérieur gauche

        // Ajuster draw_x et draw_y pour qu'ils soient le centre de la carte, car l'origine du sprite est centrée
        var draw_x = draw_x_top_left + (card_w / scale) * scale / 2; // (card_w / scale) est la largeur originale du sprite
        var draw_y = draw_y_top_left + (card_h / scale) * scale / 2; // (card_h / scale) est la hauteur originale du sprite

        draw_sprite_ext(cardData.sprite_index, cardData.image_index, draw_x, draw_y, scale, scale, 0, c_white, 1);
        var s = scale;
        var spr = cardData.sprite_index;
        var cw = sprite_get_width(spr) * s;
        var ch = sprite_get_height(spr) * s;
        var name_x1 = 24,  name_y1 = 16;  var name_x2 = 387, name_y2 = 59;
        var star_x1 = 388, star_y1 = 16;  var star_x2 = 438, star_y2 = 60;
        var genre_x1 = 29, genre_y1 = 394; var genre_x2 = 223, genre_y2 = 419;
        var arch_x1  = 228, arch_y1  = 394; var arch_x2  = 422, arch_y2  = 419;
        var desc_x1  = 23,  desc_y1  = 438; var desc_x2  = 421, desc_y2  = 592;
        var is_magic = (variable_struct_exists(cardData, "cardType") && string_lower(string(cardData.cardType)) == "magic");
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
        var tlx = draw_x - cw * 0.5;
        var tly = draw_y - ch * 0.5;
        if (variable_struct_exists(cardData, "name")) {
            var tx = string(cardData.name);
            var rw = (name_x2 - name_x1) * s - pad * 2 - mar * 2;
            var rh = (name_y2 - name_y1) * s - pad * 2;
            var sc = fit_line(tx, 20 * rel, rw, rh);
            var left = tlx + name_x1 * s + pad + mar;
            var top  = tly + name_y1 * s + pad;
            draw_text_transformed(left, top + 2, tx, sc, sc, 0);
        }
        if (!is_magic && variable_struct_exists(cardData, "star")) {
            var tx = string(cardData.star);
            var rw = (star_x2 - star_x1) * s - pad * 2;
            var rh = (star_y2 - star_y1) * s - pad * 2;
            var sc = fit_line(tx, 20 * rel, rw, rh);
            var left = tlx + star_x1 * s + pad;
            var top  = tly + star_y1 * s + pad;
            var wsc  = string_width(tx) * sc;
            var cx   = left + max(0, (rw - wsc) * 0.5);
            draw_text_transformed(cx, top + 2, tx, sc, sc, 0);
        }
        if (variable_struct_exists(cardData, "genre")) {
            var tx = string(cardData.genre);
            var rw = (genre_x2 - genre_x1) * s - pad * 2 - mar * 2;
            var rh = (genre_y2 - genre_y1) * s - pad * 2;
            var sc = fit_line(tx, 16 * rel, rw, rh);
            var left_g = tlx + genre_x1 * s + pad + mar;
            var top_g  = tly + genre_y1 * s + pad;
            draw_text_transformed(left_g, top_g + 0, tx, sc, sc, 0);
        }
        if (variable_struct_exists(cardData, "archetype")) {
            var tx = string(cardData.archetype);
            var rw = (arch_x2 - arch_x1) * s - pad * 2 - mar * 2;
            var rh = (arch_y2 - arch_y1) * s - pad * 2;
            var sc = fit_line(tx, 16 * rel, rw, rh);
            var left_a = tlx + arch_x1 * s + pad + mar;
            var top_a  = tly + arch_y1 * s + pad;
            draw_text_transformed(left_a, top_a + 0, tx, sc, sc, 0);
        }
        if (variable_struct_exists(cardData, "description")) {
            var tx = string(cardData.description);
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
            for (var p_i2 = 0; p_i2 < array_length(paragraphs); p_i2++) {
                var words = string_split(paragraphs[p_i2], " ");
                var ii = 0;
                while (ii < array_length(words)) {
                    var line_words = [];
                    var count = 0;
                    var line_w = 0;
                    while (ii < array_length(words)) {
                        var w = words[ii];
                        var ww = string_width(w) * sc;
                        var plus_space = (count > 0) ? space_w : 0;
                        if (line_w + plus_space + ww <= rw) {
                            line_words[count] = w;
                            count += 1;
                            line_w += plus_space + ww;
                            ii += 1;
                        } else {
                            break;
                        }
                    }
                    var gaps = max(0, count - 1);
                    var extra_gap = 0;
                    if (gaps > 0 && ii < array_length(words)) {
                        var extra = rw - line_w;
                        var extra_raw = (extra > 0) ? (extra / gaps) : 0;
                        var max_extra_ratio = 0.5;
                        extra_gap = min(extra_raw, string_width(" ") * sc * max_extra_ratio);
                    }
                    var dx = left;
                    for (var j2 = 0; j2 < count; j2++) {
                        var wj = line_words[j2];
                        draw_text_transformed(dx, dy, wj, sc, sc, 0);
                        var wjw = string_width(wj) * sc;
                        if (j2 < count - 1) {
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
    }
}

// === Bouton de fermeture ===
// En haut à droite du cadre avec une marge
var close_margin = 20;
var close_w = 30;
var close_h = 30;
var close_x1 = frame_right - close_margin - close_w;
var close_y1 = frame_top + close_margin;
var close_x2 = close_x1 + close_w;
var close_y2 = close_y1 + close_h;
draw_set_color(c_red);
draw_rectangle(close_x1, close_y1, close_x2, close_y2, false);
draw_set_color(c_white);
draw_set_halign(fa_center);
draw_set_valign(fa_middle);
draw_text((close_x1 + close_x2) * 0.5, (close_y1 + close_y2) * 0.5, "X");

// === Indicateur de scroll ===
var bar_w = 15;    // Largeur de la barre
var bar_margin_top = 60;
var bar_margin_bottom = 60;
var bar_x = frame_right - close_margin - bar_w; // près du bord droit
var bar_y = frame_top + bar_margin_top;   // sous le bouton
var bar_h = max(60, scaledH - (bar_margin_top + bar_margin_bottom));

// === Calcul de la taille du curseur ===
var indicator_height;
if (total > visible_cards) {
    indicator_height = max(bar_h * (visible_cards / total), 20);
} else {
    indicator_height = bar_h * 0.2; // 20% de la barre minimum
}

// Calcul du déplacement max possible
var maxScroll = max(0, total - visible_cards);

// Position verticale du curseur dans la barre
var scroll_pos = 0;
if (maxScroll > 0) {
    scroll_pos = (scrollIndex / maxScroll) * (bar_h - indicator_height);
}

// === Dessin de la barre ===
draw_set_color(c_white); // Fond blanc pour bien la voir
draw_rectangle(bar_x, bar_y, bar_x + bar_w, bar_y + bar_h, true);

draw_set_color(c_grey); // Cadre noir
draw_rectangle(bar_x, bar_y, bar_x + bar_w, bar_y + bar_h, false);


// === Dessin du curseur ===
draw_set_color(c_blue); // Fond bleu
draw_rectangle(bar_x, bar_y + scroll_pos, bar_x + bar_w, bar_y + scroll_pos + indicator_height, true);

draw_set_color(c_blue); // Contour bleu
draw_rectangle(bar_x, bar_y + scroll_pos, bar_x + bar_w, bar_y + scroll_pos + indicator_height, false);

// === Reset couleurs & alignements ===
draw_set_color(c_white);
draw_set_halign(fa_left);
draw_set_valign(fa_top);

// === Dessin de la carte sélectionnée (preview) ===
if (selectedCard != noone) {
    var card = selectedCard;

    // Position de la carte
    var preview_draw_x = 150;
    var preview_draw_y = 250;
    var preview_scale = 0.50;

    // Taille réelle du sprite affiché
    var preview_sprite_w = sprite_get_width(card.sprite_index) * preview_scale;
    var preview_sprite_h = sprite_get_height(card.sprite_index) * preview_scale;

    // Bord bas de la carte (pour positionner le texte en-dessous)
    var preview_image_bottom = preview_draw_y + preview_sprite_h * 0.5;

    // --- Position du texte et du cadre ---
    var preview_margin_side = 15; // Marge à gauche et à droite du texte
    var preview_margin_top = 8;   // Marge au-dessus du texte
    var preview_margin_bottom = 8;

    var preview_text_x = preview_draw_x - preview_sprite_w * 0.5 + preview_margin_side; // Décalage plus à gauche
    var preview_text_y = preview_image_bottom + 10;

    var preview_text_width = preview_sprite_w - 2 * preview_margin_side;
    var preview_line_height = 16; // Plus petit pour éviter chevauchement

    // --- Police et alignement ---
    draw_set_font(fontCardDisplay);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);

    // --- Contenu à afficher ---
    var preview_lines = [];
    
    // Gestion du nom sur plusieurs lignes si nécessaire
    var preview_name_text = "Nom : " + string(card.name);
    var preview_name_words = string_split(preview_name_text, " ");
    var preview_name_line = "";
    
    for (var i = 0; i < array_length(preview_name_words); i++) {
        var preview_try_name_line = preview_name_line + preview_name_words[i] + " ";
        if (string_width(preview_try_name_line) > preview_text_width) {
            if (string_length(preview_name_line) > 0) {
                array_push(preview_lines, string_trim(preview_name_line));
                preview_name_line = preview_name_words[i] + " ";
            } else {
                // Si même un seul mot est trop long, on le force quand même
                array_push(preview_lines, preview_name_words[i]);
                preview_name_line = "";
            }
        } else {
            preview_name_line = preview_try_name_line;
        }
    }
    
    if (string_length(preview_name_line) > 0) {
        array_push(preview_lines, string_trim(preview_name_line));
    }

    // Afficher le niveau si c'est un monstre
    if (variable_instance_exists(card, "type") && card.type == "Monster") {
        if (variable_instance_exists(card, "star")) {
            array_push(preview_lines, "Niveau : " + string(card.star));
        }
    }

    // Afficher ATK et DEF sur la même ligne si c'est un monstre
    if (variable_instance_exists(card, "type") && card.type == "Monster") {
        // N'affiche les stats que si la carte n'est pas face cachée ou si elle est possédée par le héros
        if (!card.isFaceDown || card.isHeroOwner) {
            var preview_atk_str = "";
            var preview_def_str = "";

            if (variable_instance_exists(card, "attack")) {
                preview_atk_str = "ATK : " + string(card.attack);
            }

            if (variable_instance_exists(card, "defense")) {
                preview_def_str = "DEF : " + string(card.defense);
            }

            var preview_stats_line = preview_atk_str;
            if (string_length(preview_def_str) > 0) {
                preview_stats_line += "    " + preview_def_str;
            }

            array_push(preview_lines, preview_stats_line);
        }
    }

    // Texte multi-lignes pour la description
    if (variable_instance_exists(card, "description")) {
        var preview_desc = "Effet : " + string(card.description);
        var preview_words = string_split(preview_desc, " ");
        var preview_line = "";

        for (var i = 0; i < array_length(preview_words); i++) {
            var preview_try_line = preview_line + preview_words[i] + " ";
            if (string_width(preview_try_line) > preview_text_width) {
                array_push(preview_lines, string_trim(preview_line));
                preview_line = preview_words[i] + " ";
            } else {
                preview_line = preview_try_line;
            }
        }

        if (string_length(preview_line) > 0) {
            array_push(preview_lines, string_trim(preview_line));
        }
    }

    // --- Rectangle noir en fond (dessiné avant le texte) ---
    var preview_total_height = array_length(preview_lines) * preview_line_height;
    var preview_rect_x1 = preview_text_x - 15;
    var preview_rect_y1 = preview_text_y - preview_margin_top;
    var preview_rect_x2 = preview_draw_x + preview_sprite_w * 0.5 - preview_margin_side + 15;
    var preview_rect_y2 = preview_text_y + preview_total_height + preview_margin_bottom;

    draw_set_color(c_black);
    draw_set_alpha(0.75);
    draw_rectangle(preview_rect_x1, preview_rect_y1, preview_rect_x2, preview_rect_y2, false);
    draw_set_alpha(1);

    // --- Affichage du texte ligne par ligne ---
    draw_set_color(c_white);
    for (var i = 0; i < array_length(preview_lines); i++) {
        draw_text(preview_text_x, preview_text_y + i * preview_line_height, preview_lines[i]);
    }

    // --- Affiche la carte en grand (après pour qu’elle soit toujours visible) ---
    if (card.isFaceDown && card.isHeroOwner) {
        // Si la carte est face cachée mais appartient au héros, on affiche sa face visible
        draw_sprite_ext(card.sprite_index, 0, preview_draw_x, preview_draw_y, preview_scale, preview_scale, 0, c_white, 1);
    } else {
        draw_sprite_ext(card.sprite_index, card.image_index, preview_draw_x, preview_draw_y, preview_scale, preview_scale, 0, c_white, 1);
    }

    var face_down = (variable_instance_exists(card, "isFaceDown") && card.isFaceDown);
    var can_show_overlay = (!face_down) || (variable_instance_exists(card, "isHeroOwner") && card.isHeroOwner);
    if (can_show_overlay) {
        var spr = card.sprite_index;
        var s = preview_scale;
        var cw = sprite_get_width(spr) * s;
        var ch = sprite_get_height(spr) * s;
        var tlx = preview_draw_x - cw * 0.5;
        var tly = preview_draw_y - ch * 0.5;
        var name_x1 = 24,  name_y1 = 16;  var name_x2 = 387, name_y2 = 59;
        var star_x1 = 388, star_y1 = 16;  var star_x2 = 438, star_y2 = 60;
        var genre_x1 = 29, genre_y1 = 394; var genre_x2 = 223, genre_y2 = 419;
        var arch_x1  = 228, arch_y1  = 394; var arch_x2  = 422, arch_y2  = 419;
        var desc_x1  = 23,  desc_y1  = 438; var desc_x2  = 421, desc_y2  = 592;
        var is_magic = object_is_ancestor(card.object_index, oCardMagic) || (variable_instance_exists(card, "type") && string_lower(string(card.type)) == "magic");
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
        if (variable_instance_exists(card, "name")) {
            var tx = string(card.name);
            var rw = (name_x2 - name_x1) * s - pad * 2 - mar * 2;
            var rh = (name_y2 - name_y1) * s - pad * 2;
            var sc = fit_line(tx, 20 * rel, rw, rh);
            var left = tlx + name_x1 * s + pad + mar;
            var top  = tly + name_y1 * s + pad;
            draw_text_transformed(left, top + 2, tx, sc, sc, 0);
        }
        if (!is_magic && variable_instance_exists(card, "star")) {
            var tx = string(card.star);
            var rw = (star_x2 - star_x1) * s - pad * 2;
            var rh = (star_y2 - star_y1) * s - pad * 2;
            var sc = fit_line(tx, 20 * rel, rw, rh);
            var left = tlx + star_x1 * s + pad;
            var top  = tly + star_y1 * s + pad;
            var wsc  = string_width(tx) * sc;
            var cx   = left + max(0, (rw - wsc) * 0.5);
            draw_text_transformed(cx, top + 2, tx, sc, sc, 0);
        }
        if (variable_instance_exists(card, "genre")) {
            var tx = string(card.genre);
            var rw = (genre_x2 - genre_x1) * s - pad * 2 - mar * 2;
            var rh = (genre_y2 - genre_y1) * s - pad * 2;
            var sc = fit_line(tx, 16 * rel, rw, rh);
            var left_g = tlx + genre_x1 * s + pad + mar;
            var top_g  = tly + genre_y1 * s + pad;
            draw_text_transformed(left_g, top_g + 0, tx, sc, sc, 0);
        }
        if (variable_instance_exists(card, "archetype")) {
            var tx = string(card.archetype);
            var rw = (arch_x2 - arch_x1) * s - pad * 2 - mar * 2;
            var rh = (arch_y2 - arch_y1) * s - pad * 2;
            var sc = fit_line(tx, 16 * rel, rw, rh);
            var left_a = tlx + arch_x1 * s + pad + mar;
            var top_a  = tly + arch_y1 * s + pad;
            draw_text_transformed(left_a, top_a + 0, tx, sc, sc, 0);
        }
        if (variable_instance_exists(card, "description")) {
            var tx = string(card.description);
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
            for (var p_i2 = 0; p_i2 < array_length(paragraphs); p_i2++) {
                var words = string_split(paragraphs[p_i2], " ");
                var ii = 0;
                while (ii < array_length(words)) {
                    var line_words = [];
                    var count = 0;
                    var line_w = 0;
                    while (ii < array_length(words)) {
                        var w = words[ii];
                        var ww = string_width(w) * sc;
                        var plus_space = (count > 0) ? space_w : 0;
                        if (line_w + plus_space + ww <= rw) {
                            line_words[count] = w;
                            count += 1;
                            line_w += plus_space + ww;
                            ii += 1;
                        } else {
                            break;
                        }
                    }
                    var gaps = max(0, count - 1);
                    var extra_gap = 0;
                    if (gaps > 0 && ii < array_length(words)) {
                        var extra = rw - line_w;
                        var extra_raw = (extra > 0) ? (extra / gaps) : 0;
                        var max_extra_ratio = 0.5;
                        extra_gap = min(extra_raw, string_width(" ") * sc * max_extra_ratio);
                    }
                    var dx = left;
                    for (var j2 = 0; j2 < count; j2++) {
                        var wj = line_words[j2];
                        draw_text_transformed(dx, dy, wj, sc, sc, 0);
                        var wjw = string_width(wj) * sc;
                        if (j2 < count - 1) {
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
    }
}
