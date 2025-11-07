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

    return net;
}