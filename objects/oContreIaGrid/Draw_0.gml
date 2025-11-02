// === oContreIaGrid - Draw Event ===
// Dessine un tableau avec 30 espaces vides au milieu de l'écran

// Configuration du tableau - 60% de la hauteur de l'écran
var grid_cols = 6;
var grid_rows = 5;
var grid_height = room_height * 0.6; // 60% de la hauteur
var cell_height = grid_height / grid_rows;
var cell_width = cell_height; // Cellules carrées
var cell_margin = 5;

// Calculer la taille totale du tableau
var total_width = (grid_cols * cell_width) + ((grid_cols - 1) * cell_margin);
var total_height = (grid_rows * cell_height) + ((grid_rows - 1) * cell_margin);

// Position centrée entre les deux cadres (400px chacun)
var frame_width = 400;
var available_width = room_width - (2 * frame_width); // Espace entre les cadres
var grid_x = frame_width + (available_width - total_width) / 2;
var grid_y = (room_height - total_height) / 2;

// Couleurs
var cell_color = c_white;
var border_color = c_black;
var bg_color = c_ltgray;

// Dessiner le fond du tableau
draw_set_color(bg_color);
draw_rectangle(grid_x - 20, grid_y - 20, grid_x + total_width + 20, grid_y + total_height + 20, false);

// Dessiner la bordure du tableau
draw_set_color(border_color);
draw_rectangle(grid_x - 20, grid_y - 20, grid_x + total_width + 20, grid_y + total_height + 20, true);

// Dessiner chaque cellule
for (var row = 0; row < grid_rows; row++) {
    for (var col = 0; col < grid_cols; col++) {
        var cell_x = grid_x + (col * (cell_width + cell_margin));
        var cell_y = grid_y + (row * (cell_height + cell_margin));
        
        // Calculer l'index de la cellule (0-29)
        var cell_index = (row * grid_cols) + col;
        
        // Déterminer le nom de l'emplacement
        var cell_name = "";
        if (cell_index == 0) {
            cell_name = "aleatoire";
        } else {
            cell_name = "bot" + string(cell_index);
        }
        
        // Déterminer la couleur de fond selon l'état
        var current_cell_color = cell_color;
        var text_color = c_black;
        
        // Vérifier si cette cellule est sélectionnée
        if (selected_bot == cell_index) {
            current_cell_color = c_lime; // Vert pour la sélection
            text_color = c_black;
        } else if (cell_index == 0) {
            // Bouton aléatoire - toujours disponible
            current_cell_color = c_yellow; // Jaune pour le bouton aléatoire
            text_color = c_black;
        } else {
            // Vérifier si ce bot est disponible
            var bot_available = false;
            for (var i = 0; i < array_length(available_bots); i++) {
                if (available_bots[i] == cell_index) {
                    bot_available = true;
                    break;
                }
            }
            
            if (!bot_available) {
                current_cell_color = c_gray; // Gris pour les bots non disponibles
                text_color = c_dkgray;
            }
        }
        
        // Dessiner le fond de la cellule
        draw_set_color(current_cell_color);
        draw_rectangle(cell_x, cell_y, cell_x + cell_width, cell_y + cell_height, false);
        
        // Dessiner la bordure de la cellule
        draw_set_color(border_color);
        draw_rectangle(cell_x, cell_y, cell_x + cell_width, cell_y + cell_height, true);
        
        // Dessiner une bordure plus épaisse si sélectionné
        if (selected_bot == cell_index) {
            draw_set_color(c_green);
            for (var i = 0; i < 3; i++) {
                draw_rectangle(cell_x - i, cell_y - i, cell_x + cell_width + i, cell_y + cell_height + i, true);
            }
        }
        
        // Dessiner le nom de l'emplacement au centre de la cellule
        draw_set_color(text_color);
        draw_set_halign(fa_center);
        draw_set_valign(fa_middle);
        draw_text(cell_x + cell_width/2, cell_y + cell_height/2, cell_name);

        // Dessiner une croix rouge sur les bots non sélectionnables (hors "aléatoire")
        if (cell_index != 0) {
            var bot_allowed = false;
            for (var j = 0; j < array_length(available_bots); j++) {
                if (available_bots[j] == cell_index) {
                    bot_allowed = true;
                    break;
                }
            }
            if (!bot_allowed) {
                draw_set_color(c_red);
                var lw = 4;
                draw_line_width(cell_x + 6, cell_y + 6, cell_x + cell_width - 6, cell_y + cell_height - 6, lw);
                draw_line_width(cell_x + cell_width - 6, cell_y + 6, cell_x + 6, cell_y + cell_height - 6, lw);
            }
        }
    }
}

// Titre du tableau
draw_set_color(c_black);
draw_set_halign(fa_center);
draw_set_valign(fa_top);
draw_text(grid_x + total_width/2, grid_y - 50, "Plateau de Jeu");

// Remettre les alignements par défaut
draw_set_halign(fa_left);
draw_set_valign(fa_top);