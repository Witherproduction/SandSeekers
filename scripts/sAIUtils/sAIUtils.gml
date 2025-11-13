/// Helpers IA globalisés pour alléger oIA
/// Expose: AI_IsTargetedEffect, AI_EvaluateContinuousNetGain, AI_EstimateCardStrength, AI_EvaluateEffectNetGain

function AI_IsTargetedEffect(effectType) {
    return (effectType == EFFECT_DAMAGE_TARGET
        || effectType == EFFECT_HEAL_TARGET
        || effectType == EFFECT_DESTROY_TARGET
        || effectType == EFFECT_BANISH_TARGET
        || effectType == EFFECT_RETURN_TO_HAND
        || effectType == EFFECT_EQUIP_SELECT_TARGET);
}

/// Évalue le gain net attendu d’une carte Magie continue (auras) sur le terrain actuel
/// Retourne un score (positif si bénéfique, négatif si nuisible)
function AI_EvaluateContinuousNetGain(card) {
    if (card == noone || !instance_exists(card)) return 0;
    if (!variable_struct_exists(card, "effects")) return 0;

    var net = 0;

    for (var i = 0; i < array_length(card.effects); i++) {
        var e = card.effects[i];
        if (!(variable_struct_exists(e, "trigger") && e.trigger == TRIGGER_CONTINUOUS)) continue;

        var eType = variable_struct_exists(e, "effect_type") ? e.effect_type : -1;

        // Aura: buff ATK/DEF par archétype
        if (eType == EFFECT_AURA_ARCHETYPE_BUFF) {
            var archetype = variable_struct_exists(e, "archetype") ? e.archetype : "";
            var atk = variable_struct_exists(e, "atk") ? e.atk : 500;
            var def = variable_struct_exists(e, "def") ? e.def : 500;
            var delta = atk + def;
            // Parcourir les monstres sur le terrain
            for (var s = 0; s < 5; s++) {
                var mHero = fieldMonsterHero.cards[s];
                if (mHero != 0 && instance_exists(mHero)) {
                    var matchH = (variable_instance_exists(mHero, "archetype") && string_lower(mHero.archetype) == string_lower(archetype));
                    if (matchH) net -= delta; // buff côté héros => négatif pour l’IA
                }
                var mEnemy = fieldMonsterEnemy.cards[s];
                if (mEnemy != 0 && instance_exists(mEnemy)) {
                    var matchE = (variable_instance_exists(mEnemy, "archetype") && string_lower(mEnemy.archetype) == string_lower(archetype));
                    if (matchE) net += delta; // buff côté ennemi (IA) => positif
                }
            }
        }

        // Aura: debuff ATK/DEF pour tous les monstres
        else if (eType == EFFECT_AURA_ALL_MONSTERS_DEBUFF) {
            var atk2 = variable_struct_exists(e, "atk") ? e.atk : -500;
            var def2 = variable_struct_exists(e, "def") ? e.def : -500;
            var delta2 = atk2 + def2; // généralement négatif
            // Exclusions de genres éventuelles
            var excludeGenres = [];
            if (variable_struct_exists(e, "exclude_genres")) {
                excludeGenres = is_array(e.exclude_genres) ? e.exclude_genres : [e.exclude_genres];
            }

            for (var s2 = 0; s2 < 5; s2++) {
                var h = fieldMonsterHero.cards[s2];
                if (h != 0 && instance_exists(h)) {
                    var excludedH = false;
                    if (array_length(excludeGenres) > 0 && variable_instance_exists(h, "genre")) {
                        var gh = string_lower(h.genre);
                        for (var gi = 0; gi < array_length(excludeGenres); gi++) {
                            if (gh == string_lower(string(excludeGenres[gi]))) { excludedH = true; break; }
                        }
                    }
                    if (!excludedH) {
                        // Debuff côté héros => bénéfice pour l’IA: inverse le signe
                        net += -(delta2);
                    }
                }

                var eMon = fieldMonsterEnemy.cards[s2];
                if (eMon != 0 && instance_exists(eMon)) {
                    var excludedE = false;
                    if (array_length(excludeGenres) > 0 && variable_instance_exists(eMon, "genre")) {
                        var ge = string_lower(eMon.genre);
                        for (var gj = 0; gj < array_length(excludeGenres); gj++) {
                            if (ge == string_lower(string(excludeGenres[gj]))) { excludedE = true; break; }
                        }
                    }
                    if (!excludedE) {
                        // Debuff côté ennemi (IA) => coût: on ajoute delta2 (négatif)
                        net += delta2;
                    }
                }
            }
        }

        // D’autres effets continus pourront être évalués ici si nécessaire
    }

    return net;
}

/// Estime la "valeur" d’un monstre (ATK+DEF effectifs)
function AI_EstimateCardStrength(mon) {
    if (mon == noone || !instance_exists(mon)) return 0;
    var atk = variable_instance_exists(mon, "attack") ? mon.attack : 0;
    var def = variable_instance_exists(mon, "defense") ? mon.defense : 0;
    var eatk = variable_instance_exists(mon, "effective_attack") ? mon.effective_attack : atk;
    var edef = variable_instance_exists(mon, "effective_defense") ? mon.effective_defense : def;
    return max(0, eatk + edef);
}

/// Évalue le gain net attendu d’un effet manuel (monstre/magie), en fonction de sa cible
/// Retourne un score (positif si bénéfique, négatif si nuisible). Si aucune cible, tente une estimation.
function AI_EvaluateEffectNetGain(card, effect, target) {
    if (card == noone || !instance_exists(card) || !is_struct(effect)) return 0;
    var type = variable_struct_exists(effect, "effect_type") ? effect.effect_type : -1;
    var net = 0;

    // Helper: signe selon propriétaire de la cible
    var targetIsHero = (target != noone && instance_exists(target) && variable_instance_exists(target, "isHeroOwner") && target.isHeroOwner);

    switch (type) {
        case EFFECT_DRAW_CARDS: {
            var count = 1;
            if (variable_struct_exists(effect, "value")) count = max(1, effect.value);
            else if (variable_struct_exists(effect, "amount")) count = max(1, effect.amount);
            var cap = (variable_global_exists("MAX_HAND_SIZE") ? global.MAX_HAND_SIZE : 10);
            var current = (instance_exists(handEnemy) ? ds_list_size(handEnemy.cards) : 0);
            var freeSlots = max(0, cap - current);
            var effectiveCount = min(count, freeSlots);
            net = (effectiveCount <= 0) ? 0 : (350 * effectiveCount);
            break;
        }
        case EFFECT_SEARCH: {
            var dest = variable_struct_exists(effect, "destination") ? string_lower(effect.destination) : "hand";
            var maxTargets = variable_struct_exists(effect, "max_targets") ? max(1, effect.max_targets) : 1;
            var perCard = (dest == "hand") ? 450 : 120;
            if (dest == "hand") {
                var cap2 = (variable_global_exists("MAX_HAND_SIZE") ? global.MAX_HAND_SIZE : 10);
                var current2 = (instance_exists(handEnemy) ? ds_list_size(handEnemy.cards) : 0);
                var freeSlots2 = max(0, cap2 - current2);
                var effectiveTargets = min(maxTargets, freeSlots2);
                net = (effectiveTargets <= 0) ? 0 : (perCard * effectiveTargets);
            } else {
                net = perCard * maxTargets;
            }
            break;
        }
        case EFFECT_DESTROY_TARGET: {
            var val = AI_EstimateCardStrength(target);
            net = (targetIsHero ? +val : -val);
            break;
        }
        // Destruction non ciblée (ex. « Sacrifice pour la meute »):
        // évalue la perte attendue côté IA et le gain attendu côté ennemi selon les critères.
        case EFFECT_DESTROY: {
            // Helper pour récupérer les candidats selon owner/criteria
            var sumValues = 0;
            var countValues = 0;
            var destroyCount = 1;
            var randomSelect = false;
            var ownerSide = "enemy"; // par défaut on considère que la cible est côté héros
            var criteriaType = "";
            var criteriaGenre = "";

            if (variable_struct_exists(effect, "destroy_count")) destroyCount = max(1, effect.destroy_count);
            if (variable_struct_exists(effect, "random_select")) randomSelect = effect.random_select;
            if (variable_struct_exists(effect, "owner")) ownerSide = string_lower(effect.owner);
            if (variable_struct_exists(effect, "criteria")) {
                var crit = effect.criteria;
                if (is_struct(crit)) {
                    criteriaType = (variable_struct_exists(crit, "type") ? string_lower(crit.type) : "");
                    criteriaGenre = (variable_struct_exists(crit, "genre") ? string(crit.genre) : "");
                }
            }

            // Sélectionne le plateau côté IA (ally) ou héros (enemy)
            var listCards = [];
            var isAlly = (ownerSide == "ally");
            var fieldList = isAlly ? fieldMonsterEnemy.cards : fieldMonsterHero.cards;
            for (var i = 0; i < array_length(fieldList); i++) {
                var cnd = fieldList[i];
                if (cnd != 0 && instance_exists(cnd)) {
                    // Filtre par type
                    if (criteriaType != "" && variable_instance_exists(cnd, "type")) {
                        if (string_lower(cnd.type) != criteriaType) continue;
                    }
                    // Filtre par genre
                    if (criteriaGenre != "" && variable_instance_exists(cnd, "genre")) {
                        if (string(cnd.genre) != criteriaGenre) continue;
                    }
                    array_push(listCards, cnd);
                }
            }

            var availableCount = array_length(listCards);
            if (availableCount <= 0) {
                // Aucun candidat: effet sans impact
                net += 0;
            } else {
                // Valeur attendue: approximation par moyenne des forces disponibles
                for (var j = 0; j < availableCount; j++) {
                    sumValues += AI_EstimateCardStrength(listCards[j]);
                    countValues++;
                }
                var avgVal = (countValues > 0) ? (sumValues / countValues) : 0;
                var expectedCount = min(destroyCount, availableCount);
                var expectedImpact = avgVal * expectedCount;
                // Détruire côté ally => coût (perte IA). Côté enemy => bénéfice.
                net += isAlly ? -(expectedImpact) : +(expectedImpact);
            }

            // Évalue un éventuel « flow » destructif enchaîné (ex.: détruire ensuite un monstre ennemi)
            if (variable_struct_exists(effect, "flow") && is_struct(effect.flow)) {
                var flow = effect.flow;
                var flowType = (variable_struct_exists(flow, "effect_type") ? flow.effect_type : -1);
                if (flowType == EFFECT_DESTROY) {
                    var fDestroyCount = (variable_struct_exists(flow, "destroy_count") ? max(1, flow.destroy_count) : 1);
                    var fOwnerSide = (variable_struct_exists(flow, "owner") ? string_lower(flow.owner) : "enemy");
                    var fCriteriaType = "";
                    var fCriteriaGenre = "";
                    if (variable_struct_exists(flow, "criteria") && is_struct(flow.criteria)) {
                        var fcrit = flow.criteria;
                        fCriteriaType = (variable_struct_exists(fcrit, "type") ? string_lower(fcrit.type) : "");
                        fCriteriaGenre = (variable_struct_exists(fcrit, "genre") ? string(fcrit.genre) : "");
                    }
                    var fList = [];
                    var fIsAlly = (fOwnerSide == "ally");
                    var fField = fIsAlly ? fieldMonsterEnemy.cards : fieldMonsterHero.cards;
                    for (var fi = 0; fi < array_length(fField); fi++) {
                        var fc = fField[fi];
                        if (fc != 0 && instance_exists(fc)) {
                            if (fCriteriaType != "" && variable_instance_exists(fc, "type")) {
                                if (string_lower(fc.type) != fCriteriaType) continue;
                            }
                            if (fCriteriaGenre != "" && variable_instance_exists(fc, "genre")) {
                                if (string(fc.genre) != fCriteriaGenre) continue;
                            }
                            array_push(fList, fc);
                        }
                    }
                    var fAvail = array_length(fList);
                    if (fAvail > 0) {
                        var fSum = 0; var fCnt = 0;
                        for (var fk = 0; fk < fAvail; fk++) { fSum += AI_EstimateCardStrength(fList[fk]); fCnt++; }
                        var fAvg = (fCnt > 0) ? (fSum / fCnt) : 0;
                        var fExpected = fAvg * min(fDestroyCount, fAvail);
                        net += fIsAlly ? -(fExpected) : +(fExpected);
                    }
                }
            }
            break;
        }
        case EFFECT_BANISH_TARGET: {
            var val2 = AI_EstimateCardStrength(target);
            net = (targetIsHero ? +floor(val2 * 1.2) : -floor(val2 * 1.2));
            break;
        }
        case EFFECT_RETURN_TO_HAND: {
            var val3 = AI_EstimateCardStrength(target);
            net = (targetIsHero ? +floor(val3 * 0.6) : -floor(val3 * 0.6));
            break;
        }
        case EFFECT_DAMAGE_TARGET: {
            var amount = 0;
            if (variable_struct_exists(effect, "amount")) amount = effect.amount; else if (variable_struct_exists(effect, "damage")) amount = effect.damage; else amount = 300;
            net = (targetIsHero ? +amount : -amount);
            break;
        }
        case EFFECT_HEAL_TARGET: {
            var amountH = 0;
            if (variable_struct_exists(effect, "amount")) amountH = effect.amount; else if (variable_struct_exists(effect, "heal")) amountH = effect.heal; else amountH = 300;
            net = (targetIsHero ? -amountH : +amountH);
            break;
        }
        case EFFECT_EQUIP_SELECT_TARGET: {
            var baseBuff = variable_struct_exists(effect, "base_buff") ? effect.base_buff : 500;
            var extraBuff = variable_struct_exists(effect, "extra_buff") ? effect.extra_buff : 500;
            var atkBuff = baseBuff;
            var defBuff = baseBuff;
            if (variable_struct_exists(effect, "atk_buff") || variable_struct_exists(effect, "def_buff")) {
                atkBuff = variable_struct_exists(effect, "atk_buff") ? effect.atk_buff : 0;
                defBuff = variable_struct_exists(effect, "def_buff") ? effect.def_buff : 0;
            }
            var bonus = false;
            if (target != noone && instance_exists(target)) {
                var objName = object_get_name(target.object_index);
                if (variable_struct_exists(effect, "bonus_if_names")) {
                    var names = effect.bonus_if_names;
                    for (var i = 0; i < array_length(names); i++) { if (objName == names[i]) { bonus = true; break; } }
                }
                if (!bonus && variable_struct_exists(effect, "bonus_if_archetype")) {
                    if (variable_instance_exists(target, "archetype") && target.archetype == effect.bonus_if_archetype) { bonus = true; }
                }
                if (!bonus && variable_struct_exists(effect, "bonus_if_genre")) {
                    if (variable_instance_exists(target, "genre") && target.genre == effect.bonus_if_genre) { bonus = true; }
                }
            }
            var totalBuff = atkBuff + defBuff + (bonus ? extraBuff : 0);
            net = (targetIsHero ? -totalBuff : +totalBuff);
            break;
        }
        default: {
            net = 0;
            break;
        }
    }

    // Bonus contextuel pour privilégier les actions menant à la victoire
    net += AI_SituationPriorityBonus(effect, target);

    return net;
}

/// Bonus contextuel de priorité selon la situation (LP, board, main)
function AI_SituationPriorityBonus(effect, target) {
    if (!is_struct(effect)) return 0;
    var bonus = 0;
    var eType = variable_struct_exists(effect, "effect_type") ? effect.effect_type : -1;

    // Lecture LP et contexte
    var enemyLP = (instance_exists(LP_Hero) && variable_instance_exists(LP_Hero, "nbLP")) ? LP_Hero.nbLP : 8000;
    var ourLP   = (instance_exists(LP_Enemy) && variable_instance_exists(LP_Enemy, "nbLP")) ? LP_Enemy.nbLP : 8000;
    var handCount = (ds_exists(handEnemy.cards, ds_type_list)) ? ds_list_size(handEnemy.cards) : 0;

    // Évaluation du plateau
    var sumOur = 0; var sumHero = 0;
    for (var i = 0; i < 5; i++) {
        var me = fieldMonsterEnemy.cards[i];
        var he = fieldMonsterHero.cards[i];
        if (me != 0 && instance_exists(me)) sumOur  += AI_EstimateCardStrength(me);
        if (he != 0 && instance_exists(he)) sumHero += AI_EstimateCardStrength(he);
    }
    var boardDelta = sumOur - sumHero; // <0: on perd le board, >0: on mène

    var targetIsHero = (target != noone && instance_exists(target) && variable_instance_exists(target, "isHeroOwner") && target.isHeroOwner);

    switch (eType) {
        case EFFECT_DAMAGE_TARGET: {
            var amount = 0; if (variable_struct_exists(effect, "amount")) amount = effect.amount; else if (variable_struct_exists(effect, "damage")) amount = effect.damage; else amount = 300;
            // Létal immédiat
            if (targetIsHero && amount >= enemyLP) { bonus += 8000; }
            // Sinon, favoriser les dégâts surtout si on domine le board
            else if (targetIsHero) { bonus += floor(amount * (boardDelta >= 0 ? 1.5 : 1.0)); }
            break;
        }
        case EFFECT_HEAL_TARGET: {
            var amountH = 0; if (variable_struct_exists(effect, "amount")) amountH = effect.amount; else if (variable_struct_exists(effect, "heal")) amountH = effect.heal; else amountH = 300;
            // Prioriser les soins si notre LP est bas
            if (!targetIsHero) {
                if (ourLP <= 2000) { bonus += amountH * 2 + max(0, 2000 - ourLP); }
                else if (ourLP <= 4000) { bonus += floor(amountH * 1.0); }
                else { bonus += floor(amountH * 0.25); }
            }
            break;
        }
        case EFFECT_DESTROY_TARGET: {
            if (target != noone && instance_exists(target)) {
                var val = AI_EstimateCardStrength(target);
                // Favoriser le retrait de menaces, surtout si l’on perd le board
                bonus += floor(val * (boardDelta < 0 ? 1.2 : 0.8));
            }
            break;
        }
        case EFFECT_BANISH_TARGET: {
            if (target != noone && instance_exists(target)) {
                var valB = AI_EstimateCardStrength(target);
                bonus += floor(valB * (boardDelta < 0 ? 1.1 : 0.75));
            }
            break;
        }
        case EFFECT_RETURN_TO_HAND: {
            if (target != noone && instance_exists(target)) {
                var valR = AI_EstimateCardStrength(target);
                bonus += floor(valR * (boardDelta < 0 ? 0.9 : 0.6));
            }
            break;
        }
        case EFFECT_DRAW_CARDS: {
            var count = 1; if (variable_struct_exists(effect, "value")) count = max(1, effect.value);
            // Main pauvre ou board désavantage → piocher est plus précieux
            if (handCount <= 2) bonus += 400 * count;
            if (boardDelta < 0) bonus += 200 * count;
            break;
        }
        default: {
            // Pas de bonus pour les autres effets par défaut
            break;
        }
    }

    // Ajustements globaux légers
    if (boardDelta < 0) { bonus = floor(bonus * 1.1); }
    return bonus;
}