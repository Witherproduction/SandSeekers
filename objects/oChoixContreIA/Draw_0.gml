// === oChoixContreIA - Draw Event ===
// Dessine un cadre neutre avec le texte "Contre l'IA"

// Définir les dimensions du bouton
var button_width = 120;
var button_height = 40;

// Position centrée sur l'objet
var draw_x = x - button_width / 2;
var draw_y = y - button_height / 2;

// Couleurs
var frame_color = c_red;
var bg_color = c_maroon;
var text_color = c_white;

// Dessiner le fond du bouton
draw_set_color(bg_color);
draw_rectangle(draw_x, draw_y, draw_x + button_width, draw_y + button_height, false);

// Dessiner le cadre
draw_set_color(frame_color);
draw_rectangle(draw_x, draw_y, draw_x + button_width, draw_y + button_height, true);

// Dessiner le texte centré
draw_set_color(text_color);
draw_set_halign(fa_center);
draw_set_valign(fa_middle);
draw_text(x, y, "Contre l'IA");

// Remettre les alignements par défaut
draw_set_halign(fa_left);
draw_set_valign(fa_top);