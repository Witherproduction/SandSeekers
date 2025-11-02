// oFX_Draw - Draw
// Dessin du sprite fantôme sans glow, uniquement le mouvement

if (variable_instance_exists(self, "spriteGhost") && spriteGhost != noone) {
    var old_alpha = draw_get_alpha();

    // Alpha et sprite
    draw_set_alpha(alpha);

    // Carte (rendu simple, blend normal)
    draw_sprite_ext(spriteGhost, imageGhost, x, y, image_xscale, image_yscale, image_angle, c_white, 1);

    draw_set_alpha(old_alpha);
}