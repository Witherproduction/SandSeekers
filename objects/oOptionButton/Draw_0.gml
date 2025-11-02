/// @description Dessin du bouton Option (cadre fixe + rouage rotatif)

// Rotation du rouage uniquement si survolé
if (hover) {
    gear_angle += 0.5;
}

// Dessiner le cadre (sprite principal) sans rotation
if (sprite_index != -1) {
    // Réduction du cadre de 30%
    var frame_sx = image_xscale * 0.7;
    var frame_sy = image_yscale * 0.7;
    draw_sprite_ext(sprite_index, image_index, x, y, frame_sx, frame_sy, 0, image_blend, image_alpha);
}

// Effet d'ombre si pressé (cadre)
if (pressed) {
    var frame_sx_p = image_xscale * 0.7;
    var frame_sy_p = image_yscale * 0.7;
    draw_sprite_ext(sprite_index, image_index, x + 2, y + 2, frame_sx_p, frame_sy_p, 0, c_black, 0.3);
}

// Dessiner le rouage (sOptionP2) avec rotation indépendante
var gear_sprite = asset_get_index("sOptionP2");
if (gear_sprite != -1) {
    // Réduction du rouage de 50%
    var gear_sx = image_xscale * 0.5;
    var gear_sy = image_yscale * 0.5;
    draw_sprite_ext(gear_sprite, 0, x, y, gear_sx, gear_sy, gear_angle, image_blend, image_alpha);
    if (pressed) {
        draw_sprite_ext(gear_sprite, 0, x + 2, y + 2, gear_sx, gear_sy, gear_angle, c_black, 0.3);
    }
}