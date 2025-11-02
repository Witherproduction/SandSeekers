// === oDeckList - Mouse Global Left Button Event ===

// Bloquer toute interaction si le panneau d'options est ouvert
if (instance_exists(oPanelOptions)) {
    return;
}

// Calculer les positions des éléments (même logique que dans Draw_0)
var sprite_x = room_width - sprite_get_width(sDeckBuilder) + 55;
var button_x = sprite_x + 50;
var button_y = room_height / 3 - 170;
var button_width = 320;
var button_height = 80;

// Vérifier d'abord si le clic est sur un deck sauvegardé (seulement si le deck builder n'est pas affiché)
var clicked_on_deck = false;
if (!show_deck_builder && variable_global_exists("saved_decks") && array_length(global.saved_decks) > 0) {
    var deck_list_y = button_y + button_height + 20;
    var deck_item_height = 35;
    var deck_item_width = button_width;
    
    // Vérifier chaque deck sauvegardé
    for (var i = 0; i < array_length(global.saved_decks); i++) {
        var deck = global.saved_decks[i];
        var item_y = deck_list_y + (i * (deck_item_height + 5));
        
        // Vérifier si on dépasse l'écran
        if (item_y + deck_item_height > room_height - 50) {
            break;
        }
        
        // Vérifier si le clic est sur ce deck
        if (point_in_rectangle(mouse_x, mouse_y, button_x, item_y, button_x + deck_item_width, item_y + deck_item_height)) {
            clicked_on_deck = true;
            
            // Ouvrir le deck builder avec le deck sélectionné
            show_deck_builder = true;
            
            // Créer l'instance oDeckBuilder si elle n'existe pas
            if (deck_builder_instance == noone || !instance_exists(deck_builder_instance)) {
                var builder_x = x;
                var builder_y = y + (sprite_get_height(sprInvisible) * image_yscale) + 10;
                deck_builder_instance = instance_create_layer(builder_x, builder_y, "Instances", oDeckBuilder);
                
                // Charger le deck dans l'éditeur
                if (instance_exists(deck_builder_instance)) {
                    with (deck_builder_instance) {
                        load_deck_for_editing(deck);
                    }
                }
            }
            
            break; // Sortir de la boucle une fois qu'un deck est cliqué
        }
    }
}

// Si aucun deck n'a été cliqué, vérifier le clic sur le bouton "nouveau deck"
if (!clicked_on_deck && point_in_rectangle(mouse_x, mouse_y, button_x, button_y, button_x + button_width, button_y + button_height)) {
    // Basculer l'affichage du deck builder pour un nouveau deck
    show_deck_builder = !show_deck_builder;
    
    if (show_deck_builder) {
        // Créer l'instance oDeckBuilder si elle n'existe pas
        if (deck_builder_instance == noone || !instance_exists(deck_builder_instance)) {
            // Position du cadre sous le bouton
            var builder_x = x;
            var builder_y = y + (sprite_get_height(sprInvisible) * image_yscale) + 10;
            deck_builder_instance = instance_create_layer(builder_x, builder_y, "Instances", oDeckBuilder);
        }
    } else {
        // Détruire l'instance oDeckBuilder si elle existe
        if (deck_builder_instance != noone && instance_exists(deck_builder_instance)) {
            instance_destroy(deck_builder_instance);
            deck_builder_instance = noone;
        }
    }
}