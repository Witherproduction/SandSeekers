// === Script de stockage des decks des bots ===
// Ce script contient tous les decks préconfigurés pour les bots

/// @function get_bot_deck_cards(deck_id)
/// @description Retourne le tableau de cartes pour un deck spécifique
/// @param {real} deck_id - L'ID du deck à récupérer
function get_bot_deck_cards(deck_id) {
    
    switch(deck_id) {
        case 1: // Bot 1 - Deck Rose noire (Archétype Rose noire)
            return [
                "oEruditDeLaRoseNoire", "oEruditDeLaRoseNoire", "oCorbeauDeLaRoseNoire", "oCorbeauDeLaRoseNoire", "oSquelettePossedeParLaRoseNoire", "oSquelettePossedeParLaRoseNoire",
                "oDragonnetBeniRoseNoire", "oDragonnetBeniRoseNoire", "oChevalierSqueletteReanimeParLaRose", "oChevalierSqueletteReanimeParLaRose", "oDragonSacreRoseNoire", "oDragonSacreRoseNoire",
                "oLacEnvahiParLaRoseNoire", "oLacEnvahiParLaRoseNoire", "oDragonCorrompuRoseNoire", "oDragonCorrompuRoseNoire", "oChevalDeLaRoseNoire", "oChevalDeLaRoseNoire",
                "oPetiteSorciereDeLaRoseNoire", "oPetiteSorciereDeLaRoseNoire", "oTreantDeLaRoseNoire", "oTreantDeLaRoseNoire", "oOmbreDeLaRoseNoire", "oOmbreDeLaRoseNoire",
                "oSorciereDeLaRoseNoire", "oSorciereDeLaRoseNoire", "oAraigneeDeLaRoseNoire", "oAraigneeDeLaRoseNoire", "oPetaleDeLaRoseNoire", "oPetaleDeLaRoseNoire",
                // Ajout de sorts thématiques Rose noire pour atteindre 40 cartes
                "oRoseNoire", "oBrumeRoseNoire", "oMaledictionRoseNoire", "oFloraisonRosePerdue", "oMaladieRonceNoire", "oBlessureInfecteRoseNoire",
                // Quelques monstres clés pour compléter
                "oChevalierSqueletteReanimeParLaRose", "oDragonSacreRoseNoire", "oLacEnvahiParLaRoseNoire", "oDragonCorrompuRoseNoire"
            ];
            
        case 2: // Bot 2 - Deck Dragon (Genre Dragon)
            return [
                // Thème Dragon (3 copies max)
                "oDragonSacreClairLune", "oDragonSacreClairLune", "oDragonSacreClairLune",
                "oDragonnetForet", "oDragonnetForet", "oDragonnetForet",
                "oDragonSacreRoseNoire", "oDragonSacreRoseNoire", "oDragonSacreRoseNoire",
                "oDragonnetBeniRoseNoire", "oDragonnetBeniRoseNoire", "oDragonnetBeniRoseNoire",
                "oDragonCorrompuRoseNoire", "oDragonCorrompuRoseNoire", "oDragonCorrompuRoseNoire",
                "oAncienDragonBeniForet", "oAncienDragonBeniForet", "oAncienDragonBeniForet",
                // Complément avec autres monstres (non-Dragon)
                "oChevalForet", "oChevalForet", "oChevalForet",
                "oSorciereForet", "oSorciereForet", "oSorciereForet",
                "oEruditForet", "oEruditForet",
                "oNueeCorbeaux", "oNueeCorbeaux",
                "oLoupAlphaForet", "oLoupAlphaForet",
                "oAraigneeSombreForet", "oAraigneeSombreForet", "oAraigneeSombreForet",
                "oCorbeauDeLaRoseNoire", "oCorbeauDeLaRoseNoire",
                "oTreant",
                "oPetaleRose",
                // Ajout de sorts thématiques Dragon/neutres pour compléter à 40 cartes
                "oAileForet", "oEcailleForet", "oGriffeForet"
            ];
            
        case 3: // Bot 3 - Deck Bête (Genre Bête)
            return [
                // Thème Bête (3 copies max)
                "oNueeCorbeaux", "oNueeCorbeaux", "oNueeCorbeaux",
                "oCorbeauDeLaRoseNoire", "oCorbeauDeLaRoseNoire", "oCorbeauDeLaRoseNoire",
                "oChevalForet", "oChevalForet", "oChevalForet",
                "oChevalDeLaRoseNoire", "oChevalDeLaRoseNoire", "oChevalDeLaRoseNoire",
                "oLoupAlphaForet", "oLoupAlphaForet", "oLoupAlphaForet",
                "oLoupBeniParLaRoseNoire", "oLoupBeniParLaRoseNoire", "oLoupBeniParLaRoseNoire",
                // Complément avec autres monstres (non-Bête) jusqu'à 40
                "oDragonSacreClairLune", "oDragonSacreClairLune", "oDragonSacreClairLune",
                "oDragonnetForet", "oDragonnetForet", "oDragonnetForet",
                "oOmbreClairLune", "oOmbreClairLune", "oOmbreClairLune",
                "oSqueletteReanime", "oSqueletteReanime", "oSqueletteReanime",
                "oChevalierSqueletteReanime", "oChevalierSqueletteReanime", "oChevalierSqueletteReanime",
                "oSorciereForet", "oSorciereForet", "oSorciereForet",
                "oEruditForet", "oEruditForet",
                // Remplacement par des sorts thématiques Bête/neutres pour garder 40 cartes
                "oBaguetteClairLune", "oSacrificeMeute"
            ];
            
        case 4: // Bot 4 - Deck Mort-vivant (Genre Mort-vivant)
            return [
                // Thème Mort-vivant (3 copies max)
                "oChevalierSqueletteReanime", "oChevalierSqueletteReanime", "oChevalierSqueletteReanime",
                "oOmbreClairLune", "oOmbreClairLune", "oOmbreClairLune",
                "oSqueletteReanime", "oSqueletteReanime", "oSqueletteReanime",
                "oSquelettePossedeParLaRoseNoire", "oSquelettePossedeParLaRoseNoire", "oSquelettePossedeParLaRoseNoire",
                "oChevalierSqueletteReanimeParLaRose", "oChevalierSqueletteReanimeParLaRose", "oChevalierSqueletteReanimeParLaRose",
                "oOmbreDeLaRoseNoire", "oOmbreDeLaRoseNoire", "oOmbreDeLaRoseNoire",
                // Complément avec autres monstres (non-Mort-vivant) jusqu'à 40
                "oDragonSacreClairLune", "oDragonSacreClairLune", "oDragonSacreClairLune",
                "oDragonnetForet", "oDragonnetForet", "oDragonnetForet",
                "oDragonSacreRoseNoire", "oDragonSacreRoseNoire", "oDragonSacreRoseNoire",
                "oAncienDragonBeniForet", "oAncienDragonBeniForet", "oAncienDragonBeniForet",
                "oCorbeauDeLaRoseNoire", "oCorbeauDeLaRoseNoire", "oCorbeauDeLaRoseNoire",
                "oNueeCorbeaux", "oNueeCorbeaux", "oNueeCorbeaux",
                "oChevalForet", "oChevalForet", "oChevalForet",
                // Ajout d'un sort synergique pour remplir à 40
                "oClairLuneForetMaudite"
            ];
            
        case 5: // Deck Bot 5 - Maître du Contrôle
            return [
                "oDragonDivinRagnarok", "oDragonDivinRagnarok", "oSorciereDeLaRoseNoire", "oSorciereDeLaRoseNoire", "oSorciereDeLaRoseNoire", "oChevalDeLaRoseNoire", "oChevalDeLaRoseNoire", "oCorbeauDeLaRoseNoire", "oCorbeauDeLaRoseNoire", "oCorbeauDeLaRoseNoire",
                "oCorbeauDeLaRoseNoire", "oCorbeauDeLaRoseNoire", "oChevalDeLaRoseNoire", "oChevalDeLaRoseNoire", "oChevalDeLaRoseNoire",
                "oDragonDivinRagnarok", "oDragonDivinRagnarok", "oDragonDivinRagnarok", "oDragonDivinRagnarok", "oDragonDivinRagnarok", "oDragonDivinRagnarok", "oDragonDivinRagnarok"
            ];
            
        // Decks génériques pour les bots 6-29
        case "Guerrier": // Deck agressif
            return [
                "oCorbeauDeLaRoseNoire", "oSorciereDeLaRoseNoire", "oDragonDivinRagnarok", "oChevalDeLaRoseNoire", "oChevalDeLaRoseNoire", "oCorbeauDeLaRoseNoire", "oSorciereDeLaRoseNoire", "oDragonDivinRagnarok", "oChevalDeLaRoseNoire", "oChevalDeLaRoseNoire",
                "oCorbeauDeLaRoseNoire", "oSorciereDeLaRoseNoire", "oDragonDivinRagnarok", "oChevalDeLaRoseNoire", "oChevalDeLaRoseNoire", "oCorbeauDeLaRoseNoire", "oSorciereDeLaRoseNoire", "oDragonDivinRagnarok", "oChevalDeLaRoseNoire", "oChevalDeLaRoseNoire"
            ];
            
        case "Magique": // Deck magique
            return [
                "oChevalDeLaRoseNoire", "oChevalDeLaRoseNoire", "oChevalDeLaRoseNoire", "oChevalDeLaRoseNoire", "oChevalDeLaRoseNoire", "oChevalDeLaRoseNoire", "oChevalDeLaRoseNoire", "oChevalDeLaRoseNoire", "oChevalDeLaRoseNoire", "oChevalDeLaRoseNoire",
                "oChevalDeLaRoseNoire", "oChevalDeLaRoseNoire", "oChevalDeLaRoseNoire", "oChevalDeLaRoseNoire", "oChevalDeLaRoseNoire", "oCorbeauDeLaRoseNoire", "oCorbeauDeLaRoseNoire", "oSorciereDeLaRoseNoire", "oSorciereDeLaRoseNoire", "oDragonDivinRagnarok"
            ];
            
        case "Support": // Deck support
            return [
                "oDragonDivinRagnarok", "oSorciereDeLaRoseNoire", "oCorbeauDeLaRoseNoire", "oCorbeauDeLaRoseNoire", "oCorbeauDeLaRoseNoire", "oDragonDivinRagnarok", "oSorciereDeLaRoseNoire", "oCorbeauDeLaRoseNoire", "oCorbeauDeLaRoseNoire", "oCorbeauDeLaRoseNoire",
                "oDragonDivinRagnarok", "oSorciereDeLaRoseNoire", "oCorbeauDeLaRoseNoire", "oCorbeauDeLaRoseNoire", "oCorbeauDeLaRoseNoire", "oDragonDivinRagnarok", "oSorciereDeLaRoseNoire", "oCorbeauDeLaRoseNoire", "oCorbeauDeLaRoseNoire", "oCorbeauDeLaRoseNoire"
            ];
            
        case "Hybride": // Deck mixte
            return [
                "oSorciereDeLaRoseNoire", "oChevalDeLaRoseNoire", "oChevalDeLaRoseNoire", "oCorbeauDeLaRoseNoire", "oCorbeauDeLaRoseNoire", "oSorciereDeLaRoseNoire", "oChevalDeLaRoseNoire", "oChevalDeLaRoseNoire", "oCorbeauDeLaRoseNoire", "oCorbeauDeLaRoseNoire",
                "oSorciereDeLaRoseNoire", "oChevalDeLaRoseNoire", "oChevalDeLaRoseNoire", "oCorbeauDeLaRoseNoire", "oCorbeauDeLaRoseNoire", "oDragonDivinRagnarok", "oDragonDivinRagnarok", "oDragonDivinRagnarok", "oDragonDivinRagnarok", "oDragonDivinRagnarok"
            ];
            
        default:
            // Deck par défaut
            return [
                "oCorbeauDeLaRoseNoire", "oCorbeauDeLaRoseNoire", "oCorbeauDeLaRoseNoire", "oCorbeauDeLaRoseNoire", "oCorbeauDeLaRoseNoire", "oCorbeauDeLaRoseNoire", "oCorbeauDeLaRoseNoire", "oCorbeauDeLaRoseNoire", "oCorbeauDeLaRoseNoire", "oCorbeauDeLaRoseNoire",
                "oCorbeauDeLaRoseNoire", "oCorbeauDeLaRoseNoire", "oCorbeauDeLaRoseNoire", "oCorbeauDeLaRoseNoire", "oCorbeauDeLaRoseNoire", "oCorbeauDeLaRoseNoire", "oCorbeauDeLaRoseNoire", "oCorbeauDeLaRoseNoire", "oCorbeauDeLaRoseNoire", "oCorbeauDeLaRoseNoire"
            ];
    }
}

// Fonction utilitaire: limite à 3 copies de chaque carte lors de la création du deck
function cap_card_copies(deck_cards, max_copies) {
    var counts = {};
    var capped = [];
    for (var i = 0; i < array_length(deck_cards); i++) {
        var card_id = deck_cards[i];
        var current = variable_struct_exists(counts, card_id) ? variable_struct_get(counts, card_id) : 0;
        if (current < max_copies) {
            variable_struct_set(counts, card_id, current + 1);
            array_push(capped, card_id);
        }
    }
    return capped;
}

// Compte le nombre de copies d'une carte dans le tableau
function count_card_copies(deck_cards, card_id) {
    var count = 0;
    for (var i = 0; i < array_length(deck_cards); i++) {
        if (deck_cards[i] == card_id) count++;
    }
    return count;
}

// Remplit le deck avec des monstres d'autres thématiques jusqu'à la taille cible
function fill_to_size(deck_cards, target_size, max_copies) {
    var pool = [
        "oChevalForet", "oSorciereForet", "oEruditForet", "oNueeCorbeaux", "oLoupAlphaForet",
        "oOmbreClairLune", "oPetaleRose", "oSqueletteReanime", "oChevalierSqueletteReanime",
        "oChevalDeLaRoseNoire", "oAraigneeSombreForet", "oDragonnetForet"
    ];
    var i = 0;
    var pool_len = array_length(pool);
    var safety = 0;
    while (array_length(deck_cards) < target_size && safety < 2000) {
        var cand = pool[i % pool_len];
        if (count_card_copies(deck_cards, cand) < max_copies) {
            array_push(deck_cards, cand);
        }
        i++;
        safety++;
    }
    return deck_cards;
}

/// @function create_bot_deck_from_script(deck_id, bot_name)
/// @description Crée un objet deck à partir du script
/// @param {real} deck_id - L'ID du deck
/// @param {string} bot_name - Le nom du bot
function create_bot_deck_from_script(deck_id, bot_name) {
    var deck_cards = get_bot_deck_cards(deck_id);
    deck_cards = cap_card_copies(deck_cards, 3);
    deck_cards = fill_to_size(deck_cards, 40, 3);
    
    var bot_deck = {
        name: "Deck de " + bot_name,
        cards: deck_cards,
        deck_id: deck_id,
        bot_name: bot_name,
        card_count: array_length(deck_cards)
    };
    
    return bot_deck;
}

// === Fonctions utilitaires ===

/// @function get_random_deck_type()
/// @description Retourne un type de deck aléatoire pour les bots génériques
function get_random_deck_type() {
    var deck_types = ["Guerrier", "Magique", "Support", "Hybride"];
    return deck_types[irandom(array_length(deck_types) - 1)];
}

/// @function get_bot_deck_name(deck_id)
/// @description Retourne le nom du deck pour l'affichage
/// @param {real} deck_id - L'ID du deck
function get_bot_deck_name(deck_id) {
    switch(deck_id) {
        case 1: return "Rose noire";
        case 2: return "Dragon";
        case 3: return "Bête";
        case 4: return "Mort-vivant";
        case 5: return "Maître du Contrôle";
        default: return "Bot " + string(deck_id);
    }
}