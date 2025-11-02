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

var count = min(total - scrollIndex, visible_cards); // Nombre de cartes réellement affichées

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
}
