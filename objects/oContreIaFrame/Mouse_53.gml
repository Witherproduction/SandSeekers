// Gestion des clics sur la liste des decks

// Récupérer la liste des decks sauvegardés
var saved_decks = global.saved_decks;
var deck_count = 0;

// Compter le nombre de decks disponibles
if (is_array(saved_decks)) {
    deck_count = array_length(saved_decks);
}

// Si aucun deck n'est disponible, ne rien faire
if (deck_count == 0) {
    // Même si aucun deck, permettre le clic sur difficulté
}

// Position du cadre (même calcul que dans Draw_0)
var sprite_x = room_width - sprite_get_width(sDeckBuilder) + 55;
var sprite_y = -60;
var scale_x = (sprite_get_width(sDeckBuilder) - 20) / sprite_get_width(sDeckBuilder);

// Position de départ pour la liste des decks
var list_start_x = sprite_x + 20;
var list_start_y = sprite_y + deck_list_y;
var list_width = (sprite_get_width(sDeckBuilder) * scale_x) - 40;

// Vérifier si le clic est dans la zone de la liste
var mouse_x_pos = mouse_x;
var mouse_y_pos = mouse_y;

if (deck_count > 0) {
    if (mouse_x_pos >= list_start_x && mouse_x_pos <= list_start_x + list_width) {
        // Calculer le nombre de decks visibles
        var visible_count = min(deck_count, max_visible_decks);
        
        // Vérifier sur quel deck on a cliqué
        for (var i = 0; i < visible_count; i++) {
            var deck_index = i + scroll_offset;
            if (deck_index >= deck_count) break;
            
            var item_y = list_start_y + (i * deck_item_height);
            
            // Vérifier si le clic est sur cet élément
            if (mouse_y_pos >= item_y && mouse_y_pos <= item_y + deck_item_height) {
                // Sélectionner ce deck
                if (selected_deck_index == deck_index) {
                    // Si on clique sur le deck déjà sélectionné, le désélectionner
                    selected_deck_index = -1;
                } else {
                    // Sélectionner le nouveau deck
                    selected_deck_index = deck_index;
                }
                
                // Afficher un message de débogage
                if (selected_deck_index >= 0) {
                    var selected_deck = saved_decks[selected_deck_index];
                    var deck_name = "Deck sans nom";
                    if (variable_struct_exists(selected_deck, "name") && selected_deck.name != "") {
                        deck_name = selected_deck.name;
                    }
                    show_debug_message("Deck sélectionné : " + deck_name);
                } else {
                    show_debug_message("Aucun deck sélectionné");
                }
                
                break;
            }
        }
    }
}

// --- Clic sur le sélecteur de difficulté ---
var diff_label_y = list_start_y + deck_list_height + 70;
var btn1_x = list_start_x;
var btn2_x = list_start_x + diff_btn_w + 10;
var btn_y  = diff_label_y;

// Bouton Normal
if (mouse_x_pos >= btn1_x && mouse_x_pos <= btn1_x + diff_btn_w && mouse_y_pos >= btn_y && mouse_y_pos <= btn_y + diff_btn_h) {
    difficulty_selected = 0; global.IA_DIFFICULTY = 0; 
    show_debug_message("Difficulté IA: Normal");
}
// Bouton Difficile
if (mouse_x_pos >= btn2_x && mouse_x_pos <= btn2_x + diff_btn_w && mouse_y_pos >= btn_y && mouse_y_pos <= btn_y + diff_btn_h) {
    difficulty_selected = 1; global.IA_DIFFICULTY = 1; 
    show_debug_message("Difficulté IA: Difficile");
}