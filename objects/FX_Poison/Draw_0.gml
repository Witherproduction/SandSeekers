/// FX_Poison Draw: flaque verte qui s’élargit autour de la cible
var t = clamp(progress / max(1, duration_steps), 0, 1);
var r = lerp(radius_start, radius_max, t);
var a = lerp(alpha_start, alpha_end, t);

var col = variable_instance_exists(self, "color") ? color : make_color_rgb(60, 200, 80);

// Dessiner une ellipse remplie légèrement aplatie pour donner l’effet de flaque
var rx = r;
var ry = r * 0.6;

var prev_col = draw_get_color();
var prev_alpha = draw_get_alpha();

draw_set_alpha(a);
draw_set_color(col);
draw_ellipse(x - rx, y - ry, x + rx, y + ry, false);

// Liseré léger plus sombre au bord
var edge_col = merge_color(col, c_black, 0.35);
draw_set_alpha(a * 0.8);
draw_set_color(edge_col);
draw_ellipse(x - rx, y - ry, x + rx, y + ry, true);

// Reset
draw_set_alpha(prev_alpha);
draw_set_color(prev_col);