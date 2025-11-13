// === Script de stockage des decks des bots ===
// Ce script contient tous les decks préconfigurés pour les bots

/// @function get_bot_deck_cards(deck_id)
/// @description Retourne le tableau de cartes pour un deck spécifique
/// @param {real} deck_id - L'ID du deck à récupérer
function get_bot_deck_cards(deck_id) {
    
    switch(deck_id) {
        case 1: // Bot 1 - Deck Rose noire (25 monstres, 15 magies) — Chemin perdu, profil Balanced
            return [
                // Monstres (25) — mettre à 2 exemplaires, sauf exceptions indiquées
                "oCorbeauDeLaRoseNoire", "oCorbeauDeLaRoseNoire",
                "oChevalDeLaRoseNoire", "oChevalDeLaRoseNoire",
                "oAraigneeDeLaRoseNoire", "oAraigneeDeLaRoseNoire",
                "oDragonnetBeniRoseNoire", "oDragonnetBeniRoseNoire",
                "oChevalierSqueletteReanimeParLaRose", "oChevalierSqueletteReanimeParLaRose",
                "oTreant", "oTreant",
                "oAraigneeSombreForet", "oAraigneeSombreForet",
                "oPetiteSorciereDeLaRoseNoire", "oPetiteSorciereDeLaRoseNoire",
                "oSorciereDeLaRoseNoire", "oSorciereDeLaRoseNoire",
                "oSquelettePossedeParLaRoseNoire", "oSquelettePossedeParLaRoseNoire",
                // Exceptions
                "oEruditDeLaRoseNoire",
                // Limite unique
                "oDragonSacreRoseNoire",
                // Compléments pour atteindre 25
                "oChevalierSqueletteReanime",
                "oChevalForet",
                "oLacEnvahiParLaRoseNoire",
                // Magies (15)
                "oRoseNoire", "oRoseNoire", "oRoseNoire",
                "oBaguetteRoseNoire", "oBaguetteRoseNoire", "oBaguetteRoseNoire",
                "oBrumeRoseNoire", "oBrumeRoseNoire",
                "oMaledictionRoseNoire", "oMaledictionRoseNoire",
                "oFloraisonRosePerdue", "oFloraisonRosePerdue",
                // Secrets
                "oRonceNoire", "oRonceNoire",
                "oMaladieRonceNoire"
            ];
            
        case 2: // Bot 2 - Deck Dragon (25 monstres, 15 magies) — Chemin perdu, profil Stompy
            return [
                // Monstres (25)
                "oDragonSacreClairLune", "oDragonSacreClairLune", "oDragonSacreClairLune",
                "oDragonnetForet", "oDragonnetForet", "oDragonnetForet",
                "oDragonnetBeniRoseNoire", "oDragonnetBeniRoseNoire", "oDragonnetBeniRoseNoire",
                "oAncienDragonBeniForet", "oAncienDragonBeniForet", "oAncienDragonBeniForet",
                // Limite unique
                "oDragonSacreRoseNoire",
                "oChevalForet", "oChevalForet", "oChevalForet",
                "oSorciereForet", "oSorciereForet", "oSorciereForet",
                "oTreant", "oTreant", "oTreant",
                "oEruditForet",
                // Ajouts: loups pour invocation facile
                "oLoupAlphaForet", "oLoupAlphaForet",
                // Magies (15)
                "oAileForet", "oAileForet",
                "oEcailleForet", "oEcailleForet",
                "oGriffeForet", "oGriffeForet",
                "oRoseNoire", "oRoseNoire",
                "oClairLuneForetMaudite", "oClairLuneForetMaudite",
                // Secrets ajoutés (remplace ClairLune Béni)
                "oRonceNoire", "oRonceNoire", "oRonceNoire",
                "oMaladieRonceNoire", "oMaladieRonceNoire"
            ];
            
        case 3: // Bot 3 - Deck Bête (30 monstres, 10 magies) — profil Aggro
            return [
                // Monstres (30)
                "oChevalForet", "oChevalForet", "oChevalForet",
                "oChevalDeLaRoseNoire", "oChevalDeLaRoseNoire", "oChevalDeLaRoseNoire",
                "oLoupAlphaForet", "oLoupAlphaForet", "oLoupAlphaForet",
                "oNueeCorbeaux", "oNueeCorbeaux", "oNueeCorbeaux",
                "oCorbeauDeLaRoseNoire", "oCorbeauDeLaRoseNoire", "oCorbeauDeLaRoseNoire",
                "oAraigneeSombreForet", "oAraigneeSombreForet", "oAraigneeSombreForet",
                // Ajout pour compenser Érudit réduit
                "oAraigneeDeLaRoseNoire", "oAraigneeDeLaRoseNoire",
                "oDragonnetForet", "oDragonnetForet", "oDragonnetForet",
                "oTreant", "oTreant", "oTreant",
                "oEruditForet",
                "oSorciereForet", "oSorciereForet", "oSorciereForet",
                // Magies (10)
                "oSacrificeMeute", "oSacrificeMeute", "oSacrificeMeute",
                "oMaledictionClairLune", "oMaledictionClairLune",
                "oRoseNoire",
                "oEcailleForet",
                "oRonceNoire", "oRonceNoire",
                "oMaladieRonceNoire"
            ];
            
        case 4: // Bot 4 - Deck Contrôle (Mort-vivant & Humanoïde) (25 monstres, 15 magies) — Chemin perdu
            return [
                // Monstres (25)
                "oChevalierSqueletteReanime", "oChevalierSqueletteReanime", "oChevalierSqueletteReanime",
                "oSqueletteReanime", "oSqueletteReanime", "oSqueletteReanime",
                "oChevalierSqueletteReanimeParLaRose", "oChevalierSqueletteReanimeParLaRose", "oChevalierSqueletteReanimeParLaRose",
                "oOmbreClairLune", "oOmbreClairLune", "oOmbreClairLune",
                "oEruditForet", "oEruditForet", "oEruditForet",
                "oSorciereForet", "oSorciereForet", "oSorciereForet",
                "oEruditDeLaRoseNoire", "oEruditDeLaRoseNoire", "oEruditDeLaRoseNoire",
                "oPetiteSorciereForet", "oPetiteSorciereForet", "oPetiteSorciereForet",
                "oCorbeauDeLaRoseNoire",
                // Magies (15)
                "oRonceNoire", "oRonceNoire", "oRonceNoire",
                "oMaladieRonceNoire", "oMaladieRonceNoire",
                "oMaledictionRoseNoire", "oMaledictionRoseNoire",
                "oClairLuneForetMaudite", "oClairLuneForetMaudite", "oClairLuneForetMaudite",
                "oClairLuneBeni", "oClairLuneBeni",
                "oBaguetteRoseNoire", "oBaguetteRoseNoire",
                "oTalismanPerdu"
            ];
            
        case 5: // Deck Bot 5 — Test Rose noire & Baguette (15 cartes, complété à 40)
            return [
                // 5x Petite Sorcière de la Rose noire
                "oPetiteSorciereDeLaRoseNoire", "oPetiteSorciereDeLaRoseNoire", "oPetiteSorciereDeLaRoseNoire", "oPetiteSorciereDeLaRoseNoire", "oPetiteSorciereDeLaRoseNoire",
                // 5x Baguette de la Rose noire
                "oBaguetteRoseNoire", "oBaguetteRoseNoire", "oBaguetteRoseNoire", "oBaguetteRoseNoire", "oBaguetteRoseNoire",
                // 5x La Rose noire
                "oRoseNoire", "oRoseNoire", "oRoseNoire", "oRoseNoire", "oRoseNoire"
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
    var max_copies = (deck_id == 5) ? 5 : 3;
    deck_cards = cap_card_copies(deck_cards, max_copies);
    deck_cards = fill_to_size(deck_cards, 40, max_copies);
    
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

/// @function get_bot_deck_profile(deck_id)
/// @description Retourne le libellé de profil d'archétype pour affichage
/// @param {real} deck_id - L'ID du deck
function get_bot_deck_profile(deck_id) {
    switch(deck_id) {
        case 1: return "Balanced";
        case 2: return "Stompy";
        case 3: return "Aggro";
        case 4: return "Control";
        default: return "Balanced";
    }
}