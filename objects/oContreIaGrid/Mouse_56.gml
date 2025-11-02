// === oContreIaGrid - Global Left Button Event ===
// Gestion des clics globaux sur les cellules du tableau

// Vérifier si le clic est dans la zone du tableau
if (mouse_x >= grid_x && mouse_x <= grid_x + total_width &&
    mouse_y >= grid_y && mouse_y <= grid_y + total_height) {
    
    // Calculer quelle cellule a été cliquée
    var relative_x = mouse_x - grid_x;
    var relative_y = mouse_y - grid_y;
    
    var clicked_col = floor(relative_x / (cell_width + cell_margin));
    var clicked_row = floor(relative_y / (cell_height + cell_margin));
    
    // Vérifier que le clic est bien dans une cellule valide
    if (clicked_col >= 0 && clicked_col < grid_cols && 
        clicked_row >= 0 && clicked_row < grid_rows) {
        
        // Calculer l'index de la cellule cliquée
        var clicked_index = (clicked_row * grid_cols) + clicked_col;
        
        // Vérifier que le clic est bien sur la cellule et pas sur les marges
        var cell_x = grid_x + (clicked_col * (cell_width + cell_margin));
        var cell_y = grid_y + (clicked_row * (cell_height + cell_margin));
        
        if (mouse_x >= cell_x && mouse_x <= cell_x + cell_width &&
            mouse_y >= cell_y && mouse_y <= cell_y + cell_height) {
            
            // Gérer la sélection
            if (clicked_index == 0) {
                // Clic sur "aléatoire" - sélectionner un bot aléatoire parmi les disponibles
                if (array_length(available_bots) > 0) {
                    var random_index = irandom(array_length(available_bots) - 1);
                    selected_bot = available_bots[random_index];
                    show_debug_message("Bot sélectionné aléatoirement : bot" + string(selected_bot));
                } else {
                    show_debug_message("Aucun bot disponible pour la sélection aléatoire");
                }
            } else {
                // Clic sur un bot spécifique
                // Vérifier si ce bot est disponible
                var bot_available = false;
                for (var i = 0; i < array_length(available_bots); i++) {
                    if (available_bots[i] == clicked_index) {
                        bot_available = true;
                        break;
                    }
                }
                
                if (bot_available) {
                    selected_bot = clicked_index;
                    show_debug_message("Bot sélectionné : bot" + string(selected_bot));
                } else {
                    show_debug_message("Bot" + string(clicked_index) + " n'est pas disponible");
                }
            }
        }
    }
}