// Visibilité du bouton
visible = true;
image_alpha = 0.8;

// Échelle du bouton
image_xscale = 0.5;
image_yscale = 0.5;

// Profondeur pour être au-dessus des cartes
depth = -2000;

// Référence vers la carte parente (définie lors de la création par UIManager)
parentCard = noone;

show_debug_message("Bouton d'attaque créé à la position: " + string(x) + ", " + string(y));