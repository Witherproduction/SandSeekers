// === oCollectionCardDisplay - Create Event ===

// Variable pour stocker la carte sélectionnée
selectedCard = noone;

// Variables pour le scroll du texte
textScrollY = 0;
maxTextHeight = 200; // Hauteur maximale de la zone de texte (agrandie)
totalTextHeight = 0; // Hauteur totale du texte calculée
scrollSpeed = 20;

// Profondeur pour s'afficher au-dessus de tous les autres éléments UI
depth = -100000;

// Méthode utilitaire pour appliquer une sélection d'instance
function select_card_instance(cardInstance) {
    if (cardInstance != noone && instance_exists(cardInstance)) {
        selectedCard = cardInstance;
        textScrollY = 0; // reset du scroll sur nouvelle carte
        show_debug_message("[DEBUG] oCollectionCardDisplay.select_card_instance -> " + string(cardInstance.name));
        return true;
    } else {
        show_debug_message("[WARN] select_card_instance: instance invalide ou inexistante");
        return false;
    }
}

show_debug_message("[DEBUG] oCollectionCardDisplay créé");