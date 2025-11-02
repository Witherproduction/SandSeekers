// === oFiltre - Step Event ===

// Hériter de la garde de oButtonBlock
event_inherited();

// Garde directe pour s'assurer du blocage
if (instance_exists(oPanelOptions)) {
    exit;
}

// Gestion uniquement dans la room rCollection
if (room == rCollection) {
    
    // Vérifier si la souris est dans la zone de saisie
    var mouseInBox = point_in_rectangle(mouse_x, mouse_y, filterBoxX, filterBoxY, filterBoxX + filterBoxWidth, filterBoxY + filterBoxHeight);
    
    // Activer/désactiver la saisie avec un clic
    if (mouse_check_button_pressed(mb_left)) {
        isTyping = mouseInBox;
    }
    
    // Gestion de la saisie de texte
    if (isTyping) {
        
        // Échapper pour arrêter la saisie
        if (keyboard_check_pressed(vk_escape)) {
            isTyping = false;
        }
        
        // Entrée pour valider et arrêter la saisie
        if (keyboard_check_pressed(vk_enter)) {
            isTyping = false;
            // Déclencher le filtrage
            if (instance_exists(oCardViewer)) {
                oCardViewer.applyFilter(filterText);
            }
        }
        
        // Effacement avec Backspace
        if (keyboard_check_pressed(vk_backspace)) {
            if (string_length(filterText) > 0) {
                filterText = string_delete(filterText, string_length(filterText), 1);
            }
        }
        
        // Saisie de caractères
        var key = keyboard_lastchar;
        if (key != "") {
            // Filtrer les caractères autorisés (lettres, chiffres, espaces, quelques symboles)
            if (string_pos(key, "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789 -_éèàùçêâîôûäëïöüÉÈÀÙÇÊÂÎÔÛÄËÏÖÜ") > 0) {
                if (string_length(filterText) < 30) { // Limite de caractères
                    filterText += key;
                }
            }
            keyboard_lastchar = ""; // Réinitialiser
        }
    }
}