// === oDeckBuilder - Mouse Global Left Button Event ===
// Gestion globale des clics pour le champ de saisie du nom et les cartes du deck

// Bloquer toute interaction si le panneau d'options est ouvert
if (instance_exists(oPanelOptions)) {
    return;
}

// === GESTION DE LA BOITE DE DIALOGUE DE CONFIRMATION ===
if (show_confirmation) {
    // Vérifier si le clic est sur le bouton "Oui"
    if (point_in_rectangle(mouse_x, mouse_y, 
                          confirmation_yes_x, confirmation_yes_y, 
                          confirmation_yes_x + confirmation_button_width, 
                          confirmation_yes_y + confirmation_button_height)) {
        show_debug_message("### CLIC SUR OUI - Confirmation de suppression");
        confirm_deck_deletion();
        return; // Sortir pour éviter d'autres interactions
    }
    // Vérifier si le clic est sur le bouton "Non"
    else if (point_in_rectangle(mouse_x, mouse_y, 
                               confirmation_no_x, confirmation_no_y, 
                               confirmation_no_x + confirmation_button_width, 
                               confirmation_no_y + confirmation_button_height)) {
        show_debug_message("### CLIC SUR NON - Annulation de suppression");
        cancel_deck_deletion();
        return; // Sortir pour éviter d'autres interactions
    }
    // Si on clique ailleurs pendant la confirmation, ne rien faire
    return;
}

// === DETECTION DE CLIC SUR LES NOMS DES CARTES ===
// Calculer les zones des cartes avec scroll
var line_height = 20;
var line_margin = 2;
var visible_lines = min(current_slots, max_visible_lines);

// Vérifier si le clic est sur une carte dans la liste
// On utilise `display_cards_list` (liste groupée/triée créée dans Draw) si elle existe, sinon fallback vers `cards_list`
var list_for_click = (display_cards_list != undefined && display_cards_list != noone && array_length(display_cards_list) > 0) ? display_cards_list : cards_list;
for (var i = 0; i < visible_lines; i++) {
    var card_index = i + scroll_offset;
    if (card_index >= current_slots) break;
    
    if (card_index < array_length(list_for_click)) {
        var line_x = cards_area_x + 5;
        var line_y = cards_area_y + 5 + i * (line_height + line_margin);
        var line_width = cards_area_width - 10;
        
        // Vérifier si le clic est dans cette ligne de carte
        if (point_in_rectangle(mouse_x, mouse_y, line_x, line_y, line_x + line_width, line_y + line_height)) {
            var card = list_for_click[card_index];
            var cardName = (is_struct(card) && variable_struct_exists(card, "name")) ? card.name : string(card);
            
            show_debug_message("### CLIC SUR LA CARTE: " + cardName);
            
            // Appeler la fonction pour afficher cette carte depuis la base de données
            show_card_from_database(cardName);
            
            // Sortir de la boucle car on a trouvé la carte cliquée
            break;
        }
    }
}

// Calculer les coordonnées du champ de saisie basées sur la position actuelle
var field_x = x + 50;
var field_y = y + 30;
var field_width = frame_width - 60;
var field_height = 25;

// Calculer les positions des boutons (même calcul que dans Draw_0)
var buttons_y = y + frame_height + 5; // 5px sous le cadre
var total_buttons_width = (button_width * 2) + button_spacing;
var buttons_start_x = cards_area_x + (cards_area_width - total_buttons_width) / 2;
var confirm_button_x = buttons_start_x;
var cancel_button_x = buttons_start_x + button_width + button_spacing;

// Vérifier si le clic est sur le bouton "Confirmer"
if (point_in_rectangle(mouse_x, mouse_y, confirm_button_x, buttons_y, confirm_button_x + button_width, buttons_y + button_height)) {
    show_debug_message("### CLIC SUR LE BOUTON CONFIRMER !");
    
    // Vérifier que le deck a un nom
    if (deck_name != "") {
        // Vérifier qu'il y a au moins une carte dans le deck
        if (array_length(cards_list) > 0) {
            // Sauvegarder le deck
            save_deck();
        } else {
            show_debug_message("### Erreur: Deck vide");
        }
    } else {
        show_debug_message("### Erreur: Nom du deck manquant");
    }
}
// Vérifier si le clic est sur le bouton "Supprimer"
else if (point_in_rectangle(mouse_x, mouse_y, cancel_button_x, buttons_y, cancel_button_x + button_width, buttons_y + button_height)) {
    show_debug_message("### CLIC SUR LE BOUTON SUPPRIMER !");
    cancel_deck_creation();
}
// Vérifier si le clic est dans le champ de saisie du nom
else if (point_in_rectangle(mouse_x, mouse_y, field_x, field_y, field_x + field_width, field_y + field_height)) {
    // Activer l'édition du nom
    deck_name_editing = true;
    show_debug_message("Édition du nom activée via événement global");
} else {
    // Désactiver l'édition si on clique ailleurs
    deck_name_editing = false;
    show_debug_message("Édition du nom désactivée via événement global");
}