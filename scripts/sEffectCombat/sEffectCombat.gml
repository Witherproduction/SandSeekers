/// sEffectCombat.gml — Helpers d’effets de combat (ATK/DEF, dégâts/soins, destruction)

function modifyAttack(card, amount, temporary = false) {
    if (card == noone) return false;
    if (temporary) {
        if (!variable_struct_exists(card, "temp_attack")) {
            card.temp_attack = 0;
        }
        card.temp_attack += amount;
    } else {
        card.attack += amount;
        card.attack = max(0, card.attack);
        // Si le système de buffs/effectifs est utilisé, recalculer l'ATK effective
        if (variable_instance_exists(card, "effective_attack") || variable_instance_exists(card, "buff_contribs")) {
            if (is_undefined(buffRecompute)) {
                // Pas de recalcul disponible, mettre à jour directement si possible
                if (variable_instance_exists(card, "effective_attack")) {
                    card.effective_attack = card.attack;
                }
            } else {
                buffRecompute(card);
            }
        }
    }
    return true;
}

/// @function modifyDefense(card, amount, temporary)
function modifyDefense(card, amount, temporary = false) {
    if (card == noone) return false;
    if (temporary) {
        if (!variable_struct_exists(card, "temp_defense")) {
            card.temp_defense = 0;
        }
        card.temp_defense += amount;
    } else {
        card.defense += amount;
        card.defense = max(0, card.defense);
        // Recalculer la DEF effective si le système est en place
        if (variable_instance_exists(card, "effective_defense") || variable_instance_exists(card, "buff_contribs")) {
            if (is_undefined(buffRecompute)) {
                if (variable_instance_exists(card, "effective_defense")) {
                    card.effective_defense = card.defense;
                }
            } else {
                buffRecompute(card);
            }
        }
    }
    return true;
}

/// @function setAttack(card, value)
function setAttack(card, value) {
    if (card == noone) return false;
    card.attack = max(0, value);
    // Synchroniser l'ATK effective si présente
    if (variable_instance_exists(card, "effective_attack") || variable_instance_exists(card, "buff_contribs")) {
        if (is_undefined(buffRecompute)) {
            if (variable_instance_exists(card, "effective_attack")) {
                card.effective_attack = card.attack;
            }
        } else {
            buffRecompute(card);
        }
    }
    return true;
}

/// @function setDefense(card, value)
function setDefense(card, value) {
    if (card == noone) return false;
    card.defense = max(0, value);
    // Synchroniser la DEF effective si présente
    if (variable_instance_exists(card, "effective_defense") || variable_instance_exists(card, "buff_contribs")) {
        if (is_undefined(buffRecompute)) {
            if (variable_instance_exists(card, "effective_defense")) {
                card.effective_defense = card.defense;
            }
        } else {
            buffRecompute(card);
        }
    }
    return true;
}

// === Dégâts et soins ===
/// @function damageCard(card, amount)
function damageCard(card, amount) {
    if (card == noone) return false;
    registerTriggerEvent(TRIGGER_ON_DAMAGE, card, { damage: amount, source: card });
    if (variable_struct_exists(card, "current_hp")) {
        card.current_hp -= amount;
        if (card.current_hp <= 0) { destroyCard(card); }
    } else if (variable_struct_exists(card, "defense")) {
        card.defense -= amount;
        if (card.defense <= 0) { destroyCard(card); }
    }
    return true;
}

/// @function healCard(card, amount)
function healCard(card, amount) {
    if (card == noone) return false;
    registerTriggerEvent(TRIGGER_ON_HEAL, card, { heal: amount, target: card });
    if (variable_struct_exists(card, "current_hp") && variable_struct_exists(card, "max_hp")) {
        card.current_hp = min(card.max_hp, card.current_hp + amount);
    } else if (variable_struct_exists(card, "defense") && variable_struct_exists(card, "original_defense")) {
        card.defense = min(card.original_defense, card.defense + amount);
    }
    return true;
}

// === Destruction, bannissement, retour en main ===
/// @function destroyCard(card, source)
/// @description Détruit une carte et enregistre le contexte (incluant l'attaquant si fourni)
function destroyCard(card, source = noone) {
    if (card == noone) return false;
    var ctx = { destroyed_card: card };
    if (source != noone && instance_exists(source)) { ctx.attacker = source; }
    registerTriggerEvent(TRIGGER_ON_DESTROY, card, ctx);
    
    // Utiliser les variables globales des cimetières
    var gyInst = noone;
    if (card.isHeroOwner) {
        gyInst = global.graveyardHero;
    } else {
        gyInst = global.graveyardEnemy;
    }
    
    if (gyInst != noone && instance_exists(gyInst)) {
        gyInst.addToGraveyard(card);
    } else {
        show_debug_message("### destroyCard: cimetière introuvable pour owner=" + string(card.isHeroOwner) + " (global.graveyardHero=" + string(global.graveyardHero) + ", global.graveyardEnemy=" + string(global.graveyardEnemy) + ")");
    }
    if (instance_exists(card) && variable_instance_exists(card, "zone")) {
        if (card.zone == "Field" || card.zone == "FieldSelected") {
            var fm = noone;
            if (instance_exists(fieldManagerHero) || instance_exists(fieldManagerEnemy)) {
                if (variable_instance_exists(card, "isHeroOwner") && card.isHeroOwner && instance_exists(fieldManagerHero)) { fm = fieldManagerHero; }
                else if (instance_exists(fieldManagerEnemy)) { fm = fieldManagerEnemy; }
            }
            if (fm != noone && variable_instance_exists(card, "fieldPosition")) { fm.remove(card); }
        }
        card.zone = "Graveyard";
        registerTriggerEvent(TRIGGER_ENTER_GRAVEYARD, card, {});
        var fx = instance_create_layer(card.x, card.y, "Instances", FX_Destruction);
        if (fx != noone) {
            fx.spriteGhost   = card.sprite_index;
            fx.imageGhost    = card.image_index;
            fx.image_xscale  = card.image_xscale;
            fx.image_yscale  = card.image_yscale;
            fx.image_angle   = card.image_angle;
            fx.duration_ms   = 700;
            fx.sep_px        = 48;
            fx.strip_h       = 3;
            fx.ragged_amp_px = 6;
            if (variable_instance_exists(self, "target") && instance_exists(target) && variable_instance_exists(target, "depth")) { fx.depth_override = target.depth + 1; }
            else { fx.depth_override = 100000; }
        }
        if (instance_exists(card)) { instance_destroy(card); }
    }
    return true;
}

/// @function spawnPoisonFX(target, source)
function spawnPoisonFX(target, source) {
    if (target == noone) return;
    var lx = (instance_exists(target) && variable_instance_exists(target, "x")) ? target.x : 0;
    var ly = (instance_exists(target) && variable_instance_exists(target, "y")) ? target.y : 0;
    var fx = instance_create_layer(lx, ly, "Instances", FX_Poison);
    if (fx != noone) {
        if (instance_exists(source)) fx.source = source;
        fx.target = target;
        fx.depth_override = -100000;
        if (variable_instance_exists(target, "image_xscale")) fx.image_xscale = target.image_xscale;
        if (variable_instance_exists(target, "image_yscale")) fx.image_yscale = target.image_yscale;
        if (!variable_instance_exists(fx, "duration_steps")) fx.duration_steps = max(1, floor(room_speed * 0.6));
        if (!variable_instance_exists(fx, "color")) fx.color = make_color_rgb(60, 200, 80);
    }
}

// === Effets de zone ===
function damageAllMonsters(amount, effect) {
    var targets = getTargetsByFilter(effect);
    for (var i = 0; i < array_length(targets); i++) { damageCard(targets[i], amount); }
    return true;
}

function healAllMonsters(amount, effect) {
    var targets = getTargetsByFilter(effect);
    for (var i = 0; i < array_length(targets); i++) { healCard(targets[i], amount); }
    return true;
}

function destroyAllMonsters(effect) {
    var targets = getTargetsByFilter(effect);
    for (var i = 0; i < array_length(targets); i++) { destroyCard(targets[i]); }
    return true;
}