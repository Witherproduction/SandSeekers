// oFX_Draw - Create
// Effet de pioche: glissade verticale vers la main (sans glow)

// Paramètres attendus via le spawner:
// - spriteGhost: sprite de la carte
// - imageGhost: frame du sprite
// - target_x, target_y: destination (ligne de la main)
// - duration_ms (optionnel): durée en millisecondes
// - depth_override (optionnel)
// - hand_to_update (optionnel): instance de la main à rafraîchir
// - card_to_reveal (optionnel): carte réelle à rendre visible à la fin

start_x = x;
start_y = y;

// Durée par défaut ~0.45s
var default_frames = 0.45 * room_speed;
duration = default_frames;
if (variable_instance_exists(self, "duration_ms")) {
    duration = max(1, (duration_ms / 1000.0) * room_speed);
}

// Apparence initiale (ne pas forcer l’échelle, elle sera fixée au premier Step)
// image_xscale et image_yscale sont assignés par le spawner juste après la création
image_angle  = (variable_instance_exists(self, "image_angle")  ? image_angle  : 0);
alpha = 0.0;

// Baselines pour le scale (initialisées au premier Step)
base_scale_x = image_xscale;
base_scale_y = image_yscale;
scale_initialized = false;

// Option profondeur
if (variable_instance_exists(self, "depth_override")) {
    depth = depth_override;
}

// Progression
_t = 0;

// Params de sprite (paresseux)
spr_w = 0;
spr_h = 0;
spr_xoff = 0;
spr_yoff = 0;

// Cibles par défaut
if (!variable_instance_exists(self, "target_x")) { target_x = x; }
if (!variable_instance_exists(self, "target_y")) { target_y = y; }