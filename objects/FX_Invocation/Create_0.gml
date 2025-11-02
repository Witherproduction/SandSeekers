// FX_Invocation - Create
// Effet d'invocation: glissade vers le terrain depuis la main + post-effet circuit

// Paramètres attendus via le spawner:
// - card_real: instance de la carte réelle à placer
// - spriteGhost: sprite du fantôme
// - imageGhost: frame du sprite
// - target_x, target_y: destination (emplacement sur le terrain)
// - field_position: index logique de position sur le terrain
// - owner_is_hero: booléen (true si héros)
// - summon_mode: "Summon", "Set", "SpecialSummon"...
// - card_type: "Monster" ou "Magic"
// - desired_orientation (ennemi): "Defense" ou "Attack" (par défaut)
// - duration_ms (optionnel): durée du mouvement (ms)
// - post_fx_duration_ms (optionnel): durée du circuit (ms)
// - depth_override (optionnel)

start_x = x;
start_y = y;

// Durée par défaut ~0.45s
var default_frames = 0.45 * room_speed;
duration = default_frames;
if (variable_instance_exists(self, "duration_ms")) {
    duration = max(1, (duration_ms / 1000.0) * room_speed);
}

// Phase post-effet circuit (~0.6s)
var post_default = 0.6 * room_speed;
post_fx_duration = post_default;
if (variable_instance_exists(self, "phase_duration_ms")) {
    post_fx_duration = max(1, ((phase_duration_ms * 4) / 1000.0) * room_speed);
} else if (variable_instance_exists(self, "post_fx_duration_ms")) {
    post_fx_duration = max(1, (post_fx_duration_ms / 1000.0) * room_speed);
}
// Durée du flash final (par défaut ~0.15s), surcharge via flash_duration_ms
var flash_default = 0.15 * room_speed;
flash_duration = (variable_instance_exists(self, "flash_duration_ms") ? max(1, (flash_duration_ms / 1000.0) * room_speed) : flash_default);
post_fx_t = 0;
finished_move = false;

// Circuit params (set lors de la fin du mouvement)
circ_w = 0;
circ_h = 0;
circ_angle = 0;
col_main = (variable_instance_exists(self, "col_main") ? col_main : make_color_rgb(255, 215, 0));
thickness_start = (variable_instance_exists(self, "thickness_start") ? thickness_start : 6);
thickness_end   = (variable_instance_exists(self, "thickness_end")   ? thickness_end   : 2);
grid_count = 3;

// Paramètres avancés du circuit imprimé (autour de la carte)
circuit_margin   = (variable_instance_exists(self, "circuit_margin")   ? circuit_margin   : 14); // marge hors carte
node_radius      = (variable_instance_exists(self, "node_radius")      ? node_radius      : 6);  // taille des "boules"
trace_thickness  = (variable_instance_exists(self, "trace_thickness")  ? trace_thickness  : 3);  // épaisseur des pistes
trace_out        = (variable_instance_exists(self, "trace_out")        ? trace_out        : 18); // extension vers l'extérieur


// Option profondeur
if (variable_instance_exists(self, "depth_override")) {
    depth = depth_override;
}

// Progression
_t = 0;

// Cibles par défaut
if (!variable_instance_exists(self, "imageGhost")) { imageGhost = 0; }
if (!variable_instance_exists(self, "target_x")) { target_x = x; }
if (!variable_instance_exists(self, "target_y")) { target_y = y; }

// Apparence du fantôme
image_angle  = (variable_instance_exists(self, "image_angle")  ? image_angle  : 0);
alpha = 1.0;

// Échelle : peut être définie par le spawner; sinon 1
image_xscale = (variable_instance_exists(self, "image_xscale") ? image_xscale : 1);
image_yscale = (variable_instance_exists(self, "image_yscale") ? image_yscale : 1);