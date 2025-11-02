// Initialisation des variables pour l'affichage des decks du joueur

// Charger les decks sauvegardés depuis le fichier
load_decks_from_file();

// Variables pour l'affichage des decks
selected_deck_index = -1; // Index du deck sélectionné (-1 = aucun)
scroll_offset = 0; // Décalage pour le défilement
max_visible_decks = 8; // Nombre maximum de decks visibles à la fois
deck_item_height = 40; // Hauteur de chaque élément de deck

// Variables pour l'interface
deck_list_y = 120; // Position Y de début de la liste des decks
deck_list_height = 320; // Hauteur de la zone de liste des decks

// Couleurs pour l'interface
color_selected = make_color_rgb(100, 150, 255); // Couleur de sélection
color_hover = make_color_rgb(200, 200, 200); // Couleur de survol
color_text = c_black; // Couleur du texte
color_background = c_white; // Couleur de fond

// Variables pour la gestion des clics
mouse_over_deck = -1; // Index du deck survolé

// Sélecteur de difficulté (Normal/Difficile)
difficulty_selected = variable_global_exists("IA_DIFFICULTY") ? global.IA_DIFFICULTY : 0; // 0=Normal, 1=Difficile
// Dimensions des boutons de difficulté (dessinés dans Draw avec mêmes calculs de position)
diff_btn_w = 140;
diff_btn_h = 36;