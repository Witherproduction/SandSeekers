// === oContreIaFrame - Draw Event ===
// Dessine un cadre à droite de l'écran en utilisant le sprite sDeckBuilder

// Position à droite de l'écran avec décalage de 55 pixels (comme dans rCollection)
var sprite_x = room_width - sprite_get_width(sDeckBuilder) + 55;
var sprite_y = -60; // Décaler vers le haut pour dépasser davantage

// Calculer l'échelle pour dépasser légèrement en haut et en bas (120 pixels de plus)
var scale_y = (room_height + 120) / sprite_get_height(sDeckBuilder);
// Calculer l'échelle horizontale pour rétrécir de 20 pixels
var scale_x = (sprite_get_width(sDeckBuilder) - 20) / sprite_get_width(sDeckBuilder);

// Dessiner le sprite sDeckBuilder étiré sur toute la hauteur
draw_sprite_ext(sDeckBuilder, 0, sprite_x, sprite_y, scale_x, scale_y, 0, c_white, 1);

// Titre du cadre
draw_set_color(c_black);
draw_set_halign(fa_center);
draw_set_valign(fa_top);
draw_text(sprite_x + (sprite_get_width(sDeckBuilder) * scale_x) / 2, 30, "Mes Decks");

// Récupérer la liste des decks sauvegardés
var saved_decks = global.saved_decks;
var deck_count = 0;

// Compter le nombre de decks disponibles
if (is_array(saved_decks)) {
    deck_count = array_length(saved_decks);
}

// Position de départ pour la liste des decks
var list_start_x = sprite_x + 20;
var list_start_y = sprite_y + deck_list_y;
var list_width = (sprite_get_width(sDeckBuilder) * scale_x) - 40;

// Si aucun deck n'est disponible
if (deck_count == 0) {
    // Dessiner un cadre pour le message "aucun deck disponible"
    var msg_box_y = list_start_y + 100;
    var msg_box_height = 60;
    
    draw_set_color(c_ltgray);
    draw_rectangle(list_start_x, msg_box_y, list_start_x + list_width, msg_box_y + msg_box_height, false);
    draw_set_color(c_black);
    draw_rectangle(list_start_x, msg_box_y, list_start_x + list_width, msg_box_y + msg_box_height, true);
    
    // Texte du message
    draw_set_font(fontCardDisplay);
    draw_set_color(c_black);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_text(list_start_x + list_width / 2, msg_box_y + msg_box_height / 2, "Aucun deck disponible");
} else {
    // Afficher la liste des decks
    draw_set_font(fontCardDisplay);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    
    // Calculer le nombre de decks visibles
    var visible_count = min(deck_count, max_visible_decks);
    
    // Dessiner chaque deck visible
    for (var i = 0; i < visible_count; i++) {
        var deck_index = i + scroll_offset;
        if (deck_index >= deck_count) break;
        
        var deck = saved_decks[deck_index];
        var item_y = list_start_y + (i * deck_item_height);
        
        // Vérifier si la souris survole cet élément
        var mouse_x_pos = mouse_x;
        var mouse_y_pos = mouse_y;
        var is_hovering = (mouse_x_pos >= list_start_x && mouse_x_pos <= list_start_x + list_width &&
                          mouse_y_pos >= item_y && mouse_y_pos <= item_y + deck_item_height);
        
        // Couleur de fond selon l'état
        var bg_color = color_background;
        if (deck_index == selected_deck_index) {
            bg_color = color_selected;
        } else if (is_hovering) {
            bg_color = color_hover;
            mouse_over_deck = deck_index;
        }
        
        // Dessiner le fond de l'élément
        draw_set_color(bg_color);
        draw_rectangle(list_start_x, item_y, list_start_x + list_width, item_y + deck_item_height, false);
        
        // Dessiner la bordure
        draw_set_color(c_black);
        draw_rectangle(list_start_x, item_y, list_start_x + list_width, item_y + deck_item_height, true);
        
        // Dessiner le nom du deck
        draw_set_color(color_text);
        var deck_name = "Deck sans nom";
        if (variable_struct_exists(deck, "name") && deck.name != "") {
            deck_name = deck.name;
        }
        draw_text(list_start_x + 10, item_y + 5, deck_name);
        
        // Dessiner le nombre de cartes
        var card_count = 0;
        if (variable_struct_exists(deck, "cards") && is_array(deck.cards)) {
            card_count = array_length(deck.cards);
        }
        draw_text(list_start_x + 10, item_y + 20, string(card_count) + " cartes");
    }
    
    // Afficher des informations sur le deck sélectionné
    if (selected_deck_index >= 0 && selected_deck_index < deck_count) {
        var selected_deck = saved_decks[selected_deck_index];
        var info_y = list_start_y + deck_list_height + 20;
        
        draw_set_color(c_black);
        draw_set_halign(fa_left);
        draw_text(list_start_x, info_y, "Deck sélectionné :");
        
        var selected_name = "Deck sans nom";
        if (variable_struct_exists(selected_deck, "name") && selected_deck.name != "") {
            selected_name = selected_deck.name;
        }
        draw_text(list_start_x, info_y + 20, selected_name);
    }
}

// (sélecteur de difficulté déplacé dans le cadre gauche)
// Remettre les alignements par défaut
draw_set_halign(fa_left);
draw_set_valign(fa_top);