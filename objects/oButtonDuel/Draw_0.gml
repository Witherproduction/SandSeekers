// === oButtonDuel - Draw Event ===
// Dessine un cadre neutre avec le texte "Duel"

// Position centrée sur l'objet
var draw_x = x - button_width / 2;
var draw_y = y - button_height / 2;

// Dessiner le sprite du bouton
draw_sprite_stretched(sButton, 0, draw_x, draw_y, button_width, button_height);

// Ombre portée légère sous le texte
draw_set_color(make_color_rgb(80, 50, 20));
draw_set_halign(fa_center);
draw_set_valign(fa_middle);
draw_text(x + 2, y + 2, "Duel");

// Dessiner le texte "Duel" centré en crème dorée
draw_set_color(make_color_rgb(230, 200, 120));
draw_text(x, y, "Duel");

// Remettre les alignements par défaut
draw_set_halign(fa_left);
draw_set_valign(fa_top);