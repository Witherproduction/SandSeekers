// === INITIALISATION DE oContreIaFrameLeft ===

// Référence vers l'instance de la grille des bots
grid_instance = instance_find(oContreIaGrid, 0);

// Variables pour l'affichage
frame_width = 400;
frame_height = 800;
frame_x = x;
frame_y = y;

// Couleurs
bg_color = c_ltgray;
border_color = c_black;
text_color = c_black;
title_color = c_blue;

// Variables de texte
line_height = 20;

// Variables pour les informations du bot
bot_name = "Aucun bot sélectionné";
bot_description = "Sélectionnez un bot pour voir ses informations.";
bot_deck = "Aucun";
bot_difficulty = "Inconnue";