// oFX_Discard - Step
// Effet de défausse: brûlure et déplacement (spécialisé)

_t++;
var progress = clamp(_t / duration, 0, 1);

// Lissage Smoothstep
var ease = progress * progress * (3 - 2 * progress);

// Calcul paresseux des dimensions du sprite si non initialisées
if ((spr_w <= 0 || spr_h <= 0) && variable_instance_exists(self, "spriteGhost") && spriteGhost != noone) {
    spr_w = sprite_get_width(spriteGhost);
    spr_h = sprite_get_height(spriteGhost);
    spr_xoff = sprite_get_xoffset(spriteGhost);
    spr_yoff = sprite_get_yoffset(spriteGhost);
}

// Défausse: brûlure progressive
var jitter = irandom_range(-flame_jitter_amp, flame_jitter_amp) * (1 - ease);
burn_px = clamp(floor(ease * spr_h + jitter), 0, spr_h);

// Interpolation de position
var base_x = lerp(start_x, target_x, ease);
var base_y = lerp(start_y, target_y, ease);

// Déviation latérale et arc
var sway = sin(curve_phase + progress * pi) * curve_amplitude * (1 - progress);
var arc  = -sin(progress * pi) * arc_amplitude; // arc vers le haut (y négatif)

// Position: centrée si demandé, sinon interpolation vers cible
if (variable_instance_exists(self, "display_at_center") && display_at_center) {
    x = room_width * 0.5;
    y = room_height * 0.5;
} else {
    x = base_x + sway;
    y = base_y + arc;
}

// Opaque pour la brûlure
alpha = 1.0;

// Fin d’animation
if (progress >= 1) {
    // Rafraîchir la main si demandé
    if (variable_instance_exists(self, "hand_to_update") && instance_exists(hand_to_update)) {
        if (variable_instance_exists(hand_to_update, "updateDisplay")) {
            hand_to_update.updateDisplay();
        }
    }
    instance_destroy();
}