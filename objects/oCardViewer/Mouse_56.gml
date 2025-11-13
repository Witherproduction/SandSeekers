// === oCardViewer - Mouse Left Pressed Event ===

// Bloquer toute interaction si le panneau d'options est ouvert
if (instance_exists(oPanelOptions)) {
    exit;
}

// Room check
if (room != rCollection) {
    exit;
}

var mx = device_mouse_x_to_gui(0);
var my = device_mouse_y_to_gui(0);

// --- Gestion du menu déroulant booster ---
{
    var drop_x = dropdown_x;
    var drop_y = dropdown_y;
    var drop_w = dropdown_w;
    var drop_h = dropdown_h;

    var clickInDropdown = (mx >= drop_x && mx <= drop_x + drop_w && my >= drop_y && my <= drop_y + drop_h);

    if (clickInDropdown) {
        dropdown_open = !dropdown_open;
        if (dropdown_open == false) {
            // Fermeture sans changement
        }
        exit; // la zone du dropdown capture le clic
    }

    if (dropdown_open) {
        var item_h = drop_h;
        var list_y1 = drop_y + drop_h + 2;
        var list_y2 = list_y1 + array_length(dropdown_items) * item_h;
        var list_x1 = drop_x;
        var list_x2 = drop_x + drop_w;

        if (mx >= list_x1 && mx <= list_x2 && my >= list_y1 && my <= list_y2) {
            var index = floor((my - list_y1) / item_h);
            index = clamp(index, 0, array_length(dropdown_items) - 1);
            dropdown_selected_index = index;
            dropdown_open = false;

            var selected_text = dropdown_items[index];
            // Assigner directement le texte sélectionné comme filtre
            global.collection_booster_filter = selected_text;

            if (array_length(allCards) > 0) {
                applyBoosterFilterNow();
                // garder le tri courant (ou par défaut alpha)
                if (!variable_global_exists("sort_mode") || global.sort_mode == "none") {
                    global.sort_mode = "alpha";
                    global.sort_descending = false;
                }
                sortCards(global.sort_mode);
            }
            exit; // le clic était dans la liste
        }
    }
}

// --- Pagination: flèches gauche/droite centrées sous la grille ---
{
    var btn_w = 28;
    var btn_h = dropdown_h;
    var grid_center_x = startX + ((cardsPerRow - 1) * cardSpacing) / 2;
    var gui_h = display_get_gui_height();
    var last_row_y = startY + (maxRows - 1) * cardSpacingVertical;
    var page_y = min(last_row_y + cardSpacingVertical - 20, gui_h - btn_h - 20);
    var left_x1 = grid_center_x - 100 - btn_w;
    var left_y1 = page_y;
    var left_x2 = left_x1 + btn_w;
    var left_y2 = left_y1 + btn_h;
    var right_x1 = grid_center_x + 100;
    var right_y1 = page_y;
    var right_x2 = right_x1 + btn_w;
    var right_y2 = right_y1 + btn_h;

    // Clic gauche
    if (mx >= left_x1 && mx <= left_x2 && my >= left_y1 && my <= left_y2) {
        if (currentPage > 1) {
            currentPage -= 1;
            displayFilteredCards();
        }
        exit;
    }
    // Clic droit
    if (mx >= right_x1 && mx <= right_x2 && my >= right_y1 && my <= right_y2) {
        if (currentPage < totalPages) {
            currentPage += 1;
            displayFilteredCards();
        }
        exit;
    }
}

// --- Gestion des boutons d'action de carte sélectionnée (+, -, étoile) ---
if (instance_exists(oCollectionCardDisplay) && 
    oCollectionCardDisplay.selectedCard != noone && 
    instance_exists(oCollectionCardDisplay.selectedCard)) {
    // IMPORTANT: la carte affichée est dessinée dans le repère "monde" (Draw normal),
    // donc on utilise les coordonnées souris du monde pour les zones cliquables ici
    var mx_world = mouse_x;
    var my_world = mouse_y;

    var viewer_x = oCollectionCardDisplay.x;
    var viewer_y = oCollectionCardDisplay.y;
    var display_scale = 0.6;
    var card_width = sprite_get_width(oCollectionCardDisplay.selectedCard.sprite_index) * display_scale;
    var card_height = sprite_get_height(oCollectionCardDisplay.selectedCard.sprite_index) * display_scale;

    var frames_x = viewer_x - card_width/2 - 60;
    var frames_start_y = viewer_y - card_height/2;
    var spacing = 50;

    // Cadres et interactions
    var plus_x1 = frames_x - 20;
    var plus_y1 = frames_start_y - 20;
    var plus_x2 = frames_x + 20;
    var plus_y2 = frames_start_y + 20;

    var minus_x1 = frames_x - 20;
    var minus_y1 = frames_start_y + spacing - 20;
    var minus_x2 = frames_x + 20;
    var minus_y2 = frames_start_y + spacing + 20;

    var star_x1 = frames_x - 20;
    var star_y1 = frames_start_y + spacing * 2 - 20;
    var star_x2 = frames_x + 20;
    var star_y2 = frames_start_y + spacing * 2 + 20;

    if (mx_world >= plus_x1 && mx_world <= plus_x2 && my_world >= plus_y1 && my_world <= plus_y2) {
        var displayObj = instance_find(oCollectionCardDisplay, 0);
        if (displayObj != noone && instance_exists(displayObj)) {
            var sel = displayObj.selectedCard;
            if (sel != noone && instance_exists(sel)) {
                var cardName = variable_instance_exists(sel, "name") ? sel.name : "";
                if (cardName != "") {
                    if (!instance_exists(oDeckBuilder)) {
                        var builder_x = room_width - 400;
                        var builder_y = 100;
                        instance_create_layer(builder_x, builder_y, "Instances", oDeckBuilder);
                    }
                    with (oDeckBuilder) {
                        if (!is_array(cards_list)) { cards_list = []; }
                        array_push(cards_list, cardName);
                        if (!is_undefined(check_and_add_slot)) check_and_add_slot();
                    }
                }
            }
        }
        exit;
    }
    if (mx_world >= minus_x1 && mx_world <= minus_x2 && my_world >= minus_y1 && my_world <= minus_y2) {
        var displayObj2 = instance_find(oCollectionCardDisplay, 0);
        if (displayObj2 != noone && instance_exists(displayObj2)) {
            var sel2 = displayObj2.selectedCard;
            if (sel2 != noone && instance_exists(sel2)) {
                var cardName2 = variable_instance_exists(sel2, "name") ? sel2.name : "";
                if (cardName2 != "" && instance_exists(oDeckBuilder)) {
                    with (oDeckBuilder) {
                        if (!is_array(cards_list)) { cards_list = []; }
                        for (var i = 0; i < array_length(cards_list); i++) {
                            var entry = cards_list[i];
                            var entry_name = is_struct(entry) && variable_struct_exists(entry, "name") ? entry.name : string(entry);
                            if (entry_name == cardName2) {
                                array_delete(cards_list, i, 1);
                                break;
                            }
                        }
                    }
                }
            }
        }
        exit;
    }
    if (mx_world >= star_x1 && mx_world <= star_x2 && my_world >= star_y1 && my_world <= star_y2) {
        var displayObj3 = instance_find(oCollectionCardDisplay, 0);
        if (displayObj3 != noone && instance_exists(displayObj3)) {
            var sel3 = displayObj3.selectedCard;
            if (sel3 != noone && instance_exists(sel3)) {
                var cardName3 = variable_instance_exists(sel3, "name") ? sel3.name : "";
                if (cardName3 != "") {
                    if (!variable_global_exists("favorite_cards") || !is_array(global.favorite_cards)) {
                        global.favorite_cards = [];
                    }
                    var found = false;
                    for (var f = 0; f < array_length(global.favorite_cards); f++) {
                        if (global.favorite_cards[f] == cardName3) { found = true; break; }
                    }
                    if (found) {
                        for (var r = 0; r < array_length(global.favorite_cards); r++) {
                            if (global.favorite_cards[r] == cardName3) { array_delete(global.favorite_cards, r, 1); break; }
                        }
                    } else {
                        array_push(global.favorite_cards, cardName3);
                    }
                }
            }
        }
        exit;
    }
}