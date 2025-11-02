// === oCardViewer - Step Event ===

// Bloquer toute logique du viewer si le panneau d'options est ouvert
if (instance_exists(oPanelOptions)) {
    exit;
}

// Garder le dernier mode de tri et filtre booster
if (!variable_instance_exists(id, "lastSortMode")) {
    lastSortMode = "none";
}
if (!variable_instance_exists(id, "lastBoosterFilter")) {
    lastBoosterFilter = "Tout"; // par défaut
}

// Défilement dans la room rCollection uniquement
if (room == rCollection) {
    handleScroll();
}

// Chargement des cartes au premier run et application du filtre booster + tri par défaut
if (!cardsLoaded) {
    cardsLoaded = true;
    allCards = dbGetAllCards();

    // Tri par défaut A→Z si aucun mode défini ou si "none"
    if (!variable_global_exists("sort_mode") || global.sort_mode == "none") {
        global.sort_mode = "alpha";
        global.sort_descending = false;
    }

    // appliquer filtre booster immédiat puis tri courant
    applyBoosterFilterNow();
    sortCards(global.sort_mode);
}

// Réagir aux changements de filtre booster global
if (variable_global_exists("collection_booster_filter")) {
    if (global.collection_booster_filter != lastBoosterFilter) {
        lastBoosterFilter = global.collection_booster_filter;
        applyBoosterFilterNow();
        // préserve ou applique le tri par défaut
        if (!variable_global_exists("sort_mode") || global.sort_mode == "none") {
            global.sort_mode = "alpha";
            global.sort_descending = false;
        }
        sortCards(global.sort_mode);
    }
}

// Réagir aux changements de mode de tri global
if (variable_global_exists("sort_mode")) {
    if (global.sort_mode != lastSortMode) {
        lastSortMode = global.sort_mode;
        sortCards(global.sort_mode);
    }
}

// Si une carte a été sélectionnée via un autre événement, la traiter
if (variable_instance_exists(id, "pending_select_card") && pending_select_card != noone) {
    with (oCollectionCardDisplay) {
        select_card_instance(other.pending_select_card);
    }
    pending_select_card = noone;
}

// Consommer la sélection différée après changement de room depuis oDeckBuilder
if (variable_global_exists("pending_card_selection") && global.pending_card_selection != "") {
    var cardName = global.pending_card_selection;

    // Garantir que les cartes sont affichées et visibles (filtre "Tout")
    global.collection_booster_filter = "Tout";
    applyBoosterFilterNow();
    if (!variable_global_exists("sort_mode") || global.sort_mode == "none") {
        global.sort_mode = "alpha";
        global.sort_descending = false;
    }

    // Trouver l'index de la carte dans filteredCards
    var targetIndex = -1;
    for (var i = 0; i < array_length(filteredCards); i++) {
        var c = filteredCards[i];
        if (variable_struct_exists(c, "name") && string(c.name) == cardName) {
            targetIndex = i;
            break;
        }
    }

    if (targetIndex != -1) {
        // Aller à la page qui contient la carte
        var targetPage = floor(targetIndex / cardsPerPage) + 1;
        gotoPage(targetPage);

        // Récupérer l'instance réelle correspondante sur la page
        var start_index = (currentPage - 1) * cardsPerPage;
        var localIndex = targetIndex - start_index;
        if (localIndex >= 0 && localIndex < array_length(cardInstances)) {
            var inst = cardInstances[localIndex];
            if (instance_exists(inst)) {
                pending_select_card = inst; // Utiliser l'instance réelle
            }
        }
    } else {
        show_debug_message("[WARN] pending_card_selection: carte introuvable dans filteredCards -> " + string(cardName));
    }

    // Réinitialiser la sélection différée globale
    global.pending_card_selection = "";
}

// Rafraîchir l'affichage manuellement avec 'R' : recharge, filtre, tri, et réaffiche
if (keyboard_check_pressed(ord("R"))) {
    allCards = dbGetAllCards();
    applyBoosterFilterNow();
    if (!variable_global_exists("sort_mode") || global.sort_mode == "none") {
        global.sort_mode = "alpha";
        global.sort_descending = false;
    }
    sortCards(global.sort_mode);
}