// FX_Effect - Create
// Aura dorée au centre pour mise en avant d’une carte
// Paramètres via spawner:
// - spriteGhost, imageGhost, image_xscale, image_yscale, image_angle
// - duration_ms (optionnel)
// - halo_pad_px, halo_thickness (optionnels)
// - depth_override (optionnel)

start_x = x;
start_y = y;

// Durée par défaut ~0.6s
var default_frames = 0.6 * room_speed;
duration = default_frames;
if (variable_instance_exists(self, "duration_ms")) {
    duration = max(1, (duration_ms / 1000.0) * room_speed);
}

// Apparence
if (!variable_instance_exists(self, "imageGhost")) { imageGhost = 0; }
image_xscale = (variable_instance_exists(self, "image_xscale") ? image_xscale : 1);
image_yscale = (variable_instance_exists(self, "image_yscale") ? image_yscale : 1);
image_angle  = (variable_instance_exists(self, "image_angle")  ? image_angle  : 0);

// Halo
halo_pad_px    = (variable_instance_exists(self, "halo_pad_px") ? halo_pad_px : 18);
halo_thickness = (variable_instance_exists(self, "halo_thickness") ? halo_thickness : 10);
halo_expand_px = 6;
halo_col1 = make_color_rgb(255, 215, 0);
halo_col2 = make_color_rgb(255, 236, 160);
// Ovalisation
halo_oval_xmul = (variable_instance_exists(self, "halo_oval_xmul") ? halo_oval_xmul : 1.30);
halo_oval_ymul = (variable_instance_exists(self, "halo_oval_ymul") ? halo_oval_ymul : 0.95);

// Propriété de centrage (activée par défaut pour afficher au milieu de l’écran)
display_at_center = true;

// Option profondeur
if (variable_instance_exists(self, "depth_override")) {
    depth = depth_override;
} else {
    depth = -100000;
}

// Calcul paresseux des dimensions du sprite
spr_w = 0;
spr_h = 0;
spr_xoff = 0;
spr_yoff = 0;

// Progression
_t = 0;

// Fondu
fade_in_frames  = floor(0.15 * room_speed);
fade_out_frames = floor(0.15 * room_speed);
// clamp pour éviter dépassement si duration trop courte
var min_frames = fade_in_frames + fade_out_frames;
if (duration < min_frames) {
    fade_in_frames  = max(1, floor(0.5 * duration));
    fade_out_frames = max(1, duration - fade_in_frames);
}

// Alpha interne
halo_base_alpha = 0.65;
card_alpha = 1.0;