/// === sSearchUtils ===
/// Fonctions de recherche de cartes unifiées avec priorité.

/// @function _cardMatchesCriteria(card, criteria) -> bool
/// @description Vérifie si une carte (instance ou struct) correspond aux critères.
function _cardMatchesCriteria(card, criteria) {
    var card_data = is_struct(card) ? card : (instance_exists(card) ? card : noone);
    if (card_data == noone) return false;

    if (variable_struct_exists(criteria, "name")) {
        var name_to_check = is_struct(card_data) ? (variable_struct_exists(card_data, "name") ? card_data.name : "") : (variable_instance_exists(card_data, "name") ? card_data.name : "");
        if (name_to_check != criteria.name) return false;
    }
    if (variable_struct_exists(criteria, "archetype")) {
        var archetype_to_check = is_struct(card_data) ? (variable_struct_exists(card_data, "archetype") ? card_data.archetype : "") : (variable_instance_exists(card_data, "archetype") ? card_data.archetype : "");
        if (archetype_to_check != criteria.archetype) return false;
    }
    if (variable_struct_exists(criteria, "object_name")) {
        var object_index_to_check = is_struct(card_data) ? (variable_struct_exists(card_data, "object_index") ? card_data.object_index : noone) : (instance_exists(card_data) ? card_data.object_index : noone);
        if (object_index_to_check == noone || object_get_name(object_index_to_check) != criteria.object_name) return false;
    }
    

    if (variable_struct_exists(criteria, "type")) {
        var type_to_check = is_struct(card_data)
            ? (variable_struct_exists(card_data, "cardType") ? card_data.cardType : (variable_struct_exists(card_data, "type") ? card_data.type : ""))
            : (variable_instance_exists(card_data, "type") ? card_data.type : "");
        if (string_lower(type_to_check) != string_lower(criteria.type)) return false;
    }
    if (variable_struct_exists(criteria, "genre")) {
        var genre_to_check = is_struct(card_data)
            ? (variable_struct_exists(card_data, "genre") ? card_data.genre : "")
            : (variable_instance_exists(card_data, "genre") ? card_data.genre : "");
        if (string_lower(genre_to_check) != string_lower(criteria.genre)) return false;
    }

    // Nouveau critère: star_eq (niveau exact)
    if (variable_struct_exists(criteria, "star_eq")) {
        var star_to_check = is_struct(card_data)
            ? (variable_struct_exists(card_data, "star") ? card_data.star : -1)
            : (variable_instance_exists(card_data, "star") ? card_data.star : -1);
        if (star_to_check != criteria.star_eq) return false;
    }

    // Ajouter d'autres vérifications de critères ici (type, attribut, etc.)
    return true;
}

/// @function _findInDeck(ownerIsHero, criteria) -> { card, index }
function _findInDeck(ownerIsHero, criteria) {
    var deck = ownerIsHero ? deckHero : deckEnemy;
    if (instance_exists(deck) && ds_list_size(deck.cards) > 0) {
        for (var i = 0; i < ds_list_size(deck.cards); i++) {
            var card = ds_list_find_value(deck.cards, i);
            if (instance_exists(card) && _cardMatchesCriteria(card, criteria)) {
                return { card: card, index: i };
            }
        }
    }
    return noone;
}

/// @function _findAllInSource(ownerIsHero, source, criteria) -> array
/// @description Trouve toutes les cartes correspondant aux critères dans une source donnée.
function _findAllInSource(ownerIsHero, source, criteria) {
    var matches = [];
    
    switch (source) {
        case "Deck":
            var deck = ownerIsHero ? deckHero : deckEnemy;
            if (instance_exists(deck) && ds_list_size(deck.cards) > 0) {
                for (var i = 0; i < ds_list_size(deck.cards); i++) {
                    var card = ds_list_find_value(deck.cards, i);
                    if (instance_exists(card) && _cardMatchesCriteria(card, criteria)) {
                        array_push(matches, { card: card, index: i });
                    }
                }
            }
            break;
            
        case "Graveyard":
            var graveyard = ownerIsHero ? graveyardHero : graveyardEnemy;
            if (instance_exists(graveyard) && variable_instance_exists(graveyard, "cards")) {
                var garr = graveyard.cards;
                for (var i = 0; i < array_length(garr); i++) {
                    var gdata = garr[i];
                    if (gdata != noone && _cardMatchesCriteria(gdata, criteria)) {
                        array_push(matches, { card: gdata, index: i });
                    }
                }
            }
            break;
            
        case "Hand":
            var hand = ownerIsHero ? handHero : handEnemy;
            if (instance_exists(hand) && ds_list_size(hand.cards) > 0) {
                for (var i = 0; i < ds_list_size(hand.cards); i++) {
                    var card = ds_list_find_value(hand.cards, i);
                    if (instance_exists(card) && _cardMatchesCriteria(card, criteria)) {
                        array_push(matches, { card: card, index: i });
                    }
                }
            }
            break;
            
        case "Field":
            var fieldMgr = ownerIsHero ? fieldManagerHero : fieldManagerEnemy;
            if (instance_exists(fieldMgr)) {
                var monsterField = fieldMgr.getField("Monster");
                for (var i = 0; i < array_length(monsterField.cards); i++) {
                    var card = monsterField.cards[i];
                    if (card != 0 && instance_exists(card) && _cardMatchesCriteria(card, criteria)) {
                        array_push(matches, { card: card, pos: i, zone_type: "Monster" });
                    }
                }
                
                var magicField = fieldMgr.getField("MagicTrap");
                for (var i = 0; i < array_length(magicField.cards); i++) {
                    var card = magicField.cards[i];
                    if (card != 0 && instance_exists(card) && _cardMatchesCriteria(card, criteria)) {
                        array_push(matches, { card: card, pos: i, zone_type: "MagicTrap" });
                    }
                }
            }
            break;
    }
    
    return matches;
}

/// @function _transferSelectedCards(ownerIsHero, selectedData, destination, shuffleAfter, initiatorCard, effect) -> bool
/// @description Transfère les cartes sélectionnées vers leur destination.
function _transferSelectedCards(ownerIsHero, selectedData, destination, shuffleAfter, initiatorCard, effect) {
    var handInst = ownerIsHero ? handHero : handEnemy;
    var deckInst = ownerIsHero ? deckHero : deckEnemy;
    var gyInst = ownerIsHero ? graveyardHero : graveyardEnemy;
    
    // Trier les indices par ordre décroissant pour éviter les problèmes lors de la suppression
    var indicesToRemove = [];
    for (var i = 0; i < array_length(selectedData); i++) {
        var data = selectedData[i];
        if (variable_struct_exists(data.data, "index")) {
            array_push(indicesToRemove, { source: data.source, index: data.data.index });
        }
    }
    
    // Traiter chaque carte sélectionnée
    for (var i = 0; i < array_length(selectedData); i++) {
        var data = selectedData[i];
        var card = data.card;
        var source = data.source;
        
        // Retirer de la source
        switch (source) {
            case "Deck":
                if (instance_exists(deckInst) && variable_struct_exists(data.data, "index")) {
                    ds_list_delete(deckInst.cards, data.data.index);
                }
                break;
                
            case "Graveyard":
                if (instance_exists(gyInst) && variable_struct_exists(data.data, "index")) {
                    array_delete(gyInst.cards, data.data.index, 1);
                    registerTriggerEvent(TRIGGER_LEAVE_GRAVEYARD, card, { owner_is_hero: ownerIsHero });
                }
                break;
                
            case "Hand":
                if (instance_exists(handInst) && variable_struct_exists(data.data, "index")) {
                    ds_list_delete(handInst.cards, data.data.index);
                }
                break;
                
            case "Field":
                var fieldMgr = ownerIsHero ? fieldManagerHero : fieldManagerEnemy;
                if (instance_exists(fieldMgr) && variable_struct_exists(data.data, "pos") && variable_struct_exists(data.data, "zone_type")) {
                    var field = fieldMgr.getField(data.data.zone_type);
                    field.cards[data.data.pos] = 0;
                }
                break;
        }
        
        // Ajouter à la destination
        switch (string_lower(destination)) {
            case "hand":
                if (instance_exists(handInst)) {
                    handInst.addCard(card);
                    var ctx = { owner_is_hero: ownerIsHero };
                    if (source == "Deck") ctx.from_deck = deckInst;
                    else if (source == "Graveyard") ctx.from_graveyard = gyInst;
                    if (instance_exists(initiatorCard)) ctx.initiator_card_id = initiatorCard.id;
                    if (variable_struct_exists(effect, "id")) ctx.source_effect_id = effect.id;
                    registerTriggerEvent(TRIGGER_ENTER_HAND, card, ctx);
                    if (variable_instance_exists(card, "zone")) card.zone = "Hand";
                }
                break;
                
            case "deck":
                if (instance_exists(deckInst)) {
                    ds_list_add(deckInst.cards, card);
                    if (variable_instance_exists(card, "zone")) card.zone = "Deck";
                }
                break;
                
            case "graveyard":
                if (instance_exists(gyInst)) {
                    gyInst.addToGraveyard(card);
                    if (variable_instance_exists(card, "zone")) card.zone = "Graveyard";
                }
                break;
                
            default:
                show_debug_message("### Destination inconnue: " + string(destination));
                return false;
        }
    }
    
    // Mélanger le deck si nécessaire
    if (string_lower(destination) == "deck" && shuffleAfter && instance_exists(deckInst)) {
        if (is_undefined(shuffleDeck)) {
            ds_list_shuffle(deckInst.cards);
        } else {
            shuffleDeck(deckInst);
        }
    }
    
    return true;
}

/// @function applySearchBySpec(card, effect, context) -> bool
/// @description Exécuteur générique de recherche unifiant toutes les zones sources et destinations.
function applySearchBySpec(card, effect, context) {
    if (card == noone || !instance_exists(card)) return false;
    var ownerIsHero = (variable_instance_exists(card, "isHeroOwner") && card.isHeroOwner);
    
    // Paramètres de recherche
    var searchSources = ["Deck"]; // Par défaut: chercher dans le deck
    if (variable_struct_exists(effect, "search_sources")) searchSources = effect.search_sources;
    else if (variable_struct_exists(effect, "source_zone")) searchSources = [effect.source_zone];
    
    var destination = "Hand"; // Par défaut: ajouter à la main
    if (variable_struct_exists(effect, "destination")) destination = effect.destination;
    
    var maxTargets = 1; // Par défaut: une seule carte
    if (variable_struct_exists(effect, "max_targets")) maxTargets = effect.max_targets;
    else if (variable_struct_exists(effect, "value")) maxTargets = effect.value;
    
    var randomSelect = false;
    if (variable_struct_exists(effect, "random_select")) randomSelect = effect.random_select;
    
    var shuffleAfter = false;
    if (variable_struct_exists(effect, "shuffle_deck")) shuffleAfter = effect.shuffle_deck;
    
    // Garde propriétaire: si déclenché à la fin du tour, n'activer que au tour du propriétaire
    if (variable_struct_exists(effect, "trigger") && effect.trigger == TRIGGER_END_TURN) {
        var gm = instance_find(oGame, 0);
        var activeIsHero = true;
        if (gm != noone && variable_instance_exists(gm, "player") && variable_instance_exists(gm, "player_current")) {
            activeIsHero = (gm.player[gm.player_current] == "Hero");
        }
        if ((ownerIsHero && !activeIsHero) || (!ownerIsHero && activeIsHero)) {
            return false;
        }
    }
    
    // Construire les critères de recherche
    var criteria = {};
    if (variable_struct_exists(effect, "search_criteria")) criteria = effect.search_criteria;
    
    // Compatibilité avec l'ancienne API
    if (variable_struct_exists(effect, "search_archetype")) criteria.archetype = effect.search_archetype;
    if (variable_struct_exists(effect, "search_name")) criteria.name = effect.search_name;
    if (variable_struct_exists(effect, "search_type")) criteria.type = effect.search_type;
    if (variable_struct_exists(effect, "search_genre")) criteria.genre = effect.search_genre;
    
    // Rechercher dans toutes les sources autorisées
    var allMatches = [];
    var allMatchData = [];
    
    for (var s = 0; s < array_length(searchSources); s++) {
        var source = searchSources[s];
        var matches = _findAllInSource(ownerIsHero, source, criteria);
        
        for (var m = 0; m < array_length(matches); m++) {
            array_push(allMatches, matches[m].card);
            array_push(allMatchData, { card: matches[m].card, source: source, data: matches[m] });
        }
    }
    
    if (array_length(allMatches) == 0) {
        show_debug_message("### Aucun résultat pour EFFECT_SEARCH dans les sources: " + string(searchSources));
        return false;
    }
    
    // Sélectionner les cartes à transférer
    var numToSelect = min(maxTargets, array_length(allMatches));
    var selectedData = [];
    
    if (randomSelect) {
        // Sélection aléatoire sans remise
        var available = array_create(array_length(allMatchData));
        for (var i = 0; i < array_length(allMatchData); i++) {
            available[i] = allMatchData[i];
        }
        
        for (var sel = 0; sel < numToSelect; sel++) {
            var r = irandom(array_length(available) - 1);
            array_push(selectedData, available[r]);
            array_delete(available, r, 1);
        }
    } else {
        // Sélection séquentielle (premier trouvé)
        for (var sel = 0; sel < numToSelect; sel++) {
            array_push(selectedData, allMatchData[sel]);
        }
    }
    
    // Transférer les cartes sélectionnées
    return _transferSelectedCards(ownerIsHero, selectedData, destination, shuffleAfter, card, effect);
}

function _findInGraveyard(ownerIsHero, criteria) {
    var graveyard = ownerIsHero ? graveyardHero : graveyardEnemy;
    if (instance_exists(graveyard) && variable_instance_exists(graveyard, "cards")) {
        var garr = graveyard.cards;
        for (var i = array_length(garr) - 1; i >= 0; i--) {
            var gdata = garr[i];
            if (gdata != noone && _cardMatchesCriteria(gdata, criteria)) {
                return { card: gdata, index: i };
            }
        }
    }
    return noone;
}

/// @function _findInHand(ownerIsHero, criteria) -> { card, index }
function _findInHand(ownerIsHero, criteria) {
    var hand = ownerIsHero ? handHero : handEnemy;
    if (instance_exists(hand) && ds_list_size(hand.cards) > 0) {
        for (var i = 0; i < ds_list_size(hand.cards); i++) {
            var card = ds_list_find_value(hand.cards, i);
            if (instance_exists(card) && _cardMatchesCriteria(card, criteria)) {
                return { card: card, index: i };
            }
        }
    }
    return noone;
}

/// @function _findInField(ownerIsHero, criteria) -> { card, pos, zone_type }
function _findInField(ownerIsHero, criteria) {
    var fieldMgr = ownerIsHero ? fieldManagerHero : fieldManagerEnemy;
    if (!instance_exists(fieldMgr)) return noone;

    var monsterField = fieldMgr.getField("Monster");
    for (var i = 0; i < array_length(monsterField.cards); i++) {
        var card = monsterField.cards[i];
        if (card != 0 && instance_exists(card) && _cardMatchesCriteria(card, criteria)) {
            return { card: card, pos: i, zone_type: "Monster" };
        }
    }

    var magicField = fieldMgr.getField("MagicTrap");
    for (var i = 0; i < array_length(magicField.cards); i++) {
        var card = magicField.cards[i];
        if (card != 0 && instance_exists(card) && _cardMatchesCriteria(card, criteria)) {
            return { card: card, pos: i, zone_type: "MagicTrap" };
        }
    }
    return noone;
}

/// @function findCard(ownerIsHero, criteria, allowedSources) -> { card, source, data }
/// @description Recherche une carte avec priorité Deck > Graveyard > Hand > Field.
function findCard(ownerIsHero, criteria, allowedSources) {
    if (allowedSources == undefined) {
        allowedSources = ["Deck", "Graveyard", "Hand", "Field"];
    }
    var sourcesToCheck = ["Deck", "Graveyard", "Hand", "Field"];

    for (var i = 0; i < array_length(sourcesToCheck); i++) {
        var source = sourcesToCheck[i];
        
        var sourceAllowed = false;
        for (var j = 0; j < array_length(allowedSources); j++) {
            if (allowedSources[j] == source) {
                sourceAllowed = true;
                break;
            }
        }
        if (!sourceAllowed) continue;

        var found = noone;
        switch (source) {
            case "Deck":      found = _findInDeck(ownerIsHero, criteria); break;
            case "Graveyard": found = _findInGraveyard(ownerIsHero, criteria); break;
            case "Hand":      found = _findInHand(ownerIsHero, criteria); break;
            case "Field":     found = _findInField(ownerIsHero, criteria); break;
        }

        if (found != noone) {
            return { card: found.card, source: source, data: found };
        }
    }
    return noone;
}