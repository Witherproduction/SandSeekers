// === oValiderDuel - Create Event ===
// Bouton pour valider le duel et aller vers rDuel

show_debug_message("### oValiderDuel.Create_0 - Objet créé à la position (" + string(x) + ", " + string(y) + ")");

// Dimensions du bouton (identiques aux autres boutons)
button_width = 120;
button_height = 40;

show_debug_message("### Dimensions du bouton: " + string(button_width) + "x" + string(button_height));

// Variables pour la détection de collision
collision_left = x - button_width / 2;
collision_top = y - button_height / 2;
collision_right = x + button_width / 2;
collision_bottom = y + button_height / 2;

show_debug_message("### Zone de collision: (" + string(collision_left) + ", " + string(collision_top) + ") à (" + string(collision_right) + ", " + string(collision_bottom) + ")");

// Variables pour le deck sélectionné
selected_player_deck = noone;
selected_bot_deck_id = 1; // Deck par défaut du bot