function summonToken(card, effect, context) {
    if (!variable_struct_exists(effect, "token_data")) return false;
    var tokenData = effect.token_data;
    var ownerIsHero = (card != noone && instance_exists(card) && variable_instance_exists(card, "isHeroOwner")) ? card.isHeroOwner
                       : (variable_struct_exists(context, "owner_is_hero") ? context.owner_is_hero : true);
    var slot = getLeftmostFreeMonsterSlot(ownerIsHero);
    if (slot == noone) { show_debug_message("### summonToken: Aucun slot libre"); return false; }
    var fieldMgr = slot.fieldMgr;
    var pos = slot.pos;
    var X = slot.x;
    var Y = slot.y;
    var objIndex = oCardMonster;
    if (variable_struct_exists(tokenData, "token_object")) {
        var tryIdx = asset_get_index(tokenData.token_object);
        if (tryIdx != -1) objIndex = tryIdx;
    }
    var token = instance_create_layer(X, Y, "Instances", objIndex);
    if (token == noone) return false;
    if (variable_struct_exists(tokenData, "name")) token.name = tokenData.name;
    if (variable_struct_exists(tokenData, "attack")) token.attack = tokenData.attack;
    if (variable_struct_exists(tokenData, "defense")) token.defense = tokenData.defense;
    if (variable_struct_exists(tokenData, "type")) token.type = tokenData.type;
    if (variable_struct_exists(tokenData, "archetype")) token.archetype = tokenData.archetype;
    if (variable_struct_exists(tokenData, "star")) token.star = tokenData.star;
    token.isToken = true;
    token.isHeroOwner = ownerIsHero;
    token.is_player_card = ownerIsHero;
    token.fieldPosition = pos;
    fieldMgr.add(token);
    token.image_xscale = 0.275;
    token.image_yscale = 0.275;
    token.zone = "Field";
    token.depth = 0;
    token.orientation = "Attack";
    token.isFaceDown = false;
    token.image_index = 0;
    token.image_angle = ownerIsHero ? 0 : 180;
    token.attackModeActivated = false;
    registerTriggerEvent(TRIGGER_ON_SUMMON, token, { summon_mode: "SpecialSummon", owner_is_hero: ownerIsHero });
    // Diffuser aussi l’événement d’invocation de monstre (utile pour Secrets)
    registerTriggerEvent(TRIGGER_ON_MONSTER_SUMMON, token, { summon_mode: "SpecialSummon", owner_is_hero: ownerIsHero });
    return true;
}

function activateSpellByCriteria(card, effect, context) {
    var ownerIsHero = (card != noone && instance_exists(card) && variable_instance_exists(card, "isHeroOwner")) ? card.isHeroOwner
                       : (variable_struct_exists(context, "owner_is_hero") ? context.owner_is_hero : true);
    var allowedSources = ["Deck", "Graveyard", "Hand"];
    if (variable_struct_exists(effect, "allowed_sources")) allowedSources = effect.allowed_sources;
    var criteria = {};
    if (variable_struct_exists(effect, "criteria")) criteria = effect.criteria;
    criteria.type = "Magic";
    var criteriaIsSecret = (variable_struct_exists(criteria, "genre") && string_lower(criteria.genre) == string_lower("Secret"));
    var found = findCard(ownerIsHero, criteria, allowedSources);
    if (found == noone) return false;
    var fieldMgr = ownerIsHero ? fieldManagerHero : fieldManagerEnemy;
    var magicField = fieldMgr.getField("MagicTrap");
    var pos = -1;
    for (var i = 0; i < array_length(magicField.cards); i++) {
        if (magicField.cards[i] == 0) { pos = i; break; }
    }
    if (pos == -1) { show_debug_message("### activateSpellByCriteria: Aucun slot Magie libre"); return false; }
    var XY = fieldMgr.getPosLocation("MagicTrap", pos);
    var X = XY[0];
    var Y = XY[1];
    var spellCard = noone;
    if (found.source == "Hand") {
        var isSecret = criteriaIsSecret;
        if (instance_exists(found.card) && variable_instance_exists(found.card, "genre")) {
            isSecret = isSecret || (string_lower(found.card.genre) == string_lower("Secret"));
        }
        UIManager.selectedSummonOrSet = isSecret ? "Set" : "Summon";
        var summoned = (ownerIsHero ? handHero : handEnemy).summon(found.card, [X, Y, pos]);
        UIManager.selectedSummonOrSet = "";
        var ctx = { summon_mode: (isSecret ? "Set" : "Summon"), owner_is_hero: ownerIsHero };
        registerTriggerEvent(TRIGGER_ON_SUMMON, found.card, ctx);
        if (!isSecret) { registerTriggerEvent(TRIGGER_ON_SPELL_CAST, found.card, ctx); }
        return summoned;
    } else if (found.source == "Deck") {
        var deck = ownerIsHero ? deckHero : deckEnemy;
        var didx = (found.data != noone && variable_struct_exists(found.data, "index")) ? found.data.index : ds_list_find_index(deck.cards, found.card);
        if (didx != -1) ds_list_delete(deck.cards, didx);
        spellCard = found.card;
    } else if (found.source == "Graveyard") {
        var graveyard = ownerIsHero ? graveyardHero : graveyardEnemy;
        var objIndex = noone;
        var gdata = found.card;
        if (is_struct(gdata) && variable_struct_exists(gdata, "object_index")) {
            objIndex = gdata.object_index;
        } else if (!is_struct(gdata) && instance_exists(gdata)) {
            objIndex = gdata.object_index;
        }
        if (objIndex != noone) {
            spellCard = instance_create_layer(X, Y, layer_get_id("Instances"), objIndex);
            if (spellCard != noone) { spellCard.isHeroOwner = ownerIsHero; }
        }
        var gidx = (found.data != noone && variable_struct_exists(found.data, "index")) ? found.data.index : -1;
        if (gidx != -1) { array_delete(graveyard.cards, gidx, 1); }
    } else {
        show_debug_message("### activateSpellByCriteria: Source non supportée: " + string(found.source));
        return false;
    }
    if (spellCard == noone) return false;
    spellCard.x = X;
    spellCard.y = Y;
    spellCard.fieldPosition = pos;
    fieldMgr.add(spellCard);
    spellCard.image_xscale = 0.275;
    spellCard.image_yscale = 0.275;
    spellCard.zone = "Field";
    spellCard.depth = 0;
    spellCard.orientation = "Attack";
    var isSecret2 = criteriaIsSecret || (variable_instance_exists(spellCard, "genre") && string_lower(spellCard.genre) == string_lower("Secret"));
    if (isSecret2) {
        spellCard.isFaceDown = true;
        spellCard.image_index = 1;
    } else {
        spellCard.isFaceDown = false;
        spellCard.image_index = 0;
    }
    spellCard.image_angle = ownerIsHero ? 0 : 180;
    var ctx2 = { summon_mode: "Summon", owner_is_hero: ownerIsHero };
    registerTriggerEvent(TRIGGER_ON_SUMMON, spellCard, ctx2);
    if (!isSecret2) { registerTriggerEvent(TRIGGER_ON_SPELL_CAST, spellCard, ctx2); }
    return true;
}

function specialSummonSelf(card, effect, context) {
    if (card == noone || !instance_exists(card)) return false;
    if (!variable_struct_exists(card, "zone")) return false;
    if (!(card.zone == "Hand" || card.zone == "HandSelected")) return false;
    // Déterminer correctement le propriétaire (héros vs IA)
    var ownerIsHero = (card != noone && instance_exists(card) && variable_instance_exists(card, "isHeroOwner")) ? card.isHeroOwner
                       : (variable_struct_exists(context, "owner_is_hero") ? context.owner_is_hero : true);

    // Si une position est fournie par le contexte, utiliser la bonne main (héros/ennemi)
    if (variable_struct_exists(context, "position") && array_length(context.position) >= 3) {
        UIManager.selectedSummonOrSet = "SpecialSummon";
        var pos = context.position;
        var handInst = ownerIsHero ? handHero : handEnemy;
        var ok = handInst.summon(card, [pos[0], pos[1], pos[2]]);
        // Nettoyage UI s'il s'agit du joueur
        if (ownerIsHero) {
            if (instance_exists(selectManager)) selectManager.unSelectAll();
            UIManager.stopIndicator();
        }
        UIManager.selectedSummonOrSet = "";
        if (ok) {
            var ctx = { summon_mode: "SpecialSummon", owner_is_hero: ownerIsHero };
            registerTriggerEvent(TRIGGER_ON_SUMMON, card, ctx);
            registerTriggerEvent(TRIGGER_ON_MONSTER_SUMMON, card, ctx);
        }
        return ok;
    }

    // Pas de position prédéfinie:
    // - Si c'est le joueur, afficher l'indicateur pour choisir le slot
    // - Si c'est l'IA, choisir automatiquement le slot libre le plus à gauche et invoquer sur son terrain
    if (ownerIsHero) {
        UIManager.selectedSummonOrSet = "SpecialSummon";
        UIManager.displayIndicator(card);
        return true;
    } else {
        var slot = getLeftmostFreeMonsterSlot(false);
        if (slot == noone) { show_debug_message("### specialSummonSelf: Aucun slot libre pour l'IA"); return false; }
        UIManager.selectedSummonOrSet = "SpecialSummon";
        var ok2 = handEnemy.summon(card, [slot.x, slot.y, slot.pos]);
        UIManager.selectedSummonOrSet = "";
        if (ok2) {
            var ctx2 = { summon_mode: "SpecialSummon", owner_is_hero: false };
            registerTriggerEvent(TRIGGER_ON_SUMMON, card, ctx2);
            registerTriggerEvent(TRIGGER_ON_MONSTER_SUMMON, card, ctx2);
        }
        return ok2;
    }
}

/// @function specialSummonSourceFromHandByCriteria(card, effect, context)
/// @description Invoque la carte source depuis la main si elle satisfait les critères et le contexte
/// @returns {bool}
function specialSummonSourceFromHandByCriteria(card, effect, context) {
    if (!variable_struct_exists(context, "source")) return false;
    var src = context.source;
    if (src == noone || !instance_exists(src)) return false;
    if (!variable_instance_exists(src, "zone") || !(src.zone == "Hand" || src.zone == "HandSelected")) return false;

    // Récupérer les critères génériques (depuis effect.criteria). Valeurs par défaut adaptées à l'ancien comportement.
    var criteria = {};
    if (variable_struct_exists(effect, "criteria")) criteria = effect.criteria;
    var wantType = variable_struct_exists(criteria, "type") ? string_lower(criteria.type) : "monster";
    var wantGenre = variable_struct_exists(criteria, "genre") ? string_lower(criteria.genre) : "dragon";
    var starEq   = variable_struct_exists(criteria, "star_eq") ? criteria.star_eq : 1;
    var starGte  = variable_struct_exists(criteria, "star_gte") ? criteria.star_gte : -1000;
    var starLte  = variable_struct_exists(criteria, "star_lte") ? criteria.star_lte :  1000;
    var nameWanted = variable_struct_exists(criteria, "name") ? criteria.name : "";
    var archeWanted = variable_struct_exists(criteria, "archetype") ? criteria.archetype : "";

    var fromDeckOnly = false;
    if (variable_struct_exists(effect, "from_deck_only")) fromDeckOnly = effect.from_deck_only;
    if (variable_struct_exists(criteria, "from_deck_only")) fromDeckOnly = criteria.from_deck_only;

    // Vérifications génériques
    if (wantType != "" && (!variable_instance_exists(src, "type") || string_lower(src.type) != wantType)) return false;
    if (wantGenre != "" && (!variable_instance_exists(src, "genre") || string_lower(src.genre) != wantGenre)) return false;
    if (nameWanted != "" && (!variable_instance_exists(src, "name") || string_lower(src.name) != string_lower(nameWanted))) return false;
    if (archeWanted != "" && (!variable_instance_exists(src, "archetype") || string_lower(src.archetype) != string_lower(archeWanted))) return false;
    if (variable_instance_exists(src, "star")) {
        if (starEq != undefined && starEq != noone && is_real(starEq)) { if (src.star != starEq) return false; }
        if (src.star < starGte) return false;
        if (src.star > starLte) return false;
    }
    if (fromDeckOnly && !variable_struct_exists(context, "from_deck")) return false;

    // Contraintes de contexte optionnelles (limiter à l’effet/instigateur exact)
    var ctxCrit = {};
    if (variable_struct_exists(effect, "context_criteria")) ctxCrit = effect.context_criteria;
    if (variable_struct_exists(ctxCrit, "initiator_card_id")) {
        if (!variable_struct_exists(context, "initiator_card_id")) return false;
        if (context.initiator_card_id != ctxCrit.initiator_card_id) return false;
    }
    if (variable_struct_exists(ctxCrit, "source_effect_id")) {
        if (!variable_struct_exists(context, "source_effect_id")) return false;
        if (context.source_effect_id != ctxCrit.source_effect_id) return false;
    }
    if (variable_struct_exists(ctxCrit, "owner_is_hero")) {
        if (!variable_struct_exists(context, "owner_is_hero")) return false;
        if (context.owner_is_hero != ctxCrit.owner_is_hero) return false;
    }

    // Propriétaire identique par défaut
    var ownerIsHero = (variable_instance_exists(card, "isHeroOwner") && card.isHeroOwner);
    var srcOwnerIsHero = (variable_instance_exists(src, "isHeroOwner") && src.isHeroOwner);
    if (ownerIsHero != srcOwnerIsHero) return false;

    var slot = getLeftmostFreeMonsterSlot(ownerIsHero);
    if (slot == noone) { show_debug_message("### Aucun slot libre pour l'invocation spéciale"); return false; }

    var handInst = ownerIsHero ? handHero : handEnemy;
    UIManager.selectedSummonOrSet = "SpecialSummon";
    var ok = handInst.summon(src, [slot.x, slot.y, slot.pos]);
    UIManager.selectedSummonOrSet = "";
    return ok;
}

/// @function applySummonBySpec(card, effect, context)
/// @description Exécuteur générique pour tous les modes d’invocation
/// @returns {bool}
function applySummonBySpec(card, effect, context) {
    var mode = "";
    if (variable_struct_exists(effect, "summon_mode")) mode = string_lower(effect.summon_mode);

    if (mode == "token") {
        return summonToken(card, effect, context);
    } else if (mode == "self") {
        return specialSummonSelf(card, effect, context);
    } else if (mode == "named") {
        return specialSummonNamed(card, effect, context);
    } else if (mode == "activate_spell") {
        return activateSpellByCriteria(card, effect, context);
    } else if (mode == "source_from_hand" || mode == "source") {
        return specialSummonSourceFromHandByCriteria(card, effect, context);
    }

    // Fallback heuristique si aucun mode n’est fourni
    if (variable_struct_exists(effect, "token_data")) {
        return summonToken(card, effect, context);
    }
    if (variable_struct_exists(effect, "target_name") || variable_struct_exists(effect, "allowed_sources") || variable_struct_exists(effect, "criteria")) {
        return specialSummonNamed(card, effect, context);
    }
    if (variable_struct_exists(context, "source")) {
        return specialSummonSourceFromHandByCriteria(card, effect, context);
    }
    // À défaut, tenter l’invocation de la carte elle-même si en main
    return specialSummonSelf(card, effect, context);
}