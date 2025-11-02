/// @description Vérification visuelle du bouton

// Vérifier si la souris est sur le bouton pour le feedback visuel
if (point_in_rectangle(mouse_x, mouse_y, x - sprite_width/2 * image_xscale, y - sprite_height/2 * image_yscale, x + sprite_width/2 * image_xscale, y + sprite_height/2 * image_yscale)) {
    // Changer la couleur pour indiquer le survol
    image_blend = c_yellow;
} else {
    // Couleur normale
    image_blend = c_white;
}