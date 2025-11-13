/// sAISecret.gml — Scoring et génération d'actions pour les cartes Secret

/// Calcul du score heuristique d'une carte Secret selon le contexte actuel
function AI_Secret_Score(card) {
    if (card == 0 || !instance_exists(card)) return -100000;
    if (!(variable_instance_exists(card, "type") && card.type == "Magic")) return -100000;
    if (!(variable_instance_exists(card, "genre") && string_lower(card.genre) == string_lower("Secret"))) return -100000;

    var hasOnAttack = false;
    var hasOnDirect = false;
    var hasOnSummon = false;
    if (variable_struct_exists(card, "effects")) {
        for (var i = 0; i < array_length(card.effects); i++) {
            var e = card.effects[i];
            if (!is_struct(e)) continue;
            if (variable_struct_exists(e, "secret_activation")) {
                if (variable_struct_exists(e.secret_activation, "on_attack") && e.secret_activation.on_attack) hasOnAttack = true;
                if (variable_struct_exists(e.secret_activation, "direct_attack") && e.secret_activation.direct_attack) hasOnDirect = true;
                if (variable_struct_exists(e.secret_activation, "on_summon") && e.secret_activation.on_summon) hasOnSummon = true;
            }
        }
    }

    // Contexte plateau
    var heroHasAtk = false; var heroAtkCount = 0;
    for (var hh = 0; hh < array_length(fieldMonsterHero.cards); hh++) {
        var hC = fieldMonsterHero.cards[hh];
        if (hC != 0 && instance_exists(hC) && hC.type == "Monster") {
            var ha = variable_struct_exists(hC, "effective_attack") ? hC.effective_attack : (variable_instance_exists(hC, "attack") ? hC.attack : 0);
            if (ha > 0) { heroHasAtk = true; heroAtkCount++; }
        }
    }
    var enemyHasMonsters = false;
    for (var ee = 0; ee < array_length(fieldMonsterEnemy.cards); ee++) {
        var eC = fieldMonsterEnemy.cards[ee]; if (eC != 0 && instance_exists(eC)) { enemyHasMonsters = true; break; }
    }

    // Éviter le conflit avec la variable builtin `score` de GameMaker
    var secret_score = 0;
    if (hasOnAttack && heroHasAtk) secret_score += 300 + min(200, heroAtkCount * 50);
    if (hasOnDirect && !enemyHasMonsters && heroHasAtk) secret_score += 320;
    if (hasOnSummon) secret_score += 180;

    var dif = (variable_global_exists("IA_DIFFICULTY") ? global.IA_DIFFICULTY : 0);
    if (dif == 1) secret_score += 80; // léger biais proactif en difficile

    return secret_score;
}

/// Génère les actions de pose des Secrets depuis la main (face cachée), si slot libre
function AI_Secret_BuildActions() {
    var actions = [];
    if (!ds_exists(handEnemy.cards, ds_type_list)) return actions;

    var mtField = fieldManagerEnemy.getField("MagicTrap");
    var hasFreeMTSlot = false;
    if (mtField != noone && variable_struct_exists(mtField, "cards")) {
        for (var i = 0; i < array_length(mtField.cards); i++) { if (mtField.cards[i] == 0) { hasFreeMTSlot = true; break; } }
    }
    if (!hasFreeMTSlot) return actions;

    var hsize = ds_list_size(handEnemy.cards);
    for (var h = 0; h < hsize; h++) {
        var c = ds_list_find_value(handEnemy.cards, h);
        if (c != 0 && instance_exists(c) && variable_instance_exists(c, "genre") && string_lower(c.genre) == string_lower("Secret") && c.type == "Magic") {
            var sc = AI_Secret_Score(c);
            var prio = 350 + sc;
            array_push(actions, { kind: "set_secret_hand", card: c, priority: prio });
        }
    }
    return actions;
}