/// @function load_player_deck_from_data(deck_data, deck_list)
/// @description Charge un deck de joueur depuis les donnees sauvegardees
/// @param {struct} deck_data - Les donnees du deck sauvegarde
/// @param {ds_list} deck_list - La liste ds_list a remplir avec les cartes
function load_player_deck_from_data(deck_data, deck_list) {
    show_debug_message("### load_player_deck_from_data - Loading deck: " + deck_data.name);
    
    // Verifier que les donnees du deck sont valides
    if (!is_struct(deck_data) || !variable_struct_exists(deck_data, "cards")) {
        show_debug_message("### Error: Invalid deck data!");
        return false;
    }
    
    var cards_array = deck_data.cards;
    var loaded_count = 0;
    
    // Ajouter chaque carte à la liste
    for (var i = 0; i < array_length(cards_array); i++) {
        var card_data = cards_array[i];
        var card_name = "";
        var object_id = "";
        
        // Gérer les deux formats : objet complexe ou simple nom
        if (is_struct(card_data)) {
            if (variable_struct_exists(card_data, "objectId")) {
                object_id = card_data.objectId;
                show_debug_message("### Using objectId from card data: " + object_id);
            }
            if (variable_struct_exists(card_data, "name")) {
                card_name = card_data.name;
            }
        } else if (is_string(card_data)) {
            // Format simple (ancien format)
            card_name = card_data;
            // Debug global supprimé
        } else {
            // Debug global supprimé
            continue;
        }
        
        // Déterminer le nom d'asset à utiliser
        var asset_name_to_use = "";
        if (object_id != "") {
            asset_name_to_use = object_id;
        } else if (card_name != "") {
            // Essayer directement le nom comme asset (si la donnée contient déjà le nom d'objet)
            var direct_obj = asset_get_index(card_name);
            if (direct_obj != -1) {
                asset_name_to_use = card_name;
            } else {
                // Fallback: résoudre via la base de données par nom lisible
                var db = getDatabase();
                if (db != noone && instance_exists(db)) {
                    var results = dbGetCardsByName(card_name);
                    var exact = noone;
                    for (var j = 0; j < array_length(results); j++) {
                        if (variable_struct_exists(results[j], "name") && results[j].name == card_name) {
                            exact = results[j];
                            break;
                        }
                    }
                    if (exact != noone && variable_struct_exists(exact, "objectId")) {
                        asset_name_to_use = exact.objectId;
                        show_debug_message("### Resolved '" + card_name + "' to objectId '" + asset_name_to_use + "'");
                    } else {
                        show_debug_message("### Error: Cannot resolve card name '" + card_name + "' to objectId");
                    }
                } else {
                    show_debug_message("### Error: Database not available to resolve '" + card_name + "'");
                }
            }
        }
        
        if (asset_name_to_use != "") {
            var card_object = asset_get_index(asset_name_to_use);
            if (card_object != -1) {
                ds_list_add(deck_list, card_object);
                loaded_count++;
                show_debug_message("### Card added: " + asset_name_to_use);
            } else {
                show_debug_message("### Error: Card asset not found: " + asset_name_to_use);
            }
        }
    }
    
    // Melanger le deck
    ds_list_shuffle(deck_list);
    
    show_debug_message("### Deck loaded with " + string(ds_list_size(deck_list)) + " cards");
    // Retourner false si aucune carte n'a été chargée pour permettre un fallback propre
    return (loaded_count > 0);
}

/// @function load_bot_deck_from_id(bot_deck_id, deck_list)
/// @description Charge un deck de bot depuis son ID
/// @param {real} bot_deck_id - L'ID du deck de bot
/// @param {ds_list} deck_list - La liste ds_list a remplir avec les cartes
function load_bot_deck_from_id(bot_deck_id, deck_list) {
    show_debug_message("### load_bot_deck_from_id - Loading bot deck ID: " + string(bot_deck_id));
    
    // Recuperer les cartes du deck de bot
    var bot_cards = get_bot_deck_cards(bot_deck_id);
    
    if (!is_array(bot_cards)) {
        show_debug_message("### Error: Cannot retrieve cards for bot deck ID: " + string(bot_deck_id));
        return false;
    }
    
    // Ajouter chaque carte à la liste
    for (var i = 0; i < array_length(bot_cards); i++) {
        var card_name = bot_cards[i];
        
        // Convertir le nom de carte en objet (asset_get_index)
        var card_object = asset_get_index(card_name);
        
        if (card_object != -1) {
            ds_list_add(deck_list, card_object);
            show_debug_message("### Bot card added: " + card_name);
        } else {
            show_debug_message("### Error: Bot card not found: " + card_name);
        }
    }
    
    // Melanger le deck
    ds_list_shuffle(deck_list);
    
    show_debug_message("### Bot deck loaded with " + string(ds_list_size(deck_list)) + " cards");
    return true;
}

/// @function clear_selected_decks()
/// @description Nettoie les variables globales des decks selectionnes
function clear_selected_decks() {
    show_debug_message("### clear_selected_decks - Cleaning global variables");
    
    if (variable_global_exists("selected_player_deck")) {
        global.selected_player_deck = noone;
    }
    
    if (variable_global_exists("selected_bot_deck_id")) {
        global.selected_bot_deck_id = noone;
    }
    
    show_debug_message("### Global variables cleaned");
}