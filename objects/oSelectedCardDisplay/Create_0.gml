// Initialisation de l'objet oSelectedCardDisplay
show_debug_message("### oSelectedCardDisplay.create");

// S'assurer que l'instance est visible pour exécuter Draw
visible = true;
// Dessiner au-dessus des autres instances (si layers actifs, crée une layer dynamique)
depth = -100000;

// Initialisation de la variable selected
selected = noone;