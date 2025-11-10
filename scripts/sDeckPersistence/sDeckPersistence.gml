// === Script de persistance des decks et favoris ===
// Fonctions pour sauvegarder et charger les decks et favoris entre les sessions

// Noms des fichiers de sauvegarde
#macro DECK_SAVE_FILE "datafiles/saved_decks.json"
#macro FAVORITES_SAVE_FILE "datafiles/favorite_cards.json"
#macro CARDS_DATABASE_SAVE_FILE "datafiles/cards_database.json"

/// @function save_decks_to_file()
/// @description Sauvegarde tous les decks dans un fichier JSON
function save_decks_to_file() {
    try {
        // Vérifier si la liste des decks existe
        if (!variable_global_exists("saved_decks")) {
            global.saved_decks = [];
        }
        
        // Créer la structure de données à sauvegarder
        var save_data = {
            version: "1.0",
            decks: global.saved_decks,
            save_date: date_current_datetime()
        };
        
        // Convertir en JSON
        var json_string = json_stringify(save_data);
        
        // Sauvegarder dans le fichier avec fallback (datafiles -> racine)
        directory_create("datafiles");
        var target_path = DECK_SAVE_FILE; // datafiles/saved_decks.json
        var file = file_text_open_write(target_path);
        if (file == -1) {
            // Fallback vers la racine si datafiles indisponible
            target_path = "saved_decks.json";
            file = file_text_open_write(target_path);
        }

        if (file != -1) {
            file_text_write_string(file, json_string);
            file_text_close(file);
            show_debug_message("### Decks sauvegardés dans le fichier: " + target_path);
            return true;
        } else {
            show_debug_message("### Erreur: Impossible d'ouvrir un fichier de sauvegarde des decks (datafiles et racine)");
            return false;
        }
    } catch (e) {
        show_debug_message("### Erreur lors de la sauvegarde des decks: " + string(e));
        return false;
    }
}

/// @function load_decks_from_file()
/// @description Charge tous les decks depuis le fichier JSON
function load_decks_from_file() {
    try {
        // Priorité: working_directory (AppData) -> program_directory (EXE)
        var wd_df   = DECK_SAVE_FILE;                 // AppData/datafiles
        var wd_root = "saved_decks.json";            // AppData root
        var exe_df  = program_directory + "datafiles/saved_decks.json";
        var exe_root= program_directory + "saved_decks.json";
        var candidate_paths = [
            wd_df,                  // 1) AppData/datafiles
            wd_root,                // 2) AppData root
            exe_df,                 // 3) EXE/datafiles
            exe_root                // 4) EXE root
        ];
        var path_to_use = "";
        var file = -1;
        for (var i = 0; i < array_length(candidate_paths); i++) {
            var p = candidate_paths[i];
            if (file_exists(p)) {
                file = file_text_open_read(p);
                if (file != -1) { path_to_use = p; break; }
            }
        }
        if (path_to_use == "") {
            show_debug_message("### Aucun fichier de decks trouvé (EXE ou AppData), initialisation d'une liste vide");
            global.saved_decks = [];
            return true;
        }

        // Lire le fichier (handle déjà ouvert)
        var json_string = "";
        while (!file_text_eof(file)) {
            json_string += file_text_read_string(file);
            file_text_readln(file);
        }
        file_text_close(file);

        // Parser le JSON
        var save_data = json_parse(json_string);

        // Vérifier la structure des données
        if (variable_struct_exists(save_data, "decks")) {
            global.saved_decks = save_data.decks;
            var src = (path_to_use == exe_df || path_to_use == exe_root) ? "EXE" : "APPDATA";
            show_debug_message("### Decks chargés depuis: " + path_to_use + " [SOURCE=" + src + "] (" + string(array_length(global.saved_decks)) + " deck(s))");

            // Migration: si lecture depuis EXE, persister aussi dans AppData
            if (src == "EXE") {
                directory_create("datafiles");
                var migrate_path = DECK_SAVE_FILE;
                var mf = file_text_open_write(migrate_path);
                if (mf != -1) {
                    // Ré-écrire le même contenu JSON dans AppData
                    file_text_write_string(mf, json_string);
                    file_text_close(mf);
                    show_debug_message("### Migration: decks copiés vers AppData -> " + migrate_path);
                } else {
                    show_debug_message("### Migration: échec de l'ouverture du fichier AppData pour decks");
                }
            }

            // Afficher les decks chargés pour debug
            for (var j = 0; j < array_length(global.saved_decks); j++) {
                var deck = global.saved_decks[j];
                if (variable_struct_exists(deck, "name")) {
                    show_debug_message("### Deck chargé: " + deck.name);
                }
            }

            return true;
        } else {
            show_debug_message("### Erreur: Structure de données invalide dans le fichier");
            global.saved_decks = [];
            return false;
        }
    } catch (e) {
        show_debug_message("### Erreur lors du chargement des decks: " + string(e));
        global.saved_decks = [];
        return false;
    }
}

/// @function get_deck_count()
/// @description Retourne le nombre de decks sauvegardés
function get_deck_count() {
    if (!variable_global_exists("saved_decks")) {
        return 0;
    }
    return array_length(global.saved_decks);
}

/// @function get_deck_by_index(index)
/// @description Retourne un deck par son index
/// @param {real} index L'index du deck à récupérer
function get_deck_by_index(index) {
    if (!variable_global_exists("saved_decks")) {
        return undefined;
    }
    
    if (index >= 0 && index < array_length(global.saved_decks)) {
        return global.saved_decks[index];
    }
    
    return undefined;
}

/// @function delete_deck_by_index(index)
/// @description Supprime un deck par son index et sauvegarde
/// @param {real} index L'index du deck à supprimer
function delete_deck_by_index(index) {
    if (!variable_global_exists("saved_decks")) {
        return false;
    }
    
    if (index >= 0 && index < array_length(global.saved_decks)) {
        array_delete(global.saved_decks, index, 1);
        save_decks_to_file(); // Sauvegarder immédiatement
        show_debug_message("### Deck supprimé à l'index: " + string(index));
        return true;
    }
    
    return false;
}

// === FONCTIONS DE PERSISTANCE DES CARTES PERSONNALISÉES ===

/// @function save_cards_database_to_file()
/// @description Sauvegarde toute la base de données des cartes dans un fichier JSON
function save_cards_database_to_file() {
    try {
        var db = getDatabase();
        if (db == noone || !instance_exists(db)) {
            show_debug_message("### Erreur: Base de données non trouvée");
            return false;
        }
        
        // Créer la structure de données à sauvegarder (toute la base de données)
        var save_data = {
            version: "1.0",
            cards_database: db.cardDatabase,
            save_date: date_current_datetime(),
            total_cards: variable_struct_names_count(db.cardDatabase)
        };
        
        // Convertir en JSON (corrige variable manquante)
        var json_string = json_stringify(save_data);
        
        // Sauvegarder dans le fichier (crée le dossier datafiles si nécessaire)
        var target_path = CARDS_DATABASE_SAVE_FILE; // datafiles/cards_database.json
        directory_create("datafiles");

        var file = file_text_open_write(target_path);
        if (file == -1) {
            // Fallback vers la racine si datafiles indisponible
            target_path = "cards_database.json";
            file = file_text_open_write(target_path);
        }

        if (file != -1) {
            file_text_write_string(file, json_string);
            file_text_close(file);
            show_debug_message("### Base de données des cartes sauvegardée dans: " + target_path);
            show_debug_message("### Nombre total de cartes sauvegardées: " + string(variable_struct_names_count(db.cardDatabase)));
            return true;
        } else {
            show_debug_message("### Erreur: Impossible d'ouvrir un fichier de sauvegarde des cartes (datafiles et racine)");
            return false;
        }
    } catch (e) {
        show_debug_message("### Erreur lors de la sauvegarde de la base de données: " + string(e));
        return false;
    }
}

/// @function load_cards_database_from_file()
/// @description Charge toute la base de données des cartes depuis le fichier JSON
function load_cards_database_from_file() {
    try {
        // Journaux des répertoires clés pour diagnostiquer les chemins
        show_debug_message("### working_directory = " + working_directory);
        show_debug_message("### program_directory = " + program_directory);
        // Écrire aussi ces infos dans un fichier de debug côté AppData
        directory_create("datafiles");
        var _dbg = file_text_open_write("datafiles/debug_paths.txt");
        if (_dbg != -1) {
            file_text_write_string(_dbg, "working_directory=" + working_directory + "\n");
            file_text_write_string(_dbg, "program_directory=" + program_directory + "\n");
            file_text_close(_dbg);
        }
        // Résoudre le meilleur chemin disponible en PRIORISANT le dossier de l'exe
        // Ordre: dossier de l'exe -> datafiles de l'exe -> datafiles (AppData/sandbox) -> racine (AppData/sandbox)
        var candidate_paths = [
            program_directory + "cards_database.json",              // 1) côté .exe (priorité max)
            program_directory + "datafiles/cards_database.json",    // 2) datafiles à côté de l'exe
            CARDS_DATABASE_SAVE_FILE,                                 // 3) AppData: datafiles/cards_database.json (working_directory)
            "cards_database.json"                                   // 4) AppData: racine du working_directory
        ];
        var path_to_use = "";
        var file = -1;
        for (var i = 0; i < array_length(candidate_paths); i++) {
            var p = candidate_paths[i];
            var exists = file_exists(p);
            show_debug_message("### Probe DB path: " + p + " exists=" + string(exists));
            if (exists) {
                var fh = file_text_open_read(p);
                if (fh != -1) {
                    file = fh;
                    path_to_use = p;
                    break;
                } else {
                    show_debug_message("### Impossible d'ouvrir '" + p + "' (sandbox/protection). Essai du prochain chemin...");
                }
            }
        }
        if (file == -1) {
            show_debug_message("### Aucun fichier de base de données utilisable trouvé (ouverture échouée). Utilisation des cartes par défaut");
            return false; // Retourner false pour indiquer qu'aucune base de données n'a été chargée
        }

        // Mémoriser le chemin choisi (pour debug / UI)
        global.cards_db_loaded_path = path_to_use;
        var from_exe = string_copy(path_to_use, 1, string_length(program_directory)) == program_directory;
        show_debug_message("### cards_database.json choisi: " + path_to_use + (from_exe ? " [SOURCE=EXE]" : " [SOURCE=APPDATA]"));
        // Écrire le chemin choisi dans le fichier de debug
        var _dbg2 = file_text_open_write("datafiles/debug_paths.txt");
        if (_dbg2 != -1) {
            file_text_write_string(_dbg2, "chosen_path=" + path_to_use + "\n");
            file_text_close(_dbg2);
        }

        var db = getDatabase();
        if (db == noone || !instance_exists(db)) {
            show_debug_message("### Erreur: Base de données non trouvée");
            file_text_close(file);
            return false;
        }
        
        // Lire le contenu complet du fichier JSON
        var json_string = "";
        while (!file_text_eof(file)) {
            json_string += file_text_read_string(file);
            file_text_readln(file);
        }
        file_text_close(file);
        
        // Parser le JSON et accepter plusieurs formats
        var save_data = json_parse(json_string);
        var db_map = noone;

        if (is_struct(save_data) && variable_struct_exists(save_data, "cards_database")) {
            // Format enveloppé { version, cards_database, ... }
            db_map = save_data.cards_database;
        } else if (is_array(save_data)) {
            // Format tableau d'objets -> convertir en map par id
            db_map = {};
            var missing_id_count = 0;
            for (var i = 0; i < array_length(save_data); i++) {
                var c = save_data[i];
                if (is_struct(c)) {
                    var has_id = variable_struct_exists(c, "id");
                    var id_val = has_id ? c.id : "";
                    if (!has_id || string(id_val) == "") {
                        // Générer un ID robuste à partir du nom, sinon index
                        var gen_id = "card_" + string(i);
                        if (variable_struct_exists(c, "name")) {
                            gen_id = string_lower(string_replace_all(string(c.name), " ", "_"));
                        }
                        c.id = gen_id;
                        missing_id_count += 1;
                    }
                    db_map[$ c.id] = c;
                }
            }
            if (missing_id_count > 0) {
                show_debug_message("### Migration: " + string(missing_id_count) + " carte(s) sans 'id' normalisée(s)");
            }
        } else if (is_struct(save_data)) {
            // Format map directe { id: cardData, ... }
            db_map = save_data;
        }

        if (db_map != noone && variable_struct_names_count(db_map) > 0) {
            db.cardDatabase = db_map;
            var total_cards = variable_struct_names_count(db.cardDatabase);
            show_debug_message("### Base de données chargée depuis: " + path_to_use);
            show_debug_message("### Nombre total de cartes chargées: " + string(total_cards));
            // Si lecture depuis EXE, migrer aussi le JSON vers AppData pour garder l'utilisateur en phase
            if (from_exe) {
                directory_create("datafiles");
                var migrate_path = CARDS_DATABASE_SAVE_FILE; // WD/datafiles/cards_database.json
                var mf = file_text_open_write(migrate_path);
                if (mf != -1) {
                    file_text_write_string(mf, json_string);
                    file_text_close(mf);
                    show_debug_message("### Migration: DB copiée vers AppData -> " + migrate_path);
                } else {
                    show_debug_message("### Migration: échec de l'ouverture du fichier AppData pour DB");
                }
            }
            return true;
        } else {
            show_debug_message("### Erreur: Format JSON non reconnu ou vide pour la base de données");
            return false;
        }
    } catch (e) {
        show_debug_message("### Erreur lors du chargement de la base de données: " + string(e));
        return false;
    }
}

/// @function export_cards_database_to_release()
/// @description Copie la base de données des cartes depuis AppData (working_directory)
/// vers le dossier de l'exécutable si possible, et crée un fallback dans `export/`.
/// Retourne true si au moins une cible a été écrite.
function export_cards_database_to_release() {
    try {
        // Déterminer la source (priorité AppData/datafiles, puis racine AppData)
        var src_candidates = [
            CARDS_DATABASE_SAVE_FILE,   // working_directory/datafiles/cards_database.json
            "cards_database.json"      // working_directory/cards_database.json
        ];
        var src = "";
        for (var i = 0; i < array_length(src_candidates); i++) {
            var p = src_candidates[i];
            if (file_exists(p)) { src = p; break; }
        }
        if (src == "") {
            show_debug_message("### Export DB: source introuvable dans AppData (datafiles ou racine)");
            return false;
        }

        // Lire le contenu JSON depuis la source
        var fh = file_text_open_read(src);
        if (fh == -1) {
            show_debug_message("### Export DB: impossible d'ouvrir la source: " + src);
            return false;
        }
        var json_string = "";
        while (!file_text_eof(fh)) {
            json_string += file_text_read_string(fh);
            file_text_readln(fh);
        }
        file_text_close(fh);

        var wrote_any = false;

// 1) PRIORITÉ: Copie directe dans le dossier SandSeekers du projet
var dst_backup_project = "C:\\Users\\arckano\\Desktop\\carte\\SandSeekers\\cards_database.json";
        var f_backup = file_text_open_write(dst_backup_project);
        if (f_backup != -1) {
            file_text_write_string(f_backup, json_string);
            file_text_close(f_backup);
            // Vérifier réellement la présence du fichier (le sandbox IDE peut refuser l'accès hors AppData)
            if (file_exists(dst_backup_project)) {
    show_debug_message("### Export DB: copié dans le projet SandSeekers -> " + dst_backup_project);
                wrote_any = true;
            } else {
    show_debug_message("### Export DB: sandbox IDE, fichier non visible dans le projet SandSeekers. Utiliser le fallback export/.");
            }
        } else {
    show_debug_message("### Export DB: échec d'ouverture/écriture dans le projet SandSeekers");
        }

        // 2) Tentative d'écriture à côté de l'exécutable (peut échouer à cause du sandbox)
        var dst_exe_root = program_directory + "cards_database.json";
        var f_exe = file_text_open_write(dst_exe_root);
        if (f_exe != -1) {
            file_text_write_string(f_exe, json_string);
            file_text_close(f_exe);
            show_debug_message("### Export DB: écrit à côté de l'EXE -> " + dst_exe_root);
            wrote_any = true;
        } else {
            show_debug_message("### Export DB: échec d'écriture à côté de l'EXE (sandbox/protection)");
        }

        // 3) Fallback: écrire dans working_directory/export/cards_database.json
        directory_create("export");
        var dst_export = "export/cards_database.json";
        var f_exp = file_text_open_write(dst_export);
        if (f_exp != -1) {
            file_text_write_string(f_exp, json_string);
            file_text_close(f_exp);
            show_debug_message("### Export DB: copie de secours -> " + dst_export);
            wrote_any = true;
        } else {
            show_debug_message("### Export DB: échec d'écriture du fallback export/");
        }

        // Journaliser les chemins dans le fichier de debug
        var _dbg = file_text_open_write("datafiles/debug_paths.txt");
        if (_dbg != -1) {
            file_text_write_string(_dbg, "export_src=" + src + "\n");
file_text_write_string(_dbg, "export_sandseekers_project=" + dst_backup_project + "\n");
            file_text_write_string(_dbg, "export_exe_root=" + dst_exe_root + "\n");
            file_text_write_string(_dbg, "export_fallback=" + dst_export + "\n");
            file_text_close(_dbg);
        }

        return wrote_any;
    } catch (e) {
        show_debug_message("### Export DB: Erreur -> " + string(e));
        return false;
    }
}

/// @function add_card_and_save(card_id, card_data)
/// @description Ajoute une carte à la base de données et la sauvegarde immédiatement
/// @param {string} card_id L'ID de la carte
/// @param {struct} card_data Les données de la carte
function add_card_and_save(card_id, card_data) {
    var db = getDatabase();
    if (db == noone || !instance_exists(db)) {
        show_debug_message("### Erreur: Base de données non trouvée");
        return false;
    }
    
    // Ajouter la carte à la base de données
    db.addCard(card_id, card_data);
    
    // Sauvegarder immédiatement toute la base de données
    save_cards_database_to_file();
    
    show_debug_message("### Carte ajoutée et base de données sauvegardée: " + card_id);
    return true;
}

// ========================================
// === FONCTIONS DE PERSISTANCE DES FAVORIS ===
// ========================================

/// @function save_favorites_to_file()
/// @description Sauvegarde la liste des cartes favorites dans un fichier JSON
function save_favorites_to_file() {
    try {
        // Vérifier si la liste des favoris existe
        if (!variable_global_exists("favorite_cards")) {
            global.favorite_cards = [];
        }
        
        // Créer la structure de données à sauvegarder
        var save_data = {
            version: "1.0",
            favorites: global.favorite_cards,
            save_date: date_current_datetime(),
            count: array_length(global.favorite_cards)
        };
        
        // Convertir en JSON
        var json_string = json_stringify(save_data);
        
        // Sauvegarder dans le fichier avec fallback (datafiles -> racine)
        directory_create("datafiles");
        var target_path = FAVORITES_SAVE_FILE; // datafiles/favorite_cards.json
        var file = file_text_open_write(target_path);
        if (file == -1) {
            // Fallback vers la racine si datafiles indisponible
            target_path = "favorite_cards.json";
            file = file_text_open_write(target_path);
        }

        if (file != -1) {
            file_text_write_string(file, json_string);
            file_text_close(file);
            show_debug_message("### Favoris sauvegardés dans le fichier: " + target_path);
            show_debug_message("### Nombre de favoris sauvegardés: " + string(array_length(global.favorite_cards)));
            return true;
        } else {
            show_debug_message("### Erreur: Impossible d'ouvrir un fichier de sauvegarde des favoris (datafiles et racine)");
            return false;
        }
    } catch (e) {
        show_debug_message("### Erreur lors de la sauvegarde des favoris: " + string(e));
        return false;
    }
}

/// @function load_favorites_from_file()
/// @description Charge la liste des cartes favorites depuis le fichier JSON
function load_favorites_from_file() {
    try {
        // Priorité: working_directory (AppData) -> program_directory (EXE)
        var wd_df   = FAVORITES_SAVE_FILE;           // AppData/datafiles
        var wd_root = "favorite_cards.json";        // AppData root
        var exe_df  = program_directory + "datafiles/favorite_cards.json";
        var exe_root= program_directory + "favorite_cards.json";
        var candidate_paths = [
            wd_df,                      // 1) AppData/datafiles
            wd_root,                    // 2) AppData root
            exe_df,                     // 3) EXE/datafiles
            exe_root                    // 4) EXE root
        ];
        var path_to_use = "";
        var file = -1;
        for (var i = 0; i < array_length(candidate_paths); i++) {
            var p = candidate_paths[i];
            if (file_exists(p)) {
                file = file_text_open_read(p);
                if (file != -1) { path_to_use = p; break; }
            }
        }
        if (path_to_use == "") {
            show_debug_message("### Aucun fichier de favoris trouvé (EXE ou AppData), initialisation d'une liste vide");
            global.favorite_cards = [];
            return true;
        }

        // Lire le fichier (handle déjà ouvert)
        var json_string = "";
        while (!file_text_eof(file)) {
            json_string += file_text_read_string(file);
            file_text_readln(file);
        }
        file_text_close(file);

        // Parser le JSON
        var save_data = json_parse(json_string);

        // Vérifier la structure des données
        if (variable_struct_exists(save_data, "favorites")) {
            global.favorite_cards = save_data.favorites;
            var src = (path_to_use == exe_df || path_to_use == exe_root) ? "EXE" : "APPDATA";
            show_debug_message("### Favoris chargés depuis: " + path_to_use + " [SOURCE=" + src + "] (" + string(array_length(global.favorite_cards)) + " carte(s))");
            
            // Migration: si lecture depuis EXE, persister aussi dans AppData
            if (src == "EXE") {
                directory_create("datafiles");
                var migrate_path = FAVORITES_SAVE_FILE;
                var mf = file_text_open_write(migrate_path);
                if (mf != -1) {
                    file_text_write_string(mf, json_string);
                    file_text_close(mf);
                    show_debug_message("### Migration: favoris copiés vers AppData -> " + migrate_path);
                } else {
                    show_debug_message("### Migration: échec de l'ouverture du fichier AppData pour favoris");
                }
            }

            // Afficher les favoris chargés pour debug
            for (var j = 0; j < array_length(global.favorite_cards); j++) {
                show_debug_message("### Favori chargé: " + global.favorite_cards[j]);
            }

            return true;
        } else {
            show_debug_message("### Erreur: Structure de données invalide dans le fichier des favoris");
            global.favorite_cards = [];
            return false;
        }
    } catch (e) {
        show_debug_message("### Erreur lors du chargement des favoris: " + string(e));
        global.favorite_cards = [];
        return false;
    }
}

/// @function get_favorites_count()
/// @description Retourne le nombre de cartes favorites
function get_favorites_count() {
    if (!variable_global_exists("favorite_cards")) {
        return 0;
    }
    return array_length(global.favorite_cards);
}

/// @function is_card_favorite(card_name)
/// @description Vérifie si une carte est dans les favoris
/// @param {string} card_name Le nom de la carte à vérifier
function is_card_favorite(card_name) {
    if (!variable_global_exists("favorite_cards")) {
        return false;
    }
    
    for (var i = 0; i < array_length(global.favorite_cards); i++) {
        if (global.favorite_cards[i] == card_name) {
            return true;
        }
    }
    
    return false;
}

/// @function add_card_to_favorites(card_name)
/// @description Ajoute une carte aux favoris et sauvegarde
/// @param {string} card_name Le nom de la carte à ajouter
function add_card_to_favorites(card_name) {
    if (!variable_global_exists("favorite_cards")) {
        global.favorite_cards = [];
    }
    
    // Vérifier si la carte n'est pas déjà en favoris
    if (!is_card_favorite(card_name)) {
        array_push(global.favorite_cards, card_name);
        save_favorites_to_file(); // Sauvegarder immédiatement
        show_debug_message("### Carte ajoutée aux favoris: " + card_name);
        return true;
    }
    
    return false;
}

/// @function remove_card_from_favorites(card_name)
/// @description Retire une carte des favoris et sauvegarde
/// @param {string} card_name Le nom de la carte à retirer
function remove_card_from_favorites(card_name) {
    if (!variable_global_exists("favorite_cards")) {
        return false;
    }
    
    for (var i = 0; i < array_length(global.favorite_cards); i++) {
        if (global.favorite_cards[i] == card_name) {
            array_delete(global.favorite_cards, i, 1);
            save_favorites_to_file(); // Sauvegarder immédiatement
            show_debug_message("### Carte retirée des favoris: " + card_name);
            return true;
        }
    }
    
    return false;
}

/// @function get_max_copies_for_card(cardName, object_id)
/// @description Retourne la limite d'exemplaires autorisés pour une carte (champ `limited`), défaut 3
function get_max_copies_for_card(cardName, object_id) {
    var DEFAULT_MAX = 3;
    var maxCopies = DEFAULT_MAX;
    var db = getDatabase();
    if (db != noone && instance_exists(db)) {
        var card = noone;
        if (object_id != "") {
            var allCards = dbGetAllCards();
            for (var i = 0; i < array_length(allCards); i++) {
                if (variable_struct_exists(allCards[i], "objectId") && allCards[i].objectId == object_id) {
                    card = allCards[i];
                    break;
                }
            }
        }
        if (card == noone) {
            var matches = dbGetCardsByName(cardName);
            for (var m = 0; m < array_length(matches); m++) {
                if (variable_struct_exists(matches[m], "name") && matches[m].name == cardName) {
                    card = matches[m];
                    break;
                }
            }
        }
    // 1) Priorité: lire la variable depuis l'instance sélectionnée (objet de carte réel)
    if (variable_instance_exists(self, "selectedCard") && self.selectedCard != noone && instance_exists(self.selectedCard)) {
        if (variable_instance_exists(self.selectedCard, "limited")) {
            var lim_inst = real(self.selectedCard.limited);
            if (is_real(lim_inst)) {
                if (lim_inst < 1) lim_inst = 1;
                if (lim_inst > 3) lim_inst = 3;
                show_debug_message("### get_max_copies_for_card: limite depuis instance = " + string(lim_inst) + " pour '" + string(cardName) + "'");
                return lim_inst;
            }
        }
    }

    // 2) Fallback: si on a l'objectId, instancier temporairement l'objet et lire 'limited'
    if (is_string(object_id) && object_id != "") {
        var obj_index = asset_get_index(object_id);
        if (obj_index != -1) {
            var temp = instance_create_layer(-10000, -10000, "Instances", obj_index);
            if (temp != noone) {
                var has_lim = variable_instance_exists(temp, "limited");
                var lim_obj = has_lim ? real(temp.limited) : undefined;
                instance_destroy(temp);
                if (has_lim && is_real(lim_obj)) {
                    if (lim_obj < 1) lim_obj = 1;
                    if (lim_obj > 3) lim_obj = 3;
                    show_debug_message("### get_max_copies_for_card: limite depuis objet = " + string(lim_obj) + " pour '" + string(cardName) + "' (" + string(object_id) + ")");
                    return lim_obj;
                }
            }
        }
    }

    // 3) Dernier recours: champ 'limited' dans la base JSON (si présent), sinon 3
    if (db != noone && instance_exists(db)) {
        var card = noone;
        var matches = dbGetCardsByName(cardName);
        for (var m = 0; m < array_length(matches); m++) {
            if (variable_struct_exists(matches[m], "name") && matches[m].name == cardName) {
                card = matches[m];
                break;
            }
        }
        if (card != noone && variable_struct_exists(card, "limited")) {
            var lim = real(card.limited);
            if (is_real(lim)) {
                if (lim < 1) lim = 1;
                if (lim > 3) lim = 3;
                maxCopies = lim;
                show_debug_message("### get_max_copies_for_card: limite depuis DB = " + string(maxCopies) + " pour '" + string(cardName) + "'");
            }
        }
    }
    return maxCopies;
}

/// @function add_selected_card_to_deck()
/// @description Ajoute la carte sélectionnée (par oCollectionCardDisplay) au deck en édition
function add_selected_card_to_deck() {
    // Cette fonction est appelée dans un contexte `with (oCollectionCardDisplay)`
    if (!variable_instance_exists(self, "selectedCard") || self.selectedCard == noone || !instance_exists(self.selectedCard)) {
        show_debug_message("### add_selected_card_to_deck: aucune carte sélectionnée");
        return false;
    }
    var cardName = variable_instance_exists(self.selectedCard, "name") ? self.selectedCard.name : "";
    if (cardName == "") {
        show_debug_message("### add_selected_card_to_deck: carte sans nom, opération ignorée");
        return false;
    }
    
    // Résoudre l'objectId via la base de données (pour chargement fiable)
    var object_id = "";
    var db = getDatabase();
    if (db != noone && instance_exists(db)) {
        var results = dbGetCardsByName(cardName);
        for (var i = 0; i < array_length(results); i++) {
            if (variable_struct_exists(results[i], "name") && results[i].name == cardName) {
                if (variable_struct_exists(results[i], "objectId")) {
                    object_id = results[i].objectId;
                }
                break;
            }
        }
    } else {
        show_debug_message("### add_selected_card_to_deck: base de données indisponible pour résoudre '" + cardName + "'");
    }
    
    // Si oDeckBuilder n'existe pas, l'ouvrir automatiquement
    if (!instance_exists(oDeckBuilder)) {
        show_debug_message("### add_selected_card_to_deck: oDeckBuilder introuvable, ouverture automatique...");
        
        // Chercher oDeckList pour ouvrir le deck builder
        var deck_list = instance_find(oDeckList, 0);
        if (instance_exists(deck_list)) {
            with (deck_list) {
                show_deck_builder = true;
                // Créer l'instance oDeckBuilder
                if (deck_builder_instance == noone || !instance_exists(deck_builder_instance)) {
                    var builder_x = x;
                    var builder_y = y + (sprite_get_height(sprInvisible) * image_yscale) + 10;
                    deck_builder_instance = instance_create_layer(builder_x, builder_y, "Instances", oDeckBuilder);
                    show_debug_message("### oDeckBuilder créé automatiquement pour l'ajout de carte");
                }
            }
        } else {
            // Fallback: créer oDeckBuilder directement si oDeckList n'existe pas
            var builder_x = room_width - 400;
            var builder_y = 100;
            instance_create_layer(builder_x, builder_y, "Instances", oDeckBuilder);
            show_debug_message("### oDeckBuilder créé en fallback pour l'ajout de carte");
        }
        
        // Vérifier à nouveau si oDeckBuilder existe maintenant
        if (!instance_exists(oDeckBuilder)) {
            show_debug_message("### add_selected_card_to_deck: impossible de créer oDeckBuilder");
            return false;
        }
    }
    var added_ok = false;
    with (oDeckBuilder) {
        if (!is_array(cards_list)) { cards_list = []; }

        // Déterminer la limite d'exemplaires (champ `limited` si présent, sinon 3)
        var MAX_COPIES = other.get_max_copies_for_card(cardName, object_id);
        
        // Compter les exemplaires déjà présents de cette carte
        var copies = 0;
        for (var i = 0; i < array_length(cards_list); i++) {
            var entry = cards_list[i];
            var entry_name = is_struct(entry) && variable_struct_exists(entry, "name") ? entry.name : string(entry);
            var entry_oid = is_struct(entry) && variable_struct_exists(entry, "objectId") ? entry.objectId : "";

            var same = false;
            if (object_id != "" && entry_oid != "") {
                same = (entry_oid == object_id);
            } else {
                same = (entry_name == cardName);
            }
            if (same) copies++;
        }

        if (copies >= MAX_COPIES) {
            show_debug_message("### DeckBuilder: limite atteinte (" + string(MAX_COPIES) + ") pour '" + cardName + "'. Ajout refusé.");
            if (variable_global_exists("debug_message")) {
                global.debug_message = "Limite de " + string(MAX_COPIES) + " exemplaires atteinte pour " + cardName;
                global.debug_timer = room_speed * 2;
            }
            other.added_ok = false;
        } else {
            // Sauvegarder en format struct si possible (name + objectId), sinon fallback en string
            if (object_id != "") {
                array_push(cards_list, { name: cardName, objectId: object_id });
            } else {
                array_push(cards_list, cardName);
            }
            if (is_undefined(current_slots)) current_slots = 1;
            // Tenter d'agrandir les slots si nécessaire (si la méthode existe)
            if (is_undefined(check_and_add_slot)) {
                // Pas de méthode locale, ajuster les dimensions minimales
                current_slots = min(max_cards, max(current_slots, array_length(cards_list)));
            } else {
                check_and_add_slot();
            }
            show_debug_message("### DeckBuilder: carte ajoutée -> " + cardName + (object_id != "" ? " (" + object_id + ")" : "") + ", total=" + string(array_length(cards_list)));
            other.added_ok = true;
        }
    }
    return added_ok;
}

/// @function remove_selected_card_from_deck()
/// @description Retire une occurrence de la carte sélectionnée du deck en édition
function remove_selected_card_from_deck() {
    // Cette fonction est appelée dans un contexte `with (oCollectionCardDisplay)`
    if (!variable_instance_exists(self, "selectedCard") || self.selectedCard == noone || !instance_exists(self.selectedCard)) {
        show_debug_message("### remove_selected_card_from_deck: aucune carte sélectionnée");
        return false;
    }
    var cardName = variable_instance_exists(self.selectedCard, "name") ? self.selectedCard.name : "";
    if (cardName == "") {
        show_debug_message("### remove_selected_card_from_deck: carte sans nom, opération ignorée");
        return false;
    }
    if (!instance_exists(oDeckBuilder)) {
        show_debug_message("### remove_selected_card_from_deck: oDeckBuilder introuvable");
        return false;
    }
    var removed = false;
    with (oDeckBuilder) {
        if (!is_array(cards_list)) { cards_list = []; }
        for (var i = 0; i < array_length(cards_list); i++) {
            var entry = cards_list[i];
            var entry_name = is_struct(entry) && variable_struct_exists(entry, "name") ? entry.name : string(entry);
            if (entry_name == cardName) {
                array_delete(cards_list, i, 1);
                removed = true;
                show_debug_message("### DeckBuilder: carte retirée -> " + cardName + ", total=" + string(array_length(cards_list)));
                break;
            }
        }
    }
    if (!removed) {
        show_debug_message("### remove_selected_card_from_deck: carte non trouvée dans le deck -> " + cardName);
        return false;
    }
    return true;
}

/// @function toggle_favorite_selected_card()
/// @description Bascule l’état favori de la carte sélectionnée et persiste
function toggle_favorite_selected_card() {
    if (!variable_instance_exists(self, "selectedCard") || self.selectedCard == noone || !instance_exists(self.selectedCard)) {
        show_debug_message("### toggle_favorite_selected_card: aucune carte sélectionnée");
        return false;
    }
    var cardName = variable_instance_exists(self.selectedCard, "name") ? self.selectedCard.name : "";
    if (cardName == "") {
        show_debug_message("### toggle_favorite_selected_card: carte sans nom, opération ignorée");
        return false;
    }
    if (is_card_favorite(cardName)) {
        var ok = remove_card_from_favorites(cardName);
        if (ok) show_debug_message("### Favori retiré: " + cardName);
        return ok;
    } else {
        var ok2 = add_card_to_favorites(cardName);
        if (ok2) show_debug_message("### Favori ajouté: " + cardName);
        return ok2;
    }
}
}