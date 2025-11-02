/// @desc Met à jour la progression et initialise au premier Step
if (!initialized) {
    spr = spriteGhost;
    if (spr == -1 || spr == 0) { spr = sprite_index; }
    if (spr == -1) { spr = 0; }

    spr_w = (spr != 0) ? sprite_get_width(spr)  : 0;
    spr_h = (spr != 0) ? sprite_get_height(spr) : 0;

    if (spr_w <= 0 || spr_h <= 0) {
        // Rien à dessiner; abort
        instance_destroy();
        exit;
    }

    // Segmentation en bandes horizontales
    var rows = ceil(spr_h / strip_h);
    tear_rows = rows;
    tear_x = array_create(rows, spr_w * 0.5);
    row_jitter_l = array_create(rows, 0);
    row_jitter_r = array_create(rows, 0);

    var seam_min = spr_w * seam_min_ratio;
    var seam_max = spr_w * seam_max_ratio;

    // Définition d’une "couture" irrégulière
    var freq = 0.18;
    var amp  = ragged_amp_px;

    for (var r = 0; r < rows; r++) {
        var top  = r * strip_h;
        var base = spr_w * 0.5 + sin(top * freq) * amp;
        var jit  = random_range(-amp * 0.6, amp * 0.6);
        var seam = clamp(base + jit, seam_min, seam_max);
        tear_x[r] = seam;

        // Petites irrégularités par bande
        row_jitter_l[r] = random_range(-row_jitter_amp, row_jitter_amp);
        row_jitter_r[r] = random_range(-row_jitter_amp, row_jitter_amp);
    }

    initialized = true;
}

_t += 1;
var dur_steps = max(1, round((duration_ms / 1000.0) * room_speed));
var p = clamp(_t / dur_steps, 0, 1);

// Ease-out (séparation qui s’accélère) 
progress = p;
sep_cur = sep_px * (p * p);

// Fin de vie
if (p >= 1) {
    instance_destroy();
}