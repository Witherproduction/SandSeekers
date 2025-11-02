/// FX_Poison Create: initialise l’animation de flaque et la teinte fantomatique
if (!variable_instance_exists(self, "target")) target = noone;
if (!variable_instance_exists(self, "source")) source = noone;

// Appliquer la profondeur par défaut: juste sous la cible si possible
if (variable_instance_exists(self, "depth_override")) {
    depth = depth_override;
} else if (target != noone && instance_exists(target) && variable_instance_exists(target, "depth")) {
    depth = target.depth + 1;
}

progress = 0;
if (!variable_instance_exists(self, "duration_steps")) duration_steps = max(1, floor(room_speed * 0.6));
if (!variable_instance_exists(self, "color")) color = make_color_rgb(60, 200, 80);

alpha_start = 0.7;
alpha_end   = 0.0;
radius_start = 6;

var baseScaleX = 1;
var baseScaleY = 1;
if (target != noone && instance_exists(target)) {
    if (variable_instance_exists(target, "image_xscale")) baseScaleX = target.image_xscale;
    if (variable_instance_exists(target, "image_yscale")) baseScaleY = target.image_yscale;
}

var spr = (target != noone && instance_exists(target)) ? target.sprite_index : -1;
var w = (spr != -1) ? sprite_get_width(spr) : 64;
var h = (spr != -1) ? sprite_get_height(spr) : 96;
var base = max(w * baseScaleX, h * baseScaleY);
radius_max = max(radius_start + 1, floor(base * 0.6));

// Sauvegarder l’apparence d’origine pour restaurer ensuite
orig_blend = c_white;
orig_alpha = 1;
if (target != noone && instance_exists(target)) {
    if (variable_instance_exists(target, "image_blend")) orig_blend = target.image_blend; else orig_blend = c_white;
    if (variable_instance_exists(target, "image_alpha")) orig_alpha = target.image_alpha; else orig_alpha = 1;
}

// Drapeau pour éviter double destruction
destroy_called = false;