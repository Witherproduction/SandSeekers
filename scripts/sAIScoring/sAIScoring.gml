/// sAIScoring.gml — Heuristiques de scoring pour l’IA

/// Priorité intrinsèque d’un effet, indépendante du gain net calculé
function AI_EffectPriority(card, effect) {
    var base = 0;
    var eType = variable_struct_exists(effect, "effect_type") ? effect.effect_type : -1;
    var dif = (variable_global_exists("IA_DIFFICULTY") ? global.IA_DIFFICULTY : 0);
    // Profil actif pour pondérer les catégories d'effets
    var profile = AI_Config_GetActiveProfile();

    var heroHas = false; var ourCount = 0;
    for (var i = 0; i < 5; i++) { if (fieldMonsterHero.cards[i] != 0 && instance_exists(fieldMonsterHero.cards[i])) heroHas = true; if (fieldMonsterEnemy.cards[i] != 0 && instance_exists(fieldMonsterEnemy.cards[i])) ourCount++; }

    if (eType == EFFECT_DESTROY_TARGET || eType == EFFECT_BANISH_TARGET || eType == EFFECT_RETURN_TO_HAND) {
        var tgt = AI_Targeting_ChooseBestTarget(eType);
        var tAtk = (tgt != noone && variable_instance_exists(tgt, "attack")) ? tgt.attack : 0;
        base = (1000 + tAtk) * (profile.removal_weight / 50.0);
        if (dif == 1 && heroHas) base += 300;
    } else if (eType == EFFECT_GAIN_ATTACK || eType == EFFECT_GAIN_DEFENSE || eType == EFFECT_SET_ATTACK || eType == EFFECT_SET_DEFENSE) {
        base = 600 * (profile.board_presence_weight / 50.0);
        if (dif == 1 && ourCount > 0) base += 150;
    } else if (eType == EFFECT_DRAW_CARDS || eType == EFFECT_SEARCH) {
        var drawBias = (eType == EFFECT_DRAW_CARDS) ? profile.draw_weight : profile.tutor_weight;
        base = 300 * (drawBias / 50.0);
        if (dif == 1 && ourCount == 0) base += 150;
    } else if (eType == EFFECT_SUMMON) {
        var emptySlots = 0; for (var i2 = 0; i2 < 5; i2++) { if (fieldMonsterEnemy.cards[i2] == 0) emptySlots++; }
        base = ((emptySlots > 0) ? 500 : 50) * (profile.summon_weight / 50.0);
        if (dif == 1 && emptySlots > 0) base += 100;
    } else if (eType == EFFECT_NEGATE_EFFECT) {
        var mt = fieldManagerHero.getField("MagicTrap"); var hasMT = false;
        if (mt != noone && variable_struct_exists(mt, "cards")) {
            for (var i3 = 0; i3 < array_length(mt.cards); i3++) { if (mt.cards[i3] != 0 && instance_exists(mt.cards[i3])) { hasMT = true; break; } }
        }
        base = (hasMT ? 900 : 200) * (profile.counter_bias / 50.0);
        if (dif == 1 && hasMT) base += 150;
    } else {
        base = 200;
    }
    return base;
}