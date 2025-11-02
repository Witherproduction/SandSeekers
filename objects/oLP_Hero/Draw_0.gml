draw_sprite_ext(sLP_Hero, 0, x, y, 0.7, 0.7, 0, c_white, 1);
draw_set_font(fontLP);
draw_set_halign(fa_center);
draw_set_valign(fa_middle);
// Origine du sprite centrée : le centre visuel est déjà (x, y)
var text_x_hero = x + 40; // décalage à droite augmenté
var text_y_hero = y;
// Couleur sombre pour contraster sur fond doré
draw_text_color(text_x_hero, text_y_hero, nbLP, #3d2b00, #3d2b00, #3d2b00, #3d2b00, 1);
