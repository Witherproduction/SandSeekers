// === oButtonCardCreator - Draw Event ===
// Affichage du bouton de création de cartes

// Calculer les limites du bouton
var button_left = x - button_width / 2;
var button_top = y - button_height / 2;
var button_right = x + button_width / 2;
var button_bottom = y + button_height / 2;

// Vérifier si la souris survole le bouton
var mouse_x_pos = mouse_x;
var mouse_y_pos = mouse_y;
is_hovered = (mouse_x_pos >= button_left && mouse_x_pos <= button_right && 
              mouse_y_pos >= button_top && mouse_y_pos <= button_bottom);

// Dessiner le sprite du bouton
draw_sprite_stretched(sButton, 0, button_left, button_top, button_width, button_height);

// Dessiner le texte
draw_set_font(fontCardDisplay);
// Ombre portée légère sous le texte
draw_set_color(make_color_rgb(80, 50, 20));
draw_set_halign(fa_center);
draw_set_valign(fa_middle);
draw_text(x + 2, y + 2, button_text);

// Texte en crème dorée (uniforme, sans variation au survol)
draw_set_color(make_color_rgb(230, 200, 120));
draw_text(x, y, button_text);

// Réinitialiser les paramètres de dessin
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_white);