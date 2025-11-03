function sEffectDiscard(card, effect, context) {
    // Effet unifié de défausse (main uniquement) avec critères et options
    // Déterminer le propriétaire ciblé
    // Priorité: contexte explicite > effet.owner > source carte
    var ownerIsHero = true;
    if (variable_struct_exists(context, "owner_is_hero")) {
        ownerIsHero = context.owner_is_hero;
    } else if (card != noone && instance_exists(card) && variable_instance_exists(card, "isHeroOwner")) {
        ownerIsHero = card.isHeroOwner;
    }
    if (variable_struct_exists(effect, "owner")) {
        var ow = string_lower(effect.owner);
        if (ow == "hero") ownerIsHero = true; else if (ow == "enemy") ownerIsHero = false; // sinon: défaut = source
    }

    var handInst = ownerIsHero ? handHero : handEnemy;
    var gyInst = ownerIsHero ? graveyardHero : graveyardEnemy;
    if (!instance_exists(handInst) || !instance_exists(gyInst)) {
        show_debug_message("### sEffectDiscard: main ou cimetière introuvables");
        return false;
    }

    // Sélection et critères
    var selection = variable_struct_exists(effect, "selection") ? effect.selection : {};
    var mode = variable_struct_exists(selection, "mode") ? string_lower(selection.mode) : (variable_struct_exists(effect, "random_select") && effect.random_select ? "random" : "count");
    var count = 1;
    if (variable_struct_exists(selection, "count")) count = selection.count; else if (variable_struct_exists(effect, "value")) count = effect.value; else if (variable_struct_exists(effect, "discard_count")) count = effect.discard_count;
    var allowPartial = variable_struct_exists(selection, "allow_partial") ? selection.allow_partial : true;
    var excludeSelf = false;
    if (variable_struct_exists(selection, "exclude_self")) excludeSelf = selection.exclude_self; else if (variable_struct_exists(effect, "as_cost")) excludeSelf = effect.as_cost;

    // Filtres de cibles (simple)
    var filter = {};
    if (variable_struct_exists(effect, "target_filter")) filter = effect.target_filter;
    else if (variable_struct_exists(effect, "search_criteria")) filter = effect.search_criteria; // alias

    var nameWanted = "";
    var archeWanted = "";
    var typeWanted = ""; // "Monster" | "Magic" | "Spell" etc.
    var faceUpReq = false;
    if (variable_struct_exists(filter, "name")) nameWanted = filter.name;
    if (variable_struct_exists(filter, "archetype")) archeWanted = filter.archetype;
    if (variable_struct_exists(filter, "type")) typeWanted = filter.type;
    if (variable_struct_exists(filter, "face_up")) faceUpReq = filter.face_up;

    // Construire la liste des candidats dans la main (respect des filtres et exclusion de la source au besoin)
    var candidates = ds_list_create();
    var n = ds_list_size(handInst.cards);
    for (var i = 0; i < n; i++) {
        var c = ds_list_find_value(handInst.cards, i);
        if (c == noone || !instance_exists(c)) continue;
        if (excludeSelf && c == card) continue;
        if (!_discard__matchesFilter(c, nameWanted, archeWanted, typeWanted, faceUpReq)) continue;
        ds_list_add(candidates, c);
    }

    // Sélectionner les cartes à défausser selon le mode
    var selected = ds_list_create();
    if (mode == "random") {
        // Mélanger les candidats et prendre jusqu'à count
        ds_list_shuffle(candidates);
        var take = min(count, ds_list_size(candidates));
        for (var r = 0; r < take; r++) {
            ds_list_add(selected, ds_list_find_value(candidates, r));
        }
    } else if (mode == "all") {
        // Prendre tous les candidats
        var m = ds_list_size(candidates);
        for (var j = 0; j < m; j++) { ds_list_add(selected, ds_list_find_value(candidates, j)); }
    } else {
        // Par défaut: prendre depuis la droite de la main (comportement historique), en respectant les filtres
        var toTake = count;
        var idx = ds_list_size(handInst.cards) - 1;
        while (toTake > 0 && idx >= 0) {
            var hc = ds_list_find_value(handInst.cards, idx);
            idx--;
            if (hc == noone || !instance_exists(hc)) continue;
            if (excludeSelf && hc == card) continue;
            if (!_discard__matchesFilter(hc, nameWanted, archeWanted, typeWanted, faceUpReq)) continue;
            ds_list_add(selected, hc);
            toTake--;
        }
    }

    var selCount = ds_list_size(selected);
    if (selCount <= 0) {
        show_debug_message("### sEffectDiscard: aucun candidat correspondant");
        ds_list_destroy(candidates);
        ds_list_destroy(selected);
        return false;
    }
    if (!allowPartial && selCount < count) {
        show_debug_message("### sEffectDiscard: résolution refusée (partial non autorisé), requis=" + string(count) + ", trouvés=" + string(selCount));
        ds_list_destroy(candidates);
        ds_list_destroy(selected);
        return false;
    }

    // Exécuter la défausse des cartes sélectionnées (utilise l’utilitaire spécifique pour supporter FX et rafraîchissement de main)
    var ok = discardSpecificCardsToGraveyard(ownerIsHero, selected);

    // Contexte de chaîne
    var ctx = { from_discard: true, owner_is_hero: ownerIsHero };
    if (card != noone && instance_exists(card)) ctx.initiator_card_id = card.id;
    if (variable_struct_exists(effect, "id")) ctx.source_effect_id = effect.id;
    ctx.discarded_cards = selected; // ds_list de cartes défaussées (instances au moment de la sélection)

    // Chaîner les post-étapes si présentes (flow[])
    if (ok && variable_struct_exists(effect, "flow") && is_array(effect.flow)) {
        var L = array_length(effect.flow);
        for (var k = 0; k < L; k++) {
            var stepEff = effect.flow[k];
            if (is_struct(stepEff) && variable_struct_exists(stepEff, "effect_type")) {
                executeEffect(card, stepEff, ctx);
            }
        }
    }

    ds_list_destroy(candidates);
    ds_list_destroy(selected);
    return ok;
}

/// Helper: vérifie si une carte de la main correspond à des filtres de défausse
function _discard__matchesFilter(c, nameWanted, archeWanted, typeWanted, faceUpReq) {
    if (c == noone || !instance_exists(c)) return false;
    if (faceUpReq) {
        if (variable_instance_exists(c, "isFaceDown") && c.isFaceDown) return false;
    }
    if (nameWanted != undefined && nameWanted != "") {
        var cn = variable_instance_exists(c, "name") ? c.name : object_get_name(c.object_index);
        if (string_lower(cn) != string_lower(nameWanted)) return false;
    }
    if (archeWanted != undefined && archeWanted != "") {
        if (!variable_instance_exists(c, "archetype") || string_lower(c.archetype) != string_lower(archeWanted)) return false;
    }
    if (typeWanted != undefined && typeWanted != "") {
        // Normaliser quelques alias
        var t = variable_instance_exists(c, "type") ? string_lower(c.type) : "";
        var wanted = string_lower(typeWanted);
        if (wanted == "spell") wanted = "magic"; // alias
        if (t != wanted) return false;
    }
    return true;
}