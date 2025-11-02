// oDamageManager - Gestionnaire des dégâts et combats
// Version corrigée - structure unifiée

// Fonction principale de gestion des attaques
tryAttack = function(target) {
    // Vérifications de base
    if (!(instance_exists(game) && game.phase[game.phase_current] == "Attack")) {
        show_debug_message("### tryAttack: Annulé (hors phase Attack)");
        return;
    }
    // Règle: pas d'attaque au tour 1 du duel
    if (variable_instance_exists(game, "nbTurn") && game.nbTurn == 1) {
        show_debug_message("### tryAttack: Attaque interdite au tour 1 du duel");
        return;
    }

    // Déterminer l'attaquant depuis le SelectManager
    var sm = noone;
    if (instance_exists(oSelectManager) && instance_exists(selectManager)) {
        sm = selectManager;
    } else {
        sm = instance_find(oSelectManager, 0);
    }
    var attacker = noone;
    if (sm != noone && variable_instance_exists(sm, "selected")) {
        attacker = sm.selected;
    }
    if (attacker == noone || attacker == "" || !instance_exists(attacker)) {
        show_debug_message("### tryAttack: Aucun attaquant valide (selectManager.selected)");
        return;
    }
    // Garde type/owner: seules les cartes Monstre du héros peuvent attaquer
    if (!(variable_instance_exists(attacker, "type") && attacker.type == "Monster")) {
        show_debug_message("### tryAttack: Attaquant non-monstre, attaque annulée");
        return;
    }
    if (!(variable_instance_exists(attacker, "isHeroOwner") && attacker.isHeroOwner)) {
        show_debug_message("### tryAttack: Attaquant non-héros, attaque annulée");
        return;
    }

    // Vérifier si l'attaquant peut attaquer
    if (variable_instance_exists(attacker, "attacksUsedThisTurn") && attacker.attacksUsedThisTurn >= 1) {
        show_debug_message("### tryAttack: Cette carte a déjà attaqué ce tour");
        return;
    }
    if (variable_instance_exists(attacker, "lastTurnAttack") && attacker.lastTurnAttack == game.nbTurn) {
        show_debug_message("### tryAttack: Cette carte a déjà attaqué ce tour (lastTurnAttack)");
        return;
    }
    // Vérifier l'orientation
    if (attacker.orientation != "Attack") {
        show_debug_message("### tryAttack: La carte attaquante n'est pas en position d'attaque");
        return;
    }

    // Déterminer le défenseur depuis le paramètre 'target' (carte cliquée)
    var defender = noone;
    if (target != noone && instance_exists(target)) {
        if (variable_instance_exists(target, "isHeroOwner") && !target.isHeroOwner &&
            variable_instance_exists(target, "zone") && target.zone == "Field" &&
            variable_instance_exists(target, "type") && target.type == "Monster") {
            defender = target;
        }
    }

    show_debug_message("### tryAttack: Début du combat - Attaquant: " + attacker.name + ", Défenseur: " + (defender != noone ? defender.name : "Attaque directe"));

    // Effet visuel de combat si activé
    if (variable_global_exists("USE_COMBAT_FX") && global.USE_COMBAT_FX) {
        var fx = instance_create_layer(attacker.x, attacker.y, "Instances", FX_Combat);
        if (fx != noone) {
            fx.attacker = attacker;
            fx.defender = defender;
            fx.mode = (defender != noone) ? "vsMonster" : "direct";
        }
    } else {
        // Résolution directe sans FX
        if (defender == noone) {
            resolveAttackDirect(attacker);
        } else {
            resolveAttackMonster(attacker, defender);
        }
    }
}

// Résolution d'attaque contre un monstre
resolveAttackMonster = function(cardHero, cardEnemy) {
    show_debug_message("### resolveAttackMonster: Début - Héros: " + cardHero.name + " vs Ennemi: " + cardEnemy.name);
    
    // Phase guard
    if (!(instance_exists(game) && game.phase[game.phase_current] == "Attack")) {
        show_debug_message("### resolveAttackMonster: Annulé (hors phase Attack)");
        return;
    }
    
    // Trouver les instances LP
    var LP_Hero_Instance = instance_find(oLP_Hero, 0);
    var LP_Enemy_Instance = instance_find(oLP_Enemy, 0);
    
    if (LP_Hero_Instance == noone) {
        show_debug_message("### resolveAttackMonster: ERREUR - Instance LP_Hero non trouvée!");
        return;
    }
    
    if (LP_Enemy_Instance == noone) {
        show_debug_message("### resolveAttackMonster: ERREUR - Instance LP_Enemy non trouvée!");
        return;
    }
    
    show_debug_message("### resolveAttackMonster: LP Héros avant combat: " + string(LP_Hero_Instance.nbLP));
    show_debug_message("### resolveAttackMonster: LP Ennemi avant combat: " + string(LP_Enemy_Instance.nbLP));
    
    // Révéler la carte ennemie si elle est face cachée
    if (variable_instance_exists(cardEnemy, "isFaceDown") && cardEnemy.isFaceDown) {
        cardEnemy.isFaceDown = false;
        if (cardEnemy.orientation == "Defense") cardEnemy.orientation = "DefenseVisible";
        cardEnemy.image_index = 0;
        cardEnemy.image_angle = (cardEnemy.isHeroOwner ? 90 : 270);
        show_debug_message("### resolveAttackMonster: Carte ennemie révélée");
    }
    
    // Enregistrer les événements de combat
    registerTriggerEvent(TRIGGER_ON_ATTACK, cardHero, { 
        attacker: cardHero, 
        defender: cardEnemy, 
        defender_orientation: cardEnemy.orientation, 
        direct_attack: false 
    });
    
    // Activer les secrets
    activateSecretsOnAttack(cardHero, cardEnemy);
    
    // Combat selon l'orientation de l'ennemi
    if (cardEnemy.orientation == "Attack") {
        resolveAttackVsAttack(cardHero, cardEnemy, LP_Hero_Instance, LP_Enemy_Instance);
    } else if (cardEnemy.orientation == "Defense" || cardEnemy.orientation == "DefenseVisible") {
        resolveAttackVsDefense(cardHero, cardEnemy, LP_Hero_Instance, LP_Enemy_Instance);
    }
    
    // Marquer l'attaque comme utilisée
    if (instance_exists(cardHero)) {
        cardHero.attacksUsedThisTurn = (variable_instance_exists(cardHero, "attacksUsedThisTurn") ? cardHero.attacksUsedThisTurn : 0) + 1;
        cardHero.lastTurnAttack = game.nbTurn;
    }
    
    // Désélectionner la carte
    if (instance_exists(oSelectManager)) {
        selectManager.unSelect(cardHero);
    }
}

// Combat Attaque vs Attaque
resolveAttackVsAttack = function(cardHero, cardEnemy, LP_Hero_Instance, LP_Enemy_Instance) {
    var effHeroAtk = variable_struct_exists(cardHero, "effective_attack") ? cardHero.effective_attack : cardHero.attack;
    var effEnemyAtk = variable_struct_exists(cardEnemy, "effective_attack") ? cardEnemy.effective_attack : cardEnemy.attack;
    
    show_debug_message("### resolveAttackVsAttack: ATK Héros: " + string(effHeroAtk) + ", ATK Ennemi: " + string(effEnemyAtk));
    
    if (effHeroAtk > effEnemyAtk) {
        // Héros gagne - Ennemi détruit, dégâts aux LP ennemis
        var damage = effHeroAtk - effEnemyAtk;
        show_debug_message("### resolveAttackVsAttack: Héros gagne - Dégâts: " + string(damage));
        LP_Enemy_Instance.nbLP -= damage;
        show_debug_message("### resolveAttackVsAttack: LP Ennemi après: " + string(LP_Enemy_Instance.nbLP));
        destroyCard(cardEnemy, cardHero);
        
    } else if (effHeroAtk == effEnemyAtk) {
        // Égalité - Destruction mutuelle
        show_debug_message("### resolveAttackVsAttack: Égalité - Destruction mutuelle");
        destroyCard(cardHero, cardEnemy);
        destroyCard(cardEnemy, cardHero);
        
    } else {
        // Héros perd - Héros détruit, dégâts aux LP du héros
        var damage = effEnemyAtk - effHeroAtk;
        show_debug_message("### resolveAttackVsAttack: Héros perd - Dégâts: " + string(damage));
        LP_Hero_Instance.nbLP -= damage;
        show_debug_message("### resolveAttackVsAttack: LP Héros après: " + string(LP_Hero_Instance.nbLP));
        destroyCard(cardHero, cardEnemy);
    }

    // Déclencher l'événement post-attaque avec la cible (défenseur)
    if (instance_exists(cardHero) && instance_exists(cardEnemy)) {
        registerTriggerEvent(TRIGGER_AFTER_ATTACK, cardHero, {
            attacker: cardHero,
            defender: cardEnemy,
            target: cardEnemy,
            defender_orientation: (variable_instance_exists(cardEnemy, "orientation") ? cardEnemy.orientation : "unknown"),
            direct_attack: false
        });
    }
}

// Combat Attaque vs Défense
resolveAttackVsDefense = function(cardHero, cardEnemy, LP_Hero_Instance, LP_Enemy_Instance) {
    var effHeroAtk = variable_struct_exists(cardHero, "effective_attack") ? cardHero.effective_attack : cardHero.attack;
    var effEnemyDef = variable_struct_exists(cardEnemy, "effective_defense") ? cardEnemy.effective_defense : cardEnemy.defense;
    
    show_debug_message("### resolveAttackVsDefense: ATK Héros: " + string(effHeroAtk) + ", DEF Ennemi: " + string(effEnemyDef));
    
    if (effHeroAtk > effEnemyDef) {
        // Héros gagne - Ennemi détruit, pas de dégâts aux LP
        show_debug_message("### resolveAttackVsDefense: Héros gagne - Ennemi détruit");
        destroyCard(cardEnemy, cardHero);
        
    } else if (effHeroAtk == effEnemyDef) {
        // Égalité - Pas de destruction (sauf poison)
        show_debug_message("### resolveAttackVsDefense: Égalité");
        if (variable_struct_exists(cardHero, "isPoisoner") && cardHero.isPoisoner) {
            show_debug_message("### resolveAttackVsDefense: Poison appliqué");
            destroyCard(cardEnemy, cardHero);
            spawnPoisonFX(cardEnemy, cardHero);
        }
        
    } else {
        // Héros perd - Dégâts aux LP du héros
        var damage = effEnemyDef - effHeroAtk;
        show_debug_message("### resolveAttackVsDefense: Héros perd - Dégâts: " + string(damage));
        LP_Hero_Instance.nbLP -= damage;
        show_debug_message("### resolveAttackVsDefense: LP Héros après: " + string(LP_Hero_Instance.nbLP));
        
        // Poison si applicable
        if (variable_struct_exists(cardHero, "isPoisoner") && cardHero.isPoisoner) {
            show_debug_message("### resolveAttackVsDefense: Poison appliqué malgré la défaite");
            destroyCard(cardEnemy, cardHero);
            spawnPoisonFX(cardEnemy, cardHero);
        }
    }

    // Déclencher l'événement post-attaque avec la cible (défenseur)
    if (instance_exists(cardHero) && instance_exists(cardEnemy)) {
        registerTriggerEvent(TRIGGER_AFTER_ATTACK, cardHero, {
            attacker: cardHero,
            defender: cardEnemy,
            target: cardEnemy,
            defender_orientation: (variable_instance_exists(cardEnemy, "orientation") ? cardEnemy.orientation : "unknown"),
            direct_attack: false
        });
    }
}



// Attaque directe
resolveAttackDirect = function(cardHero) {
    show_debug_message("### resolveAttackDirect: Attaque directe avec " + cardHero.name);
    // Triggers & Secrets (attaque directe contre l’ennemi)
    registerTriggerEvent(TRIGGER_ON_ATTACK, cardHero, { attacker: cardHero, defender: noone, direct_attack: true });
    var redirectedDefender = noone;
    if (!is_undefined(activateSecretsOnDirectAttack)) {
        redirectedDefender = activateSecretsOnDirectAttack(cardHero);
    }
    // Si un Secret adverse a redirigé l’attaque vers une invocation, résoudre comme une attaque vs monstre
    if (redirectedDefender != noone && instance_exists(redirectedDefender)) {
        resolveAttackMonster(cardHero, redirectedDefender);
        return;
    }
    
    var LP_Enemy_Instance = instance_find(oLP_Enemy, 0);
    if (LP_Enemy_Instance == noone) {
        show_debug_message("### resolveAttackDirect: ERREUR - Instance LP_Enemy non trouvée!");
        return;
    }
    
    var damage = variable_struct_exists(cardHero, "effective_attack") ? cardHero.effective_attack : cardHero.attack;
    show_debug_message("### resolveAttackDirect: Dégâts directs: " + string(damage));
    
    LP_Enemy_Instance.nbLP -= damage;
    show_debug_message("### resolveAttackDirect: LP Ennemi après: " + string(LP_Enemy_Instance.nbLP));
    
    // Marquer l'attaque comme utilisée
    if (instance_exists(cardHero)) {
        cardHero.attacksUsedThisTurn = (variable_instance_exists(cardHero, "attacksUsedThisTurn") ? cardHero.attacksUsedThisTurn : 0) + 1;
        cardHero.lastTurnAttack = game.nbTurn;
    }
    
    // Désélectionner
    if (instance_exists(oSelectManager)) {
        selectManager.unSelect(cardHero);
    }
}

// Version pour l'ennemi (si nécessaire)
resolveAttackMonsterEnemy = function(attacker, defender) {
    if (attacker == noone || !instance_exists(attacker)) return;
    show_debug_message("### resolveAttackMonsterEnemy: Début - Ennemi: " + attacker.name + " vs Héros: " + (instance_exists(defender) ? defender.name : "noone"));
    
    if (!(instance_exists(game) && game.phase[game.phase_current] == "Attack")) {
        show_debug_message("### resolveAttackMonsterEnemy: Annulé (hors phase Attack)");
        return;
    }
    
    var LP_Hero_Instance = instance_find(oLP_Hero, 0);
    var LP_Enemy_Instance = instance_find(oLP_Enemy, 0);
    if (LP_Hero_Instance == noone || LP_Enemy_Instance == noone) {
        show_debug_message("### resolveAttackMonsterEnemy: ERREUR - Instances LP introuvables");
        return;
    }
    show_debug_message("### resolveAttackMonsterEnemy: LP Héros avant: " + string(LP_Hero_Instance.nbLP) + ", LP Ennemi avant: " + string(LP_Enemy_Instance.nbLP));
    
    // Révéler le défenseur si face cachée
    if (defender != noone && instance_exists(defender) && variable_instance_exists(defender, "isFaceDown") && defender.isFaceDown) {
        defender.isFaceDown = false;
        if (defender.orientation == "Defense") defender.orientation = "DefenseVisible";
        defender.image_index = 0;
        defender.image_angle = (defender.isHeroOwner ? 90 : 270);
        show_debug_message("### resolveAttackMonsterEnemy: Défenseur héros révélé");
    }
    
    // Triggers et secrets
    registerTriggerEvent(TRIGGER_ON_ATTACK, attacker, { attacker: attacker, defender: defender, defender_orientation: (defender != noone ? defender.orientation : "unknown"), direct_attack: false });
    activateSecretsOnAttack(attacker, defender);
    
    if (defender == noone || !instance_exists(defender)) {
        show_debug_message("### resolveAttackMonsterEnemy: Pas de défenseur — annulation");
        return;
    }
    
    if (defender.orientation == "Attack") {
        var effEnemyAtk = variable_struct_exists(attacker, "effective_attack") ? attacker.effective_attack : attacker.attack;
        var effHeroAtk  = variable_struct_exists(defender, "effective_attack") ? defender.effective_attack : defender.attack;
        show_debug_message("### resolveAttackMonsterEnemy[Atk vs Atk]: ATK Ennemi=" + string(effEnemyAtk) + ", ATK Héros=" + string(effHeroAtk));
        if (effEnemyAtk > effHeroAtk) {
            var damage = effEnemyAtk - effHeroAtk;
            LP_Hero_Instance.nbLP -= damage;
            show_debug_message("### resolveAttackMonsterEnemy: Ennemi gagne — dégâts héros=" + string(damage) + ", LP Héros=" + string(LP_Hero_Instance.nbLP));
            destroyCard(defender, attacker);
        } else if (effEnemyAtk == effHeroAtk) {
            show_debug_message("### resolveAttackMonsterEnemy: Égalité — destruction mutuelle");
            destroyCard(attacker, defender);
            destroyCard(defender, attacker);
        } else {
            var damage = effHeroAtk - effEnemyAtk;
            LP_Enemy_Instance.nbLP -= damage;
            show_debug_message("### resolveAttackMonsterEnemy: Ennemi perd — dégâts ennemis=" + string(damage) + ", LP Ennemi=" + string(LP_Enemy_Instance.nbLP));
            destroyCard(attacker, defender);
        }
    } else if (defender.orientation == "Defense" || defender.orientation == "DefenseVisible") {
        var effEnemyAtk = variable_struct_exists(attacker, "effective_attack") ? attacker.effective_attack : attacker.attack;
        var effHeroDef  = variable_struct_exists(defender, "effective_defense") ? defender.effective_defense : defender.defense;
        show_debug_message("### resolveAttackMonsterEnemy[Atk vs Def]: ATK Ennemi=" + string(effEnemyAtk) + ", DEF Héros=" + string(effHeroDef));
        if (effEnemyAtk > effHeroDef) {
            show_debug_message("### resolveAttackMonsterEnemy: Ennemi gagne — défenseur détruit (pas de dégâts LP)");
            destroyCard(defender, attacker);
        } else if (effEnemyAtk == effHeroDef) {
            show_debug_message("### resolveAttackMonsterEnemy: Égalité");
            if (variable_struct_exists(attacker, "isPoisoner") && attacker.isPoisoner) {
                show_debug_message("### resolveAttackMonsterEnemy: Poison appliqué — défenseur détruit");
                destroyCard(defender, attacker);
                spawnPoisonFX(defender, attacker);
            }
        } else {
            var damage = effHeroDef - effEnemyAtk;
            LP_Enemy_Instance.nbLP -= damage; // dégâts de contre pour l’ennemi
            show_debug_message("### resolveAttackMonsterEnemy: Ennemi perd — dégâts ennemis=" + string(damage) + ", LP Ennemi=" + string(LP_Enemy_Instance.nbLP));
            if (variable_struct_exists(attacker, "isPoisoner") && attacker.isPoisoner) {
                show_debug_message("### resolveAttackMonsterEnemy: Poison appliqué malgré la défaite");
                destroyCard(defender, attacker);
                spawnPoisonFX(defender, attacker);
            }
        }
    }
    
    // Marquer l'attaque côté ennemi
    if (instance_exists(attacker)) {
        attacker.attacksUsedThisTurn = (variable_instance_exists(attacker, "attacksUsedThisTurn") ? attacker.attacksUsedThisTurn : 0) + 1;
        attacker.lastTurnAttack = game.nbTurn;
    }

    // Déclencher l'événement post-attaque côté ennemi avec la cible (défenseur héros)
    if (instance_exists(attacker) && instance_exists(defender)) {
        registerTriggerEvent(TRIGGER_AFTER_ATTACK, attacker, {
            attacker: attacker,
            defender: defender,
            target: defender,
            defender_orientation: (variable_instance_exists(defender, "orientation") ? defender.orientation : "unknown"),
            direct_attack: false
        });
    }
};

resolveAttackDirectEnemy = function(cardEnemy) {
    if (cardEnemy == noone || !instance_exists(cardEnemy)) return;
    show_debug_message("### resolveAttackDirectEnemy: Attaque directe ennemie avec " + cardEnemy.name);
    if (!(instance_exists(game) && game.phase[game.phase_current] == "Attack")) {
        show_debug_message("### resolveAttackDirectEnemy: Annulé (hors phase Attack)");
        return;
    }
    // Triggers & Secrets (attaque directe contre le héros)
    registerTriggerEvent(TRIGGER_ON_ATTACK, cardEnemy, { attacker: cardEnemy, defender: noone, direct_attack: true });
    var redirectedDefender = noone;
    if (!is_undefined(activateSecretsOnDirectAttack)) {
        redirectedDefender = activateSecretsOnDirectAttack(cardEnemy);
    }
    // Si un Secret a redirigé l’attaque vers une invocation, résoudre comme une attaque vs monstre
    if (redirectedDefender != noone && instance_exists(redirectedDefender)) {
        if (variable_instance_exists(id, "resolveAttackMonsterEnemy")) {
            with (id) resolveAttackMonsterEnemy(cardEnemy, redirectedDefender);
        } else {
            // Fallback minimal si l’API n’existe pas: pas de dégâts directs, marquer l’attaque
            show_debug_message("### resolveAttackDirectEnemy: Redirection active, pas de dégâts directs");
            if (instance_exists(cardEnemy)) {
                cardEnemy.attacksUsedThisTurn = (variable_instance_exists(cardEnemy, "attacksUsedThisTurn") ? cardEnemy.attacksUsedThisTurn : 0) + 1;
                cardEnemy.lastTurnAttack = game.nbTurn;
            }
        }
        return;
    }
    var LP_Hero_Instance = instance_find(oLP_Hero, 0);
    if (LP_Hero_Instance == noone) {
        show_debug_message("### resolveAttackDirectEnemy: ERREUR - Instance LP_Hero non trouvée!");
        return;
    }
    var effEnemyAtk = variable_struct_exists(cardEnemy, "effective_attack") ? cardEnemy.effective_attack : cardEnemy.attack;
    var damage = max(0, effEnemyAtk);
    LP_Hero_Instance.nbLP -= damage;
    show_debug_message("### resolveAttackDirectEnemy: Dégâts directs au héros: " + string(damage) + ", LP Héros après: " + string(LP_Hero_Instance.nbLP));
    if (instance_exists(cardEnemy)) {
        cardEnemy.attacksUsedThisTurn = (variable_instance_exists(cardEnemy, "attacksUsedThisTurn") ? cardEnemy.attacksUsedThisTurn : 0) + 1;
        cardEnemy.lastTurnAttack = game.nbTurn;
    }
};


