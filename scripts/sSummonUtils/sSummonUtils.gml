// === Script d’Invocation Spéciale (sSummonUtils) ===
// Regroupe la recherche du slot libre et l’invocation nommée

/// @function getLeftmostFreeMonsterSlot(ownerIsHero)
/// @description Retourne le slot libre le plus à gauche et ses coordonnées
/// @returns {struct|noone} - { fieldMgr, pos, x, y } ou noone
function getLeftmostFreeMonsterSlot(ownerIsHero) {
    var fieldMgr = ownerIsHero ? fieldManagerHero : fieldManagerEnemy;
    var monsterField = fieldMgr.getField("Monster");
    var pos = -1;
    for (var i = 0; i < array_length(monsterField.cards); i++) {
        if (monsterField.cards[i] == 0) { pos = i; break; }
    }
    if (pos == -1) return noone;
    var XY = fieldMgr.getPosLocation("Monster", pos);
    return { fieldMgr: fieldMgr, pos: pos, x: XY[0], y: XY[1] };
}

/// @function specialSummonNamed(card, effect, context)
/// @description Invoque spécialement par nom/objet depuis main/deck/cimetière au slot libre le plus à gauche
/// @returns {bool}
function specialSummonNamed(card, effect, context) {
    var ownerIsHero = variable_struct_exists(card, "isHeroOwner") ? card.isHeroOwner : true;
    var slot = getLeftmostFreeMonsterSlot(ownerIsHero);
    if (slot == noone) { show_debug_message("### Effet: Aucun slot libre"); return false; }

    var targetName = variable_struct_exists(effect, "target_name") ? effect.target_name : "";
    var targetObjectName = variable_struct_exists(effect, "target_object") ? effect.target_object : "";

    show_debug_message("### specialSummonNamed: owner=" + string(ownerIsHero) + ", targetName=" + string(targetName) + ", targetObject=" + string(targetObjectName));

    // Déterminer les sources autorisées (par défaut: Deck > Graveyard > Hand)
    var allowedSources = ["Deck", "Graveyard", "Hand"];
    if (variable_struct_exists(effect, "allowed_sources")) {
        allowedSources = effect.allowed_sources;
    } else if (variable_struct_exists(effect, "from_deck_only") && effect.from_deck_only) {
        allowedSources = ["Deck"];
    }

    // Construire les critères puis chercher via la priorité globale
    var criteria = {};
    if (variable_struct_exists(effect, "criteria")) criteria = effect.criteria;
    if (targetName != "") criteria.name = targetName;
    if (targetObjectName != "") criteria.object_name = targetObjectName;

    var found = findCard(ownerIsHero, criteria, allowedSources);
    if (found == noone) {
        show_debug_message("### Effet: aucune source disponible pour " + string(targetName));
        return false;
    }

    var fieldMgr = slot.fieldMgr;
    var pos = slot.pos;
    var X = slot.x;
    var Y = slot.y;

    var cardToSummon = noone;

    // Selon la source trouvée, retirer et invoquer
    if (found.source == "Hand") {
        UIManager.selectedSummonOrSet = "SpecialSummon";
        var summoned = (ownerIsHero ? handHero : handEnemy).summon(found.card, [X, Y, pos]);
        UIManager.selectedSummonOrSet = "";
        cardToSummon = found.card;
    } else if (found.source == "Deck") {
        var deck = ownerIsHero ? deckHero : deckEnemy;
        var didx = (found.data != noone && variable_struct_exists(found.data, "index")) ? found.data.index : ds_list_find_index(deck.cards, found.card);
        if (didx != -1) ds_list_delete(deck.cards, didx);
        cardToSummon = found.card;
    } else if (found.source == "Graveyard") {
        var graveyard = ownerIsHero ? graveyardHero : graveyardEnemy;
        var objIndex = noone;
        var gdataSummon = found.card;
        if (is_struct(gdataSummon) && variable_struct_exists(gdataSummon, "object_index")) {
            objIndex = gdataSummon.object_index;
            show_debug_message("### specialSummonNamed: graveyard objIndex from struct=" + string(objIndex));
        } else if (!is_struct(gdataSummon) && instance_exists(gdataSummon)) {
            objIndex = gdataSummon.object_index;
            show_debug_message("### specialSummonNamed: graveyard instance object_index=" + string(objIndex));
        } else if (targetObjectName != "") {
            objIndex = asset_get_index(targetObjectName);
            show_debug_message("### specialSummonNamed: graveyard fallback asset targetObject->index=" + string(objIndex));
        } else if (targetName != "") {
            objIndex = asset_get_index(targetName);
            show_debug_message("### specialSummonNamed: graveyard fallback targetName->index=" + string(objIndex));
        }
        if (objIndex != noone) {
            cardToSummon = instance_create_layer(X, Y, layer_get_id("Instances"), objIndex);
            if (cardToSummon != noone) { cardToSummon.isHeroOwner = ownerIsHero; }
        }
        var gidx = (found.data != noone && variable_struct_exists(found.data, "index")) ? found.data.index : -1;
        if (gidx != -1) { array_delete(graveyard.cards, gidx, 1); }
    } else {
        show_debug_message("### specialSummonNamed: source non supportée: " + string(found.source));
        return false;
    }

    if (cardToSummon == noone) return false;

    cardToSummon.x = X;
    cardToSummon.y = Y;
    cardToSummon.fieldPosition = pos;
    fieldMgr.add(cardToSummon);

    cardToSummon.image_xscale = 0.275;
    cardToSummon.image_yscale = 0.275;
    cardToSummon.zone = "Field";
    cardToSummon.depth = 0;
    cardToSummon.orientation = "Attack";
    cardToSummon.isFaceDown = false;
    cardToSummon.image_index = 0;
    cardToSummon.image_angle = ownerIsHero ? 0 : 180;

    if (cardToSummon.type == "Monster") {
        cardToSummon.orientationChangedThisTurn = true;
    }

    // Exposer l'instance invoquée dans le contexte et déclencher les triggers d'invocation spéciale
    if (is_struct(context)) {
        context.summoned = cardToSummon;
        registerTriggerEvent(TRIGGER_ON_SUMMON, cardToSummon, { summon_mode: "SpecialSummon", owner_is_hero: ownerIsHero });
        // Assurer la diffusion de l’événement d’invocation de monstre
        registerTriggerEvent(TRIGGER_ON_MONSTER_SUMMON, cardToSummon, { summon_mode: "SpecialSummon", owner_is_hero: ownerIsHero });
    }

    return true;
}