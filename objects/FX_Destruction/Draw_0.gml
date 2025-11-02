/// @desc Dessine les deux moitiés déchirées avec une couture irrégulière
if (!initialized) { exit; }

var spr = spriteGhost;
if (spr == -1 || spr == 0) spr = sprite_index;
if (spr == -1) exit;

// Sauvegarde de l’alpha
var prev_alpha = draw_get_alpha();
draw_set_alpha(alpha_fx);

// Matrice de transformation centrée sur la carte
var mat = matrix_build(x, y, 0, 0, 0, image_angle, image_xscale, image_yscale, 1);
matrix_set(matrix_world, mat);

var half_sep = sep_cur * 0.5;

// Origine (coin supérieur gauche) de la carte dans l’espace local
var base_x = -spr_w * 0.5;
var base_y = -spr_h * 0.5;

var rows = tear_rows;

// Moitié gauche (bandes)
for (var r = 0; r < rows; r++) {
    var top   = r * strip_h;
    var h     = min(strip_h, spr_h - top);
    var seam  = tear_x[r];
    var w_left = max(1, floor(seam));
    var dx = base_x - half_sep + row_jitter_l[r];
    var dy = base_y + top;
    draw_sprite_part_ext(spr, imageGhost, 0, top, w_left, h, dx, dy, 1, 1, c_white, alpha_fx);
}

// Moitié droite (bandes)
for (var r = 0; r < rows; r++) {
    var top   = r * strip_h;
    var h     = min(strip_h, spr_h - top);
    var seam  = tear_x[r];
    var w_right = max(1, spr_w - ceil(seam));
    var dx = base_x + seam + half_sep + row_jitter_r[r];
    var dy = base_y + top;
    draw_sprite_part_ext(spr, imageGhost, seam, top, w_right, h, dx, dy, 1, 1, c_white, alpha_fx);
}

// Optionnel: léger éclaircissement le long de la couture
gpu_set_blendmode(bm_add);
var prev_color = draw_get_color();
draw_set_color(c_white);
for (var r = 0; r < rows; r++) {
    var top   = r * strip_h;
    var h     = min(strip_h, spr_h - top);
    var seam  = tear_x[r];
    // Bord gauche (suivant la moitié gauche)
    var w_left   = max(1, floor(seam));
    var dx_l     = base_x - half_sep + row_jitter_l[r];
    var seam_x_l = dx_l + w_left;
    draw_rectangle(seam_x_l - 0.5, base_y + top, seam_x_l + 0.5, base_y + top + h, false);
    // Bord droit (suivant la moitié droite)
    var dx_r     = base_x + seam + half_sep + row_jitter_r[r];
    var seam_x_r = dx_r;
    draw_rectangle(seam_x_r - 0.5, base_y + top, seam_x_r + 0.5, base_y + top + h, false);
}
draw_set_color(prev_color);
gpu_set_blendmode(bm_normal);

// Restaurer la transformation et l’alpha
matrix_set(matrix_world, matrix_build_identity());
draw_set_alpha(prev_alpha);