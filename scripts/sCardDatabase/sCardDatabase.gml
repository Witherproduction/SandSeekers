// === Script utilitaire pour la base de données des cartes ===

// Fonction pour obtenir l'instance de la base de données
function getDatabase() {
    var db = instance_find(oDataBase, 0);
    if (db == noone) {
        show_debug_message("ERREUR: oDataBase non trouvé!");
        return noone;
    }
    return db;
}

// Fonction globale pour ajouter une carte
function dbAddCard(cardId, cardData) {
    var db = getDatabase();
    if (db != noone && instance_exists(db)) {
        db.addCard(cardId, cardData);
    }
}

// Fonction globale pour récupérer une carte
function dbGetCard(cardId) {
    var db = getDatabase();
    if (db != noone && instance_exists(db)) {
        return db.getCard(cardId);
    }
    return undefined;
}

// Fonction globale pour rechercher par type
function dbGetCardsByType(cardType) {
    var db = getDatabase();
    if (db != noone && instance_exists(db)) {
        return db.getCardsByType(cardType);
    }
    return [];
}

// Fonction globale pour rechercher par nom
function dbGetCardsByName(searchName) {
    var db = getDatabase();
    if (db != noone && instance_exists(db)) {
        return db.getCardsByName(searchName);
    }
    return [];
}

// Fonction globale pour obtenir toutes les cartes
function dbGetAllCards() {
    var db = getDatabase();
    if (db != noone && instance_exists(db)) {
        return db.getAllCards();
    }
    show_debug_message("### dbGetAllCards: Base de données non disponible");
    return [];
}

// Fonction de debug pour afficher toutes les données stockées
function dbShowAllData() {
    var db = getDatabase();
    if (db == noone || !instance_exists(db)) {
        show_debug_message("ERREUR: Base de données non trouvée!");
        return;
    }
    
    show_debug_message("=== CONTENU DE LA BASE DE DONNÉES ===");
    
    var keys = variable_struct_get_names(db.cardDatabase);
    var totalCards = array_length(keys);
    
    show_debug_message("Nombre total de cartes: " + string(totalCards));
    show_debug_message("===========================================");
    
    for (var i = 0; i < totalCards; i++) {
        var cardId = keys[i];
        var card = db.cardDatabase[$ cardId];
        
        show_debug_message("[" + string(i+1) + "/" + string(totalCards) + "] ID: " + cardId);
        show_debug_message("  Nom: " + card.name);
        show_debug_message("  Type: " + card.type);
        
        if (card.type == "Monster") {
            show_debug_message("  ATK: " + string(card.attack) + " / DEF: " + string(card.defense));
            show_debug_message("  Étoiles: " + string(card.star));
        }
        
        show_debug_message("  Description: " + card.description);
        show_debug_message("  Sprite: " + card.sprite);
        show_debug_message("  Objet: " + card.objectId);
        show_debug_message("-------------------------------------------");
    }
    
    show_debug_message("=== FIN DU CONTENU ===");
}

// Fonction pour compter les cartes par type
function dbCountCardsByType() {
    var db = getDatabase();
    if (db == noone || !instance_exists(db)) {
        show_debug_message("ERREUR: Base de données non trouvée!");
        return;
    }
    
    var keys = variable_struct_get_names(db.cardDatabase);
    var monsterCount = 0;
    var magicCount = 0;
    var trapCount = 0;
    var otherCount = 0;
    
    for (var i = 0; i < array_length(keys); i++) {
        var card = db.cardDatabase[$ keys[i]];
        switch(card.type) {
            case "Monster":
                monsterCount++;
                break;
            case "Magic":
                magicCount++;
                break;
            case "Trap":
                trapCount++;
                break;
            default:
                otherCount++;
                break;
        }
    }
    
    show_debug_message("=== STATISTIQUES DE LA BASE ===");
    show_debug_message("Cartes Monstre: " + string(monsterCount));
    show_debug_message("Cartes Magie: " + string(magicCount));
    show_debug_message("Cartes Piège: " + string(trapCount));
    show_debug_message("Autres: " + string(otherCount));
    show_debug_message("Total: " + string(monsterCount + magicCount + trapCount + otherCount));
    show_debug_message("===============================");
}

// Fonction globale pour obtenir toutes les cartes (correction)
function dbGetAllCardsFixed() {
    var db = getDatabase();
    if (db != noone && instance_exists(db)) {
        return db.getAllCards();
    }
    return [];
}

// Fonction pour afficher toutes les cartes (debug)
function dbShowAllCards() {
    var cards = dbGetAllCards();
    show_debug_message("=== Liste de toutes les cartes ===");
    
    for (var i = 0; i < array_length(cards); i++) {
        var card = cards[i];
        show_debug_message("ID: " + card.id + " | Nom: " + card.name + " | Type: " + card.type);
        
        if (card.type == "Monster") {
            show_debug_message("  ATK: " + string(card.attack) + " | DEF: " + string(card.defense) + " | Étoiles: " + string(card.star));
        }
        
        show_debug_message("  Description: " + card.description);
        show_debug_message("  Sprite: " + card.sprite + " | Objet: " + card.objectId);
        show_debug_message("---");
    }
    
    show_debug_message("Total: " + string(array_length(cards)) + " cartes");
}

// Fonction pour sauvegarder la base de données
function dbSaveToFile(filename) {
    var db = getDatabase();
    if (db != noone && instance_exists(db)) {
        var json_string = json_stringify(db.cardDatabase);
        var file = file_text_open_write(filename);
        file_text_write_string(file, json_string);
        file_text_close(file);
        show_debug_message("Base de données sauvegardée dans: " + filename);
        return true;
    }
    return false;
}

// Fonction pour charger la base de données
function dbLoadFromFile(filename) {
    if (file_exists(filename)) {
        var file = file_text_open_read(filename);
        var json_string = file_text_read_string(file);
        file_text_close(file);
        
        var db = getDatabase();
        if (db != noone && instance_exists(db)) {
            try {
                db.cardDatabase = json_parse(json_string);
                show_debug_message("Base de données chargée depuis: " + filename);
                return true;
            } catch (e) {
                show_debug_message("ERREUR lors du chargement: " + string(e));
            }
        }
    } else {
        show_debug_message("Fichier non trouvé: " + filename);
    }
    return false;
}

// === SYSTÈME DE RARETÉ ===

// Fonction pour obtenir la couleur d'une rareté
function getRarityColor(rarity) {
    switch(rarity) {
        case "commun":
            return c_gray;      // Gris pour commun
        case "rare":
            return c_blue;      // Bleu pour rare
        case "epique":
            return c_purple;    // Violet pour épique
        case "legendaire":
            return c_orange;    // Orange pour légendaire
        default:
            return c_white;     // Blanc par défaut
    }
}

// Fonction pour obtenir le nom affiché d'une rareté
function getRarityDisplayName(rarity) {
    switch(rarity) {
        case "commun":
            return "Commun";
        case "rare":
            return "Rare";
        case "epique":
            return "Épique";
        case "legendaire":
            return "Légendaire";
        default:
            return "Inconnue";
    }
}

// Fonction pour obtenir l'intensité de l'effet visuel selon la rareté
function getRarityGlowIntensity(rarity) {
    switch(rarity) {
        case "commun":
            return 0.3;         // Faible lueur
        case "rare":
            return 0.5;         // Lueur moyenne
        case "epique":
            return 0.7;         // Forte lueur
        case "legendaire":
            return 1.0;         // Lueur maximale
        default:
            return 0.0;         // Pas de lueur
    }
}

// Fonction pour rechercher par rareté
function dbGetCardsByRarity(rarity) {
    var db = getDatabase();
    if (db != noone && instance_exists(db)) {
        return db.getCardsByRarity(rarity);
    }
    return [];
}

// === GESTION DES CARTES DE TEST ===

// Fonction pour supprimer une carte de la base de données
function dbRemoveCard(cardId) {
    var db = getDatabase();
    if (db != noone && instance_exists(db)) {
        if (variable_struct_exists(db.cardDatabase, cardId)) {
            variable_struct_remove(db.cardDatabase, cardId);
            show_debug_message("Carte supprimée: " + cardId);
            return true;
        } else {
            show_debug_message("Carte non trouvée pour suppression: " + cardId);
            return false;
        }
    }
    return false;
}

// Fonction pour supprimer toutes les cartes de test
function dbRemoveTestCards() {
    show_debug_message("=== Suppression des cartes de test ===");
    
    // Liste des IDs des cartes de test à supprimer
    var testCardIds = [
        
    ];
    
    var removedCount = 0;
    
    for (var i = 0; i < array_length(testCardIds); i++) {
        if (dbRemoveCard(testCardIds[i])) {
            removedCount++;
        }
    }
    
    show_debug_message("Cartes de test supprimées: " + string(removedCount) + "/" + string(array_length(testCardIds)));
    show_debug_message("=== Fin de suppression des cartes de test ===");
    
    return removedCount;
}

// Fonction pour vérifier si des cartes de test existent encore
function dbCheckForTestCards() {
    var testCardIds = [
        
    ];
    
    var foundTestCards = [];
    
    for (var i = 0; i < array_length(testCardIds); i++) {
        if (dbGetCard(testCardIds[i]) != undefined) {
            array_push(foundTestCards, testCardIds[i]);
        }
    }
    
    if (array_length(foundTestCards) > 0) {
        show_debug_message("Cartes de test encore présentes: " + string(array_length(foundTestCards)));
        for (var i = 0; i < array_length(foundTestCards); i++) {
            show_debug_message("  - " + foundTestCards[i]);
        }
        return foundTestCards;
    } else {
        show_debug_message("Aucune carte de test trouvée dans la base de données");
        return [];
    }
}

// === FONCTIONS POUR CARTES PERSONNALISÉES ===

/// @function create_custom_monster_card(card_id, name, attack, defense, star, description, sprite, object_id, rarity, genre, archetype, booster)
/// @description Crée et sauvegarde une nouvelle carte monstre personnalisée
function create_custom_monster_card(card_id, name, attack, defense, star, description, sprite, object_id, rarity, genre, archetype, booster) {
    var card_data = {
        id: card_id,
        name: name,
        type: "Monster",
        attack: attack,
        defense: defense,
        star: star,
        description: description,
        sprite: sprite,
        objectId: object_id,
        rarity: rarity,
        genre: genre,
        archetype: archetype,
        booster: booster
    };
    
    return add_card_and_save(card_id, card_data);
}

/// @function create_custom_magic_card(card_id, name, description, sprite, object_id, rarity, genre, archetype, booster)
/// @description Crée et sauvegarde une nouvelle carte magique personnalisée
function create_custom_magic_card(card_id, name, description, sprite, object_id, rarity, genre, archetype, booster) {
    var card_data = {
        id: card_id,
        name: name,
        type: "Magic",
        attack: 0,
        defense: 0,
        star: 0,
        description: description,
        sprite: sprite,
        objectId: object_id,
        rarity: rarity,
        genre: genre,
        archetype: archetype,
        booster: booster
    };
    
    return add_card_and_save(card_id, card_data);
}

/// @function example_add_custom_cards()
/// @description Fonction d'exemple pour ajouter des cartes personnalisées
/// Appelez cette fonction depuis n'importe où dans le jeu pour ajouter vos cartes
function example_add_custom_cards() {
    show_debug_message("=== Ajout de cartes personnalisées d'exemple ===");
}    