// === oDeckList - Draw Event ===
// Affiche le sprite sDeckBuilder à droite de l'écran et la liste des decks sauvegardés

// Position à droite de l'écran avec décalage de 55 pixels (décalé de 20 pixels vers la gauche)
var sprite_x = room_width - sprite_get_width(sDeckBuilder) + 55;
var sprite_y = -60; // Décaler vers le haut pour dépasser davantage

// Calculer l'échelle pour dépasser légèrement en haut et en bas (120 pixels de plus)
var scale_y = (room_height + 120) / sprite_get_height(sDeckBuilder);
// Calculer l'échelle horizontale pour rétrécir de 20 pixels
var scale_x = (sprite_get_width(sDeckBuilder) - 20) / sprite_get_width(sDeckBuilder);

// Dessiner le sprite sDeckBuilder étiré sur toute la hauteur et allongé de 30 pixels
draw_sprite_ext(sDeckBuilder, 0, sprite_x, sprite_y, scale_x, scale_y, 0, c_white, 1);

// Dessiner le bouton "nouveau deck" à 1/3 de la hauteur, remonté de 140 pixels
var button_x = sprite_x + 50;
var button_y = room_height / 3 - 170;
var button_width = 320;
var button_height = 80;

// Dessiner le bouton avec le sprite sButton (comme les autres boutons)
draw_sprite_stretched(sButton, 0, button_x, button_y, button_width, button_height);

// Dessiner le texte "nouveau deck" centré avec légère ombre
draw_set_color(c_black);
draw_set_halign(fa_center);
draw_set_valign(fa_middle);
draw_text(button_x + button_width/2 + 2, button_y + button_height/2 + 2, "nouveau deck");
draw_set_color(make_color_rgb(230, 200, 120));
draw_text(button_x + button_width/2, button_y + button_height/2, "nouveau deck");
draw_text(button_x + button_width/2, button_y + button_height/2, "nouveau deck");

// === Affichage des decks sauvegardés ===
// Vérifier si des decks sont sauvegardés ET si le deck builder n'est pas affiché
if (!show_deck_builder && variable_global_exists("saved_decks") && array_length(global.saved_decks) > 0) {
    var deck_list_y = button_y + button_height + 20; // Commencer sous le bouton "nouveau deck"
    var deck_item_height = 35;
    var deck_item_width = button_width;
    
    // Titre de la section
    draw_set_color(c_black);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_text(button_x + button_width/2, deck_list_y - 10, "Decks sauvegardés:");
    
    // Afficher chaque deck sauvegardé
    for (var i = 0; i < array_length(global.saved_decks); i++) {
        var deck = global.saved_decks[i];
        var item_y = deck_list_y + (i * (deck_item_height + 5));
        
        // Vérifier si on dépasse l'écran
        if (item_y + deck_item_height > room_height - 50) {
            break; // Arrêter si on dépasse l'écran
        }
        
        // Dessiner le fond du deck
        draw_set_color(c_ltgray);
        draw_rectangle(button_x, item_y, button_x + deck_item_width, item_y + deck_item_height, false);
        draw_set_color(c_black);
        draw_rectangle(button_x, item_y, button_x + deck_item_width, item_y + deck_item_height, true);
        
        // Dessiner le nom du deck
        draw_set_color(c_black);
        draw_set_halign(fa_left);
        draw_set_valign(fa_top);
        draw_text(button_x + 5, item_y + 3, deck.name);
        
        // Dessiner le nombre de cartes
        draw_set_color(c_gray);
        draw_text(button_x + 5, item_y + 18, string(deck.card_count) + " cartes");
    }
}

// Remettre les paramètres par défaut
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_white);