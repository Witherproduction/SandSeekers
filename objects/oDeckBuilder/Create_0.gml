// === oDeckBuilder - Create Event ===
// Initialisation du constructeur de deck

// Décaler vers la gauche puis vers la droite
x -= 100;
x += 70;


show_debug_message("oDeckBuilder créé à la position: (" + string(x) + ", " + string(y) + ")");

// Vérification de l'existence de oCardViewer
if (instance_exists(oCardViewer)) {
    show_debug_message("✅ oCardViewer existe dans la room");
    var cardviewer_inst = instance_find(oCardViewer, 0);
    show_debug_message("✅ oCardViewer position: (" + string(cardviewer_inst.x) + ", " + string(cardviewer_inst.y) + ")");
} else {
    show_debug_message("❌ oCardViewer N'EXISTE PAS dans la room !");
}

// Variables pour le champ de nom
deck_name = "";
deck_name_editing = false;

// Variables pour le mode édition
editing_mode = false;
original_deck_name = ""; // Pour retrouver le deck original lors de la sauvegarde

// Variables pour la liste des cartes
cards_list = [];
max_cards = 50; // Maximum 50 emplacements
current_slots = 1; // Commencer avec 1 emplacement

// Variables pour le système de scroll
scroll_offset = 0; // Décalage du scroll (en nombre de lignes)
max_visible_lines = 25; // Nombre maximum de lignes visibles
max_cards_area_height = 560; // Hauteur maximale de la zone des cartes (25 lignes * 22px + 10px padding)

// Variables pour l'interface
frame_width = 250; // Largeur doublée
frame_color = c_ltgray;
frame_border_color = c_black;

// Variables pour la confirmation de suppression
show_confirmation = false;
confirmation_message = "";
confirmation_yes_x = 0;
confirmation_yes_y = 0;
confirmation_no_x = 0;
confirmation_no_y = 0;
confirmation_button_width = 60;
confirmation_button_height = 25;

// Fonction pour calculer la hauteur dynamique (définie avant utilisation)
function calculate_dynamic_height() {
    var base_height = 70; // Hauteur pour le titre et le nom
    var cards_height = calculate_cards_area_height(); // Hauteur dynamique des cartes
    var buttons_height = 30; // Hauteur des boutons
    var padding = 50; // Espacement (augmenté pour les boutons)
    return base_height + cards_height + buttons_height + padding;
}

// Calculer la hauteur initiale
frame_height = calculate_dynamic_height();

// Variables pour le champ de saisie du nom
name_field_x = x + 10;
name_field_y = y + 30;
name_field_width = frame_width - 20;
name_field_height = 25;

// Variables pour la zone des cartes
cards_area_x = x + 10;
cards_area_y = y + 70;
cards_area_width = frame_width - 20;

// Fonction pour calculer la hauteur dynamique de la zone des cartes
function calculate_cards_area_height() {
    var line_height = 20;
    var line_margin = 2;
    var padding = 10; // Padding en haut et en bas
    var calculated_height = (line_height + line_margin) * min(current_slots, max_visible_lines) + padding;
    return min(calculated_height, max_cards_area_height);
}

cards_area_height = calculate_cards_area_height();

// Variables pour les boutons
button_width = 80;
button_height = 30;
button_spacing = 10;

// Profondeur pour s'afficher au-dessus
depth = -100;

// Fonction pour ajouter un nouvel emplacement si nécessaire
function check_and_add_slot() {
    // Calculer le nombre de groupes uniques (empilements) plutôt que le nombre brut d'entrées
    var grouped_map = ds_map_create();
    for (var _i = 0; _i < array_length(cards_list); _i++) {
        var e = cards_list[_i];
        var cname = (is_struct(e) && variable_struct_exists(e, "name")) ? e.name : string(e);
        var coid = (is_struct(e) && variable_struct_exists(e, "objectId")) ? e.objectId : "";

        // Si l'entrée est juste un objectId stocké comme string, tenter de résoudre le vrai nom
        if (coid == "" && string_length(cname) > 0 && string_pos("o", cname) == 1) {
            var allTmp = dbGetAllCards();
            if (is_array(allTmp) && array_length(allTmp) > 0) {
                for (var _t = 0; _t < array_length(allTmp); _t++) {
                    if (variable_struct_exists(allTmp[_t], "objectId") && allTmp[_t].objectId == cname) {
                        coid = cname;
                        if (variable_struct_exists(allTmp[_t], "name")) cname = allTmp[_t].name;
                        break;
                    }
                }
            }
        }

        var key = string_trim(string_lower(string(cname)));
        if (!ds_map_exists(grouped_map, key)) ds_map_add(grouped_map, key, 1);
    }
    var unique_count = ds_map_size(grouped_map);
    ds_map_destroy(grouped_map);

    if (unique_count >= current_slots && current_slots < max_cards) {
        current_slots++;
        cards_area_height = calculate_cards_area_height(); // Recalculer la hauteur de la zone des cartes
        frame_height = calculate_dynamic_height();
        show_debug_message("Nouvel emplacement ajouté. Total: " + string(current_slots));
    }
}

// Fonction pour sauvegarder le deck
function save_deck() {
    show_debug_message("### Sauvegarde du deck: " + deck_name);
    show_debug_message("### Nombre de cartes: " + string(array_length(cards_list)));
    show_debug_message("### Mode édition: " + string(editing_mode));
    
    // Normaliser les cartes à sauvegarder: toujours { name, objectId }
    var cards_for_save = [];
    for (var i = 0; i < array_length(cards_list); i++) {
        var entry = cards_list[i];
        var name = is_struct(entry) && variable_struct_exists(entry, "name") ? entry.name : string(entry);
        var oid = is_struct(entry) && variable_struct_exists(entry, "objectId") ? entry.objectId : "";
        if (oid == "" && name != "") {
            var matches = dbGetCardsByName(name);
            for (var k = 0; k < array_length(matches); k++) {
                if (variable_struct_exists(matches[k], "name") && matches[k].name == name && variable_struct_exists(matches[k], "objectId")) {
                    oid = matches[k].objectId;
                    break;
                }
            }
        }
        array_push(cards_for_save, { name: name, objectId: oid });
    }
    
    // Créer la structure du deck à sauvegarder
    var deck_data = {
        name: deck_name,
        cards: cards_for_save,
        created_date: date_current_datetime(),
        card_count: array_length(cards_for_save)
    };
    
    // Initialiser la liste globale des decks si elle n'existe pas
    if (!variable_global_exists("saved_decks")) {
        global.saved_decks = [];
    }
    
    var save_success = false;
    
    if (editing_mode) {
        // Mode édition : remplacer le deck existant
        var deck_found = false;
        for (var i = 0; i < array_length(global.saved_decks); i++) {
            if (global.saved_decks[i].name == original_deck_name) {
                // Remplacer le deck existant
                global.saved_decks[i] = deck_data;
                deck_found = true;
                show_debug_message("### Deck existant mis à jour à l'index: " + string(i));
                break;
            }
        }
        
        if (!deck_found) {
            // Si le deck original n'est pas trouvé, l'ajouter comme nouveau
            array_push(global.saved_decks, deck_data);
            show_debug_message("### Deck original non trouvé, ajouté comme nouveau deck");
        }
        
        save_success = save_decks_to_file();
        
        if (save_success) {
            // Deck modifié avec succès
        } else {
            // Erreur lors de la modification du deck
        }
    } else {
        // Mode création : ajouter un nouveau deck
        array_push(global.saved_decks, deck_data);
        save_success = save_decks_to_file();
        
        if (save_success) {
            // Deck créé avec succès
        } else {
            // Erreur lors de la création du deck
        }
    }
    
    if (save_success) {
        show_debug_message("### Deck sauvegardé avec succès sur fichier !");
    } else {
        show_debug_message("### Erreur lors de la sauvegarde sur fichier !");
    }
    

    show_debug_message("### Total decks sauvegardés: " + string(array_length(global.saved_decks)));
    
    // Fermer le constructeur de deck
    close_deck_builder();
}

// Fonction pour supprimer/annuler la création du deck
function cancel_deck_creation() {
    if (editing_mode) {
        // Mode edition : demander confirmation avant suppression
        show_confirmation = true;
        confirmation_message = "Etes-vous sur de vouloir supprimer le deck '" + original_deck_name + "' ?";
        
        // Calculer les positions des boutons de confirmation
        var dialog_width = 300;
        var dialog_height = 100;
        var dialog_x = x + (frame_width - dialog_width) / 2;
        var dialog_y = y + frame_height / 2 - dialog_height / 2;
        
        confirmation_yes_x = dialog_x + 50;
        confirmation_yes_y = dialog_y + dialog_height - 40;
        confirmation_no_x = dialog_x + dialog_width - 110;
        confirmation_no_y = dialog_y + dialog_height - 40;
        
        show_debug_message("### Demande de confirmation pour supprimer: " + original_deck_name);
    } else {
        // Mode creation : simplement annuler
        show_debug_message("### Annulation de la creation du deck");
        close_deck_builder();
    }
}

// Fonction pour confirmer la suppression du deck
function confirm_deck_deletion() {
    show_debug_message("### Confirmation de suppression du deck: " + original_deck_name);
    
    // Chercher et supprimer le deck de la liste globale
    if (variable_global_exists("saved_decks")) {
        var deck_found = false;
        for (var i = 0; i < array_length(global.saved_decks); i++) {
            var deck = global.saved_decks[i];
            if (deck.name == original_deck_name) {
                // Supprimer le deck de la liste
                array_delete(global.saved_decks, i, 1);
                deck_found = true;
                show_debug_message("### Deck supprime: " + original_deck_name);
                break;
            }
        }
        
        if (deck_found) {
            // Sauvegarder la liste mise à jour
            var save_success = save_decks_to_file();
            if (save_success) {
                show_debug_message("### Deck supprime avec succes du fichier !");
            } else {
                show_debug_message("### Erreur lors de la suppression du deck du fichier !");
            }
        } else {
            show_debug_message("### Erreur: Deck a supprimer non trouve: " + original_deck_name);
        }
    }
    
    // Fermer le constructeur de deck
    close_deck_builder();
}

// Fonction pour annuler la suppression
function cancel_deck_deletion() {
    show_debug_message("### Suppression annulee");
    show_confirmation = false;
}

// Fonction pour fermer le constructeur de deck
function close_deck_builder() {
    // Trouver l'instance oDeckList pour la notifier
    if (instance_exists(oDeckList)) {
        var deck_list = instance_find(oDeckList, 0);
        deck_list.show_deck_builder = false;
        deck_list.deck_builder_instance = noone;
    }
    
    // Détruire cette instance
    instance_destroy();
}

// Initialiser la hauteur
frame_height = calculate_dynamic_height();

// Fonction pour charger un deck existant pour modification
function load_deck_for_editing(deck_data) {
    show_debug_message("### Chargement du deck pour modification: " + deck_data.name);
    
    // Activer le mode édition
    editing_mode = true;
    original_deck_name = deck_data.name;
    
    // Charger les données du deck
    deck_name = deck_data.name;
    cards_list = [];
    
    // Copier les cartes du deck (créer une nouvelle copie pour éviter les références)
    for (var i = 0; i < array_length(deck_data.cards); i++) {
        array_push(cards_list, deck_data.cards[i]);
    }
    
    // Ajuster le nombre d'emplacements pour afficher toutes les cartes + 1 emplacement libre
    current_slots = max(array_length(cards_list) + 1, 1);
    if (current_slots > max_cards) {
        current_slots = max_cards;
    }
    
    // Recalculer les dimensions
    cards_area_height = calculate_cards_area_height();
    frame_height = calculate_dynamic_height();
    

    
    show_debug_message("### Deck chargé avec " + string(array_length(cards_list)) + " cartes");
    show_debug_message("### Emplacements disponibles: " + string(current_slots));
    show_debug_message("### Mode édition activé pour: " + original_deck_name);
}

// Fonction pour afficher une carte depuis la base de données
function show_card_from_database(cardName) {
    // Unifier l'affichage: utiliser oCardViewer réel dans rCollection
    if (room != rCollection) {
        global.pending_card_selection = cardName;
        room_goto(rCollection);
        return true;
    }

    // Essayer d'utiliser le visualiseur réel
    if (instance_exists(oCardViewer)) {
        var viewer = instance_find(oCardViewer, 0);
        if (viewer != noone) {
            if (variable_instance_exists(viewer.id, "selectCardByName")) {
                viewer.selectCardByName(cardName);
                return true;
            } else {
                // Repli: programmer la sélection par nom pour que Step_0 la traite
                global.pending_card_selection = cardName;
                return true;
            }
        }
    }

    // Deuxième repli: ancien chemin d'affichage temporaire si pas de viewer
    if (!instance_exists(oDataBase)) {
        return false;
    }

    var cardsFound = dbGetCardsByName(cardName);
    var cardData = noone;
    for (var i = 0; i < array_length(cardsFound); i++) {
        if (cardsFound[i].name == cardName) {
            cardData = cardsFound[i];
            break;
        }
    }
    if (cardData == noone) {
        return false;
    }

    var tempInstance = instance_create_layer(-1000, -1000, "Instances", oCardParent);
    if (tempInstance == noone) {
        return false;
    }
    tempInstance.visible = false;
    tempInstance.name = cardData.name;
    tempInstance.attack = variable_struct_exists(cardData, "attack") ? cardData.attack : 0;
    tempInstance.defense = variable_struct_exists(cardData, "defense") ? cardData.defense : 0;
    tempInstance.cost = variable_struct_exists(cardData, "cost") ? cardData.cost : 0;
    tempInstance.description = variable_struct_exists(cardData, "description") ? cardData.description : "";
    tempInstance.rarity = variable_struct_exists(cardData, "rarity") ? cardData.rarity : "commun";
    tempInstance.star = variable_struct_exists(cardData, "star") ? cardData.star : 0;
    if (variable_struct_exists(cardData, "sprite")) {
        var spriteAsset = asset_get_index(cardData.sprite);
        if (spriteAsset != -1) {
            tempInstance.sprite_index = spriteAsset;
        }
    }

    if (instance_exists(oCollectionCardDisplay)) {
        var cardDisplay = instance_find(oCollectionCardDisplay, 0);
        if (cardDisplay != noone) {
            cardDisplay.selectedCard = tempInstance;
            return true;
        }
    }

    instance_destroy(tempInstance);
    return false;
}

// Initialiser les variables globales de debug
global.debug_message = "";
global.debug_timer = 0;

// Initialiser la variable pour la sélection de carte en attente
if (!variable_global_exists("pending_card_selection")) {
    global.pending_card_selection = "";
}