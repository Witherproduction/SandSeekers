// FX_Invocation - Step
// Phase 1: Interpolation vers l'emplacement désigné
// Phase 2: Post-effet circuit imprimé autour de la carte posée

if (!variable_instance_exists(self, "_post_fx_duration_applied")) {
    if (variable_instance_exists(self, "phase_duration_ms")) {
        post_fx_duration = max(1, ((phase_duration_ms * 4) / 1000.0) * room_speed);
        _post_fx_duration_applied = true;
    } else if (variable_instance_exists(self, "post_fx_duration_ms")) {
        post_fx_duration = max(1, (post_fx_duration_ms / 1000.0) * room_speed);
        _post_fx_duration_applied = true;
    } else {
        _post_fx_duration_applied = true;
    }
}

if (!finished_move) {
    _t++;
    var progress = clamp(_t / duration, 0, 1);
    var ease = progress * progress * (3 - 2 * progress);

    // Position fantôme
    var base_x = lerp(start_x, target_x, ease);
    var base_y = lerp(start_y, target_y, ease);
    x = base_x;
    y = base_y;

    // Fin du mouvement: placer la carte réelle
    if (progress >= 1) {
        if (variable_instance_exists(self, "card_real") && instance_exists(card_real)) {
            var ownerHero = (variable_instance_exists(self, "owner_is_hero") ? owner_is_hero : true);
            var mode      = (variable_instance_exists(self, "summon_mode")   ? summon_mode   : "");
            var ctype     = (variable_instance_exists(self, "card_type")      ? card_type      : "");
            var desiredOr = (variable_instance_exists(self, "desired_orientation") ? desired_orientation : "");

            with (card_real) {
                // Position/zone/échelle
                x = other.target_x;
                y = other.target_y;
                fieldPosition = other.field_position;
                var is_magic_card = (variable_instance_exists(self, "type") && string(type) == "Magic");
                image_xscale = is_magic_card ? 0.2475 : 0.275;
                image_yscale = is_magic_card ? 0.2475 : 0.275;
                zone = "Field";
                depth = ((variable_instance_exists(self, "type") && string(type) == "Monster") ? -1 : 0);

                // Orientation/face selon camp et mode
                if (ownerHero) {
                    if (ctype == "Monster" && mode == "Set") {
                        orientation = "Defense";
                        image_angle = 90;
                        image_index = 1;
                        isFaceDown = true;
                    }
                    else if (ctype == "Monster" && (mode == "Summon" || mode == "SpecialSummon")) {
                        orientation = "Attack";
                        image_angle = 0;
                        image_index = 0;
                        isFaceDown = false;
                    }
                    else if (ctype == "Magic" && mode == "Set") {
                        orientation = "Attack";
                        image_angle = 0;
                        image_index = 1;
                        isFaceDown = true;
                    }
                    else if (ctype == "Magic" && mode == "Summon") {
                        orientation = "Attack";
                        image_angle = 0;
                        image_index = 0;
                        isFaceDown = false;
                    }
                } else {
                    if (desiredOr == "Defense") {
                        orientation = "Defense";
                        image_angle = 270;
                        image_index = 1;
                        isFaceDown = true;
                    } else if (ctype == "Magic" && mode == "Set") {
                        // Secrets/magies posées côté IA doivent être face cachée
                        orientation = "Attack";
                        image_angle = 180;
                        image_index = 1;
                        isFaceDown = true;
                    } else {
                        orientation = "Attack";
                        image_angle = 180;
                        image_index = 0;
                        isFaceDown = false;
                    }
                }

                // Verrou: un monstre invoqué ne peut pas changer de position ce tour
                if (other.card_type == "Monster") {
                    orientationChangedThisTurn = true;
                }

                visible = true;
            }

            // Ajout au terrain via le bon fieldManager
            if (ownerHero) {
                if (instance_exists(fieldManagerHero)) { fieldManagerHero.add(card_real); }
            } else {
                if (instance_exists(fieldManagerEnemy)) { fieldManagerEnemy.add(card_real); }
            }

            // Préparer le post-effet circuit (dimensions réelles + angle)
            circ_w = sprite_get_width(card_real.sprite_index) * card_real.image_xscale;
            circ_h = sprite_get_height(card_real.sprite_index) * card_real.image_yscale;
            circ_angle = card_real.image_angle;

            // Déclencher les événements d’entrée sur le terrain et d’invocation
            if (instance_exists(card_real)) {
                registerTriggerEvent(TRIGGER_ENTER_FIELD, card_real, { summon_mode: mode, owner_is_hero: ownerHero });
                if (ctype == "Monster") {
                    if (mode == "Summon" || mode == "SpecialSummon") {
                        registerTriggerEvent(TRIGGER_ON_SUMMON, card_real, { summon_mode: mode, owner_is_hero: ownerHero });
                        registerTriggerEvent(TRIGGER_ON_MONSTER_SUMMON, card_real, { summon_mode: mode, owner_is_hero: ownerHero });
                    }
                } else if (ctype == "Magic") {
                    if (mode == "Summon") {
                        registerTriggerEvent(TRIGGER_ON_SUMMON, card_real, { summon_mode: mode, owner_is_hero: ownerHero });
                        registerTriggerEvent(TRIGGER_ON_SPELL_CAST, card_real, { summon_mode: mode, owner_is_hero: ownerHero });
                    } else {
                        // Mode Set: ne déclenche pas TRIGGER_ON_SUMMON pour éviter l'activation immédiate
                        // La carte reste posée face cachée et n'active rien ici
                    }
                }
            }

            // Basculer en phase post-effet
            finished_move = true;
            post_fx_t = 0;
        } else {
            // Si la carte réelle n'existe plus (consommée/détruite avant la fin de l'animation),
            // détruire immédiatement cet effet pour éviter qu'une image fantôme reste affichée.
            instance_destroy();
            return;
        }
    }
} else {
    // Phase circuit + flash final: incrémenter le timer
    post_fx_t++;
    // Sécurité: définir une courte durée de flash si absente (par défaut ~0.15s)
    if (!variable_instance_exists(self, "flash_duration")) {
        flash_duration = max(1, (variable_instance_exists(self, "flash_duration_ms") ? (flash_duration_ms / 1000.0) : 0.15) * room_speed);
    }
    if (post_fx_t >= post_fx_duration + flash_duration) {
        // Fin de l'effet total (après le flash)
        instance_destroy();
    }
}
