// FX_Effect - Step
_t++;
var progress = clamp(_t / duration, 0, 1);

// Lissage Smoothstep
var ease = progress * progress * (3 - 2 * progress);

// Centre de l'écran si demandé
if (display_at_center) {
    x = room_width * 0.5;
    y = room_height * 0.5;
}

// Calcul paresseux des dimensions du sprite
if ((spr_w <= 0 || spr_h <= 0) && variable_instance_exists(self, "spriteGhost") && spriteGhost != noone) {
    spr_w   = sprite_get_width(spriteGhost);
    spr_h   = sprite_get_height(spriteGhost);
    spr_xoff = sprite_get_xoffset(spriteGhost);
    spr_yoff = sprite_get_yoffset(spriteGhost);
}

// Expansion douce du halo (respire légèrement)
var expand = sin(progress * pi) * halo_expand_px;

// Alpha du halo: fade-in -> plein -> fade-out
var halo_a = halo_base_alpha;
if (_t <= fade_in_frames) {
    halo_a = halo_base_alpha * (_t / max(1, fade_in_frames));
} else if (_t >= (duration - fade_out_frames)) {
    var rem = duration - _t;
    halo_a = halo_base_alpha * (rem / max(1, fade_out_frames));
}

halo_alpha_current = halo_a;
halo_expand_current = expand;

// Fin
// Lorsque le halo est terminé, enchaîner la file ou libérer le verrou
if (progress >= 1) {
    // Exécuter l'action de fin, si fournie pour CE halo
    if (variable_instance_exists(self, "on_complete_action") && is_callable(on_complete_action)) {
        var __fn = on_complete_action;
        on_complete_action = noone;
        __fn();
    }

    // Vérifier la présence d'une queue valide et non vide
    var __has_queue = variable_global_exists("fx_aura_queue") && (global.fx_aura_queue != undefined) && (ds_queue_size(global.fx_aura_queue) > 0);
    if (__has_queue) {
        var cfg = ds_queue_dequeue(global.fx_aura_queue);
        var px = room_width * 0.5;
        var py = room_height * 0.5;
        var fx = instance_create_depth(px, py, -100000, FX_Effect);
        if (fx != noone) {
            // Aura centrée: ne pas forcer la position carte
            fx.display_at_center = true;
            // Paramètres visuels
            if (variable_struct_exists(cfg, "spriteGhost")) {
                fx.spriteGhost = cfg.spriteGhost;
            }
            fx.imageGhost     = cfg.imageGhost;
            fx.image_xscale   = cfg.image_xscale;
            fx.image_yscale   = cfg.image_yscale;
            fx.image_angle    = cfg.image_angle;
            fx.duration_ms    = cfg.duration_ms;
            fx.halo_pad_px    = cfg.halo_pad_px;
            fx.halo_thickness = cfg.halo_thickness;
            fx.halo_oval_xmul = cfg.halo_oval_xmul;
            fx.halo_oval_ymul = cfg.halo_oval_ymul;
            // Propager une éventuelle action de fin associée à cet item de queue
            if (variable_struct_exists(cfg, "on_complete_action")) {
                fx.on_complete_action = cfg.on_complete_action;
            }
        }
        global.fx_aura_instance = fx;
    } else {
        global.fx_aura_lock = false;
        global.fx_aura_instance = noone;
        instance_destroy();
    }
}