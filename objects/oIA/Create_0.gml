if (variable_global_exists("VERBOSE_LOGS") && global.VERBOSE_LOGS) show_debug_message("### oIA.create")

///////////////////////////////////////////////////////////////////////
// Méthodes
///////////////////////////////////////////////////////////////////////

if (!variable_global_exists("IA_ACTION_DELAY_FRAMES")) global.IA_ACTION_DELAY_FRAMES = 2 * room_speed;
if (!variable_instance_exists(id, "iaDelayFrames")) iaDelayFrames = 0;
if (!variable_instance_exists(id, "iaNextPhasePending")) iaNextPhasePending = false;
scheduleNextPhase = function() { iaNextPhasePending = true; iaDelayFrames = (variable_global_exists("IA_ACTION_DELAY_FRAMES") ? global.IA_ACTION_DELAY_FRAMES : room_speed); };
#region Function manageOrientation
manageOrientation = function() {
    if (variable_global_exists("VERBOSE_LOGS") && global.VERBOSE_LOGS) show_debug_message("### oIA.manageOrientation")
    
    var dif = (variable_global_exists("IA_DIFFICULTY") ? global.IA_DIFFICULTY : 0);

    // Parcourt les monstres de l'IA pour optimiser leur orientation
    for (var i = 0; i < 5; i++) {
        var cardEnemy = fieldMonsterEnemy.cards[i];
        var shouldDefend = false;

        // Nettoyage des références invalides
        if (cardEnemy != 0 && !instance_exists(cardEnemy)) {
            fieldMonsterEnemy.cards[i] = 0;
            continue;
        }

        if (cardEnemy != 0 && instance_exists(cardEnemy) && !cardEnemy.orientationChangedThisTurn) {
            // Si la carte est face cachée, l'IA peut décider de la retourner en attaque
            if (cardEnemy.isFaceDown) {
                var canAttackEffectively = false;
                var heroHasMonsters = false;
                for (var j = 0; j < array_length(fieldMonsterHero.cards); j++) {
                    var cardHero = fieldMonsterHero.cards[j];
                    if (cardHero != 0 && instance_exists(cardHero)) {
                        heroHasMonsters = true;
                        var effEnemyAtk = variable_struct_exists(cardEnemy, "effective_attack") ? cardEnemy.effective_attack : cardEnemy.attack;
                        var effHeroAtk = variable_struct_exists(cardHero, "effective_attack") ? cardHero.effective_attack : cardHero.attack;
                        var effHeroDef = variable_struct_exists(cardHero, "effective_defense") ? cardHero.effective_defense : cardHero.defense;
                        if (dif == 1) {
                            if (effEnemyAtk > max(effHeroAtk, effHeroDef)) { canAttackEffectively = true; break; }
                        } else {
                            if (effEnemyAtk > effHeroAtk || effEnemyAtk > effHeroDef) { canAttackEffectively = true; break; }
                        }
                    }
                }
                if (!heroHasMonsters || canAttackEffectively) {
                    cardEnemy.orientation = "Attack";
                    cardEnemy.position_anim_active = true;
                    cardEnemy.anim_rotate_speed = (variable_global_exists("ANIM_ROTATE_SPEED") ? global.ANIM_ROTATE_SPEED : 6);
                    cardEnemy.anim_flip_speed = (variable_global_exists("ANIM_FLIP_SPEED") ? global.ANIM_FLIP_SPEED : 0.03);
                    cardEnemy.anim_flip_orig_scale = cardEnemy.image_xscale;
                    cardEnemy.anim_pre_delay_frames = (variable_global_exists("ANIM_ROTATE_PRE_DELAY_FRAMES") ? global.ANIM_ROTATE_PRE_DELAY_FRAMES : 6);
                    cardEnemy.anim_phase = "flip_in";
                    cardEnemy.target_angle = 180;
                    cardEnemy.target_orientation = "Attack";
                    cardEnemy.image_index = 0;
                    cardEnemy.orientationChangedThisTurn = true;
                    if (variable_global_exists("VERBOSE_LOGS") && global.VERBOSE_LOGS) show_debug_message("IA retourne monstre face cachée en attaque (anim)");
                }
            }

            // Analyser les menaces du héros
            for (var j = 0; j < array_length(fieldMonsterHero.cards); j++) {
                var cardHero = fieldMonsterHero.cards[j];
                if (cardHero != 0 && instance_exists(cardHero) && instance_exists(cardEnemy)) {
                    if (dif == 1) {
                        var eAtkE = variable_struct_exists(cardEnemy, "effective_attack") ? cardEnemy.effective_attack : cardEnemy.attack;
                        var eDefE = variable_struct_exists(cardEnemy, "effective_defense") ? cardEnemy.effective_defense : cardEnemy.defense;
                        var eAtkH = variable_struct_exists(cardHero, "effective_attack") ? cardHero.effective_attack : cardHero.attack;
                        var eDefH = variable_struct_exists(cardHero, "effective_defense") ? cardHero.effective_defense : cardHero.defense;
                        if ((eAtkH >= eDefE && eAtkE < eDefH) || (eAtkH > eDefE && eDefE > eAtkE)) { shouldDefend = true; break; }
                    } else {
                        if (cardHero.attack >= cardEnemy.defense && cardEnemy.attack < cardHero.defense) { shouldDefend = true; break; }
                        if (cardHero.attack > cardEnemy.defense && cardEnemy.defense > cardEnemy.attack) { shouldDefend = true; break; }
                    }
                }
            }

            // Changer l'orientation si nécessaire
            if (instance_exists(cardEnemy)) {
                if (shouldDefend && cardEnemy.orientation == "Attack") {
                    cardEnemy.orientation = "DefenseVisible";
                    cardEnemy.position_anim_active = true;
                    cardEnemy.anim_rotate_speed = (variable_global_exists("ANIM_ROTATE_SPEED") ? global.ANIM_ROTATE_SPEED : 6);
                    cardEnemy.anim_flip_speed = (variable_global_exists("ANIM_FLIP_SPEED") ? global.ANIM_FLIP_SPEED : 0.03);
                    cardEnemy.anim_flip_orig_scale = cardEnemy.image_xscale;
                    cardEnemy.anim_pre_delay_frames = (variable_global_exists("ANIM_ROTATE_PRE_DELAY_FRAMES") ? global.ANIM_ROTATE_PRE_DELAY_FRAMES : 6);
                    cardEnemy.anim_phase = "rotate";
                    cardEnemy.target_angle = 270;
                    cardEnemy.target_orientation = "DefenseVisible";
                    cardEnemy.image_index = 0;
                    if (variable_instance_exists(cardEnemy.id, "isFaceDown")) cardEnemy.isFaceDown = false;
                    cardEnemy.orientationChangedThisTurn = true;
                    if (variable_global_exists("VERBOSE_LOGS") && global.VERBOSE_LOGS) show_debug_message("IA change monstre en défense visible (anim)");
                } else if (!shouldDefend && (cardEnemy.orientation == "Defense" || cardEnemy.orientation == "DefenseVisible")) {
                    cardEnemy.orientation = "Attack";
                    cardEnemy.position_anim_active = true;
                    cardEnemy.anim_rotate_speed = (variable_global_exists("ANIM_ROTATE_SPEED") ? global.ANIM_ROTATE_SPEED : 6);
                    cardEnemy.anim_flip_speed = (variable_global_exists("ANIM_FLIP_SPEED") ? global.ANIM_FLIP_SPEED : 0.03);
                    cardEnemy.anim_flip_orig_scale = cardEnemy.image_xscale;
                    cardEnemy.anim_pre_delay_frames = (variable_global_exists("ANIM_ROTATE_PRE_DELAY_FRAMES") ? global.ANIM_ROTATE_PRE_DELAY_FRAMES : 6);
                    cardEnemy.anim_phase = "rotate";
                    cardEnemy.target_angle = 180;
                    cardEnemy.target_orientation = "Attack";
                    cardEnemy.image_index = 0;
                    cardEnemy.orientationChangedThisTurn = true;
                    if (variable_global_exists("VERBOSE_LOGS") && global.VERBOSE_LOGS) show_debug_message("IA change monstre en attaque (anim)");
                }
            }
        }
    }
}
#endregion

#region Function evaluateCardPriority
evaluateCardPriority = function(card) {
    var priority = 0;
    if (card == 0 || !instance_exists(card)) return -100000;
    if (card.type != "Monster") return -100000;

    var dif = (variable_global_exists("IA_DIFFICULTY") ? global.IA_DIFFICULTY : 0);

    // Base: stats
    var atk = variable_instance_exists(card, "attack") ? card.attack : 0;
    var def = variable_instance_exists(card, "defense") ? card.defense : 0;
    var stars = variable_instance_exists(card, "star") ? card.star : 0;
    priority += atk * 10 + def * 5;

    // Vérifier invocabilité (sacrifices)
    var reqLevel = getSacrificeLevel(stars);
    var reqCount = (reqLevel == 0) ? 0 : (reqLevel == 1 ? 1 : 2);
    var available = 0;
    for (var i = 0; i < 5; i++) { if (fieldMonsterEnemy.cards[i] != 0) available++; }
    if (reqCount <= available) {
        priority += stars * 50; // bonus si invocable
    } else {
        priority -= 100000; // pas invocable maintenant
    }

    // Malus/bonus selon plateau (Difficile uniquement)
    if (dif == 1) {
        var heroHas = false; var heroMaxAtk = 0; var heroMaxDef = 0;
        for (var hi = 0; hi < 5; hi++) {
            var h = fieldMonsterHero.cards[hi];
            if (h != 0 && instance_exists(h)) {
                heroHas = true;
                var ha = variable_struct_exists(h, "effective_attack") ? h.effective_attack : h.attack;
                var hd = variable_struct_exists(h, "effective_defense") ? h.effective_defense : h.defense;
                heroMaxAtk = max(heroMaxAtk, ha);
                heroMaxDef = max(heroMaxDef, hd);
            }
        }
        var emptySlots = 0; for (var i2 = 0; i2 < 5; i2++) if (fieldMonsterEnemy.cards[i2] == 0) emptySlots++;
        if (reqCount == 0 && emptySlots > 0) { priority += 120; }
        if (heroHas) {
            if (atk > heroMaxDef) priority += 200; // peut passer en attaque
            else if (def >= heroMaxAtk) priority += 120; // bon bloqueur
            else priority -= 100; // faible dans l'immédiat
        }
    } else {
        // Malus si terrain plein (comportement existant)
        var emptySlotsNorm = 0; for (var i3 = 0; i3 < 5; i3++) if (fieldMonsterEnemy.cards[i3] == 0) emptySlotsNorm++;
        if (emptySlotsNorm == 0) priority -= 500;
    }

    return priority;
}
#endregion

#region Function pick
pick = function() {
    if (variable_global_exists("VERBOSE_LOGS") && global.VERBOSE_LOGS) show_debug_message("### oIA.pick")
    deckEnemy.pick();
    if (instance_exists(game) && !game.timerEnabledPick) { scheduleNextPhase(); }
}
#endregion

#region IA Effect Helpers
// Délégation aux scripts globaux pour alléger le code de l’objet
aiIsTargetedEffect = function(effectType) { return AI_IsTargetedEffect(effectType); }
aiEvaluateContinuousNetGain = function(card) { return AI_EvaluateContinuousNetGain(card); }
aiEstimateCardStrength = function(mon) { return AI_EstimateCardStrength(mon); }
aiEvaluateEffectNetGain = function(card, effect, target) { return AI_EvaluateEffectNetGain(card, effect, target); }

aiChooseBestTarget = function(effectType) {
    var best = noone; var bestScore = -100000;
    var dif = (variable_global_exists("IA_DIFFICULTY") ? global.IA_DIFFICULTY : 0);

    // Monstres héros
    for (var i = 0; i < array_length(fieldMonsterHero.cards); i++) {
        var cand = fieldMonsterHero.cards[i];
        if (cand != 0 && instance_exists(cand)) {
            var atk = variable_instance_exists(cand, "attack") ? cand.attack : 0;
            var def = variable_instance_exists(cand, "defense") ? cand.defense : 0;
            var eatk = variable_struct_exists(cand, "effective_attack") ? cand.effective_attack : atk;
            var edef = variable_struct_exists(cand, "effective_defense") ? cand.effective_defense : def;
            var sc = max(atk, def);
            if (dif == 1) {
                var scHard = max(eatk, edef);
                if (variable_instance_exists(cand, "orientation") && cand.orientation == "Attack") scHard += 80;
                sc = scHard;
            }
            if (sc > bestScore) { bestScore = sc; best = cand; }
        }
    }
    // Magies/Pièges si aucun monstre sélectionné
    if (best == noone) {
        var mt = fieldManagerHero.getField("MagicTrap");
        if (mt != noone && variable_struct_exists(mt, "cards")) {
            for (var j = 0; j < array_length(mt.cards); j++) {
                var m = mt.cards[j];
                if (m != 0 && instance_exists(m)) { var sc2 = (dif == 1) ? 150 : 100; if (sc2 > bestScore) { bestScore = sc2; best = m; } }
            }
        }
    }
    return best;
}

aiEffectPriority = function(card, effect) {
    var base = 0;
    var eType = variable_struct_exists(effect, "effect_type") ? effect.effect_type : -1;
    var dif = (variable_global_exists("IA_DIFFICULTY") ? global.IA_DIFFICULTY : 0);

    var heroHas = false; var ourCount = 0;
    for (var i = 0; i < 5; i++) { if (fieldMonsterHero.cards[i] != 0 && instance_exists(fieldMonsterHero.cards[i])) heroHas = true; if (fieldMonsterEnemy.cards[i] != 0 && instance_exists(fieldMonsterEnemy.cards[i])) ourCount++; }

    if (eType == EFFECT_DESTROY_TARGET || eType == EFFECT_BANISH_TARGET || eType == EFFECT_RETURN_TO_HAND) {
        var tgt = aiChooseBestTarget(eType);
        var tAtk = (tgt != noone && variable_instance_exists(tgt, "attack")) ? tgt.attack : 0;
        base = 1000 + tAtk;
        if (dif == 1 && heroHas) base += 300;
    } else if (eType == EFFECT_GAIN_ATTACK || eType == EFFECT_GAIN_DEFENSE || eType == EFFECT_SET_ATTACK || eType == EFFECT_SET_DEFENSE) {
        base = 600;
        if (dif == 1 && ourCount > 0) base += 150;
    } else if (eType == EFFECT_DRAW_CARDS || eType == EFFECT_SEARCH) {
        base = 300;
        if (dif == 1 && ourCount == 0) base += 150; // chercher du tempo si board vide
    } else if (eType == EFFECT_SUMMON) {
        var emptySlots = 0; for (var i2 = 0; i2 < 5; i2++) { if (fieldMonsterEnemy.cards[i2] == 0) emptySlots++; }
        base = (emptySlots > 0) ? 500 : 50;
        if (dif == 1 && emptySlots > 0) base += 100;
    } else if (eType == EFFECT_NEGATE_EFFECT) {
        var mt = fieldManagerHero.getField("MagicTrap"); var hasMT = false;
        if (mt != noone && variable_struct_exists(mt, "cards")) {
            for (var i3 = 0; i3 < array_length(mt.cards); i3++) { if (mt.cards[i3] != 0 && instance_exists(mt.cards[i3])) { hasMT = true; break; } }
        }
        base = hasMT ? 900 : 200;
        if (dif == 1 && hasMT) base += 150;
    } else {
        base = 200;
    }
    return base;
}

// Sélectionne la meilleure cible d'équipement (Artéfact) parmi nos monstres
aiChooseBestEquipTargetFor = function(card, effect) {
    var best = noone; var bestScore = -100000;
    var allyOnly = variable_struct_exists(effect, "ally_only") ? effect.ally_only : true;
    var allowedGenres = variable_struct_exists(effect, "allowed_genres") ? effect.allowed_genres : undefined;
    for (var i = 0; i < array_length(fieldMonsterEnemy.cards); i++) {
        var cand = fieldMonsterEnemy.cards[i];
        if (cand != 0 && instance_exists(cand)) {
            if (!(variable_instance_exists(cand, "zone") && (cand.zone == "Field" || cand.zone == "FieldSelected"))) continue;
            if (variable_instance_exists(cand, "orientation") && variable_instance_exists(cand, "isFaceDown")) {
                if (cand.orientation == "Defense" && cand.isFaceDown) continue;
            }
            if (allyOnly) {
                if (!(variable_instance_exists(cand, "isHeroOwner") && !cand.isHeroOwner)) continue;
            }
            if (allowedGenres != undefined) {
                var g = variable_instance_exists(cand, "genre") ? cand.genre : "";
                var okGenre = false;
                for (var gi = 0; gi < array_length(allowedGenres); gi++) {
                    if (string_lower(g) == string_lower(allowedGenres[gi])) { okGenre = true; break; }
                }
                if (!okGenre) continue;
            }
            var atk = variable_instance_exists(cand, "attack") ? cand.attack : 0;
            var def = variable_instance_exists(cand, "defense") ? cand.defense : 0;
            var eatk = variable_struct_exists(cand, "effective_attack") ? cand.effective_attack : atk;
            var edef = variable_struct_exists(cand, "effective_defense") ? cand.effective_defense : def;
            var sc = eatk + edef;
            if (sc > bestScore) { bestScore = sc; best = cand; }
        }
    }
    return best;
}

useEffectsMainPhase = function() {
    // 1) Poser en priorité les sorts à effet continu depuis la main (auras, malédictions, etc.)
    //    afin qu'ils soient actifs avant le reste des activations manuelles
    if (ds_exists(handEnemy.cards, ds_type_list)) {
        // Vérifier s'il existe au moins un slot libre côté Magie/Piège
        var mtField = fieldManagerEnemy.getField("MagicTrap");
        var hasFreeMTSlot = false;
        if (mtField != noone && variable_struct_exists(mtField, "cards")) {
            for (var mti = 0; mti < array_length(mtField.cards); mti++) {
                if (mtField.cards[mti] == 0) { hasFreeMTSlot = true; break; }
            }
        }

        if (hasFreeMTSlot) {
            var hsize0 = ds_list_size(handEnemy.cards);
            for (var h0 = 0; h0 < hsize0; h0++) {
                var c0 = ds_list_find_value(handEnemy.cards, h0);
                if (c0 != 0 && instance_exists(c0) && c0.type == "Magic" && variable_struct_exists(c0, "effects")) {
                    // Détection d'au moins un effet continu sur cette carte
                    var hasContinuous = false;
                    var isArtifact = (variable_instance_exists(c0, "genre") && string_lower(c0.genre) == string_lower("Artéfact"));
                    var equipEffect = noone;
                    for (var e0 = 0; e0 < array_length(c0.effects); e0++) {
                        var ef0 = c0.effects[e0];
                        if (variable_struct_exists(ef0, "trigger") && ef0.trigger == TRIGGER_CONTINUOUS) { hasContinuous = true; break; }
                        if (variable_struct_exists(ef0, "effect_type") && ef0.effect_type == EFFECT_EQUIP_SELECT_TARGET) {
                            equipEffect = ef0;
                        }
                    }
                    // Ne pas auto-poser les Artéfacts s'il n'y a pas de cible à équiper
                    if (isArtifact) {
                        var tgtEquip = (equipEffect != noone) ? aiChooseBestEquipTargetFor(c0, equipEffect) : noone;
                        if (tgtEquip == noone) { hasContinuous = false; }
                    }
                    if (hasContinuous) {
                        // Calculer le gain net attendu et ne poser que si positif
                        var netScore = aiEvaluateContinuousNetGain(c0);
                        if (netScore <= 0) { continue; }
                        // Placer la carte sur le terrain Magie/Piège si une position libre existe
                        var XY0 = fieldManagerEnemy.getCardPositionAvailableIA(c0);
                        if (XY0 != -1) {
                            UIManager.selectedSummonOrSet = "Summon";
                            var summoned0 = handEnemy.summon(c0, XY0);
                            UIManager.selectedSummonOrSet = "";
                            if (summoned0) {
                                var ctx0 = { summon_mode: "Summon", owner_is_hero: false };
                                registerTriggerEvent(TRIGGER_ON_SUMMON, c0, ctx0);
                                registerTriggerEvent(TRIGGER_ON_SPELL_CAST, c0, ctx0);
                                // Si c’est un Artéfact et qu’une cible valide existe, lancer immédiatement la sélection d’équipement
                                if (isArtifact && equipEffect != noone) {
                                    var tgtEquipNow = (typeof(tgtEquip) != undefined) ? tgtEquip : aiChooseBestEquipTargetFor(c0, equipEffect);
                                    if (tgtEquipNow != noone) {
                                        c0.equip_pending = true; // éviter destruction par l’effet continu avant sélection
                                        var ctxEquipNow = { owner_is_hero: false, target: tgtEquipNow };
                                        var okEquip = executeEffect(c0, equipEffect, ctxEquipNow);
                                        markEffectAsUsed(c0, equipEffect);
                                        // L’effet de sélection met equip_pending à false en cas de succès
                                    }
                                }
                                // Mettre à jour l'état du terrain libre restant
                                hasFreeMTSlot = false;
                                if (mtField != noone && variable_struct_exists(mtField, "cards")) {
                                    for (var mti2 = 0; mti2 < array_length(mtField.cards); mti2++) {
                                        if (mtField.cards[mti2] == 0) { hasFreeMTSlot = true; break; }
                                    }
                                }
                                if (!hasFreeMTSlot) break; // Stop si plus de slot disponible
                            }
                        }
                    }
                }
            }
        }
    }

    var effectsToUse = [];
    // Main de l’IA
    if (ds_exists(handEnemy.cards, ds_type_list)) {
        var hsize = ds_list_size(handEnemy.cards);
        for (var hi = 0; hi < hsize; hi++) {
            var c = ds_list_find_value(handEnemy.cards, hi);
            if (c != 0 && instance_exists(c) && variable_struct_exists(c, "effects")) {
                for (var ei = 0; ei < array_length(c.effects); ei++) {
                    var e = c.effects[ei];
                    var hasManual = !variable_struct_exists(e, "trigger") || e.trigger == TRIGGER_MAIN_PHASE || e.trigger == TRIGGER_QUICK_EFFECT;
                    if (!hasManual) continue; if (!checkTriggerConditions(c, e, { owner_is_hero: false })) continue;
                    var tgt = noone; var eType = variable_struct_exists(e, "effect_type") ? e.effect_type : -1;
                    if (eType == EFFECT_EQUIP_SELECT_TARGET) {
                        tgt = aiChooseBestEquipTargetFor(c, e);
                        if (tgt == noone) continue;
                    } else if (aiIsTargetedEffect(eType)) { tgt = aiChooseBestTarget(eType); if (tgt == noone) continue; }
                    var pr = aiEffectPriority(c, e);
                    var netGain = aiEvaluateEffectNetGain(c, e, tgt);
                    if (netGain <= 0) continue;
                    var prCombined = pr + netGain;
                    array_push(effectsToUse, { card: c, effect: e, priority: prCombined, target: tgt, net: netGain });
                }
            }
        }
    }
    // Terrain: monstres
    for (var i3 = 0; i3 < 5; i3++) {
        var c2 = fieldMonsterEnemy.cards[i3];
        if (c2 != 0 && instance_exists(c2) && variable_struct_exists(c2, "effects")) {
            for (var ei2 = 0; ei2 < array_length(c2.effects); ei2++) {
                var e2 = c2.effects[ei2];
                var hasManual2 = !variable_struct_exists(e2, "trigger") || e2.trigger == TRIGGER_MAIN_PHASE || e2.trigger == TRIGGER_QUICK_EFFECT;
                if (!hasManual2) continue; if (!checkTriggerConditions(c2, e2, { owner_is_hero: false })) continue;
                var tgt2 = noone; var eType2 = variable_struct_exists(e2, "effect_type") ? e2.effect_type : -1;
                if (eType2 == EFFECT_EQUIP_SELECT_TARGET) {
                    tgt2 = aiChooseBestEquipTargetFor(c2, e2);
                    if (tgt2 == noone) continue;
                } else if (aiIsTargetedEffect(eType2)) { tgt2 = aiChooseBestTarget(eType2); if (tgt2 == noone) continue; }
                var pr2 = aiEffectPriority(c2, e2);
                array_push(effectsToUse, { card: c2, effect: e2, priority: pr2, target: tgt2 });
            }
        }
    }
    // Terrain: Magie/Piège
    var mtEnemy = fieldManagerEnemy.getField("MagicTrap");
    if (mtEnemy != noone && variable_struct_exists(mtEnemy, "cards")) {
        for (var mi = 0; mi < array_length(mtEnemy.cards); mi++) {
            var c3 = mtEnemy.cards[mi];
            if (c3 != 0 && instance_exists(c3) && variable_struct_exists(c3, "effects")) {
                for (var ei3 = 0; ei3 < array_length(c3.effects); ei3++) {
                    var e3 = c3.effects[ei3];
                    var hasManual3 = !variable_struct_exists(e3, "trigger") || e3.trigger == TRIGGER_MAIN_PHASE || e3.trigger == TRIGGER_QUICK_EFFECT;
                    if (!hasManual3) continue; if (!checkTriggerConditions(c3, e3, { owner_is_hero: false })) continue;
                    var tgt3 = noone; var eType3 = variable_struct_exists(e3, "effect_type") ? e3.effect_type : -1;
                    if (eType3 == EFFECT_EQUIP_SELECT_TARGET) {
                        tgt3 = aiChooseBestEquipTargetFor(c3, e3);
                        if (tgt3 == noone) continue;
                    } else if (aiIsTargetedEffect(eType3)) { tgt3 = aiChooseBestTarget(eType3); if (tgt3 == noone) continue; }
                    var pr3 = aiEffectPriority(c3, e3);
                    var netGain3 = aiEvaluateEffectNetGain(c3, e3, tgt3);
                    if (netGain3 <= 0) continue;
                    var prCombined3 = pr3 + netGain3;
                    array_push(effectsToUse, { card: c3, effect: e3, priority: prCombined3, target: tgt3, net: netGain3 });
                }
            }
        }
    }
    // Tri décroissant
    for (var a = 0; a < array_length(effectsToUse) - 1; a++) {
        for (var b = a + 1; b < array_length(effectsToUse); b++) {
            if (effectsToUse[a].priority < effectsToUse[b].priority) {
                var tmp = effectsToUse[a]; effectsToUse[a] = effectsToUse[b]; effectsToUse[b] = tmp;
            }
        }
    }
    // Activer les effets
    for (var k = 0; k < array_length(effectsToUse); k++) {
        var it = effectsToUse[k]; if (it == noone) continue;
        var ctx = { owner_is_hero: false };
        if (it.target != noone) ctx.target = it.target;
        if (variable_struct_exists(it.effect, "trigger")) {
            activateTrigger(it.card, it.effect.trigger, ctx);
        } else {
            var ok = executeEffect(it.card, it.effect, ctx);
            markEffectAsUsed(it.card, it.effect);
        }
    }
}

useQuickEffectsBeforeAttack = function() {
    for (var i = 0; i < 5; i++) {
        var c = fieldMonsterEnemy.cards[i];
        if (c != 0 && instance_exists(c) && variable_struct_exists(c, "effects")) {
            for (var ei = 0; ei < array_length(c.effects); ei++) {
                var e = c.effects[ei];
                if (variable_struct_exists(e, "trigger") && e.trigger == TRIGGER_QUICK_EFFECT) {
                    if (checkTriggerConditions(c, e, { owner_is_hero: false })) {
                        var tgt = noone; var eType = variable_struct_exists(e, "effect_type") ? e.effect_type : -1;
                        if (eType == EFFECT_EQUIP_SELECT_TARGET) {
                            tgt = aiChooseBestEquipTargetFor(c, e);
                        } else if (aiIsTargetedEffect(eType)) {
                            tgt = aiChooseBestTarget(eType);
                        }
                        var netQ = aiEvaluateEffectNetGain(c, e, tgt);
                        if (netQ <= 0) { continue; }
                        var ctx = { owner_is_hero: false }; if (tgt != noone) ctx.target = tgt;
                        activateTrigger(c, TRIGGER_QUICK_EFFECT, ctx);
                    }
                }
            }
        }
    }
}
#endregion

#region Function summon
summon = function() {
    if (variable_global_exists("VERBOSE_LOGS") && global.VERBOSE_LOGS) show_debug_message("### oIA.summon")

    if (game.hasSummonedThisTurn[1]) { if (variable_global_exists("VERBOSE_LOGS") && global.VERBOSE_LOGS) show_debug_message("IA a déjà invoqué un monstre ce tour"); scheduleNextPhase(); return; }

    // Effets de phase principale avant
    useEffectsMainPhase();

    // Choisir le meilleur monstre à invoquer
    var card = noone; var bestScore = -100000;
    if (ds_exists(handEnemy.cards, ds_type_list)) {
        var hsize = ds_list_size(handEnemy.cards);
        for (var hi = 0; hi < hsize; hi++) {
            var cand = ds_list_find_value(handEnemy.cards, hi);
            if (cand != 0 && instance_exists(cand) && cand.type == "Monster") {
                var sc = evaluateCardPriority(cand);
                if (sc > bestScore) { bestScore = sc; card = cand; }
            }
        }
    }

    if (card) {
        var requiredSacrificeLevel = getSacrificeLevel(card.star);
        if (requiredSacrificeLevel > 0) {
            var availableSacrifices = [];
            for (var i = 0; i < 5; i++) {
                if (fieldMonsterEnemy.cards[i] != 0) {
                    var sac = fieldMonsterEnemy.cards[i];
                    if (instance_exists(sac) && sac.type == "Monster") array_push(availableSacrifices, sac);
                }
            }
            var requiredSacrificeCount = (requiredSacrificeLevel == 1) ? 1 : 2;
            if (array_length(availableSacrifices) < requiredSacrificeCount) {
                if (variable_global_exists("VERBOSE_LOGS") && global.VERBOSE_LOGS) show_debug_message("IA ne peut pas invoquer ce monstre (sacrifices insuffisants). Recherche d'un fallback sans sacrifice...");
                var fallback = noone;
                if (ds_exists(handEnemy.cards, ds_type_list)) {
                    var hsize2 = ds_list_size(handEnemy.cards);
                    for (var hi2 = 0; hi2 < hsize2; hi2++) {
                        var cand2 = ds_list_find_value(handEnemy.cards, hi2);
                        if (cand2 != 0 && instance_exists(cand2) && cand2.type == "Monster") {
                            var req2 = getSacrificeLevel(cand2.star);
                            if (req2 == 0) { fallback = cand2; break; }
                        }
                    }
                }
                if (fallback != noone) {
                    if (variable_global_exists("VERBOSE_LOGS") && global.VERBOSE_LOGS) show_debug_message("Fallback sélectionné: " + string(variable_instance_exists(fallback, "name") ? fallback.name : object_get_name(fallback.object_index)));
                    card = fallback; requiredSacrificeLevel = 0; requiredSacrificeCount = 0;
                } else { if (variable_global_exists("VERBOSE_LOGS") && global.VERBOSE_LOGS) show_debug_message("Aucun fallback sans sacrifice disponible. Passage à la phase suivante."); scheduleNextPhase(); return; }
            }
            var selectedSacrifices = [];
            // Trier par ATK croissante pour sacrifier les plus faibles
            for (var ii = 0; ii < array_length(availableSacrifices) - 1; ii++) {
                for (var jj = ii + 1; jj < array_length(availableSacrifices); jj++) {
                    if (availableSacrifices[ii].attack > availableSacrifices[jj].attack) {
                        var tmp = availableSacrifices[ii]; availableSacrifices[ii] = availableSacrifices[jj]; availableSacrifices[jj] = tmp;
                    }
                }
            }
        var summonedValue = (variable_instance_exists(card, "attack") ? card.attack : 0) + (variable_instance_exists(card, "defense") ? card.defense : 0) + (variable_instance_exists(card, "star") ? card.star : 0) * 100;
        // Utiliser les stats effectives pour évaluer la qualité réelle des échanges
        var effCandAtk = variable_struct_exists(card, "effective_attack") ? card.effective_attack : (variable_instance_exists(card, "attack") ? card.attack : 0);
        var effCandDef = variable_struct_exists(card, "effective_defense") ? card.effective_defense : (variable_instance_exists(card, "defense") ? card.defense : 0);
        var summonedValue = effCandAtk + effCandDef + ((variable_instance_exists(card, "star") ? card.star : 0) * 50);
        var sacrificeValue = 0;
        var requiredSacrificeCount = (requiredSacrificeLevel == 1) ? 1 : (requiredSacrificeLevel == 2 ? 2 : 0);
        var highestSacEff = 0;
        for (var s = 0; s < requiredSacrificeCount && s < array_length(availableSacrifices); s++) {
            var sCard = availableSacrifices[s];
            if (sCard != 0 && instance_exists(sCard)) {
                var sEffAtk = variable_struct_exists(sCard, "effective_attack") ? sCard.effective_attack : (variable_instance_exists(sCard, "attack") ? sCard.attack : 0);
                var sEffDef = variable_struct_exists(sCard, "effective_defense") ? sCard.effective_defense : (variable_instance_exists(sCard, "defense") ? sCard.defense : 0);
                sacrificeValue += sEffAtk + sEffDef; // ne pas surpondérer les étoiles pour les sacrifices
                highestSacEff = max(highestSacEff, max(sEffAtk, sEffDef));
            }
        }
        var dif = (variable_global_exists("IA_DIFFICULTY") ? global.IA_DIFFICULTY : 0);
        var heroMaxStat = 0; var heroHas = false;
            for (var hk = 0; hk < 5; hk++) {
                var hC = fieldMonsterHero.cards[hk];
                if (hC != 0 && instance_exists(hC)) {
                    heroHas = true;
                    var ha = variable_struct_exists(hC, "effective_attack") ? hC.effective_attack : hC.attack;
                    var hd = variable_struct_exists(hC, "effective_defense") ? hC.effective_defense : hC.defense;
                    heroMaxStat = max(heroMaxStat, max(ha, hd));
                }
            }
        var allowWorseTrade = (dif == 1 && heroHas && (max(effCandAtk, effCandDef) >= heroMaxStat));
        var margin = (dif == 1 && allowWorseTrade) ? 200 : 0;
        // Éviter les sacrifices défavorables: la carte invoquée doit dépasser la somme ET la meilleure des sacrifiées
        if (requiredSacrificeCount > 0 && ((summonedValue + margin) <= sacrificeValue || max(effCandAtk, effCandDef) <= highestSacEff)) {
            var fallback2 = noone;
            if (ds_exists(handEnemy.cards, ds_type_list)) {
                var hsize3 = ds_list_size(handEnemy.cards);
                for (var hi3 = 0; hi3 < hsize3; hi3++) {
                    var cand3 = ds_list_find_value(handEnemy.cards, hi3);
                    if (cand3 != 0 && instance_exists(cand3) && cand3.type == "Monster" && getSacrificeLevel(cand3.star) == 0) { fallback2 = cand3; break; }
                }
            }
            if (fallback2 != noone) {
                if (variable_global_exists("VERBOSE_LOGS") && global.VERBOSE_LOGS) show_debug_message("Sacrifice défavorable évité. Fallback sans sacrifice: " + string(variable_instance_exists(fallback2, "name") ? fallback2.name : object_get_name(fallback2.object_index)));
                card = fallback2; requiredSacrificeLevel = 0; requiredSacrificeCount = 0; selectedSacrifices = [];
            } else { if (variable_global_exists("VERBOSE_LOGS") && global.VERBOSE_LOGS) show_debug_message("Sacrifice défavorable détecté, pas de fallback. Passage à la phase suivante."); scheduleNextPhase(); return; }
        }
            for (var iSel = 0; iSel < requiredSacrificeCount; iSel++) { array_push(selectedSacrifices, availableSacrifices[iSel]); }
            if (requiredSacrificeCount > 0 && array_length(selectedSacrifices) >= requiredSacrificeCount) { performSacrifices(selectedSacrifices, false); }
        }
        var XYPos = fieldManagerEnemy.getCardPositionAvailableIA(card);
        if (XYPos != -1) {
            // Choix de position basé sur l'attaque effective adverse
            var heroMaxEffAtk = 0; var heroHasMonsters2 = false;
            for (var k = 0; k < array_length(fieldMonsterHero.cards); k++) {
                var cardHero2 = fieldMonsterHero.cards[k];
                if (cardHero2 != 0 && instance_exists(cardHero2)) {
                    heroHasMonsters2 = true;
                    var effAtkHero2 = variable_struct_exists(cardHero2, "effective_attack") ? cardHero2.effective_attack : cardHero2.attack;
                    if (effAtkHero2 > heroMaxEffAtk) heroMaxEffAtk = effAtkHero2;
                }
            }
            var candAtk = variable_struct_exists(card, "effective_attack") ? card.effective_attack : (variable_instance_exists(card, "attack") ? card.attack : 0);
            var candDef = variable_instance_exists(card, "defense") ? card.defense : 0;
            // Heuristique simple: si l'adversaire peut dépasser notre ATK, se placer en Défense
            var shouldSummonInDefense = (candAtk <= 0) || (heroHasMonsters2 && (heroMaxEffAtk >= candAtk));
            var orientation = shouldSummonInDefense ? "Defense" : "";
            handEnemy.summon(card, XYPos, orientation);
            game.hasSummonedThisTurn[1] = true;
            useEffectsMainPhase();
        }
    }
    manageOrientation();
    scheduleNextPhase();
}
#endregion

// === Helpers pour attaque séquentielle ===
iaAttackResetEngagement = function() {
    for (var k = 0; k < array_length(fieldMonsterHero.cards); k++) {
        var ch0 = fieldMonsterHero.cards[k];
        if (ch0 != 0 && instance_exists(ch0)) { ch0.engagedThisPhase = false; }
    }
}

iaAttackTryLaunchNext = function() {
    var difficulty = (variable_global_exists("IA_DIFFICULTY") ? global.IA_DIFFICULTY : 0);
    
    if (difficulty == 0) {
        // Mode Normal : ordre séquentiel simple (comportement existant)
        for (var i = 0; i < 5; i++) {
            var cardEnemy = fieldMonsterEnemy.cards[i];
            if (cardEnemy != 0 && instance_exists(cardEnemy) && cardEnemy.orientation == "Attack" && (variable_instance_exists(cardEnemy, "lastTurnAttack") ? cardEnemy.lastTurnAttack < game.nbTurn : true)) {
                // Vérifie s'il y a des monstres héros
                var heroHasMonsters = false;
                for (var j = 0; j < array_length(fieldMonsterHero.cards); j++) { var ch = fieldMonsterHero.cards[j]; if (ch != 0 && instance_exists(ch)) { heroHasMonsters = true; break; } }
                if (heroHasMonsters) {
                    var bestTarget = -1; var bestValue = -1;
                    for (var j2 = 0; j2 < array_length(fieldMonsterHero.cards); j2++) {
                        var cardHero = fieldMonsterHero.cards[j2];
                        if (cardHero != 0 && instance_exists(cardHero)) {
                            if (variable_instance_exists(cardHero, "engagedThisPhase") && cardHero.engagedThisPhase) continue;
                            var effEnemyAtk = variable_struct_exists(cardEnemy, "effective_attack") ? cardEnemy.effective_attack : cardEnemy.attack;
                            var effEnemyDef = variable_struct_exists(cardEnemy, "effective_defense") ? cardEnemy.effective_defense : cardEnemy.defense;
                            var effHeroAtk = variable_struct_exists(cardHero, "effective_attack") ? cardHero.effective_attack : cardHero.attack;
                            var effHeroDef = variable_struct_exists(cardHero, "effective_defense") ? cardHero.effective_defense : cardHero.defense;
                            var attackValue = 0;
                            // Anti-suicide: éviter attaques perdantes sauf égalité utile pour empoisonneur
                            var heroInAttack = (variable_instance_exists(cardHero, "orientation") && cardHero.orientation == "Attack");
                            var heroInDefense = (variable_instance_exists(cardHero, "orientation") && (cardHero.orientation == "Defense" || cardHero.orientation == "DefenseVisible"));
                            var isPoisoner = (variable_struct_exists(cardEnemy, "isPoisoner") && cardEnemy.isPoisoner);
                            if ((heroInAttack && effEnemyAtk <= effHeroAtk && !(isPoisoner && effEnemyAtk == effHeroAtk)) || (heroInDefense && effEnemyAtk < effHeroDef && !(isPoisoner && effEnemyAtk == effHeroDef))) {
                                attackValue = -100000; // Écarter cible suicidaire
                            } else {
                                if ((effEnemyAtk > effHeroDef) && (effHeroAtk < effEnemyDef)) { attackValue = 1000 + effHeroAtk; }
                                else if (effEnemyAtk > effHeroAtk) { attackValue = 500 + (effEnemyAtk - effHeroAtk); }
                                else { attackValue = 100 - effHeroAtk; }
                            }
                            if (attackValue > bestValue) { bestValue = attackValue; bestTarget = j2; }
                        }
                    }
                    if (bestTarget != -1) {
                        var cardHeroPick = fieldMonsterHero.cards[bestTarget];
                        if (variable_global_exists("USE_COMBAT_FX") && global.USE_COMBAT_FX) {
                            var fx = instance_create_layer(cardEnemy.x, cardEnemy.y, "Instances", FX_Combat);
                            if (fx != noone) { fx.attacker = cardEnemy; fx.defender = cardHeroPick; fx.mode = "vsMonster"; }
                        } else {
                            var dm = instance_find(oDamageManager, 0);
                            if (dm != noone) { with (dm) resolveAttackMonsterEnemy(cardEnemy, cardHeroPick); }
                        }
                        cardEnemy.lastTurnAttack = game.nbTurn; cardHeroPick.engagedThisPhase = true; return true;
                    }
                } else {
                    // Attaque directe (éviter d'attaquer avec ATK=0)
                    var effEnemyAtkDir = variable_struct_exists(cardEnemy, "effective_attack") ? cardEnemy.effective_attack : (variable_instance_exists(cardEnemy, "attack") ? cardEnemy.attack : 0);
                    if (effEnemyAtkDir <= 0) { continue; }
                    if (variable_global_exists("USE_COMBAT_FX") && global.USE_COMBAT_FX) {
                        var fx2 = instance_create_layer(cardEnemy.x, cardEnemy.y, "Instances", FX_Combat);
                        if (fx2 != noone) { fx2.attacker = cardEnemy; fx2.defender = noone; fx2.mode = "direct"; }
                    } else {
                        var dm2 = instance_find(oDamageManager, 0);
                        if (dm2 != noone) { with (dm2) resolveAttackDirectEnemy(cardEnemy); }
                    }
                    cardEnemy.attacksUsedThisTurn = (variable_instance_exists(cardEnemy, "attacksUsedThisTurn") ? cardEnemy.attacksUsedThisTurn : 0) + 1; cardEnemy.lastTurnAttack = game.nbTurn; return true;
                }
            }
        }
        return false;
    } else {
        // Mode Difficile : ordre d'attaque optimisé
        // 1. Collecter tous les attaquants disponibles
        var availableAttackers = [];
        for (var i = 0; i < 5; i++) {
            var cardEnemy = fieldMonsterEnemy.cards[i];
            if (cardEnemy != 0 && instance_exists(cardEnemy) && cardEnemy.orientation == "Attack" && (variable_instance_exists(cardEnemy, "lastTurnAttack") ? cardEnemy.lastTurnAttack < game.nbTurn : true)) {
                var effEnemyAtkSel = variable_struct_exists(cardEnemy, "effective_attack") ? cardEnemy.effective_attack : (variable_instance_exists(cardEnemy, "attack") ? cardEnemy.attack : 0);
                if (effEnemyAtkSel > 0) {
                    array_push(availableAttackers, {card: cardEnemy, index: i});
                }
            }
        }
        
        if (array_length(availableAttackers) == 0) return false;
        
        // 2. Vérifier s'il y a des monstres héros
        var heroHasMonsters = false;
        for (var j = 0; j < array_length(fieldMonsterHero.cards); j++) { 
            var ch = fieldMonsterHero.cards[j]; 
            if (ch != 0 && instance_exists(ch)) { heroHasMonsters = true; break; } 
        }
        
        if (!heroHasMonsters) {
            // Attaque directe : prioriser le plus fort ATK
            var bestDirectAttacker = availableAttackers[0];
            var bestDirectAtk = variable_struct_exists(bestDirectAttacker.card, "effective_attack") ? bestDirectAttacker.card.effective_attack : bestDirectAttacker.card.attack;
            for (var a = 1; a < array_length(availableAttackers); a++) {
                var currentAtk = variable_struct_exists(availableAttackers[a].card, "effective_attack") ? availableAttackers[a].card.effective_attack : availableAttackers[a].card.attack;
                if (currentAtk > bestDirectAtk) {
                    bestDirectAtk = currentAtk;
                    bestDirectAttacker = availableAttackers[a];
                }
            }
            
            var cardEnemy = bestDirectAttacker.card;
            if (variable_global_exists("USE_COMBAT_FX") && global.USE_COMBAT_FX) {
                var fx2 = instance_create_layer(cardEnemy.x, cardEnemy.y, "Instances", FX_Combat);
                if (fx2 != noone) { fx2.attacker = cardEnemy; fx2.defender = noone; fx2.mode = "direct"; }
            } else {
                var dm2 = instance_find(oDamageManager, 0);
                if (dm2 != noone) { with (dm2) resolveAttackDirectEnemy(cardEnemy); }
            }
            cardEnemy.attacksUsedThisTurn = (variable_instance_exists(cardEnemy, "attacksUsedThisTurn") ? cardEnemy.attacksUsedThisTurn : 0) + 1; cardEnemy.lastTurnAttack = game.nbTurn; return true;
            return true;
        }
        
        // 3. Évaluer toutes les combinaisons attaquant-cible et choisir la meilleure
        var bestAttackPlan = noone;
        var bestAttackScore = -100000;
        
        for (var a = 0; a < array_length(availableAttackers); a++) {
            var attacker = availableAttackers[a];
            var cardEnemy = attacker.card;
            var effEnemyAtk = variable_struct_exists(cardEnemy, "effective_attack") ? cardEnemy.effective_attack : cardEnemy.attack;
            var effEnemyDef = variable_struct_exists(cardEnemy, "effective_defense") ? cardEnemy.effective_defense : cardEnemy.defense;
            
            for (var j2 = 0; j2 < array_length(fieldMonsterHero.cards); j2++) {
                var cardHero = fieldMonsterHero.cards[j2];
                if (cardHero != 0 && instance_exists(cardHero)) {
                    if (variable_instance_exists(cardHero, "engagedThisPhase") && cardHero.engagedThisPhase) continue;
                    
                    var effHeroAtk = variable_struct_exists(cardHero, "effective_attack") ? cardHero.effective_attack : cardHero.attack;
                    var effHeroDef = variable_struct_exists(cardHero, "effective_defense") ? cardHero.effective_defense : cardHero.defense;
                    
                    // Calcul du score d'attaque stratégique
                    var attackScore = 0;
                    // Détruire un défenseur uniquement si ATK strictement supérieure à DEF
                    var destroysDef = (effEnemyAtk > effHeroDef);
                    var destroysAtk = (effEnemyAtk > effHeroAtk);
                    var heroInAttack = (variable_instance_exists(cardHero, "orientation") && cardHero.orientation == "Attack");
                    var damageToLP = heroInAttack ? max(0, effEnemyAtk - effHeroAtk) : 0;
                    var survives = (effHeroAtk < effEnemyDef);
                    
                    // Détection empoisonneur
                    var isEnemyPoisoner = (variable_struct_exists(cardEnemy, "isPoisoner") && cardEnemy.isPoisoner);
                    var poisonKill = false;
                    var poisonValue = 0;
                    
                    if (isEnemyPoisoner) {
                        // L'empoisonneur détruit toujours le défenseur dans ces cas :
                        // - Victoire (ATK > DEF) : défenseur détruit par poison
                        // - Égalité (ATK == DEF) : défenseur détruit par poison, attaquant survit
                        // - Défaite (ATK < DEF) : dégâts subis puis défenseur détruit par poison
                        poisonKill = true;
                        poisonValue = effHeroAtk + effHeroDef; // Valeur de la carte détruite par poison
                    }
                    
                    // Priorités stratégiques avec logique empoisonneur :
                    // 1. Empoisonneur : destruction garantie du défenseur (priorité maximale)
                    if (isEnemyPoisoner && poisonKill) {
                        if (effEnemyAtk >= effHeroDef) {
                            // Victoire : défenseur détruit, attaquant survit
                            attackScore += 2500 + poisonValue;
                        } else if (effEnemyAtk == effHeroDef) {
                            // Égalité : défenseur détruit, attaquant survit, pas de dégâts LP
                            attackScore += 2200 + poisonValue;
                        } else {
                            // Défaite : dégâts LP subis mais défenseur détruit quand même
                            var lpDamage = effHeroDef - effEnemyAtk;
                            var netGain = poisonValue - lpDamage - effEnemyAtk; // Gain net (valeur détruite - coûts)
                            if (netGain > 0) {
                                attackScore += 1800 + netGain; // Trade favorable malgré la défaite
                            } else if (netGain >= -200) {
                                attackScore += 1200 + netGain; // Trade acceptable (perte limitée)
                            } else {
                                attackScore += 600 + netGain; // Trade défavorable mais peut être justifié
                            }
                        }
                    }
                    // 2. Destruction sans perte (priorité maximale pour non-empoisonneurs)
                    else if ((destroysDef || destroysAtk) && survives) {
                        attackScore += 2000 + effHeroAtk; // Élimination gratuite
                    }
                    // 3. Dégâts directs aux LP (très important)
                    else if (damageToLP > 0) {
                        attackScore += 1500 + damageToLP * 3;
                    }
                    // 4. Trade favorable (destruction mutuelle mais on gagne en valeur)
                    else if ((destroysDef || destroysAtk) && !survives) {
                        var tradeValue = effHeroAtk - effEnemyAtk;
                        if (tradeValue > 0) {
                            attackScore += 1000 + tradeValue;
                        } else {
                            attackScore += 800 + tradeValue; // Trade égal ou légèrement défavorable
                        }
                    }
                    // 5. Attaque défavorable (éviter sauf si nécessaire)
                    else {
                        attackScore = 100 - effHeroAtk; // Score très bas
                        if (heroInAttack && effHeroAtk > effEnemyAtk) {
                            attackScore -= 500; // Pénalité pour trade très défavorable
                        }
                    }
                    
                    // Bonus pour éliminer les menaces en position d'attaque
                    if (heroInAttack && (destroysDef || destroysAtk)) {
                        attackScore += 300;
                    }
                    
                    // Heuristiques supplémentaires: révéler face cachée, éviter égalités stériles, casser les ex-aequo
                    var heroIsFaceDown = (variable_instance_exists(cardHero, "isFaceDown") && cardHero.isFaceDown);
                    if (!heroInAttack && heroIsFaceDown) {
                        if (destroysDef) {
                            attackScore += 1200; // révélation + élimination sûre
                        } else {
                            attackScore += 150;   // curiosité: révéler si aucune meilleure option
                        }
                    }
                    // Pénalité pour égalités non productives
                    if (heroInAttack && effEnemyAtk == effHeroAtk) {
                        attackScore -= 300;
                    }
                    if (!heroInAttack && effEnemyAtk == effHeroDef) {
                        attackScore -= 400;
                    }
                    // Légère randomisation pour éviter des choix identiques entre tours
                    attackScore += irandom_range(-15, 15);
                    
                    if (attackScore > bestAttackScore) {
                        bestAttackScore = attackScore;
                        bestAttackPlan = {attacker: cardEnemy, target: cardHero, targetIndex: j2};
                    }
                }
            }
        }
        
        // 4. Exécuter la meilleure attaque trouvée
        if (bestAttackPlan != noone) {
            var cardEnemy = bestAttackPlan.attacker;
            var cardHeroPick = bestAttackPlan.target;
            
            if (variable_global_exists("USE_COMBAT_FX") && global.USE_COMBAT_FX) {
                var fx = instance_create_layer(cardEnemy.x, cardEnemy.y, "Instances", FX_Combat);
                if (fx != noone) { fx.attacker = cardEnemy; fx.defender = cardHeroPick; fx.mode = "vsMonster"; }
            } else {
                var dm = instance_find(oDamageManager, 0);
                if (dm != noone) { with (dm) resolveAttackMonsterEnemy(cardEnemy, cardHeroPick); }
            }
            cardEnemy.attacksUsedThisTurn = (variable_instance_exists(cardEnemy, "attacksUsedThisTurn") ? cardEnemy.attacksUsedThisTurn : 0) + 1; cardEnemy.lastTurnAttack = game.nbTurn; 
            cardHeroPick.engagedThisPhase = true; 
            return true;
        }
        
        return false;
    }
}

#region Function attack
attack = function() {
    if (variable_global_exists("VERBOSE_LOGS") && global.VERBOSE_LOGS) show_debug_message("### oIA.attack");

    // Orientation et effets rapides
    manageOrientation();
    useQuickEffectsBeforeAttack();

    // Règle: pas d'attaque au tour 1
    if (game.nbTurn == 1) { if (variable_global_exists("VERBOSE_LOGS") && global.VERBOSE_LOGS) show_debug_message("### oIA.attack: Attaque interdite au tour 1 du duel"); game.nextPhase(); return; }

    iaAttackResetEngagement();
    if (variable_instance_exists(id, "attackProcessing") == false) attackProcessing = false;
    if (variable_instance_exists(id, "attackDelayFrames") == false) attackDelayFrames = 0;

    var launched = iaAttackTryLaunchNext();
    
    // Toujours dépiler via Step, avec délai configurable, que les FX soient activés ou non
    attackProcessing = launched;
    if (!launched) { game.nextPhase(); return; }

    // Initialiser un délai entre la première attaque et la suivante
    attackDelayFrames = (variable_global_exists("IA_ACTION_DELAY_FRAMES") ? global.IA_ACTION_DELAY_FRAMES : 30);

    // Avec FX: le Step d'oIA dépilera au fur et à mesure
    // Sans FX: idem, le Step s'occupe du séquencement lent
}
#endregion

