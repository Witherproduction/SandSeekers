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

    if (mx >= plus_x1 && mx <= plus_x2 && my >= plus_y1 && my <= plus_y2) {
        with (oCollectionCardDisplay) {
            add_selected_card_to_deck();
        }
        exit;
    }
    if (mx >= minus_x1 && mx <= minus_x2 && my >= minus_y1 && my <= minus_y2) {
        with (oCollectionCardDisplay) {
            remove_selected_card_from_deck();
        }
        exit;
    }
    if (mx >= star_x1 && mx <= star_x2 && my >= star_y1 && my <= star_y2) {
        with (oCollectionCardDisplay) {
            toggle_favorite_selected_card();
        }
        exit;
    }
}