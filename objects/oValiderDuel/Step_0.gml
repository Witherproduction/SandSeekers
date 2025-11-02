// === oValiderDuel - Step Event ===
// Détection manuelle des clics sur le bouton Valider

// Hériter de la garde de oButtonBlock
event_inherited();

// Vérifier si on est dans la room rContreIa
if (room != rContreIa) {
    exit; // Sortir si on n'est pas dans la bonne room
}

// Vérifier si le bouton gauche de la souris vient d'être pressé
if (mouse_check_button_pressed(mb_left)) {
    
    // Obtenir la position de la souris
    var mouse_x_pos = mouse_x;
    var mouse_y_pos = mouse_y;
    
    // Calculer les limites du bouton
    var button_left = x - button_width / 2;
    var button_top = y - button_height / 2;
    var button_right = x + button_width / 2;
    var button_bottom = y + button_height / 2;
    
    // Vérifier si le clic est dans la zone du bouton
    if (mouse_x_pos >= button_left && mouse_x_pos <= button_right && 
        mouse_y_pos >= button_top && mouse_y_pos <= button_bottom) {
        
        show_debug_message("### oValiderDuel.Step_0 - Clic détecté dans la zone du bouton!");
        show_debug_message("### Position souris: (" + string(mouse_x_pos) + ", " + string(mouse_y_pos) + ")");
        show_debug_message("### Zone bouton: (" + string(button_left) + ", " + string(button_top) + ") à (" + string(button_right) + ", " + string(button_bottom) + ")");
        
        // Récupérer le deck sélectionné du joueur depuis oContreIaFrame
        var player_deck = noone;
        var bot_deck_id = 1; // Deck par défaut
        
        // Chercher l'instance oContreIaFrame pour récupérer le deck sélectionné
        var frame_instance = instance_find(oContreIaFrame, 0);
        if (frame_instance != noone && frame_instance.selected_deck_index >= 0) {
            if (is_array(global.saved_decks) && frame_instance.selected_deck_index < array_length(global.saved_decks)) {
                player_deck = global.saved_decks[frame_instance.selected_deck_index];
                show_debug_message("### Deck joueur sélectionné: " + player_deck.name);
            }
        }
        
        // Récupérer le bot sélectionné depuis oContreIaGrid
        var grid_instance = instance_find(oContreIaGrid, 0);
        if (grid_instance != noone && grid_instance.selected_bot >= 0) {
            if (grid_instance.selected_bot < array_length(grid_instance.bot_data)) {
                var selected_bot = grid_instance.bot_data[grid_instance.selected_bot];
                bot_deck_id = selected_bot.deck_id;
                show_debug_message("### Bot sélectionné: " + selected_bot.name + " avec deck ID: " + string(bot_deck_id));
            }
        }
        
        // Vérifier qu'un deck joueur est sélectionné
        if (player_deck == noone) {
            show_debug_message("### Erreur: Aucun deck joueur sélectionné!");
            exit;
        }
        
        // Créer les variables globales pour les decks
        global.selected_player_deck = player_deck;
        global.selected_bot_deck_id = bot_deck_id;
        
        show_debug_message("### Préparation du duel:");
        show_debug_message("### - Deck joueur: " + player_deck.name + " (" + string(player_deck.card_count) + " cartes)");
        show_debug_message("### - Deck bot ID: " + string(bot_deck_id));
        show_debug_message("### Navigation vers rDuel depuis rContreIa");
        
        // Sauvegarder la room actuelle avant d'aller vers rDuel
        global.previous_room_before_duel = room;
        show_debug_message("### Room précédente sauvegardée: " + string(room_get_name(room)));
        
        // Naviguer vers la room de duel
        room_goto(rDuel);
    }
}