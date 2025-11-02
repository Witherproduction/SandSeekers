/// @function requestFXAura(spriteGhost, imageGhost, xscale, yscale, angle, duration_ms, halo_pad_px, halo_thickness, halo_oval_xmul, halo_oval_ymul, pos_x, pos_y)
/// @description Demande un halo doré autour d’une carte. Si un halo est en cours, met en file d'attente; sinon, instancie immédiatement.
function requestFXAura(spriteGhost, imageGhost, xscale, yscale, angle, duration_ms, halo_pad_px, halo_thickness, halo_oval_xmul, halo_oval_ymul, pos_x, pos_y) {
    // Init du verrou et de la file (FIFO)
    if (!variable_global_exists("fx_aura_lock")) {
        global.fx_aura_lock = false;
    }
    if (!variable_global_exists("fx_aura_queue") || global.fx_aura_queue == undefined) {
        global.fx_aura_queue = ds_queue_create();
    }

    // Construire la configuration de halo
    var cfg = {
        spriteGhost: spriteGhost,
        imageGhost: imageGhost,
        image_xscale: xscale,
        image_yscale: yscale,
        image_angle : angle,
        duration_ms : duration_ms,
        halo_pad_px : halo_pad_px,
        halo_thickness: halo_thickness,
        halo_oval_xmul: halo_oval_xmul,
        halo_oval_ymul: halo_oval_ymul,
        pos_x: pos_x,
        pos_y: pos_y,
    };

    // Lire une action post-aura (optionnelle) et la purger après usage
    var oncomp = (variable_global_exists("fx_aura_next_on_complete") ? global.fx_aura_next_on_complete : noone);

    // Si pas de halo actif, instancier immédiatement
    if (!global.fx_aura_lock) {
        var px = room_width * 0.5;
        var py = room_height * 0.5;
        var fx = instance_create_depth(px, py, -100000, FX_Effect);
        if (fx != noone) {
            // Aura centrée: ne pas forcer la position carte
            fx.display_at_center = true;
            // Propager les paramètres visuels
            fx.spriteGhost    = cfg.spriteGhost;
            fx.imageGhost     = cfg.imageGhost;
            fx.image_xscale   = cfg.image_xscale;
            fx.image_yscale   = cfg.image_yscale;
            fx.image_angle    = cfg.image_angle;
            fx.duration_ms    = cfg.duration_ms;
            fx.halo_pad_px    = cfg.halo_pad_px;
            fx.halo_thickness = cfg.halo_thickness;
            fx.halo_oval_xmul = cfg.halo_oval_xmul;
            fx.halo_oval_ymul = cfg.halo_oval_ymul;
            // Attacher l'action de fin si fournie
            if (oncomp != noone) { fx.on_complete_action = oncomp; }
        }
        global.fx_aura_lock = true;
        global.fx_aura_instance = fx;
        // Purge du next action consommé
        global.fx_aura_next_on_complete = noone;
    }
    // Sinon, mettre en file pour apparition séquentielle
    else {
        // Joindre aussi l'action de fin au cfg si présente
        if (oncomp != noone) { cfg.on_complete_action = oncomp; }
        ds_queue_enqueue(global.fx_aura_queue, cfg);
        // Purge du next action consommé
        global.fx_aura_next_on_complete = noone;
    }
}