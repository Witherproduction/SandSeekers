// oFX_Discard - Create
// Effet de défausse: paramètres de brûlure et déplacement (spécialisé)
// Paramètres attendus via le spawner:
// - spriteGhost: sprite de la carte
// - imageGhost: frame du sprite
// - target_x, target_y: destination (cimetière ou position voulue)
// - duration_ms (optionnel): durée en millisecondes
// - depth_override (optionnel)

start_x = x;
start_y = y;

// Durée par défaut ~2.1s
var default_frames = 2.1 * room_speed;
duration = default_frames;
if (variable_instance_exists(self, "duration_ms")) {
    duration = max(1, (duration_ms / 1000.0) * room_speed);
}

// Courbe fantôme
curve_amplitude = 16; // déviation latérale maximale
curve_phase = irandom_range(0, 360) * pi / 180;
arc_amplitude = 24; // arc vertical (vers le haut)

// Apparence initiale
image_xscale = (variable_instance_exists(self, "image_xscale") ? image_xscale : 1);
image_yscale = (variable_instance_exists(self, "image_yscale") ? image_yscale : 1);
image_angle  = (variable_instance_exists(self, "image_angle")  ? image_angle  : 0);
alpha = 0.9;

// Option profondeur
if (variable_instance_exists(self, "depth_override")) {
    depth = depth_override;
}

// Progression
_t = 0;

// Params de sprite
spr_w = 0;
spr_h = 0;
spr_xoff = 0;
spr_yoff = 0;
if (!variable_instance_exists(self, "imageGhost")) { imageGhost = 0; }
if (!variable_instance_exists(self, "target_x")) { target_x = x; }
if (!variable_instance_exists(self, "target_y")) { target_y = y; }

// Spécifiques à la défausse (brûlure)
burn_px = 0;
flame_jitter_amp = 4;
flame_thickness = 8;
flame_col1 = make_color_rgb(255, 220, 96);
flame_col2 = make_color_rgb(255, 120, 0);