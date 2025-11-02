// === oCollectionCardDisplay - Step Event ===

// Variable statique pour suivre les changements de selectedCard
static previous_selectedCard = noone;

// Vérifier si selectedCard a changé
if (selectedCard != previous_selectedCard) {
    if (selectedCard == noone) {
        show_debug_message("[DEBUG] oCollectionCardDisplay: selectedCard mis à noone");
        textScrollY = 0; // Reset du scroll
    } else if (instance_exists(selectedCard)) {
        show_debug_message("[DEBUG] oCollectionCardDisplay: selectedCard mis à " + string(selectedCard.name));
        textScrollY = 0; // Reset du scroll pour la nouvelle carte
    } else {
        show_debug_message("[DEBUG] oCollectionCardDisplay: selectedCard mis à une instance inexistante");
    }
    previous_selectedCard = selectedCard;
}

// Gestion du scroll avec la molette de souris (uniquement si une carte est sélectionnée)
// Gestion de la carte sélectionnée
if (global.selectedCard != selectedCard) {
    selectedCard = global.selectedCard;
    textScrollY = 0; // Reset scroll when card changes
    
    if (selectedCard == noone) {
        // Pas de message de debug pour ce cas commun
    } else if (instance_exists(selectedCard)) {
        // Pas de message de debug pour ce cas commun
    } else {
        // Pas de message de debug pour ce cas commun
    }
}

// Gestion du scroll avec la molette
if (selectedCard != noone && instance_exists(selectedCard)) {
    // Vérifier si la souris est dans la zone d'affichage des informations
    var info_x = x + 10;
    var info_y = y + 50;
    var card_width = 200;
    var maxTextHeight = 300;
    
    if (mouse_x >= info_x - 5 && mouse_x <= info_x + card_width + 5 && 
        mouse_y >= info_y - 5 && mouse_y <= info_y + maxTextHeight + 5) {
        
        if (mouse_wheel_up()) {
            textScrollY = max(0, textScrollY - 20);
            // Pas de message de debug pour le scroll
        }
        
        if (mouse_wheel_down()) {
            var totalTextHeight = string_height_ext(selectedCard.description, 16, card_width - 20);
            var maxScroll = max(0, totalTextHeight - maxTextHeight);
            textScrollY = min(maxScroll, textScrollY + 20);
            // Pas de message de debug pour le scroll
        }
    } else {
        // Pas de message de debug pour la molette hors zone
    }
}