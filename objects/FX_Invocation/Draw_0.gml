// FX_Invocation - Draw
// Phase 1: dessine le fantôme
// Phase 2: dessine le contour "circuit imprimé" autour de la carte posée

var old_alpha = draw_get_alpha();
var old_blend = gpu_get_blendmode();

// Phase fantôme (avant la pose)
if (!finished_move) {
    if (variable_instance_exists(self, "spriteGhost") && spriteGhost != noone) {
        draw_set_alpha(alpha);
        draw_sprite_ext(spriteGhost, imageGhost, x, y, image_xscale, image_yscale, image_angle, c_white, 1);
    }
}
else {
    // Phase circuit: révélation progressive de la carte vers l’extérieur
    var p = clamp(post_fx_t / max(1, post_fx_duration), 0, 1);
    // Progression séquentielle uniforme: A, puis B, puis C, puis nœuds
    var inner_frac = 0.20;
    var ring_frac  = 0.20;
    var diag_frac  = 0.20;
    var nodes_start = inner_frac + ring_frac + diag_frac; // 0.60
    var nodes_frac  = max(0.0001, 1.0 - nodes_start);     // 0.40
    var p_inner = clamp(p / inner_frac, 0, 1);
    var p_ring  = clamp((p - inner_frac) / ring_frac, 0, 1);
    var p_diag  = clamp((p - inner_frac - ring_frac) / diag_frac, 0, 1);
    var p_nodes = clamp((p - nodes_start) / nodes_frac, 0, 1);
    // Linéaire pour une vitesse constante dans chaque phase
    var e_inner = p_inner;
    var e_ring  = p_ring;
    var e_diag  = p_diag;
    var e_nodes = p_nodes;
    
    // Alpha constant pendant le dessin pour bien voir chaque étape
    var a = 1.0;
    var ring_thickness = max(1, thickness_start + (thickness_end - thickness_start) * e_ring);
    var trace_w = max(1, trace_thickness);
    var node_r = max(1, node_radius * e_nodes);
    
    gpu_set_blendmode(bm_add);
    draw_set_alpha(a);
    // Couleur flash pour pins et nœuds (pas de cercle)
    var is_flash = (post_fx_t > post_fx_duration);
    var flash_p = is_flash ? clamp((post_fx_t - post_fx_duration) / max(1, flash_duration), 0, 1) : 0;
    var flash_str = is_flash ? max(0, 1.0 - (flash_p * flash_p * flash_p)) : 0;
    var col_fx = (flash_str > 0) ? merge_color(col_main, c_white, flash_str) : col_main;
    draw_set_color(col_fx);

    // Axes orientés et dimensions
    var cos_a = dcos(circ_angle);
    var sin_a = dsin(circ_angle);
    var vx_x = cos_a; var vx_y = sin_a;        // axe horizontal
    var vy_x = -sin_a; var vy_y = cos_a;       // axe vertical
    var half_w = circ_w * 0.5;
    var half_h = circ_h * 0.5;
    var half_w_o = half_w + circuit_margin;
    var half_h_o = half_h + circuit_margin;

    // Coins carte (sans marge)
    var c1x = x + vx_x * half_w + vy_x * half_h; // top-right
    var c1y = y + vx_y * half_w + vy_y * half_h;
    var c2x = x - vx_x * half_w + vy_x * half_h; // top-left
    var c2y = y - vx_y * half_w + vy_y * half_h;
    var c3x = x - vx_x * half_w - vy_x * half_h; // bottom-left
    var c3y = y - vx_y * half_w - vy_y * half_h;
    var c4x = x + vx_x * half_w - vy_x * half_h; // bottom-right
    var c4y = y + vx_y * half_w - vy_y * half_h;

    // Midpoints carte (départ des traces)
    var ct_x = 0.5 * (c1x + c2x); var ct_y = 0.5 * (c1y + c2y);
    var cr_x = 0.5 * (c2x + c3x); var cr_y = 0.5 * (c2y + c3y);
    var cb_x = 0.5 * (c3x + c4x); var cb_y = 0.5 * (c3y + c4y);
    var cl_x = 0.5 * (c4x + c1x); var cl_y = 0.5 * (c4y + c1y);

    // Coins de l’anneau externe (autour de la carte)
    var p1x = x + vx_x * half_w_o + vy_x * half_h_o; // top-right
    var p1y = y + vx_y * half_w_o + vy_y * half_h_o;
    var p2x = x - vx_x * half_w_o + vy_x * half_h_o; // top-left
    var p2y = y - vx_y * half_w_o + vy_y * half_h_o;
    var p3x = x - vx_x * half_w_o - vy_x * half_h_o; // bottom-left
    var p3y = y - vx_y * half_w_o - vy_y * half_h_o;
    var p4x = x + vx_x * half_w_o - vy_x * half_h_o; // bottom-right
    var p4y = y + vx_y * half_w_o - vy_y * half_h_o;

    // Milieux de l’anneau
    var tmx = 0.5 * (p1x + p2x); var tmy = 0.5 * (p1y + p2y);
    var rmx = 0.5 * (p2x + p3x); var rmy = 0.5 * (p2y + p3y);
    var bmx = 0.5 * (p3x + p4x); var bmy = 0.5 * (p3y + p4y);
    var lmx = 0.5 * (p4x + p1x); var lmy = 0.5 * (p4y + p1y);

    // Ancrages externes (extension hors anneau)
    var a_tx = tmx + (tmx - x) / max(0.0001, point_distance(x, y, tmx, tmy)) * trace_out;
    var a_ty = tmy + (tmy - y) / max(0.0001, point_distance(x, y, tmx, tmy)) * trace_out;
    var a_rx = rmx + (rmx - x) / max(0.0001, point_distance(x, y, rmx, rmy)) * trace_out;
    var a_ry = rmy + (rmy - y) / max(0.0001, point_distance(x, y, rmx, rmy)) * trace_out;
    var a_bx = bmx + (bmx - x) / max(0.0001, point_distance(x, y, bmx, bmy)) * trace_out;
    var a_by = bmy + (bmy - y) / max(0.0001, point_distance(x, y, bmx, bmy)) * trace_out;
    var a_lx = lmx + (lmx - x) / max(0.0001, point_distance(x, y, lmx, lmy)) * trace_out;
    var a_ly = lmy + (lmy - y) / max(0.0001, point_distance(x, y, lmx, lmy)) * trace_out;

    // Motif microchip: calcul du corps du chip (sans le dessiner)
    var chip_scale = (variable_instance_exists(self, "chip_scale") ? chip_scale : 0.55);
    var chw = half_w * chip_scale;
    var chh = half_h * chip_scale;

    // Coins du chip (orientés avec circ_angle) — utilisés comme origine des pins
    var ch1x = x + vx_x * chw + vy_x * chh; var ch1y = y + vx_y * chw + vy_y * chh; // top-right
    var ch2x = x - vx_x * chw + vy_x * chh; var ch2y = y - vx_y * chw + vy_y * chh; // top-left
    var ch3x = x - vx_x * chw - vy_x * chh; var ch3y = y - vx_y * chw - vy_y * chh; // bottom-left
    var ch4x = x + vx_x * chw - vy_x * chh; var ch4y = y + vx_y * chw - vy_y * chh; // bottom-right

    // Ne pas dessiner le carré central ni le contour du chip: seulement les lignes (pins)



    // Pins autour du chip: révélation par segments (A: sortie, B: latéral, C: sortie finale)
    var base_margin = (variable_instance_exists(self, "circuit_margin") ? circuit_margin : 10);
    var pin_out1    = base_margin * 0.8;
    var pin_out2    = base_margin * 1.4;
    var pin_lat_base= base_margin * 1.0;
    var edge_inset  = max(2, base_margin * 0.5);

    var tA = e_inner;
    var tB = e_ring;
    var tC = e_diag;

    // Quantité de pins par côté (approximée sur l’image)
    var pins_top    = (variable_instance_exists(self, "pins_top")    ? pins_top    : 5);
    var pins_bottom = (variable_instance_exists(self, "pins_bottom") ? pins_bottom : 5);
    var pins_left   = (variable_instance_exists(self, "pins_left")   ? pins_left   : 4);
    var pins_right  = (variable_instance_exists(self, "pins_right")  ? pins_right  : 4);

    // TOP
    var top_left_x = c2x; var top_left_y = c2y;
    var top_len = half_w * 2;
    var gap_t = (top_len - edge_inset * 2) / max(1, pins_top - 1);
    for (var i = 0; i < pins_top; i++) {
        var along = edge_inset + i * gap_t;
        var Sx = top_left_x + vx_x * along; var Sy = top_left_y + vx_y * along;
        var side_factor = abs((i - (pins_top - 1) * 0.5)) / max(1, (pins_top - 1) * 0.5);
        var lat = pin_lat_base * side_factor;
        var sgn = ((i & 1) == 0) ? 1 : -1;
        var P1x = Sx + vy_x * pin_out1; var P1y = Sy + vy_y * pin_out1;
        var P2x = P1x + vx_x * (sgn * lat); var P2y = P1y + vx_y * (sgn * lat);
        var P3x = P2x + vy_x * pin_out2; var P3y = P2y + vy_y * pin_out2;
        if (tA > 0) { var e1x = Sx + (P1x - Sx) * tA; var e1y = Sy + (P1y - Sy) * tA; draw_line_width(Sx, Sy, e1x, e1y, trace_w); }
        if (tB > 0) { var e2x = P1x + (P2x - P1x) * tB; var e2y = P1y + (P2y - P1y) * tB; draw_line_width(P1x, P1y, e2x, e2y, trace_w); }
        if (tC > 0) { var e3x = P2x + (P3x - P2x) * tC; var e3y = P2y + (P3y - P2y) * tC; draw_line_width(P2x, P2y, e3x, e3y, trace_w); }
        if (node_r > 1) { draw_circle_color(P3x, P3y, node_r, col_fx, col_fx, false); }
    }

    // BOTTOM
    var bottom_left_x = c3x; var bottom_left_y = c3y;
    var gap_b = (top_len - edge_inset * 2) / max(1, pins_bottom - 1);
    for (var j = 0; j < pins_bottom; j++) {
        var alongb = edge_inset + j * gap_b;
        var Sbx = bottom_left_x + vx_x * alongb; var Sby = bottom_left_y + vx_y * alongb;
        var side_factor_b = abs((j - (pins_bottom - 1) * 0.5)) / max(1, (pins_bottom - 1) * 0.5);
        var lat_b = pin_lat_base * side_factor_b;
        var sgn_b = ((j & 1) == 0) ? -1 : 1;
        var P1bx = Sbx - vy_x * pin_out1; var P1by = Sby - vy_y * pin_out1;
        var P2bx = P1bx + vx_x * (sgn_b * lat_b); var P2by = P1by + vx_y * (sgn_b * lat_b);
        var P3bx = P2bx - vy_x * pin_out2; var P3by = P2by - vy_y * pin_out2;
        if (tA > 0) { var e1bx = Sbx + (P1bx - Sbx) * tA; var e1by = Sby + (P1by - Sby) * tA; draw_line_width(Sbx, Sby, e1bx, e1by, trace_w); }
        if (tB > 0) { var e2bx = P1bx + (P2bx - P1bx) * tB; var e2by = P1by + (P2by - P1by) * tB; draw_line_width(P1bx, P1by, e2bx, e2by, trace_w); }
        if (tC > 0) { var e3bx = P2bx + (P3bx - P2bx) * tC; var e3by = P2by + (P3by - P2by) * tC; draw_line_width(P2bx, P2by, e3bx, e3by, trace_w); }
        if (node_r > 1) { draw_circle_color(P3bx, P3by, node_r, col_fx, col_fx, false); }
    }

    // LEFT
    var left_top_x = c2x; var left_top_y = c2y;
    var left_len = half_h * 2;
    var gap_l = (left_len - edge_inset * 2) / max(1, pins_left - 1);
    for (var k = 0; k < pins_left; k++) {
        var alongl = edge_inset + k * gap_l;
        var Slx = left_top_x - vy_x * alongl; var Sly = left_top_y - vy_y * alongl;
        var side_factor_l = abs((k - (pins_left - 1) * 0.5)) / max(1, (pins_left - 1) * 0.5);
        var lat_l = pin_lat_base * side_factor_l;
        var sgn_l = ((k & 1) == 0) ? -1 : 1; // vers l'extérieur gauche
        var P1lx = Slx - vx_x * pin_out1; var P1ly = Sly - vx_y * pin_out1;
        var P2lx = P1lx + vy_x * (sgn_l * lat_l); var P2ly = P1ly + vy_y * (sgn_l * lat_l);
        var P3lx = P2lx - vx_x * pin_out2; var P3ly = P2ly - vx_y * pin_out2;
        if (tA > 0) { var e1lx = Slx + (P1lx - Slx) * tA; var e1ly = Sly + (P1ly - Sly) * tA; draw_line_width(Slx, Sly, e1lx, e1ly, trace_w); }
        if (tB > 0) { var e2lx = P1lx + (P2lx - P1lx) * tB; var e2ly = P1ly + (P2ly - P1ly) * tB; draw_line_width(P1lx, P1ly, e2lx, e2ly, trace_w); }
        if (tC > 0) { var e3lx = P2lx + (P3lx - P2lx) * tC; var e3ly = P2ly + (P3ly - P2ly) * tC; draw_line_width(P2lx, P2ly, e3lx, e3ly, trace_w); }
        if (node_r > 1) { draw_circle_color(P3lx, P3ly, node_r, col_fx, col_fx, false); }
    }

    // RIGHT
    var right_top_x = c1x; var right_top_y = c1y;
    var right_len = half_h * 2;
    var gap_r = (right_len - edge_inset * 2) / max(1, pins_right - 1);
    for (var m = 0; m < pins_right; m++) {
        var alongr = edge_inset + m * gap_r;
        var Srx = right_top_x - vy_x * alongr; var Sry = right_top_y - vy_y * alongr;
        var side_factor_r = abs((m - (pins_right - 1) * 0.5)) / max(1, (pins_right - 1) * 0.5);
        var lat_r = pin_lat_base * side_factor_r;
        var sgn_r = ((m & 1) == 0) ? 1 : -1; // vers l'extérieur droite
        var P1rx = Srx + vx_x * pin_out1; var P1ry = Sry + vx_y * pin_out1;
        var P2rx = P1rx + vy_x * (sgn_r * lat_r); var P2ry = P1ry + vy_y * (sgn_r * lat_r);
        var P3rx = P2rx + vx_x * pin_out2; var P3ry = P2ry + vx_y * pin_out2;
        if (tA > 0) { var e1rx = Srx + (P1rx - Srx) * tA; var e1ry = Sry + (P1ry - Sry) * tA; draw_line_width(Srx, Sry, e1rx, e1ry, trace_w); }
        if (tB > 0) { var e2rx = P1rx + (P2rx - P1rx) * tB; var e2ry = P1ry + (P2ry - P1ry) * tB; draw_line_width(P1rx, P1ry, e2rx, e2ry, trace_w); }
        if (tC > 0) { var e3rx = P2rx + (P3rx - P2rx) * tC; var e3ry = P2ry + (P3ry - P2ry) * tC; draw_line_width(P2rx, P2ry, e3rx, e3ry, trace_w); }
        if (node_r > 1) { draw_circle_color(P3rx, P3ry, node_r, col_fx, col_fx, false); }
    }
}

// Restore state
draw_set_alpha(old_alpha);
gpu_set_blendmode(old_blend);