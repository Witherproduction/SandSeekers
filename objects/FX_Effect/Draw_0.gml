// FX_Effect - Draw
// Affiche la carte fantôme au centre et une aura dorée autour

var old_alpha = draw_get_alpha();
var old_blend = gpu_get_blendmode();

// Appliquer un multiplicateur d'échelle lorsque l'affichage est centré
var sx = image_xscale * (display_at_center ? 2.0 : 1.0);
var sy = image_yscale * (display_at_center ? 2.0 : 1.0);

// Halo elliptique (autour du centre de la carte)
if (variable_instance_exists(self, "spriteGhost") && spriteGhost != noone && spr_w > 0 && spr_h > 0) {
    var x_left   = x - spr_xoff * sx;
    var y_top    = y - spr_yoff * sy;
    var x_right  = x_left + spr_w * sx;
    var y_bottom = y_top  + spr_h * sy;

    var cx = (x_left + x_right) * 0.5;
    var cy = (y_top + y_bottom) * 0.5;
    var pad = halo_pad_px + halo_expand_current;

    var rx = ((x_right - x_left) * 0.5) + pad;
    var ry = ((y_bottom - y_top) * 0.5) + pad;
    rx *= (variable_instance_exists(self, "halo_oval_xmul") ? halo_oval_xmul : 1.20);
    ry *= (variable_instance_exists(self, "halo_oval_ymul") ? halo_oval_ymul : 0.90);

    // Rotation de 90°: échanger les rayons pour inverser l’orientation de l’ellipse
    var rx_rot = ry;
    var ry_rot = rx;

    var hx1 = cx - rx_rot;
    var hy1 = cy - ry_rot;
    var hx2 = cx + rx_rot;
    var hy2 = cy + ry_rot;

    gpu_set_blendmode(bm_add);

    // Glow externe doux (ellipse pleine)
    draw_set_alpha(min(1, 0.35 * halo_alpha_current));
    draw_ellipse_color(hx1 - 4, hy1 - 4, hx2 + 4, hy2 + 4, halo_col2, halo_col2, false);

    // Anneau lumineux par couches (ellipses en contour)
    var layers = max(1, halo_thickness);
    for (var i = 0; i < layers; i += 2) {
        var t = i;
        var a = halo_alpha_current * (1.0 - (i / max(1, layers)));
        draw_set_alpha(a);
        draw_ellipse_color(hx1 - t, hy1 - t, hx2 + t, hy2 + t, halo_col1, halo_col1, true);
    }

    gpu_set_blendmode(old_blend);
}

// Dessiner la carte fantôme au centre (double taille si centré)
if (variable_instance_exists(self, "spriteGhost") && spriteGhost != noone) {
    draw_set_alpha(card_alpha);
    draw_sprite_ext(spriteGhost, imageGhost, x, y, sx, sy, image_angle, c_white, 1);
}

draw_set_alpha(old_alpha);