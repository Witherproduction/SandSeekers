/// Fonctions de gestion des Artefacts (équipements) — généralisées

function equipSelectTarget(card, effect, context) {
    if (card == noone || !instance_exists(card)) return false;
    var target = variable_struct_exists(context, "target") ? context.target : noone;
    if (target == noone || !instance_exists(target)) return false;
    // Valider cible: monstre sur le terrain (par héritage OU par type)
    var isMonsterByAncestry = object_is_ancestor(target.object_index, oCardMonster);
    var isMonsterByType = (variable_instance_exists(target, "type") && string_lower(target.type) == "monster");
    if (!(isMonsterByAncestry || isMonsterByType)) {
        show_debug_message("### Equip: cible non-monstre refusée");
        return false;
    }
    if (!(variable_instance_exists(target, "zone") && (target.zone == "Field" || target.zone == "FieldSelected"))) return false;
    // Interdire cible en défense face cachée
    if (variable_instance_exists(target, "orientation") && variable_instance_exists(target, "isFaceDown")) {
        if (target.orientation == "Defense" && target.isFaceDown) {
            show_debug_message("### Equip: cible en défense cachée refusée");
            if (variable_instance_exists(card, "equip_pending")) card.equip_pending = false;
            return false;
        }
    }
    // Restriction allégeance paramétrable
    var allyOnly = variable_struct_exists(effect, "ally_only") ? effect.ally_only : false;
    if (allyOnly && variable_instance_exists(card, "isHeroOwner") && variable_instance_exists(target, "isHeroOwner") && card.isHeroOwner != target.isHeroOwner) {
        show_debug_message("### Equip: cible adverse refusée");
        return false;
    }
    // Restriction de genre (Humanoïde/Bête, etc.) si précisée sur l'effet
    if (variable_struct_exists(effect, "allowed_genres")) {
        var targetGenre = string_lower(variable_instance_exists(target, "genre") ? target.genre : "");
        var genreOk = false;
        var gWanted = effect.allowed_genres;
        if (is_array(gWanted)) {
            for (var gi = 0; gi < array_length(gWanted); gi++) {
                var wanted = string_lower(gWanted[gi]);
                if (targetGenre == wanted) { genreOk = true; break; }
            }
        } else if (is_string(gWanted)) {
            genreOk = (targetGenre == string_lower(gWanted));
        }
        if (!genreOk) {
            show_debug_message("### Equip: genre refusé pour cible=" + string(targetGenre));
            if (variable_instance_exists(card, "equip_pending")) card.equip_pending = false;
            return false;
        }
    }
    // Poser l'équipement sur le terrain si depuis la main
    if (variable_instance_exists(card, "zone") && (card.zone == "Hand" || card.zone == "HandSelected")) {
        var ownerIsHero = variable_instance_exists(card, "isHeroOwner") ? card.isHeroOwner : true;
        var fieldMgr = ownerIsHero ? fieldManagerHero : fieldManagerEnemy;
        if (fieldMgr == noone) { show_debug_message("### Equip: fieldMgr manquant"); return false; }
        var magicField = fieldMgr.getField("MagicTrap");
        var pos = -1;
        for (var i = 0; i < array_length(magicField.cards); i++) { if (magicField.cards[i] == 0) { pos = i; break; } }
        if (pos == -1) { show_debug_message("### Equip: aucun slot Magie libre"); return false; }
        var XY = fieldMgr.getPosLocation("MagicTrap", pos);
        UIManager.selectedSummonOrSet = "Summon";
        var summonedOK = (ownerIsHero ? handHero : handEnemy).summon(card, [XY[0], XY[1], pos]);
        UIManager.selectedSummonOrSet = "";
        var ctxEquip = { summon_mode: "Summon", owner_is_hero: ownerIsHero };
        registerTriggerEvent(TRIGGER_ON_SUMMON, card, ctxEquip);
        registerTriggerEvent(TRIGGER_ON_SPELL_CAST, card, ctxEquip);
        // Tolérance: certaines implémentations de oHand.summon ne retournent pas explicitement un booléen.
        // Considérer la pose réussie si la carte est bien passée en zone Field après l'appel.
        if (!summonedOK) {
            if (variable_instance_exists(card, "zone") && card.zone == "Field") {
                summonedOK = true;
            }
        }
        if (!summonedOK) { return false; }
    }
    // Lier la cible
    card.equipped_target = target;
    // Fin du ciblage en cours pour cet équipement
    if (variable_instance_exists(card, "equip_pending")) card.equip_pending = false;
    show_debug_message("### Equip: " + string(card.name) + " -> cible=" + string(target.name));

    // Appliquer immédiatement le buff d'équipement si un effet correspondant est présent,
    // afin d'éviter d'attendre le cycle d'effets continus du Step.
    if (variable_instance_exists(card, "effects") && is_array(card.effects)) {
        for (var bi = 0; bi < array_length(card.effects); bi++) {
            var beff = card.effects[bi];
            if (is_struct(beff) && variable_struct_exists(beff, "effect_type") && beff.effect_type == EFFECT_BUFF && variable_struct_exists(beff, "scope") && string_lower(beff.scope) == "equip") {
                executeEffect(card, beff, {});
                break;
            }
        }
    }
    return true;
}


function equipCleanup(card, effect, context) {
    if (card == noone || !instance_exists(card)) return false;
    var t2 = (variable_instance_exists(card, "equipped_target")) ? card.equipped_target : noone;
    if (t2 != noone && instance_exists(t2)) {
        var srcKey = "equip:" + string(card.id);
        buffRemoveContribution(t2, srcKey);
        buffRecompute(t2);
    }
    card.equipped_target = noone;
    if (variable_instance_exists(card, "equip_pending")) card.equip_pending = false;
    show_debug_message("### Equip: nettoyage sur destruction pour " + string(card.name));
    return true;
}