/// FX_Poison Step: progression de l’animation, teinte fantomatique, et destruction différée
if (duration_steps <= 0) duration_steps = 1;
progress += 1;

var t = clamp(progress / max(1, duration_steps), 0, 1);

// Appliquer une teinte verte fantomatique sur la carte cible pendant l’animation
if (target != noone && instance_exists(target)) {
    var ghost_col = make_color_rgb(60, 200, 80);
    // Intensité qui décroit légèrement dans le temps
    var mix_amt = 0.75 * (1.0 - t * 0.2);
    target.image_blend = merge_color(orig_blend, ghost_col, mix_amt);
    // On laisse image_alpha intacte pour éviter les effets de transparence non désirés
}

if (progress >= duration_steps) {
    // Restaurer l’apparence de la carte puis la détruire
    if (target != noone && instance_exists(target)) {
        target.image_blend = orig_blend;
        if (variable_instance_exists(target, "image_alpha")) target.image_alpha = orig_alpha;
        if (!destroy_called) {
            destroy_called = true;
            if (instance_exists(target)) instance_destroy(target);
        }
    }
    instance_destroy();
}