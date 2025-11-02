function sMagicSecret() {
    // Initialisation du module des secrets (placeholder)
}

function activateSecretsOnDirectAttack(attacker, targetSecretCard = noone) {
    if (!instance_exists(attacker)) return noone;
    var attackerIsHero = variable_instance_exists(attacker, "isHeroOwner") ? attacker.isHeroOwner : true;
    var defendingIsHero = !attackerIsHero;
    var effAtk = variable_instance_exists(attacker, "effective_attack") ? attacker.effective_attack : (variable_instance_exists(attacker, "attack") ? attacker.attack : 0);

    // Ensemble des noms de secrets déjà activés pendant cette attaque
    var activatedNames = [];
    var redirectDefender = noone;
    
    // Parcourir toutes les cartes Magie (incluant les objets enfants de oCardMagic)
    with (all) {
        if (!instance_exists(id)) continue;
        if (!variable_instance_exists(self, "type") || type != "Magic") continue;
        if (!instance_exists(id)) continue;
        if (!variable_instance_exists(self, "zone") || zone != "Field") continue;
        if (!variable_instance_exists(self, "genre") || string_lower(genre) != string_lower("Secret")) continue;
        // Si une carte précise est ciblée (séquence FX_Combat), ne pas exiger face cachée
        if (targetSecretCard == noone) {
            if (!variable_instance_exists(self, "isFaceDown") || !isFaceDown) continue;
        } else {
            // Restreindre au seul secret ciblé
            if (id != targetSecretCard) continue;
        }
        if (!variable_instance_exists(self, "isHeroOwner") || isHeroOwner != defendingIsHero) continue;
        if (!variable_instance_exists(self, "effects") || array_length(effects) <= 0) continue;
        
        // Cherche un effet de Secret à activer sur attaque directe ou générique
        var chosenEffect = noone;
        for (var i = 0; i < array_length(effects); i++) {
            var e = effects[i];
            if (!is_struct(e)) continue;
            var requireDirect = false;
            var requireOnAttack = false;
            if (variable_struct_exists(e, "secret_activation")) {
                if (variable_struct_exists(e.secret_activation, "direct_attack")) {
                    requireDirect = e.secret_activation.direct_attack;
                }
                if (variable_struct_exists(e.secret_activation, "on_attack")) {
                    requireOnAttack = e.secret_activation.on_attack;
                }
            }
            if (!(requireDirect || requireOnAttack)) continue;
            chosenEffect = e; break;
        }
        if (chosenEffect == noone) continue;
        
        // Clé de déduplication: le nom canonique de la carte
        var cardName = variable_instance_exists(self, "name") ? self.name : object_get_name(object_index);
        var alreadyActivated = false;
        for (var j = 0; j < array_length(activatedNames); j++) {
            if (activatedNames[j] == cardName) { alreadyActivated = true; break; }
        }
        if (alreadyActivated) {
            // Un exemplaire identique a déjà été activé; ignorer cette copie
            continue;
        }
        array_push(activatedNames, cardName);
        
        // Révéler la carte (si pas déjà retournée par l'animation)
        isFaceDown = false;
        image_index = 0;
        
        // Calcul des dégâts
        var dmg = 0;
        if (variable_struct_exists(chosenEffect, "use_attacker_attack_as_value") && chosenEffect.use_attacker_attack_as_value) {
            dmg = effAtk;
        }
        
        // Préparer le contexte avec la valeur des dégâts et le propriétaire cible
        var ctx = { attacker: attacker, defender: noone, value: dmg };
        
        // Si l'effet affecte les LP de l'adversaire, configurer owner_is_hero
        if (variable_struct_exists(chosenEffect, "affect_opponent_lp") && chosenEffect.affect_opponent_lp) {
            ctx.owner_is_hero = !defendingIsHero; // Cibler l'adversaire
        }
        
        // Exécution générique de l'effet
        executeEffect(self, chosenEffect, ctx);
        
        // Si l'effet demande une redirection vers l'instance invoquée, l'utiliser comme nouveau défenseur
        if (variable_struct_exists(chosenEffect, "redirect_attack_to_summoned") && chosenEffect.redirect_attack_to_summoned) {
            if (variable_struct_exists(ctx, "summoned") && ctx.summoned != noone && instance_exists(ctx.summoned)) {
                redirectDefender = ctx.summoned;
            }
        }
        
        // Consommer la carte Secret après activation
        destroyCard(id);
    }
    
    return redirectDefender;
}

// Activation des Secrets sur toute attaque (non-directe ou directe via on_attack)
function activateSecretsOnAttack(attacker, defender) {
    if (!instance_exists(attacker)) return;
    var attackerIsHero = variable_instance_exists(attacker, "isHeroOwner") ? attacker.isHeroOwner : true;
    var defendingIsHero = !attackerIsHero;
    var effAtk = variable_instance_exists(attacker, "effective_attack") ? attacker.effective_attack : (variable_instance_exists(attacker, "attack") ? attacker.attack : 0);

    var activatedNames = [];
    // Parcourir toutes les cartes Magie (incluant les objets enfants de oCardMagic)
    with (all) {
        if (!instance_exists(id)) continue;
        if (!variable_instance_exists(self, "type") || type != "Magic") continue;
        if (!instance_exists(id)) continue;
        if (!variable_instance_exists(self, "zone") || zone != "Field") continue;
        if (!variable_instance_exists(self, "genre") || string_lower(genre) != string_lower("Secret")) continue;
        if (!variable_instance_exists(self, "isFaceDown") || !isFaceDown) continue;
        if (!variable_instance_exists(self, "isHeroOwner") || isHeroOwner != defendingIsHero) continue;
        if (!variable_instance_exists(self, "effects") || array_length(effects) <= 0) continue;

        var chosenEffect = noone;
        for (var i = 0; i < array_length(effects); i++) {
            var e = effects[i];
            if (!is_struct(e)) continue;
            var requireOnAttack = false;
            if (variable_struct_exists(e, "secret_activation") && variable_struct_exists(e.secret_activation, "on_attack")) {
                requireOnAttack = e.secret_activation.on_attack;
            }
            if (!requireOnAttack) continue;
            chosenEffect = e; break;
        }
        if (chosenEffect == noone) continue;

        var cardName = variable_instance_exists(self, "name") ? self.name : object_get_name(object_index);
        var alreadyActivated = false;
        for (var j = 0; j < array_length(activatedNames); j++) {
            if (activatedNames[j] == cardName) { alreadyActivated = true; break; }
        }
        if (alreadyActivated) continue;
        array_push(activatedNames, cardName);

        // Révéler la carte
        isFaceDown = false;
        image_index = 0;

        // Calcul des dégâts
        var dmg = 0;
        if (variable_struct_exists(chosenEffect, "use_attacker_attack_as_value") && chosenEffect.use_attacker_attack_as_value) {
            dmg = effAtk;
            // Support fraction/multiplicateur: moitié d’ATK via attack_value_divisor=2 ou ratio
            if (variable_struct_exists(chosenEffect, "attack_value_divisor") && is_real(chosenEffect.attack_value_divisor) && chosenEffect.attack_value_divisor > 1) {
                dmg = floor(dmg / chosenEffect.attack_value_divisor);
            } else if (variable_struct_exists(chosenEffect, "attack_value_ratio") && is_real(chosenEffect.attack_value_ratio)) {
                dmg = floor(dmg * chosenEffect.attack_value_ratio);
            }
        }

        // Préparer le contexte; si la cible est basée sur la source, la définir
        var ctx = { attacker: attacker, defender: defender, value: dmg };
        if (variable_struct_exists(chosenEffect, "target_source")) {
            var ts = chosenEffect.target_source;
            if (ts == "attacker") ctx.target = attacker;
            else if (ts == "defender") ctx.target = defender;
        }
        
        // Si l'effet affecte les LP de l'adversaire, configurer owner_is_hero
        if (variable_struct_exists(chosenEffect, "affect_opponent_lp") && chosenEffect.affect_opponent_lp) {
            ctx.owner_is_hero = !defendingIsHero; // Cibler l'adversaire
        }
        
        executeEffect(self, chosenEffect, ctx);
        // Consommer la carte Secret après activation
        destroyCard(id);
    }
}

function activateSecretsOnMonsterSummon(summoned) {
    if (!instance_exists(summoned)) return;
    var summonedIsHero = variable_instance_exists(summoned, "isHeroOwner") ? summoned.isHeroOwner : true;
    var defendingIsHero = !summonedIsHero;
    var summonedName = (instance_exists(summoned) && variable_instance_exists(summoned, "name")) ? summoned.name : object_get_name(summoned.object_index);
    show_debug_message("### Secrets: ON_MONSTER_SUMMON pour '" + string(summonedName) + "' ownerIsHero=" + string(summonedIsHero));

    var activatedNames = [];
    // Parcourir toutes les cartes Magie (incluant les objets enfants de oCardMagic)
    with (all) {
        if (!instance_exists(id)) continue;
        if (!variable_instance_exists(self, "type") || type != "Magic") continue;
        if (!instance_exists(id)) continue;
        if (!variable_instance_exists(self, "zone") || zone != "Field") continue;
        if (!variable_instance_exists(self, "genre") || string_lower(genre) != string_lower("Secret")) continue;
        if (!variable_instance_exists(self, "isFaceDown") || !isFaceDown) {
            var nm_fd = variable_instance_exists(self, "name") ? self.name : object_get_name(object_index);
            show_debug_message("### Secrets: skip '" + string(nm_fd) + "' (pas face cachée)");
            continue;
        }
        if (!variable_instance_exists(self, "isHeroOwner") || isHeroOwner != defendingIsHero) {
            var nm_own = variable_instance_exists(self, "name") ? self.name : object_get_name(object_index);
            show_debug_message("### Secrets: skip '" + string(nm_own) + "' (mauvais propriétaire)");
            continue;
        }
        if (!variable_instance_exists(self, "effects") || array_length(effects) <= 0) continue;

        var chosenEffect = noone;
        for (var i = 0; i < array_length(effects); i++) {
            var e = effects[i];
            if (!is_struct(e)) continue;
            var requireOnSummon = false;
            if (variable_struct_exists(e, "secret_activation") && variable_struct_exists(e.secret_activation, "on_summon")) {
                requireOnSummon = e.secret_activation.on_summon;
            }
            if (!requireOnSummon) continue;
            chosenEffect = e; break;
        }
        if (chosenEffect == noone) continue;

        var cardName = variable_instance_exists(self, "name") ? self.name : object_get_name(object_index);
        var alreadyActivated = false;
        for (var j = 0; j < array_length(activatedNames); j++) {
            if (activatedNames[j] == cardName) { alreadyActivated = true; break; }
        }
        if (alreadyActivated) continue;
        array_push(activatedNames, cardName);

        // Révéler la carte
        isFaceDown = false;
        image_index = 0;

        var etype = variable_struct_exists(chosenEffect, "effect_type") ? chosenEffect.effect_type : "unknown";
        show_debug_message("### Secrets: activation '" + string(cardName) + "' sur '" + string(summonedName) + "' (effet=" + string(etype) + ")");

        var ctx = { source: summoned };
        if (variable_struct_exists(chosenEffect, "target_source")) {
            var ts = chosenEffect.target_source;
            if (ts == "summoned") ctx.target = summoned;
        }
        var ok = executeEffect(self, chosenEffect, ctx);
        show_debug_message("### Secrets: effet exécuté=" + string(ok) + "; destruction");
        // Consommer la carte Secret après activation
        destroyCard(id);
    }
}