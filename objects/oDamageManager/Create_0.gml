// oDamageManager - Gestionnaire des dégâts et combats
// Version corrigée - structure unifiée

// Fonction principale de gestion des attaques
tryAttack = function(target) {
    // Vérifications de base
    if (!(instance_exists(game) && game.phase[game.phase_current] == "Attack")) {
        return;
    }
    // Règle: pas d'attaque au tour 1 du duel
    if (variable_instance_exists(game, "nbTurn") && game.nbTurn == 1) {
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
        return;
    }
    // Garde type/owner: seules les cartes Monstre du héros peuvent attaquer
    if (!(variable_instance_exists(attacker, "type") && attacker.type == "Monster")) {
        return;
    }
    if (!(variable_instance_exists(attacker, "isHeroOwner") && attacker.isHeroOwner)) {
        return;
    }

    // Vérifier si l'attaquant peut attaquer
    if (variable_instance_exists(attacker, "attacksUsedThisTurn") && attacker.attacksUsedThisTurn >= 1) {
        return;
    }
    if (variable_instance_exists(attacker, "lastTurnAttack") && attacker.lastTurnAttack == game.nbTurn) {
        return;
    }
    // Vérifier l'orientation
    if (attacker.orientation != "Attack") {
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

    // Combat: démarrage (debug supprimé)

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
    // Début de résolution (debug supprimé)
    
    // Phase guard
    if (!(instance_exists(game) && game.phase[game.phase_current] == "Attack")) {
        return;
    }
    
    // Trouver les instances LP
    var LP_Hero_Instance = instance_find(oLP_Hero, 0);
    var LP_Enemy_Instance = instance_find(oLP_Enemy, 0);
    
    if (LP_Hero_Instance == noone) {
        return;
    }
    
    if (LP_Enemy_Instance == noone) {
        return;
    }
    
    
    // Révéler la carte ennemie si elle est face cachée
    if (variable_instance_exists(cardEnemy, "isFaceDown") && cardEnemy.isFaceDown) {
        cardEnemy.isFaceDown = false;
        if (cardEnemy.orientation == "Defense") cardEnemy.orientation = "DefenseVisible";
        cardEnemy.image_index = 0;
        cardEnemy.image_angle = (cardEnemy.isHeroOwner ? 90 : 270);
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
    
    // Debug ATK Héros/ATK Ennemi supprimé
    
    if (effHeroAtk > effEnemyAtk) {
        // Héros gagne - Ennemi détruit, dégâts aux LP ennemis
        var damage = effHeroAtk - effEnemyAtk;
        
        LP_Enemy_Instance.nbLP -= damage;
        
        destroyCard(cardEnemy, cardHero);
        // Optionnel: FX poison si empoisonneur (cohérence visuelle)
        if (variable_struct_exists(cardHero, "isPoisoner") && cardHero.isPoisoner) {
            spawnPoisonFX(cardEnemy, cardHero);
        }
        
    } else if (effHeroAtk == effEnemyAtk) {
        // Égalité
        var isPoisoner = (variable_struct_exists(cardHero, "isPoisoner") && cardHero.isPoisoner);
        if (isPoisoner) {
            // Empoisonneur: défenseur détruit par poison, attaquant survit
            
            destroyCard(cardEnemy, cardHero);
            spawnPoisonFX(cardEnemy, cardHero);
        } else {
            // Cas normal: destruction mutuelle
            
            destroyCard(cardHero, cardEnemy);
            destroyCard(cardEnemy, cardHero);
        }
        
    } else {
        // Héros perd - Héros détruit, dégâts aux LP du héros
        var damage = effEnemyAtk - effHeroAtk;
        
        LP_Hero_Instance.nbLP -= damage;
        
        destroyCard(cardHero, cardEnemy);
        // Empoisonneur: malgré la défaite, le défenseur est détruit par poison
        if (variable_struct_exists(cardHero, "isPoisoner") && cardHero.isPoisoner) {
            
            destroyCard(cardEnemy, cardHero);
            spawnPoisonFX(cardEnemy, cardHero);
        }
    }

    // Déclencher l'événement post-attaque même si le défenseur a été détruit
    if (instance_exists(cardHero)) {
        var defExists1 = instance_exists(cardEnemy);
        registerTriggerEvent(TRIGGER_AFTER_ATTACK, cardHero, {
            attacker: cardHero,
            defender: defExists1 ? cardEnemy : noone,
            target: defExists1 ? cardEnemy : noone,
            defender_orientation: (defExists1 && variable_instance_exists(cardEnemy, "orientation")) ? cardEnemy.orientation : "unknown",
            direct_attack: false
        });
    }
}

// Combat Attaque vs Défense
resolveAttackVsDefense = function(cardHero, cardEnemy, LP_Hero_Instance, LP_Enemy_Instance) {
    var effHeroAtk = variable_struct_exists(cardHero, "effective_attack") ? cardHero.effective_attack : cardHero.attack;
    var effEnemyDef = variable_struct_exists(cardEnemy, "effective_defense") ? cardEnemy.effective_defense : cardEnemy.defense;
    
    // Debug ATK/DEF supprimé
    
    if (effHeroAtk > effEnemyDef) {
        // Héros gagne - Ennemi détruit, pas de dégâts aux LP
        
        destroyCard(cardEnemy, cardHero);
        
    } else if (effHeroAtk == effEnemyDef) {
        // Égalité - Pas de destruction (sauf poison)
        
        if (variable_struct_exists(cardHero, "isPoisoner") && cardHero.isPoisoner) {
            
            destroyCard(cardEnemy, cardHero);
            spawnPoisonFX(cardEnemy, cardHero);
        }
        
    } else {
        // Héros perd - Dégâts aux LP du héros
        var damage = effEnemyDef - effHeroAtk;
        
        LP_Hero_Instance.nbLP -= damage;
        
        
        // Poison si applicable
        if (variable_struct_exists(cardHero, "isPoisoner") && cardHero.isPoisoner) {
            
            destroyCard(cardEnemy, cardHero);
            spawnPoisonFX(cardEnemy, cardHero);
        }
    }

    // Déclencher l'événement post-attaque même si le défenseur a été détruit
    if (instance_exists(cardHero)) {
        var defExists2 = instance_exists(cardEnemy);
        registerTriggerEvent(TRIGGER_AFTER_ATTACK, cardHero, {
            attacker: cardHero,
            defender: defExists2 ? cardEnemy : noone,
            target: defExists2 ? cardEnemy : noone,
            defender_orientation: (defExists2 && variable_instance_exists(cardEnemy, "orientation")) ? cardEnemy.orientation : "unknown",
            direct_attack: false
        });
    }
}



// Attaque directe
resolveAttackDirect = function(cardHero) {
    // Debug attaque directe supprimé
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
        return;
    }
    
    var damage = variable_struct_exists(cardHero, "effective_attack") ? cardHero.effective_attack : cardHero.attack;
    LP_Enemy_Instance.nbLP -= damage;
    
    
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
    
    if (!(instance_exists(game) && game.phase[game.phase_current] == "Attack")) {
        return;
    }
    
    var LP_Hero_Instance = instance_find(oLP_Hero, 0);
    var LP_Enemy_Instance = instance_find(oLP_Enemy, 0);
    if (LP_Hero_Instance == noone || LP_Enemy_Instance == noone) {
        return;
    }
    
    
    // Révéler le défenseur si face cachée
    if (defender != noone && instance_exists(defender) && variable_instance_exists(defender, "isFaceDown") && defender.isFaceDown) {
        defender.isFaceDown = false;
        if (defender.orientation == "Defense") defender.orientation = "DefenseVisible";
        defender.image_index = 0;
        defender.image_angle = (defender.isHeroOwner ? 90 : 270);
        
    }
    
    // Triggers et secrets
    registerTriggerEvent(TRIGGER_ON_ATTACK, attacker, { attacker: attacker, defender: defender, defender_orientation: (defender != noone ? defender.orientation : "unknown"), direct_attack: false });
    activateSecretsOnAttack(attacker, defender);

    // Déclencher l'événement de défense côté héros avant la résolution
    if (defender != noone && instance_exists(defender)) {
        registerTriggerEvent(TRIGGER_ON_DEFENSE, defender, {
            attacker: attacker,
            defender: defender,
            target: defender,
            direct_attack: false
        });
    }
    if (attacker == noone || !instance_exists(attacker)) {
        return;
    }
    
    if (defender == noone || !instance_exists(defender)) {
        return;
    }
    
    if (defender.orientation == "Attack") {
        var effEnemyAtk = variable_struct_exists(attacker, "effective_attack") ? attacker.effective_attack : attacker.attack;
        var effHeroAtk  = variable_struct_exists(defender, "effective_attack") ? defender.effective_attack : defender.attack;
        
        if (effEnemyAtk > effHeroAtk) {
            var damage = effEnemyAtk - effHeroAtk;
            LP_Hero_Instance.nbLP -= damage;
            destroyCard(defender, attacker);
        } else if (effEnemyAtk == effHeroAtk) {
            destroyCard(attacker, defender);
            destroyCard(defender, attacker);
        } else {
            var damage = effHeroAtk - effEnemyAtk;
            LP_Enemy_Instance.nbLP -= damage;
            destroyCard(attacker, defender);
        }
    } else if (defender.orientation == "Defense" || defender.orientation == "DefenseVisible") {
        var effEnemyAtk = variable_struct_exists(attacker, "effective_attack") ? attacker.effective_attack : attacker.attack;
        var effHeroDef  = variable_struct_exists(defender, "effective_defense") ? defender.effective_defense : defender.defense;
        
        if (effEnemyAtk > effHeroDef) {
            destroyCard(defender, attacker);
        } else if (effEnemyAtk == effHeroDef) {
            if (variable_struct_exists(attacker, "isPoisoner") && attacker.isPoisoner) {
                destroyCard(defender, attacker);
                spawnPoisonFX(defender, attacker);
            }
        } else {
            var damage = effHeroDef - effEnemyAtk;
            LP_Enemy_Instance.nbLP -= damage; // dégâts de contre pour l’ennemi
            if (variable_struct_exists(attacker, "isPoisoner") && attacker.isPoisoner) {
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
    if (instance_exists(attacker)) {
        var defExists3 = instance_exists(defender);
        registerTriggerEvent(TRIGGER_AFTER_ATTACK, attacker, {
            attacker: attacker,
            defender: defExists3 ? defender : noone,
            target: defExists3 ? defender : noone,
            defender_orientation: (defExists3 && variable_instance_exists(defender, "orientation")) ? defender.orientation : "unknown",
            direct_attack: false
        });
    }
};

resolveAttackDirectEnemy = function(cardEnemy) {
    if (cardEnemy == noone || !instance_exists(cardEnemy)) return;
    
    if (!(instance_exists(game) && game.phase[game.phase_current] == "Attack")) {
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
            if (instance_exists(cardEnemy)) {
                cardEnemy.attacksUsedThisTurn = (variable_instance_exists(cardEnemy, "attacksUsedThisTurn") ? cardEnemy.attacksUsedThisTurn : 0) + 1;
                cardEnemy.lastTurnAttack = game.nbTurn;
            }
        }
        return;
    }
    var LP_Hero_Instance = instance_find(oLP_Hero, 0);
    if (LP_Hero_Instance == noone) {
        return;
    }
    var effEnemyAtk = variable_struct_exists(cardEnemy, "effective_attack") ? cardEnemy.effective_attack : cardEnemy.attack;
    var damage = max(0, effEnemyAtk);
    LP_Hero_Instance.nbLP -= damage;
    
    if (instance_exists(cardEnemy)) {
        cardEnemy.attacksUsedThisTurn = (variable_instance_exists(cardEnemy, "attacksUsedThisTurn") ? cardEnemy.attacksUsedThisTurn : 0) + 1;
        cardEnemy.lastTurnAttack = game.nbTurn;
    }
};


