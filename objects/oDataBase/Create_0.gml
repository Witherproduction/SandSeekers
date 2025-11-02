// === Base de données des cartes ===
show_debug_message("### oDataBase.create");

// Structure principale de la base de données
cardDatabase = {};

// Fonction pour ajouter une carte à la base de données
addCard = function(cardId, cardData) {
    cardDatabase[$ cardId] = cardData;
    show_debug_message("Carte ajoutée: " + cardId);
};

// Fonction pour récupérer une carte par son ID
getCard = function(cardId) {
    if (variable_struct_exists(cardDatabase, cardId)) {
        return cardDatabase[$ cardId];
    }
    show_debug_message("Carte non trouvée: " + cardId);
    return undefined;
};

// Fonction pour rechercher des cartes par type
getCardsByType = function(cardType) {
    var results = [];
    var keys = variable_struct_get_names(cardDatabase);
    
    for (var i = 0; i < array_length(keys); i++) {
        var card = cardDatabase[$ keys[i]];
        if (card.type == cardType) {
            array_push(results, card);
        }
    }
    
    return results;
};

// Fonction pour rechercher des cartes par nom
getCardsByName = function(searchName) {
    var results = [];
    var keys = variable_struct_get_names(cardDatabase);
    
    for (var i = 0; i < array_length(keys); i++) {
        var card = cardDatabase[$ keys[i]];
        if (string_pos(string_lower(searchName), string_lower(card.name)) > 0) {
            array_push(results, card);
        }
    }
    
    return results;
};

// Fonction pour obtenir toutes les cartes
getAllCards = function() {
    var results = [];
    var keys = variable_struct_get_names(cardDatabase);
    
    for (var i = 0; i < array_length(keys); i++) {
        array_push(results, cardDatabase[$ keys[i]]);
    }
    
    return results;
};

// Fonction pour obtenir les cartes par rareté
getCardsByRarity = function(rarity) {
    var results = [];
    var keys = variable_struct_get_names(cardDatabase);
    
    for (var i = 0; i < array_length(keys); i++) {
        var card = cardDatabase[$ keys[i]];
        if (card.rarity == rarity) {
            array_push(results, card);
        }
    }
    
    return results;
};

// Initialiser la base de données avec les cartes existantes
initializeDatabase();

// Fonction d'initialisation
function initializeDatabase() {
    show_debug_message("=== Initialisation de la base de données ===");
    // Synchronisation: toujours copier la DB depuis le dossier de l'exe vers AppData (WD)
    // Objectif: garantir que les JSON mis à jour dans la release écrasent les versions locales obsolètes
    var wd_datafile = CARDS_DATABASE_SAVE_FILE; // working_directory/datafiles/cards_database.json
    var wd_rootfile = "cards_database.json";   // working_directory/cards_database.json
    var exe_df = program_directory + "datafiles/cards_database.json";
    var exe_root = program_directory + "cards_database.json";
    show_debug_message("### Sync DB: probing EXE paths...");
    if (file_exists(exe_df)) {
        directory_create("datafiles");
        if (file_exists(wd_datafile)) { file_delete(wd_datafile); }
        var ok_sync_df = file_copy(exe_df, wd_datafile);
        show_debug_message("### Sync DB from EXE datafiles -> WD: " + string(ok_sync_df));
    } else if (file_exists(exe_root)) {
        if (file_exists(wd_rootfile)) { file_delete(wd_rootfile); }
        var ok_sync_root = file_copy(exe_root, wd_rootfile);
        show_debug_message("### Sync DB from EXE root -> WD: " + string(ok_sync_root));
    } else {
        show_debug_message("### Sync DB skipped: no DB found beside EXE");
    }

    // Amorçage des decks: copier vers AppData si absent
    var wd_decks_datafile = DECK_SAVE_FILE;      // working_directory/datafiles/saved_decks.json
    var wd_decks_rootfile = "saved_decks.json"; // working_directory/saved_decks.json
    var has_wd_decks = file_exists(wd_decks_datafile) || file_exists(wd_decks_rootfile);
    if (!has_wd_decks) {
        var exe_decks_df = program_directory + "datafiles/saved_decks.json";
        var exe_decks_root = program_directory + "saved_decks.json";
        show_debug_message("### Seed check: WD has decks? " + string(has_wd_decks) + ", probing EXE...");
        if (file_exists(exe_decks_df)) {
            directory_create("datafiles");
            var okd = file_copy(exe_decks_df, wd_decks_datafile);
            show_debug_message("### Seed copy DECKS from EXE datafiles -> WD: " + string(okd));
        } else if (file_exists(exe_decks_root)) {
            var okdr = file_copy(exe_decks_root, wd_decks_rootfile);
            show_debug_message("### Seed copy DECKS from EXE root -> WD: " + string(okdr));
        } else {
            show_debug_message("### Seed failed: no decks file found beside EXE");
        }
    }
    
    // Essayer de charger la base de données sauvegardée d'abord
    var database_loaded = load_cards_database_from_file();
    
    if (!database_loaded) {
        // Si pas de base de données sauvegardée, utiliser les cartes par défaut
        show_debug_message("Base de données initialisée avec " + string(array_length(variable_struct_get_names(cardDatabase))) + " cartes par défaut");
        
        // Supprimer les cartes de test au lancement
        dbRemoveTestCards();
        show_debug_message("Base de données après suppression des cartes de test: " + string(array_length(variable_struct_get_names(cardDatabase))) + " cartes");
        
        // Sauvegarder cette base de données par défaut pour la prochaine fois
        save_cards_database_to_file();
    }
    
    // Charger les decks sauvegardés
    var decks_loaded = load_decks_from_file();
    show_debug_message("Decks chargés: " + string(get_deck_count()) + " deck(s)");

    // Charger les favoris sauvegardés
    // Amorçage des favoris: copier vers AppData si absent
    var wd_fav_datafile = FAVORITES_SAVE_FILE;      // working_directory/datafiles/favorite_cards.json
    var wd_fav_rootfile = "favorite_cards.json";   // working_directory/favorite_cards.json
    var has_wd_fav = file_exists(wd_fav_datafile) || file_exists(wd_fav_rootfile);
    if (!has_wd_fav) {
        var exe_fav_df = program_directory + "datafiles/favorite_cards.json";
        var exe_fav_root = program_directory + "favorite_cards.json";
        show_debug_message("### Seed check: WD has favorites? " + string(has_wd_fav) + ", probing EXE...");
        if (file_exists(exe_fav_df)) {
            directory_create("datafiles");
            var okf = file_copy(exe_fav_df, wd_fav_datafile);
            show_debug_message("### Seed copy FAVORITES from EXE datafiles -> WD: " + string(okf));
        } else if (file_exists(exe_fav_root)) {
            var okfr = file_copy(exe_fav_root, wd_fav_rootfile);
            show_debug_message("### Seed copy FAVORITES from EXE root -> WD: " + string(okfr));
        } else {
            show_debug_message("### Seed failed: no favorites file found beside EXE");
        }
    }

    // Charger les favoris sauvegardés
    load_favorites_from_file();
    show_debug_message("Favoris chargés: " + string(get_favorites_count()) + " cartes favorites");

}   show_debug_message("Base de données finale: " + string(array_length(variable_struct_get_names(cardDatabase))) + " cartes au total");