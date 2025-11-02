draw_sprite_ext(sLP_Enemy, 0, x, y+5, 0.7, 0.7, 0, c_white, 1);
draw_set_font(fontLP);
draw_set_halign(fa_center);
draw_set_valign(fa_middle);
// Origine du sprite centrée : le centre visuel est déjà (x, y+5)
var text_x_enemy = x - 40; // décalage à gauche augmenté
var text_y_enemy = y + 5;
// Couleur sombre pour contraster sur fond doré
draw_text_color(text_x_enemy, text_y_enemy, nbLP, #3d2b00, #3d2b00, #3d2b00, #3d2b00, 1);
