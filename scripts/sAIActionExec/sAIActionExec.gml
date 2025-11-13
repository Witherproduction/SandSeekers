/// sAIActionExec.gml — Planification et exécution des actions IA (magies, secrets, effets)

// Exécution réelle d'une action (dépilée depuis la file par oIA.Step)
function AI_ActionExec_Perform(action) {
    if (action == noone) return false;

    if (action.kind == "play_magic_hand") {
        var c0 = action.card; var equipEffect = action.equipEffect; var tgtEquip = (variable_struct_exists(action, "target") ? action.target : noone);
        var mtField = fieldManagerEnemy.getField("MagicTrap"); if (mtField == noone || !variable_struct_exists(mtField, "cards")) return false;
        var pos = -1; for (var mti = 0; mti < array_length(mtField.cards); mti++) { if (mtField.cards[mti] == 0) { pos = mti; break; } }
        if (pos == -1) return false;
        var XY0 = fieldManagerEnemy.getPosLocation("MagicTrap", pos);
        var isSecretMagic = (variable_instance_exists(c0, "genre") && string_lower(c0.genre) == string_lower("Secret"));
        UIManager.selectedSummonOrSet = isSecretMagic ? "Set" : "Summon";
        var summoned0 = handEnemy.summon(c0, [XY0[0], XY0[1], pos]);
        UIManager.selectedSummonOrSet = "";
        if (!summoned0) {
            if (c0 != noone && instance_exists(c0) && variable_instance_exists(c0, "zone") && (c0.zone == "Field" || c0.zone == "FieldSelected")) {
                summoned0 = true;
                show_debug_message("### IA: pose Magie considérée réussie malgré retour false");
            } else {
                return false;
            }
        }
        var ctx0 = { summon_mode: (isSecretMagic ? "Set" : "Summon"), owner_is_hero: false };
        registerTriggerEvent(TRIGGER_ON_SUMMON, c0, ctx0);
        if (!isSecretMagic) { registerTriggerEvent(TRIGGER_ON_SPELL_CAST, c0, ctx0); }
        if (equipEffect != noone) {
            if (!variable_instance_exists(c0, "equip_pending")) c0.equip_pending = false;
            if (tgtEquip != noone) {
                c0.equip_pending = true;
                var ctxEquipNow = { owner_is_hero: false, target: tgtEquip };
                show_debug_message("### Artefact IA: activation '" + string(variable_instance_exists(c0, "name") ? c0.name : "[sans nom]") + "' -> cible '" + string(variable_instance_exists(tgtEquip, "name") ? tgtEquip.name : "[sans nom]") + "'");
                var okEquip = executeEffect(c0, equipEffect, ctxEquipNow);
                if (okEquip) {
                    markEffectAsUsed(c0, equipEffect);
                } else {
                    show_debug_message("### IA: activation d'équipement échouée, effet non marqué comme utilisé");
                }
            }
        }
        // Si un effet direct a été sélectionné pour cette magie, l'exécuter après la pose
        if (variable_struct_exists(action, "effectToExecute") && action.effectToExecute != noone) {
            var eff = action.effectToExecute;
            var ctxEff = { owner_is_hero: false };
            if (variable_struct_exists(action, "target") && action.target != noone) ctxEff.target = action.target;
            if (variable_struct_exists(eff, "trigger")) {
                activateTrigger(c0, eff.trigger, ctxEff);
            } else {
                var okEff = executeEffect(c0, eff, ctxEff);
                if (okEff) { markEffectAsUsed(c0, eff); }
            }
        }
        return true;
    } else if (action.kind == "set_secret_hand") {
        var cS = action.card;
        var mtFieldS = fieldManagerEnemy.getField("MagicTrap"); if (mtFieldS == noone || !variable_struct_exists(mtFieldS, "cards")) return false;
        var posS = -1; for (var ms = 0; ms < array_length(mtFieldS.cards); ms++) { if (mtFieldS.cards[ms] == 0) { posS = ms; break; } }
        if (posS == -1) return false;
        var XYs = fieldManagerEnemy.getPosLocation("MagicTrap", posS);
        UIManager.selectedSummonOrSet = "Set";
        var summonedS = handEnemy.summon(cS, [XYs[0], XYs[1], posS]);
        UIManager.selectedSummonOrSet = "";
        if (!summonedS) return false;
        var ctxS = { summon_mode: "Set", owner_is_hero: false };
        registerTriggerEvent(TRIGGER_ON_SUMMON, cS, ctxS);
        return true;
    } else if (action.kind == "effect") {
        var ctx = { owner_is_hero: false };
        if (variable_struct_exists(action, "target") && action.target != noone) ctx.target = action.target;
        if (variable_struct_exists(action.effect, "trigger")) {
            activateTrigger(action.card, action.effect.trigger, ctx);
        } else {
            var ok = executeEffect(action.card, action.effect, ctx);
            markEffectAsUsed(action.card, action.effect);
        }
        return true;
    }
    return false;
}

// Planifie une action IA pour exécution différée (file dans oIA)
function AI_ActionExec_Run(action) {
    if (action == noone) return false;
    if (instance_exists(IA)) {
        if (!variable_instance_exists(IA, "manualEffectsQueue") || !is_array(IA.manualEffectsQueue)) IA.manualEffectsQueue = [];
        array_push(IA.manualEffectsQueue, action);
        IA.manualEffectProcessing = true;
        IA.iaDelayFrames = (variable_global_exists("IA_ACTION_DELAY_FRAMES") ? global.IA_ACTION_DELAY_FRAMES : room_speed);
        return true;
    }
    return false;
}