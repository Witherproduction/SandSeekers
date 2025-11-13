/// sAIActionSelect.gml — Construction des actions candidates pour la Main Phase

/// Construit les actions « Magies continues depuis la main »
function AI_ActionSelect_BuildContinuousFromHand() {
    var actions = [];
    var profile = AI_Config_GetActiveProfile();
    if (!ds_exists(handEnemy.cards, ds_type_list)) return actions;

    // Vérifier s’il existe un slot libre côté Magie/Piège
    var mtField = fieldManagerEnemy.getField("MagicTrap");
    var hasFreeMTSlot = false;
    if (mtField != noone && variable_struct_exists(mtField, "cards")) {
        for (var mti = 0; mti < array_length(mtField.cards); mti++) { if (mtField.cards[mti] == 0) { hasFreeMTSlot = true; break; } }
    }
    if (!hasFreeMTSlot) return actions;

    var hsize = ds_list_size(handEnemy.cards);
    for (var h = 0; h < hsize; h++) {
        var c = ds_list_find_value(handEnemy.cards, h);
        if (c != 0 && instance_exists(c) && c.type == "Magic" && variable_struct_exists(c, "effects")) {
            var hasContinuous = false; var isArtifact = (variable_instance_exists(c, "genre") && string_lower(c.genre) == string_lower("Artéfact")); var equipEffect = noone;
            for (var e = 0; e < array_length(c.effects); e++) {
                var ef = c.effects[e];
                if (variable_struct_exists(ef, "trigger") && ef.trigger == TRIGGER_CONTINUOUS) { hasContinuous = true; }
                if (variable_struct_exists(ef, "effect_type") && ef.effect_type == EFFECT_EQUIP_SELECT_TARGET) { equipEffect = ef; }
            }
            if (!hasContinuous) continue;
            var tgtEquip = noone;
            if (isArtifact) {
                tgtEquip = (equipEffect != noone) ? AI_Targeting_ChooseBestEquipTargetFor(c, equipEffect) : noone;
                if (tgtEquip == noone) { continue; } // pas de cible à équiper → éviter de poser
            }
            var netScore = AI_EvaluateContinuousNetGain(c);
            if (netScore <= 0) continue;
            var prio = (400 + netScore) * (profile.continuous_weight / 50.0); // pondéré par profil
            array_push(actions, { kind: "play_magic_hand", card: c, priority: prio, equipEffect: equipEffect, target: tgtEquip });
        }
    }
    return actions;
}

/// Construit les actions « Magies directes depuis la main » (non continues)
function AI_ActionSelect_BuildDirectMagicFromHand() {
    var actions = [];
    var profile = AI_Config_GetActiveProfile();
    if (!ds_exists(handEnemy.cards, ds_type_list)) return actions;

    // Vérifier s’il existe un slot libre côté Magie/Piège
    var mtField = fieldManagerEnemy.getField("MagicTrap");
    var hasFreeMTSlot = false;
    if (mtField != noone && variable_struct_exists(mtField, "cards")) {
        for (var mti = 0; mti < array_length(mtField.cards); mti++) { if (mtField.cards[mti] == 0) { hasFreeMTSlot = true; break; } }
    }
    if (!hasFreeMTSlot) return actions;

    var hsize = ds_list_size(handEnemy.cards);
    for (var h = 0; h < hsize; h++) {
        var c = ds_list_find_value(handEnemy.cards, h);
        if (c != 0 && instance_exists(c) && c.type == "Magic" && variable_struct_exists(c, "effects")) {
            var bestEffect = noone; var bestTarget = noone; var bestScore = -100000;
            for (var e = 0; e < array_length(c.effects); e++) {
                var ef = c.effects[e];
                // Écarter les effets continus
                if (variable_struct_exists(ef, "trigger") && ef.trigger == TRIGGER_CONTINUOUS) { continue; }
                // Garder uniquement les effets manuels (Main Phase / Quick) ou sans trigger
                var hasManual = !variable_struct_exists(ef, "trigger") || ef.trigger == TRIGGER_MAIN_PHASE || ef.trigger == TRIGGER_QUICK_EFFECT;
                if (!hasManual) continue;
                if (!checkTriggerConditions(c, ef, { owner_is_hero: false })) continue;

                var tgt = noone; var eType = variable_struct_exists(ef, "effect_type") ? ef.effect_type : -1;
                // Ne pas traiter ici la sélection d’équipement (gérée dans les magies continues)
                if (eType == EFFECT_EQUIP_SELECT_TARGET) { continue; }
                else if (AI_IsTargetedEffect(eType)) { tgt = AI_Targeting_ChooseBestTarget(eType); if (tgt == noone) continue; }

                var pr = AI_EffectPriority(c, ef) * (profile.manual_effect_weight / 50.0);
                var netGain = AI_EvaluateEffectNetGain(c, ef, tgt);
                if (netGain <= 0) continue;
                var prCombined = pr + netGain;
                if (prCombined > bestScore) { bestScore = prCombined; bestEffect = ef; bestTarget = tgt; }
            }
            if (bestEffect != noone) {
                array_push(actions, { kind: "play_magic_hand", card: c, priority: bestScore, effectToExecute: bestEffect, target: bestTarget });
            }
        }
    }
    return actions;
}
/// Construit les actions « Effets manuels » (main + terrain)
function AI_ActionSelect_BuildManualEffects() {
    var actions = [];
    var profile = AI_Config_GetActiveProfile();

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
                    if (eType == EFFECT_EQUIP_SELECT_TARGET) { tgt = AI_Targeting_ChooseBestEquipTargetFor(c, e); if (tgt == noone) continue; }
                    else if (AI_IsTargetedEffect(eType)) { tgt = AI_Targeting_ChooseBestTarget(eType); if (tgt == noone) continue; }
                    var pr = AI_EffectPriority(c, e) * (profile.manual_effect_weight / 50.0);
                    var netGain = AI_EvaluateEffectNetGain(c, e, tgt); if (netGain <= 0) continue;
                    array_push(actions, { kind: "effect", card: c, effect: e, priority: pr + netGain, target: tgt });
                }
            }
        }
    }

    // Terrain: monstres
    for (var i2 = 0; i2 < 5; i2++) {
        var c2 = fieldMonsterEnemy.cards[i2];
        if (c2 != 0 && instance_exists(c2) && variable_struct_exists(c2, "effects")) {
            for (var ei2 = 0; ei2 < array_length(c2.effects); ei2++) {
                var e2 = c2.effects[ei2];
                var hasManual2 = !variable_struct_exists(e2, "trigger") || e2.trigger == TRIGGER_MAIN_PHASE || e2.trigger == TRIGGER_QUICK_EFFECT;
                if (!hasManual2) continue; if (!checkTriggerConditions(c2, e2, { owner_is_hero: false })) continue;
                var tgt2 = noone; var eType2 = variable_struct_exists(e2, "effect_type") ? e2.effect_type : -1;
                if (eType2 == EFFECT_EQUIP_SELECT_TARGET) { tgt2 = AI_Targeting_ChooseBestEquipTargetFor(c2, e2); if (tgt2 == noone) continue; }
                else if (AI_IsTargetedEffect(eType2)) { tgt2 = AI_Targeting_ChooseBestTarget(eType2); if (tgt2 == noone) continue; }
                var pr2 = AI_EffectPriority(c2, e2) * (profile.manual_effect_weight / 50.0);
                var netGain2 = AI_EvaluateEffectNetGain(c2, e2, tgt2); if (netGain2 <= 0) continue;
                array_push(actions, { kind: "effect", card: c2, effect: e2, priority: pr2 + netGain2, target: tgt2 });
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
                    if (eType3 == EFFECT_EQUIP_SELECT_TARGET) { tgt3 = AI_Targeting_ChooseBestEquipTargetFor(c3, e3); if (tgt3 == noone) continue; }
                    else if (AI_IsTargetedEffect(eType3)) { tgt3 = AI_Targeting_ChooseBestTarget(eType3); if (tgt3 == noone) continue; }
                    var pr3 = AI_EffectPriority(c3, e3) * (profile.manual_effect_weight / 50.0);
                    var netGain3 = AI_EvaluateEffectNetGain(c3, e3, tgt3); if (netGain3 <= 0) continue;
                    array_push(actions, { kind: "effect", card: c3, effect: e3, priority: pr3 + netGain3, target: tgt3 });
                }
            }
        }
    }

    return actions;
}

/// Construit un pool d’actions pour la Main Phase (Secrets + Magies continues + Effets)
function AI_ActionSelect_BuildMainPhase() {
    var actions = [];
    var profile = AI_Config_GetActiveProfile();
    // Secrets posés face cachée depuis la main
    var secretActions = AI_Secret_BuildActions();
    for (var i = 0; i < array_length(secretActions); i++) { array_push(actions, secretActions[i]); }
    // Magies continues
    var contActions = AI_ActionSelect_BuildContinuousFromHand();
    for (var j = 0; j < array_length(contActions); j++) { array_push(actions, contActions[j]); }
    // Magies directes (non continues) à jouer depuis la main
    var directMagicActions = AI_ActionSelect_BuildDirectMagicFromHand();
    for (var dj = 0; dj < array_length(directMagicActions); dj++) { array_push(actions, directMagicActions[dj]); }
    // Effets manuels
    var manualActions = AI_ActionSelect_BuildManualEffects();
    for (var k = 0; k < array_length(manualActions); k++) { array_push(actions, manualActions[k]); }

    // Tri décroissant par priorité
    for (var a = 0; a < array_length(actions) - 1; a++) {
        for (var b = a + 1; b < array_length(actions); b++) {
            // Légère priorité aux types selon le profil si égalité ou presque
            var pa = actions[a].priority;
            var pb = actions[b].priority;
            if (abs(pa - pb) < 50) {
                var wa = 0; var wb = 0;
                if (actions[a].kind == "effect") wa = profile.manual_effect_weight; else if (actions[a].kind == "play_magic_hand") wa = profile.continuous_weight; else if (actions[a].kind == "set_secret") wa = profile.secret_weight;
                if (actions[b].kind == "effect") wb = profile.manual_effect_weight; else if (actions[b].kind == "play_magic_hand") wb = profile.continuous_weight; else if (actions[b].kind == "set_secret") wb = profile.secret_weight;
                pa += wa; pb += wb;
            }
            if (pa < pb) { var tmp = actions[a]; actions[a] = actions[b]; actions[b] = tmp; }
        }
    }
    return actions;
}