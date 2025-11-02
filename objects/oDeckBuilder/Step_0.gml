// === oDeckBuilder - Step Event ===
// Gestion de la saisie de texte pour le nom du deck (inspiré de oFiltre)

// Bloquer la saisie si le panneau d'options est ouvert
if (instance_exists(oPanelOptions)) {
    exit;
}

// Gestion de la saisie de texte
if (deck_name_editing) {
    
    // Échapper pour arrêter la saisie
    if (keyboard_check_pressed(vk_escape)) {
        deck_name_editing = false;
    }
    
    // Entrée pour valider et arrêter la saisie
    if (keyboard_check_pressed(vk_enter)) {
        // Valider le nom du deck
        if (string_length(deck_name) > 0) {
            // Nettoyer le nom (supprimer les espaces en début/fin)
            deck_name = string_trim(deck_name);
            
            if (string_length(deck_name) > 0) {
                show_debug_message("Nom du deck validé: '" + deck_name + "'");
                // Ici on pourrait ajouter d'autres actions comme sauvegarder le deck
            } else {
                show_debug_message("Nom du deck vide après nettoyage");
                deck_name = "";
            }
        } else {
            show_debug_message("Aucun nom saisi pour le deck");
        }
        
        deck_name_editing = false;
    }
    
    // Effacement avec Backspace
    if (keyboard_check_pressed(vk_backspace)) {
        if (string_length(deck_name) > 0) {
            deck_name = string_delete(deck_name, string_length(deck_name), 1);
        }
    }
    
    // Saisie de caractères
    var key = keyboard_lastchar;
    if (key != "") {
        // Filtrer les caractères autorisés (lettres, chiffres, espaces, quelques symboles)
        if (string_pos(key, "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789 -_'()[]{}!?") > 0) {
            // Limiter la longueur du nom (par exemple 30 caractères)
            if (string_length(deck_name) < 30) {
                deck_name += key;
            }
        }
        // Réinitialiser keyboard_lastchar pour éviter la répétition
        keyboard_lastchar = "";
    }
}

// Gestion du scroll avec la molette de la souris
var mx = mouse_x;
var my = mouse_y;

// Vérifier si la souris est dans la zone des cartes
var cards_area_x = x + 10;
var cards_area_y = y + 80;
var cards_area_width = frame_width - 20;
var cards_area_height = calculate_cards_area_height();

if (point_in_rectangle(mx, my, cards_area_x, cards_area_y, cards_area_x + cards_area_width, cards_area_y + cards_area_height)) {
    // Scroll vers le haut
    if (mouse_wheel_up()) {
        scroll_offset = max(0, scroll_offset - 1);
    }
    
    // Scroll vers le bas
    if (mouse_wheel_down()) {
        var max_scroll = max(0, current_slots - max_visible_lines);
        scroll_offset = min(max_scroll, scroll_offset + 1);
    }
}

// Vérifier si on doit ajouter un nouvel emplacement
check_and_add_slot();