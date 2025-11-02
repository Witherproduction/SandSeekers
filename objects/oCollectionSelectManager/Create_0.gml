// === oCollectionSelectManager - Create Event ===
show_debug_message("### oCollectionSelectManager créé");

// Variable pour stocker la carte actuellement sélectionnée
selected = noone;

// Fonction pour sélectionner une carte
function selectCard(cardInstance) {
    if (cardInstance != noone && instance_exists(cardInstance)) {
        selected = cardInstance;
         show_debug_message("[DEBUG] Sélection: " + string(cardInstance.name));
         
         // Notifier oCollectionCardDisplay
         show_debug_message("[DEBUG] Recherche de oCollectionCardDisplay...");
         var displayObj = instance_find(oCollectionCardDisplay, 0);
         if (displayObj != noone && instance_exists(displayObj)) {
             displayObj.selectedCard = selected;
             var selectedName = (instance_exists(selected) && variable_instance_exists(selected, "name")) ? selected.name : "Unknown";
             show_debug_message("[DEBUG] Notification envoyée à oCollectionCardDisplay (ID: " + string(displayObj) + "): " + string(selectedName));
         } else {
             show_debug_message("[ERROR] oCollectionCardDisplay manquant ou non trouvé");
         }
        
        return true;
    }
    return false;
}

// Fonction pour désélectionner la carte actuelle
function unselectCard() {
    if (selected != noone) {
        show_debug_message("[DEBUG] Désélection");
         selected = noone;
         
         // Notifier oCollectionCardDisplay
         var displayObj = instance_find(oCollectionCardDisplay, 0);
         if (displayObj != noone && instance_exists(displayObj)) {
             displayObj.selectedCard = noone;
             show_debug_message("[DEBUG] Désélection notifiée à oCollectionCardDisplay");
         }
        
        return true;
    }
    return false;
}

// Fonction pour basculer la sélection d'une carte
function toggleSelection(cardInstance) {
    show_debug_message("[DEBUG] toggleSelection appelée avec: " + string(cardInstance.name));
    if (selected == cardInstance) {
         // Si la carte est déjà sélectionnée, la désélectionner
         show_debug_message("[DEBUG] Carte déjà sélectionnée, désélection...");
         return unselectCard();
     } else {
         // Sinon, la sélectionner
         show_debug_message("[DEBUG] Nouvelle sélection...");
         return selectCard(cardInstance);
     }
}

show_debug_message("[DEBUG] oCollectionSelectManager créé");