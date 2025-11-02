/// @desc Initialise les paramètres de l’effet de déchirure
// Valeurs par défaut; elles peuvent être surchargées après la création par le spawner
initialized = false;
_t = 0;

// Temporisation (ne pas lire une variable non initialisée)
if (!variable_instance_exists(id, "duration_ms")) duration_ms = 700;

// Géométrie (sera finalisée une fois initialisé)
spr = -1;
spr_w = 0;
spr_h = 0;
if (!variable_instance_exists(id, "strip_h")) strip_h = 3;

// Contrôles de l’arête déchirée (irrégularité)
if (!variable_instance_exists(id, "ragged_amp_px"))   ragged_amp_px   = 6;
if (!variable_instance_exists(id, "seam_min_ratio"))  seam_min_ratio  = 0.32;
if (!variable_instance_exists(id, "seam_max_ratio"))  seam_max_ratio  = 0.68;

// Séparation latérale maximale des deux moitiés
if (!variable_instance_exists(id, "sep_px")) sep_px = 48; // augmenté

// Jitter latéral par bande (rend la séparation moins "propre")
if (!variable_instance_exists(id, "row_jitter_amp")) row_jitter_amp = 1.0;

// Paramètres de sprite fournis par le spawner (si absents, fallback sur l’instance)
if (!variable_instance_exists(id, "spriteGhost")) spriteGhost = sprite_index;
if (!variable_instance_exists(id, "imageGhost"))  imageGhost  = image_index;

// Visuel
alpha_fx = 1.0;

// Profondeur optionnelle
if (variable_instance_exists(id, "depth_override")) {
    depth = depth_override;
}