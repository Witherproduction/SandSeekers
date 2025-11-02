// === oCardViewer - Affichage des cartes de la collection ===
event_inherited(); // Heriter des variables du parent (oCardParent)
show_debug_message("### oCardViewer.create");

// Configuration du sprite invisible pour la detection des clics
show_debug_message("### oCardViewer: sprite_index = " + string(sprite_index));

// Zone d'affichage : 8 cartes par ligne * 120px d'espacement = 960px de largeur
// 4 lignes * 120px d'espacement = 480px de hauteur
var display_width = 8 * 120;  // 960px
var display_height = 4 * 120; // 480px
image_xscale = display_width / sprite_get_width(sprite_index);
image_yscale = display_height / sprite_get_height(sprite_index);

show_debug_message("### oCardViewer: Position (" + string(x) + ", " + string(y) + ") Taille (" + string(image_xscale) + ", " + string(image_yscale) + ")");

// Variables pour l'affichage
cardInstances = [];
cardsPerRow = 8;
cardSpacing = 120; // Espacement horizontal
cardSpacingVertical = 150; // Espacement vertical plus grand pour éviter le chevauchement
startX = 200; // Décalage de +50px vers la droite pour rCollection
startY = 300;
scrollY = 0;
maxScrollY = 0;
maxRows = 4; // Limite a 4 lignes

// Variables pour les cartes
allCards = [];
filteredCards = [];
currentFilter = ""; // Valeur par défaut pour éviter la lecture avant initialisation
cardsLoaded = false; // Initialisation de la variable manquante

// Pagination
currentPage = 1;
cardsPerPage = maxRows * cardsPerRow; // 32
totalPages = 1;

// Pipeline de sélection unifié: initialiser le canal
pending_select_card = noone;

// Fonction pour nettoyer l'affichage
function clearCardDisplay() {
    show_debug_message("### clearCardDisplay: nettoyage des instances existantes");
    for (var i = 0; i < array_length(cardInstances); i++) {
        if (cardInstances[i] != noone && instance_exists(cardInstances[i])) {
            instance_destroy(cardInstances[i]);
        }
    }
    cardInstances = [];
}

filteredCards = [];
allCards = [];

// === Menu déroulant (filtre booster) ===
dropdown_items = ["Tout", "Chemin perdu"];
dropdown_selected_index = 0;
dropdown_open = false;
dropdown_x = 40;
dropdown_y = 40;
dropdown_w = 220;
dropdown_h = 28;

if (!variable_global_exists("collection_booster_filter")) {
    global.collection_booster_filter = dropdown_items[dropdown_selected_index];
}
lastBoosterFilter = global.collection_booster_filter;

// Fonctions pagination
function updateTotalPages() {
    totalPages = max(1, ceil(array_length(filteredCards) / cardsPerPage));
    currentPage = clamp(currentPage, 1, totalPages);
}

function gotoPage(page_num) {
    currentPage = clamp(page_num, 1, totalPages);
    displayFilteredCards();
}

// Fonction pour appliquer le filtre booster immédiatement
function applyBoosterFilterNow() {
    var target = global.collection_booster_filter;
    var tmp = [];
    for (var i = 0; i < array_length(allCards); i++) {
        var c = allCards[i];
        if (target == "Tout") {
            array_push(tmp, c);
        } else if (variable_struct_exists(c, "booster") && string(c.booster) == "Chemin perdu") {
            array_push(tmp, c);
        }
    }
    filteredCards = tmp;
    updateTotalPages();
    gotoPage(1);
}

// Fonction pour appliquer un filtre
function applyFilter(filterText) {
    currentFilter = string_lower(filterText);
    
    // Si pas de filtre, afficher toutes les cartes
    if (currentFilter == "") {
        filteredCards = allCards;
    } else {
        // Filtrer les cartes selon le texte
        filteredCards = [];
        for (var i = 0; i < array_length(allCards); i++) {
            var card = allCards[i];
            var matches = false;
            
            // Verifier le nom
            if (string_pos(currentFilter, string_lower(card.name)) > 0) matches = true;
            
            // Verifier l'attaque (si existe)
            if (variable_struct_exists(card, "attack") && string_pos(currentFilter, string_lower(string(card.attack))) > 0) matches = true;
            
            // Verifier la defense (si existe)
            if (variable_struct_exists(card, "defense") && string_pos(currentFilter, string_lower(string(card.defense))) > 0) matches = true;
            
            // Verifier le type
            if (string_pos(currentFilter, string_lower(card.type)) > 0) matches = true;
            
            // Verifier la description
            if (string_pos(currentFilter, string_lower(card.description)) > 0) matches = true;
            
            // Verifier l'archetype (si existe)
            if (variable_struct_exists(card, "archetype") && string_pos(currentFilter, string_lower(card.archetype)) > 0) matches = true;
            
            // Verifier les etoiles (si existe)
            if (variable_struct_exists(card, "star") && string_pos(currentFilter, string_lower(string(card.star))) > 0) matches = true;
            
            // Verifier la rarete
            if (variable_struct_exists(card, "rarity") && string_pos(currentFilter, string_lower(card.rarity)) > 0) matches = true;
            
            if (matches) {
                array_push(filteredCards, card);
            }
        }
    }
    
    // Reafficher les cartes filtrees avec pagination
    updateTotalPages();
    gotoPage(1);
}

// Fonction pour afficher les cartes filtrees
function displayFilteredCards() {
    show_debug_message("### displayFilteredCards: Debut, " + string(array_length(filteredCards)) + " cartes a afficher");
    
    // Nettoie l'affichage actuel
    clearCardDisplay();
    
    // Déterminer la sous-liste pour la page courante
    var start_index = (currentPage - 1) * cardsPerPage;
    var end_index = min(start_index + cardsPerPage, array_length(filteredCards));
    var count = max(0, end_index - start_index);
    show_debug_message("### displayFilteredCards: Page " + string(currentPage) + ", cartes " + string(count));
    
    for (var i = 0; i < count; i++) {
        var card = filteredCards[start_index + i];
        var row = floor(i / cardsPerRow);
        var col = i % cardsPerRow;
        var posX = startX + (col * cardSpacing);
        var posY = startY + (row * cardSpacingVertical) + scrollY;
        
        // Créer une instance de l'objet original de la carte
        var cardObjectName = card.objectId;
        var cardObject = asset_get_index(cardObjectName);

        // Si l'objet n'existe pas, appliquer un fallback sûr pour éviter l'erreur -1
        if (cardObject == -1) {
            show_debug_message("### ERREUR: Objet introuvable: " + string(cardObjectName) + " pour la carte " + string(card.name));
            var typeLower = variable_struct_exists(card, "type") ? string_lower(string(card.type)) : "";
            if (typeLower == "magic") {
                cardObject = oCardMagic;
            } else if (typeLower == "monster") {
                cardObject = oCardMonster;
            } else {
                cardObject = oCardParent;
            }
        }

        // Créer l'instance uniquement si l'objet est valide
        var cardInstance = instance_create_layer(posX, posY, "Instances", cardObject);
        
        if (cardInstance != noone) {
            show_debug_message("### Carte creee: " + card.name + " a la position (" + string(posX) + ", " + string(posY) + ")");
            
            // Configure la carte avec les donnees de la base
            cardInstance.name = card.name;
            cardInstance.attack = (card.attack != undefined) ? card.attack : 0;
            cardInstance.defense = (card.defense != undefined) ? card.defense : 0;
            cardInstance.star = (card.star != undefined) ? card.star : 0;
            cardInstance.description = (card.description != undefined) ? card.description : "";
            cardInstance.rarity = (card.rarity != undefined) ? card.rarity : "commun";
            cardInstance.archetype = (card.archetype != undefined) ? card.archetype : (variable_instance_exists(cardInstance, "archetype") ? cardInstance.archetype : "");
            // Résoudre et valider le sprite; fallback si introuvable
            var sprIndex = asset_get_index(card.sprite);
            if (sprIndex != -1) {
                cardInstance.sprite_index = sprIndex;
            } else {
                show_debug_message("### WARN: Sprite introuvable: " + string(card.sprite) + ", fallback sprite par défaut");
                // Garder le sprite par défaut actuel de l'objet
            }
            cardInstance.image_index = 0;
            cardInstance.zone = "Collection";
            cardInstance.isHeroOwner = true;
            
            // Force l'orientation normale pour la collection
            cardInstance.image_angle = 0;
            cardInstance.orientation = "Attack";
            cardInstance.isFaceDown = false;
            
            // Echelle pour l'affichage collection
            cardInstance.image_xscale = 0.2;
            cardInstance.image_yscale = 0.2;
            
            // Variables d'affichage de base
            cardInstance.isHovered = false;
            
            // Ajoute a la liste des instances
            array_push(cardInstances, cardInstance);
        } else {
            show_debug_message("### ERREUR: Impossible de creer l'instance pour " + card.name);
        }
    }
    
    // Pas de scroll pour la pagination fixe sur 4 lignes
    scrollY = 0;
    maxScrollY = 0;
}

// Fonction pour trier les cartes
function sortCards(sortMode) {
    show_debug_message("### Tri des cartes par: " + sortMode + " (ordre " + (global.sort_descending ? "décroissant" : "croissant") + ")");
    
    switch(sortMode) {
        case "attack":
            array_sort(filteredCards, function(a, b) {
                var typeA = variable_struct_exists(a, "type") ? string_lower(string(a.type)) : "";
                var typeB = variable_struct_exists(b, "type") ? string_lower(string(b.type)) : "";
                var isMagicA = (typeA == "magic");
                var isMagicB = (typeB == "magic");
                // Magic toujours après les non-Magic
                if (isMagicA != isMagicB) return isMagicA ? 1 : -1;
                
                var attackA = variable_struct_exists(a, "attack") ? a.attack : 0;
                var attackB = variable_struct_exists(b, "attack") ? b.attack : 0;
                return global.sort_descending ? (attackB - attackA) : (attackA - attackB);
            });
            break;
            
        case "defense":
            array_sort(filteredCards, function(a, b) {
                var typeA = variable_struct_exists(a, "type") ? string_lower(string(a.type)) : "";
                var typeB = variable_struct_exists(b, "type") ? string_lower(string(b.type)) : "";
                var isMagicA = (typeA == "magic");
                var isMagicB = (typeB == "magic");
                if (isMagicA != isMagicB) return isMagicA ? 1 : -1;
                
                var defenseA = variable_struct_exists(a, "defense") ? a.defense : 0;
                var defenseB = variable_struct_exists(b, "defense") ? b.defense : 0;
                return global.sort_descending ? (defenseB - defenseA) : (defenseA - defenseB);
            });
            break;
            
        case "level":
            array_sort(filteredCards, function(a, b) {
                var typeA = variable_struct_exists(a, "type") ? string_lower(string(a.type)) : "";
                var typeB = variable_struct_exists(b, "type") ? string_lower(string(b.type)) : "";
                var isMagicA = (typeA == "magic");
                var isMagicB = (typeB == "magic");
                if (isMagicA != isMagicB) return isMagicA ? 1 : -1;
                
                var levelA = variable_struct_exists(a, "star") ? a.star : 0;
                var levelB = variable_struct_exists(b, "star") ? b.star : 0;
                return global.sort_descending ? (levelB - levelA) : (levelA - levelB);
            });
            break;
            
        case "type":
            array_sort(filteredCards, function(a, b) {
                var typeA = variable_struct_exists(a, "type") ? string(a.type) : "";
                var typeB = variable_struct_exists(b, "type") ? string(b.type) : "";
                if (typeA < typeB) return global.sort_descending ? 1 : -1;
                if (typeA > typeB) return global.sort_descending ? -1 : 1;
                return 0;
            });
            break;
            
        case "favorites":
            array_sort(filteredCards, function(a, b) {
                // Verifier si les cartes sont dans les favoris
                var cardNameA = variable_struct_exists(a, "name") ? string(a.name) : "";
                var cardNameB = variable_struct_exists(b, "name") ? string(b.name) : "";
                
                var isFavoriteA = is_card_favorite(cardNameA);
                var isFavoriteB = is_card_favorite(cardNameB);
                
                // Les favoris en premier ou en dernier selon l'ordre
                if (isFavoriteA && !isFavoriteB) return global.sort_descending ? -1 : 1;
                if (!isFavoriteA && isFavoriteB) return global.sort_descending ? 1 : -1;
                return 0;
            });
            break;
            
        case "rarity":
            array_sort(filteredCards, function(a, b) {
                // Definir l'ordre de rarete
                function getRarityOrder(rarity) {
                    switch(rarity) {
                        case "legendaire": return 4;
                        case "epique": return 3;
                        case "rare": return 2;
                        case "commun": return 1;
                        default: return 0;
                    }
                }
                
                var rarityA = variable_struct_exists(a, "rarity") ? string(a.rarity) : "commun";
                var rarityB = variable_struct_exists(b, "rarity") ? string(b.rarity) : "commun";
                
                var orderA = getRarityOrder(rarityA);
                var orderB = getRarityOrder(rarityB);
                
                return global.sort_descending ? (orderB - orderA) : (orderA - orderB);
            });
            break;
            
        case "alpha":
            array_sort(filteredCards, function(a, b) {
                // Tri alphabétique par nom de carte
                var nameA = variable_struct_exists(a, "name") ? string_lower(string(a.name)) : "";
                var nameB = variable_struct_exists(b, "name") ? string_lower(string(b.name)) : "";
                
                if (nameA < nameB) return global.sort_descending ? 1 : -1;
                if (nameA > nameB) return global.sort_descending ? -1 : 1;
                return 0;
            });
            break;
            
        default:
            // Pas de tri ou tri par defaut
            break;
    }
    
    // Reaffiche les cartes triees (garde la page courante)
    displayFilteredCards();
}

// Fonction utilitaire: sélectionner une carte par son nom dans l'affichage réel
function selectCardByName(cardName) {
    if (is_undefined(cardName) || cardName == "") { show_debug_message("### selectCardByName: nom vide"); return false; }

    // S'assurer que la base est chargée
    if (!cardsLoaded) {
        cardsLoaded = true;
        allCards = dbGetAllCards();
        if (!variable_global_exists("sort_mode") || global.sort_mode == "none") {
            global.sort_mode = "alpha";
            global.sort_descending = false;
        }
        applyBoosterFilterNow();
        sortCards(global.sort_mode);
    }

    // Forcer filtre "Tout" et tri alpha pour rendre la carte accessible
    global.collection_booster_filter = "Tout";
    applyBoosterFilterNow();
    if (!variable_global_exists("sort_mode") || global.sort_mode == "none") {
        global.sort_mode = "alpha";
        global.sort_descending = false;
    }
    sortCards(global.sort_mode);

    // Trouver l'index global dans filteredCards
    var targetIndex = -1;
    for (var i = 0; i < array_length(filteredCards); i++) {
        var c = filteredCards[i];
        if (variable_struct_exists(c, "name") && string(c.name) == cardName) { targetIndex = i; break; }
    }
    if (targetIndex == -1) { show_debug_message("### selectCardByName: carte introuvable -> " + string(cardName)); return false; }

    // Aller à la page correspondante et (ré)afficher
    var pageIndex = floor(targetIndex / cardsPerPage) + 1;
    gotoPage(pageIndex);

    // Index local dans la page et récupération de l'instance
    var indexOnPage = targetIndex - (pageIndex - 1) * cardsPerPage;
    var inst = noone;
    if (indexOnPage >= 0 && indexOnPage < array_length(cardInstances)) {
        inst = cardInstances[indexOnPage];
    }
    if (inst != noone && instance_exists(inst)) {
        pending_select_card = inst;
        show_debug_message("### selectCardByName: sélection programmée -> " + string(cardName) + " (page " + string(pageIndex) + ", index " + string(indexOnPage) + ")");
        return true;
    } else {
        show_debug_message("### selectCardByName: instance non trouvée sur la page");
        return false;
    }
}

// Fonction pour gérer le défilement des cartes
function handleScroll() {
    // Défilement avec la molette de la souris
    if (mouse_wheel_up()) {
        scrollY = max(0, scrollY - cardSpacingVertical);
        displayFilteredCards();
    }
    if (mouse_wheel_down()) {
        scrollY = min(maxScrollY, scrollY + cardSpacingVertical);
        displayFilteredCards();
    }
    
    // Défilement avec les flèches du clavier
    if (keyboard_check_pressed(vk_up)) {
        scrollY = max(0, scrollY - cardSpacingVertical);
        displayFilteredCards();
    }
    if (keyboard_check_pressed(vk_down)) {
        scrollY = min(maxScrollY, scrollY + cardSpacingVertical);
        displayFilteredCards();
    }
}

// Initialise l'affichage (sans filtre au debut)
// On attend que oDataBase soit pret avant d'afficher les cartes
show_debug_message("### oCardViewer: Avant verification oDataBase");
if (instance_exists(oDataBase)) {
    show_debug_message("### oCardViewer: oDataBase existe, recuperation des cartes...");
    // Initialiser la liste des cartes depuis la base
    allCards = dbGetAllCards();
    cardsLoaded = true;
    // Initialiser tri/ordre par défaut si nécessaire
    if (!variable_global_exists("sort_mode") || global.sort_mode == "none") {
        global.sort_mode = "alpha";
        global.sort_descending = false;
    }
    // Appliquer le filtre booster courant et trier, ce qui déclenche l'affichage
    applyBoosterFilterNow();
    sortCards(global.sort_mode);
    show_debug_message("### oCardViewer: Initialisation terminee avec succes! cartes=" + string(array_length(allCards)));
} else {
    show_debug_message("### oCardViewer: En attente de oDataBase...");
}