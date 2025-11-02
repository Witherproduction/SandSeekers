// === oDeckList - Create Event ===
// Initialisation des variables

show_debug_message("=== oDeckList Create Event démarré ===");

// Variable pour contrôler l'affichage du cadre oDeckBuilder
show_deck_builder = false;

// Instance de l'objet oDeckBuilder (sera créée quand nécessaire)
deck_builder_instance = noone;

// Redimensionner l'objet pour couvrir la zone du bouton
// Calculer la position du bouton (même calcul que dans Draw_0)
var sprite_x = room_width - sprite_get_width(sDeckBuilder) + 55;
var button_x = sprite_x + 50;
var button_y = room_height / 3 - 170;
var button_width = 320;
var button_height = 80;

// Positionner l'objet sur le bouton et ajuster sa taille
x = button_x;
y = button_y;
image_xscale = button_width / sprite_get_width(sprInvisible);
image_yscale = button_height / sprite_get_height(sprInvisible);

show_debug_message("oDeckList positionné à: (" + string(x) + ", " + string(y) + ") avec échelle: (" + string(image_xscale) + ", " + string(image_yscale) + ")");