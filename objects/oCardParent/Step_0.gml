// === oCardParent - Step Event ===

if (variable_instance_exists(id, "position_anim_active") && position_anim_active) {
    // Lire vitesses/délai depuis globals si non définis
    if (!variable_instance_exists(id, "anim_rotate_speed")) {
        anim_rotate_speed = (variable_global_exists("ANIM_ROTATE_SPEED") ? global.ANIM_ROTATE_SPEED : 6);
    }
    if (!variable_instance_exists(id, "anim_flip_speed")) {
        anim_flip_speed = (variable_global_exists("ANIM_FLIP_SPEED") ? global.ANIM_FLIP_SPEED : 0.03);
    }
    if (!variable_instance_exists(id, "anim_pre_delay_frames")) {
        anim_pre_delay_frames = (variable_global_exists("ANIM_ROTATE_PRE_DELAY_FRAMES") ? global.ANIM_ROTATE_PRE_DELAY_FRAMES : 6);
    }
    if (!variable_instance_exists(id, "anim_phase")) anim_phase = "rotate";
    if (!variable_instance_exists(id, "anim_flip_orig_scale")) anim_flip_orig_scale = image_xscale;
    if (!variable_instance_exists(id, "target_angle")) target_angle = image_angle;

    var pi_c = 3.141592653589793;

    // Phase 1: flip-in (rétrécit X)
    if (anim_phase == "flip_in") {
        if (!variable_instance_exists(id, "anim_init_flip_in") || !anim_init_flip_in) {
            anim_init_flip_in = true;
            anim_timer = 0;
            flip_start = image_xscale;
            flip_end = 0;
            anim_duration = max(1, round(abs(flip_start - flip_end) / max(0.001, anim_flip_speed)));
        }
        anim_timer = min(anim_timer + 1 / anim_duration, 1);
        var t = -(cos(pi_c * anim_timer) - 1) / 2; // easeInOutSine
        image_xscale = lerp(flip_start, flip_end, t);
        if (anim_timer >= 1) {
            image_xscale = 0;
            image_index = 0;
            if (variable_instance_exists(id, "isFaceDown")) isFaceDown = false;
            anim_init_flip_in = false;
            anim_phase = "flip_out";
        }
    }
    // Phase 2: flip-out (ré-élargit X)
    else if (anim_phase == "flip_out") {
        if (!variable_instance_exists(id, "anim_init_flip_out") || !anim_init_flip_out) {
            anim_init_flip_out = true;
            anim_timer = 0;
            flip_start = image_xscale;
            flip_end = anim_flip_orig_scale;
            anim_duration = max(1, round(abs(flip_end - flip_start) / max(0.001, anim_flip_speed)));
        }
        anim_timer = min(anim_timer + 1 / anim_duration, 1);
        var t2 = -(cos(pi_c * anim_timer) - 1) / 2;
        image_xscale = lerp(flip_start, flip_end, t2);
        if (anim_timer >= 1) {
            image_xscale = anim_flip_orig_scale;
            anim_init_flip_out = false;
            anim_phase = "rotate";
        }
    }
    // Phase 3: rotation (avec pré-délai léger)
    else if (anim_phase == "rotate") {
        if (!variable_instance_exists(id, "anim_init_rotate") || !anim_init_rotate) {
            anim_init_rotate = true;
            anim_timer = 0;
            anim_start_angle = image_angle;
            anim_end_angle = target_angle;
            anim_delta_angle = anim_end_angle - anim_start_angle;
            anim_duration = max(1, round(abs(anim_delta_angle) / max(0.001, anim_rotate_speed)));
            anim_delay_counter = 0; // pré-délai avant rotation
        }
        // Appliquer le pré-délai
        if (anim_delay_counter < anim_pre_delay_frames) {
            anim_delay_counter++;
        } else {
            // Interpolation ease-in-out
            anim_timer = min(anim_timer + 1 / anim_duration, 1);
            var t3 = -(cos(pi_c * anim_timer) - 1) / 2;
            image_angle = anim_start_angle + anim_delta_angle * t3;
            if (anim_timer >= 1) {
                image_angle = target_angle;
                if (variable_instance_exists(id, "target_orientation")) orientation = target_orientation;
                // Renforcer la synchro finale
                image_index = 0;
                if (variable_instance_exists(id, "isFaceDown")) isFaceDown = false;
                orientationChangedThisTurn = true;
                position_anim_active = false;
                anim_init_rotate = false;
            }
        }
    }
}

// --- Détection de survol (sans interférer avec la sélection) ---
// Désactiver le survol pendant une animation de position/flip
if (variable_instance_exists(id, "position_anim_active") && position_anim_active) {
    isHovered = false;
} else {
    // Restreindre le survol aux cartes de la main et du terrain uniquement
    var zone_exists = variable_instance_exists(id, "zone");
    var hover_zone_allowed = zone_exists && (zone == "Hand" || zone == "Field");
    // Ne pas appliquer l'effet si la carte est sélectionnée (états HandSelected/FieldSelected)
    var selected_by_zone = zone_exists && (zone == "HandSelected" || zone == "FieldSelected");
    if (selected_by_zone || !hover_zone_allowed) {
        isHovered = false;
    } else {
        // Calculer un rectangle englobant la carte en tenant compte de l'échelle et de la rotation
        var w = sprite_get_width(sprite_index) * image_xscale;
        var h = sprite_get_height(sprite_index) * image_yscale;
        var cx = x;
        var cy = y;
        var ca = cos(image_angle * pi / 180);
        var sa = sin(image_angle * pi / 180);
        var lx1 = -w * 0.5; var ly1 = -h * 0.5;
        var lx2 =  w * 0.5; var ly2 = -h * 0.5;
        var lx3 =  w * 0.5; var ly3 =  h * 0.5;
        var lx4 = -w * 0.5; var ly4 =  h * 0.5;
        var x1 = cx + lx1*ca - ly1*sa; var y1 = cy + lx1*sa + ly1*ca;
        var x2 = cx + lx2*ca - ly2*sa; var y2 = cy + lx2*sa + ly2*ca;
        var x3 = cx + lx3*ca - ly3*sa; var y3 = cy + lx3*sa + ly3*ca;
        var x4 = cx + lx4*ca - ly4*sa; var y4 = cy + lx4*sa + ly4*ca;
        var left_b   = min(min(x1,x2), min(x3,x4));
        var right_b  = max(max(x1,x2), max(x3,x4));
        var top_b    = min(min(y1,y2), min(y3,y4));
        var bottom_b = max(max(y1,y2), max(y3,y4));
        isHovered = (mouse_x >= left_b && mouse_x <= right_b && mouse_y >= top_b && mouse_y <= bottom_b);
    }
}