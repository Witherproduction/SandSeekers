// === oRetour1 - Draw Event ===
// Dessine le sprite sButton à la taille cible et le texte "retour"

// Définir les dimensions du bouton (doublées)
var button_width = 240;
var button_height = 80;

// Position centrée sur l'objet
var draw_x = x - button_width / 2;
var draw_y = y - button_height / 2;

// Dessiner le sprite du bouton étiré à la taille cible (toujours sButton)
draw_sprite_stretched(sButton, 0, draw_x, draw_y, button_width, button_height);

// Dessiner le texte "retour" centré au-dessus
// Ombre portée légère sous le texte
draw_set_color(make_color_rgb(80, 50, 20));
draw_set_halign(fa_center);
draw_set_valign(fa_middle);
draw_text(x + 2, y + 2, "retour");

// Couleur légèrement dorée pour un bon contraste sur fond marron
draw_set_color(make_color_rgb(230, 200, 120));
draw_text(x, y, "retour");

// Remettre les alignements par défaut
draw_set_halign(fa_left);
draw_set_valign(fa_top);