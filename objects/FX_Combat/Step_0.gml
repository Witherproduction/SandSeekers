// FX_Combat - Step

// Initialisation paresseuse: attendre que attacker/defender/mode soient posés
if (!initialized) {
    // Start depuis l’attaquant si dispo
    if (variable_instance_exists(self, "attacker") && attacker != noone && instance_exists(attacker)) {
        start_x = attacker.x; start_y = attacker.y;
    } else {
        start_x = x; start_y = y;
    }
    var tx = start_x; var ty = start_y;
    // Attendre le mode
    if (!variable_instance_exists(self, "mode")) {
        exit;
    }
    
    // Ne pas exécuter de FX de combat hors phase Attaque
    if (!(instance_exists(game) && game.phase[game.phase_current] == "Attack")) {
        show_debug_message("### FX_Combat: Annulé (hors phase Attack). Phase actuelle=" + (instance_exists(game) ? string(game.phase[game.phase_current]) : "unknown"));
        instance_destroy(self);
        exit;
    }
    
    if (mode == "vsMonster") {
        if (variable_instance_exists(self, "defender") && defender != noone && instance_exists(defender)) {
            tx = defender.x; ty = defender.y;
        } else {
            // Pas encore prêt: attendre prochain step
            exit; // quitte l'événement Step pour ce frame
        }
    } else {
        // Attaque directe: choisir cible selon le camp de l’attaquant
        var attacker_is_hero = true;
        if (variable_instance_exists(self, "attacker") && attacker != noone && instance_exists(attacker)) {
            if (variable_instance_exists(attacker, "isHeroOwner")) {
                attacker_is_hero = attacker.isHeroOwner;
            } else {
                // Fallback: déduire le camp par la position à l’écran
                attacker_is_hero = (attacker.y >= room_height * 0.5);
            }
        }
        if (attacker_is_hero) {
            // Héros -> viser bouton ennemi si présent, sinon centre haut
            var btn = instance_find(oAttackDirectEnemy, 0);
            if (btn != noone) { tx = btn.x; ty = btn.y; }
            else { tx = room_width * 0.5; ty = 120; }
        } else {
            // Ennemi -> viser centre de la main héros si dispo, sinon centre bas
            if (instance_exists(handHero)) {
                tx = room_width * 0.5;
                ty = handHero.y;
            } else {
                tx = room_width * 0.5;
                ty = room_height - 120;
            }
        }
    }
    var dx = tx - start_x;
    var dy = ty - start_y;
    var dist = max(1, point_distance(start_x, start_y, tx, ty));
    var nx = dx / dist;
    var ny = dy / dist;
    impact_margin_px = 48;
    impact_x = tx - nx * impact_margin_px;
    impact_y = ty - ny * impact_margin_px;

    // Cible à secouer
    if (variable_instance_exists(self, "mode") && mode == "vsMonster") {
        shake_target_inst = defender;
    } else {
        // Attaque directe: pas de secousse
        shake_target_inst = noone;
    }

    // S'assurer que le défenseur face cachée est révélé en défense visible au début du combat (visuel)
    if (variable_instance_exists(self, "mode") && mode == "vsMonster" && defender != noone && instance_exists(defender)) {
        if (variable_instance_exists(defender.id, "isFaceDown") && defender.isFaceDown) {
            defender.isFaceDown = false;
            if (defender.orientation == "Defense") defender.orientation = "DefenseVisible";
            defender.image_index = 0;
            defender.image_angle = (defender.isHeroOwner ? 90 : 270);
            defender.orientationChangedThisTurn = true; // verrouiller changement de position ce tour
            show_debug_message("### FX_Combat: Défenseur révélé en défense visible au début de l'animation");
        }
    }

    shake_target_orig_x = (shake_target_inst != noone && instance_exists(shake_target_inst)) ? shake_target_inst.x : 0;
    shake_target_orig_y = (shake_target_inst != noone && instance_exists(shake_target_inst)) ? shake_target_inst.y : 0;

    // Secousse (déterminer côté et amplitude)
    shake_amp_px = 6;
    shake_side = "defender";
    if (variable_instance_exists(self, "mode") && mode == "vsMonster" &&
        variable_instance_exists(self, "attacker") && attacker != noone && instance_exists(attacker) &&
        variable_instance_exists(self, "defender") && defender != noone && instance_exists(defender)) {
        var compareVal = 0;
        if (defender.orientation == "Attack") compareVal = attacker.attack - defender.attack; else compareVal = attacker.attack - defender.defense;
        if (compareVal > 0) shake_side = "defender"; else if (compareVal < 0) shake_side = "attacker"; else shake_side = "both";
        shake_amp_px = clamp(abs(compareVal) / 300, 3, 10);
    } else if (variable_instance_exists(self, "mode") && mode != "vsMonster") {
        shake_side = "defender"; // côté LP ennemi
        shake_amp_px = 6;
    }

    // Verrouiller animation d’orientation si besoin
    attacker_orig_pos_anim = false;
    if (variable_instance_exists(self, "attacker") && attacker != noone && instance_exists(attacker)) {
        if (variable_instance_exists(attacker.id, "position_anim_active") && attacker.position_anim_active) {
            attacker_orig_pos_anim = true;
            attacker.position_anim_active = false;
        }
    }

    // Sauvegarder position d’origine
    attacker_orig_x = start_x;
    attacker_orig_y = start_y;
    // Sauvegarder et surélever la profondeur de l’attaquant pour l’animation
    if (variable_instance_exists(self, "attacker") && attacker != noone && instance_exists(attacker)) {
        attacker_orig_depth = attacker.depth;
        attacker.depth = -100001; // dessiner au-dessus des overlays/UI
    }
    if (variable_instance_exists(self, "defender") && defender != noone && instance_exists(defender)) {
        defender_orig_x = defender.x;
        defender_orig_y = defender.y;
    } else { defender_orig_x = 0; defender_orig_y = 0; }

    initialized = true;
}

if (phase == "approach") {
    _t += 1;
    var p = clamp(_t / max(1, approach_frames), 0, 1);
    var pp = 1 - power(1 - p, 3); // easeOutCubic
    if (variable_instance_exists(self, "attacker") && attacker != noone && instance_exists(attacker)) {
        attacker.x = start_x + (impact_x - start_x) * pp;
        attacker.y = start_y + (impact_y - start_y) * pp;
    }
    if (_t >= approach_frames) { phase = "impact"; _t = 0; }
}

else if (phase == "impact") {
    _t += 1;
    var amp = shake_amp_px;
    var jx = random_range(-amp, amp);
    var jy = random_range(-amp, amp);

    if (shake_side == "defender") {
        if (shake_target_inst != noone && instance_exists(shake_target_inst)) {
            shake_target_inst.x = shake_target_orig_x + jx;
            shake_target_inst.y = shake_target_orig_y + jy;
        }
    } else if (shake_side == "attacker") {
        if (variable_instance_exists(self, "attacker") && attacker != noone && instance_exists(attacker)) {
            attacker.x = impact_x + jx * 0.6;
            attacker.y = impact_y + jy * 0.6;
        }
    } else { // both
        if (shake_target_inst != noone && instance_exists(shake_target_inst)) {
            shake_target_inst.x = shake_target_orig_x + jx * 0.75;
            shake_target_inst.y = shake_target_orig_y + jy * 0.75;
        }
        if (variable_instance_exists(self, "attacker") && attacker != noone && instance_exists(attacker)) {
            attacker.x = impact_x + jx * 0.5;
            attacker.y = impact_y + jy * 0.5;
        }
    }

    if (_t >= shake_frames) {
        // Restauration des positions secouées
        if (shake_target_inst != noone && instance_exists(shake_target_inst)) {
            shake_target_inst.x = shake_target_orig_x;
            shake_target_inst.y = shake_target_orig_y;
        }
        if (variable_instance_exists(self, "attacker") && attacker != noone && instance_exists(attacker)) {
            attacker.x = impact_x;
            attacker.y = impact_y;
        }
        // Si attaque directe, insérer une étape de scan des Secrets pour séquencer les animations
        if (variable_instance_exists(self, "mode") && mode != "vsMonster") {
            phase = "secret_scan";
        } else {
            phase = "resolve";
        }
        _t = 0;
    }
}

else if (phase == "secret_scan") {
    // Déterminer si un Secret face cachée va s'activer sur attaque directe
    secret_exists = false;
    secret_card = noone;
    secret_effect_done = false;
    // Déduire le camp: l'attaquant frappe directement son opposant
    var attackerIsHero = (variable_instance_exists(self, "attacker") && attacker != noone && instance_exists(attacker) && variable_instance_exists(attacker, "isHeroOwner")) ? attacker.isHeroOwner : true;
    var defendingIsHero = !attackerIsHero;
    with (oCardMagic) {
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
            var requireDirect = false;
            if (variable_struct_exists(e, "secret_activation") && variable_struct_exists(e.secret_activation, "direct_attack")) {
                requireDirect = e.secret_activation.direct_attack;
            }
            if (!requireDirect) continue;
            chosenEffect = e; break;
        }
        if (chosenEffect == noone) continue;
        other.secret_exists = true;
        other.secret_card = id;
        break;
    }
    if (secret_exists && secret_card != noone && instance_exists(secret_card)) {
        // Lancer une animation de retournement de la carte secrète
        with (secret_card) {
            position_anim_active = true;
            anim_phase = "flip_in";
            anim_flip_orig_scale = image_xscale;
            target_angle = image_angle;
        }
        phase = "secret_reveal";
        _t = 0;
    } else {
        phase = "resolve";
        _t = 0;
    }
}

else if (phase == "secret_reveal") {
    // Attendre la fin de l'animation de flip de la carte secrète
    if (secret_card != noone && instance_exists(secret_card)) {
        if (variable_instance_exists(secret_card.id, "position_anim_active") && !secret_card.position_anim_active) {
            // Déclencher une aura d'effet au centre, puis poursuivre
            if (!is_undefined(requestFXAura)) {
                // Préparer une action de fin pour poursuivre le flux
                global.fx_aura_next_on_complete = function() { secret_effect_done = true; };
                // Afficher la carte secrète au centre avec l’aura
                var spr = (variable_instance_exists(secret_card, "sprite_index")) ? secret_card.sprite_index : noone;
                var img = (variable_instance_exists(secret_card, "image_index")) ? secret_card.image_index : 0;
                var xs  = (variable_instance_exists(secret_card, "image_xscale")) ? secret_card.image_xscale : 1;
                var ys  = (variable_instance_exists(secret_card, "image_yscale")) ? secret_card.image_yscale : 1;
                var ang = (variable_instance_exists(secret_card, "image_angle")) ? secret_card.image_angle : 0;
                // Durée d’aura portée à 1500 ms pour espacer les séquences
                requestFXAura(spr, img, xs, ys, ang, 1500, 18, 10, 1.25, 0.9, room_width * 0.5, room_height * 0.5);
            } else {
                secret_effect_done = true;
            }
            phase = "secret_effect";
            _t = 0;
        }
    } else {
        // Si la carte n'existe plus, poursuivre la résolution normale
        phase = "resolve";
        _t = 0;
    }
}

else if (phase == "secret_effect") {
    // Attendre la fin de l'aura d'effet, puis exécuter l'activation des Secrets et gérer éventuelle redirection
    if (secret_effect_done) {
        var redirectedDefender = noone;
        if (!is_undefined(activateSecretsOnDirectAttack)) {
            // Passer la carte secrète révélée pour activation ciblée même si elle n'est plus face cachée
            redirectedDefender = activateSecretsOnDirectAttack(attacker, secret_card);
        }
        if (redirectedDefender != noone && instance_exists(redirectedDefender)) {
            // Basculer en mode vsMonster et repartir sur une approche vers le défenseur invoqué
            defender = redirectedDefender;
            mode = "vsMonster";
            // Réinitialiser le trajet d'approche
            start_x = attacker.x; start_y = attacker.y;
            var tx = defender.x; var ty = defender.y;
            var dx = tx - start_x;
            var dy = ty - start_y;
            var dist = max(1, point_distance(start_x, start_y, tx, ty));
            var nx = dx / dist;
            var ny = dy / dist;
            impact_margin_px = 48;
            impact_x = tx - nx * impact_margin_px;
            impact_y = ty - ny * impact_margin_px;
            // Mise à jour cible secouée
            shake_target_inst = defender;
            shake_target_orig_x = defender.x;
            shake_target_orig_y = defender.y;
            // Insérer une pause post-invocation avant le départ de l'attaque
            // Pause post-invocation portée à ~1.5s (90 frames à 60 FPS)
            if (!variable_instance_exists(self, "post_summon_pause_frames")) post_summon_pause_frames = 90;
            phase = "post_summon_pause";
            _t = 0;
        } else {
            // Pas de redirection: poursuivre la résolution directe
            phase = "resolve";
            _t = 0;
        }
    }
}

else if (phase == "post_summon_pause") {
    // Pause après l'invocation/redirection pour laisser l'animation respirer
    // Optionnel: on peut ajouter une légère lueur sur le monstre invoqué ici
    _t += 1;
    if (_t >= post_summon_pause_frames) {
        // Après la pause, reprendre l’approche vers le défenseur invoqué
        phase = "approach";
        _t = 0;
    }
}

else if (phase == "resolve") {
    // Résolution via oDamageManager
    var dm = instance_find(oDamageManager, 0);
    if (dm != noone && instance_exists(dm)) {
        if (variable_instance_exists(self, "mode") && mode == "vsMonster") {
            if (variable_instance_exists(self, "attacker") && attacker != noone && instance_exists(attacker) && attacker.isHeroOwner) {
                if (variable_instance_exists(dm.id, "resolveAttackMonster")) {
                    with (dm) resolveAttackMonster(other.attacker, other.defender);
                } else {
                    show_debug_message("### FX_Combat: resolveAttackMonster introuvable sur oDamageManager");
                }
            } else {
                // Ajout d'une garde pour éviter l'erreur si la méthode n'existe pas sur dm
                if (variable_instance_exists(dm.id, "resolveAttackMonsterEnemy")) {
                    with (dm) resolveAttackMonsterEnemy(other.attacker, other.defender);
                } else {
                    show_debug_message("### FX_Combat: resolveAttackMonsterEnemy introuvable sur oDamageManager");
                }
            }
        } else {
            if (variable_instance_exists(self, "attacker") && attacker != noone && instance_exists(attacker) && attacker.isHeroOwner) {
                with (dm) resolveAttackDirect(other.attacker);
            } else {
                if (variable_instance_exists(dm.id, "resolveAttackDirectEnemy")) {
                    with (dm) resolveAttackDirectEnemy(other.attacker);
                } else {
                    // Fallback: résolution directe ennemie locale si la méthode n'existe pas
                    if (variable_instance_exists(self, "attacker") && attacker != noone && instance_exists(attacker)) {
                        var effAtkEnemy = (variable_struct_exists(other.attacker, "effective_attack") ? other.attacker.effective_attack : other.attacker.attack);
                        registerTriggerEvent(TRIGGER_ON_ATTACK, other.attacker, { attacker: other.attacker, defender: noone, direct_attack: true });
                        if (!is_undefined(activateSecretsOnDirectAttack)) activateSecretsOnDirectAttack(other.attacker);
                        var LP_Hero_Instance = instance_find(LP_Hero, 0);
                        if (LP_Hero_Instance != noone) LP_Hero_Instance.nbLP -= effAtkEnemy;
                        if (instance_exists(other.attacker)) { other.attacker.attacksUsedThisTurn = (variable_instance_exists(other.attacker, "attacksUsedThisTurn") ? other.attacker.attacksUsedThisTurn : 0) + 1; other.attacker.lastTurnAttack = game.nbTurn; }
                    }
                }
            }
        }
    }

    // Si l’attaquant existe encore, ne le renvoyer que s’il n’est pas à détruire
    if (variable_instance_exists(self, "attacker") && attacker != noone && instance_exists(attacker)) {
        var willBeDestroyed = (variable_instance_exists(attacker.id, "pendingDestroy") && attacker.pendingDestroy);
        if (!willBeDestroyed) {
            phase = "return";
            _t = 0;
            return_origin_x = attacker.x; // au cas où la résolution a déplacé
            return_origin_y = attacker.y;
            // Cible de retour: centre du slot du terrain
            var fm = attacker.isHeroOwner ? fieldManagerHero : fieldManagerEnemy;
            if (fm != noone) {
                var homeXY = fm.getPosLocation(attacker.type, attacker.fieldPosition);
                return_target_x = homeXY[0];
                return_target_y = homeXY[1];
            } else {
                return_target_x = attacker_orig_x;
                return_target_y = attacker_orig_y;
            }
        } else {
            // Attaquant marqué pour destruction: ne pas le renvoyer
            phase = "done";
        }
    } else {
        phase = "done";
    }
}

else if (phase == "return") {
    _t += 1;
    var p = clamp(_t / max(1, return_frames), 0, 1);
    var pp = 1 - power(1 - p, 3);
    if (variable_instance_exists(self, "attacker") && attacker != noone && instance_exists(attacker)) {
        attacker.x = return_origin_x + (return_target_x - return_origin_x) * pp;
        attacker.y = return_origin_y + (return_target_y - return_origin_y) * pp;
        if (_t >= return_frames) {
            if (attacker_orig_pos_anim && variable_instance_exists(attacker.id, "position_anim_active")) {
                attacker.position_anim_active = true;
            }
            // Restaurer la profondeur d’origine de l’attaquant
            if (variable_instance_exists(self, "attacker") && attacker != noone && instance_exists(attacker)) {
                attacker.depth = attacker_orig_depth;
            }
            phase = "done";
        }
    } else {
        phase = "done";
    }
}

else if (phase == "done") {
    // Finaliser les destructions différées après le retour de l'attaquant
    if (variable_instance_exists(self, "attacker") && attacker != noone && instance_exists(attacker)
        && variable_instance_exists(attacker.id, "pendingDestroy") && attacker.pendingDestroy) {
        var fxA = instance_create_layer(attacker.x, attacker.y, "Instances", FX_Destruction);
        if (fxA != noone) {
            fxA.spriteGhost   = attacker.sprite_index;
            fxA.imageGhost    = attacker.image_index;
            fxA.image_xscale  = attacker.image_xscale;
            fxA.image_yscale  = attacker.image_yscale;
            fxA.image_angle   = attacker.image_angle;
            fxA.duration_ms   = 700;
            fxA.sep_px        = 48;
            fxA.strip_h       = 3;
            fxA.ragged_amp_px = 6;
            fxA.depth_override = -100000;
        }
        instance_destroy(attacker);
    }
    if (variable_instance_exists(self, "defender") && defender != noone && instance_exists(defender)
        && variable_instance_exists(defender.id, "pendingDestroy") && defender.pendingDestroy) {
        var fxD = instance_create_layer(defender.x, defender.y, "Instances", FX_Destruction);
        if (fxD != noone) {
            fxD.spriteGhost   = defender.sprite_index;
            fxD.imageGhost    = defender.image_index;
            fxD.image_xscale  = defender.image_xscale;
            fxD.image_yscale  = defender.image_yscale;
            fxD.image_angle   = defender.image_angle;
            fxD.duration_ms   = 700;
            fxD.sep_px        = 48;
            fxD.strip_h       = 3;
            fxD.ragged_amp_px = 6;
            fxD.depth_override = -100000;
        }
        instance_destroy(defender);
    }
    instance_destroy();
}