// oFX_Draw - Step
// Effet de pioche: glissade verticale vers la main avec glow

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

// Initialisation paresseuse de l’échelle au premier Step (après assignation par le spawner)
if (!scale_initialized) {
    base_scale_x = image_xscale;
    base_scale_y = image_yscale;
    scale_initialized = true;
}

// Alpha et interpolation de position (verticale si target_x == start_x)
alpha = min(1, 0.15 + 0.85 * ease);
var base_x = lerp(start_x, target_x, ease);
var base_y = lerp(start_y, target_y, ease);
x = base_x;
y = base_y;

// Échelle fixe (sans pulse)
image_xscale = base_scale_x;
image_yscale = base_scale_y;

// Fin d’animation
if (progress >= 1) {
    // Rafraîchir la main seulement une fois l’animation terminée
    if (variable_instance_exists(self, "hand_to_update") && instance_exists(hand_to_update)) {
        if (variable_instance_exists(hand_to_update, "updateDisplay")) {
            hand_to_update.updateDisplay();
        }
    }
    // Révéler la carte réelle si fournie
    if (variable_instance_exists(self, "card_to_reveal") && instance_exists(card_to_reveal)) {
        card_to_reveal.visible = true;
    }
    instance_destroy();
}