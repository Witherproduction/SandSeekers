// === Script des Déclencheurs d'Effets de Monstres ===

// Ce script contient tous les déclencheurs possibles pour les effets de cartes



// === CONSTANTES DES DÉCLENCHEURS ===



// Déclencheurs de base

#macro TRIGGER_ON_SUMMON "on_summon"                    // Quand la carte est invoquée

#macro TRIGGER_ON_DESTROY "on_destroy"                  // Quand la carte est détruite

#macro TRIGGER_ON_ATTACK "on_attack"                    // Quand la carte attaque

#macro TRIGGER_ON_DEFENSE "on_defense"                  // Quand la carte se défend

#macro TRIGGER_ON_DAMAGE "on_damage"                    // Quand la carte subit des dégâts

#macro TRIGGER_ON_HEAL "on_heal"                        // Quand la carte est soignée



// Déclencheurs de phase

#macro TRIGGER_START_TURN "start_turn"                  // Début du tour

#macro TRIGGER_END_TURN "end_turn"                      // Fin du tour

#macro TRIGGER_DRAW_PHASE "draw_phase"                  // Phase de pioche

#macro TRIGGER_MAIN_PHASE "main_phase"                  // Phase principale

#macro TRIGGER_BATTLE_PHASE "battle_phase"              // Phase de combat

#macro TRIGGER_END_PHASE "end_phase"                    // Phase de fin



// Déclencheurs d'interaction

#macro TRIGGER_ON_TARGET "on_target"                    // Quand la carte est ciblée

#macro TRIGGER_ON_EQUIP "on_equip"                      // Quand un équipement est attaché

#macro TRIGGER_ON_UNEQUIP "on_unequip"                  // Quand un équipement est retiré

#macro TRIGGER_ON_FLIP "on_flip"                        // Quand la carte est retournée



// Déclencheurs de zone

#macro TRIGGER_ENTER_FIELD "enter_field"                // Entre sur le terrain

#macro TRIGGER_LEAVE_FIELD "leave_field"                // Quitte le terrain

#macro TRIGGER_ENTER_HAND "enter_hand"                  // Entre dans la main

#macro TRIGGER_LEAVE_HAND "leave_hand"                  // Quitte la main

#macro TRIGGER_ENTER_GRAVEYARD "enter_graveyard"        // Entre dans le cimetière

#macro TRIGGER_LEAVE_GRAVEYARD "leave_graveyard"        // Quitte le cimetière



// Ajouts: déclencheurs de combat dédiés

#macro TRIGGER_AFTER_ATTACK "after_attack"              // Apres la resolution dune attaque

#macro TRIGGER_AFTER_DEFENSE "after_defense"            // Apres la resolution dune defense



// Déclencheurs conditionnels

#macro TRIGGER_ON_LP_CHANGE "on_lp_change"              // Quand les LP changent

#macro TRIGGER_ON_CARD_DRAW "on_card_draw"              // Quand une carte est piochée

#macro TRIGGER_ON_SPELL_CAST "on_spell_cast"            // Quand un sort est lancé

#macro TRIGGER_ON_MONSTER_SUMMON "on_monster_summon"    // Quand un monstre est invoqué

#macro TRIGGER_ON_MONSTER_SENT_TO_GRAVEYARD "on_monster_sent_to_graveyard" // Quand un monstre est envoyé au cimetière (global)



// Déclencheurs spéciaux

#macro TRIGGER_ONCE_PER_TURN "once_per_turn"            // Une fois par tour

#macro TRIGGER_CONTINUOUS "continuous"                   // Effet continu

#macro TRIGGER_QUICK_EFFECT "quick_effect"              // Effet rapide

#macro TRIGGER_COUNTER "counter"                        // Effet de contre



// === FONCTION PRINCIPALE DE GESTION DES DÉCLENCHEURS ===



/// @function checkTrigger(card, triggerType, context)

/// @description Vérifie si un déclencheur doit être activé pour une carte

/// @param {struct} card - La carte à vérifier

/// @param {string} triggerType - Le type de déclencheur

/// @param {struct} context - Le contexte de l'événement

/// @returns {bool} - True si le déclencheur doit être activé

function checkTrigger(card, triggerType, context = {}) {

    // Vérifier si la carte a des effets

    if (!variable_struct_exists(card, "effects") || array_length(card.effects) == 0) {

        return false;

    }

    

    // Parcourir tous les effets de la carte

    for (var i = 0; i < array_length(card.effects); i++) {

        var effect = card.effects[i];

        

        // Vérifier si l'effet a le bon déclencheur

        if (variable_struct_exists(effect, "trigger") && effect.trigger == triggerType) {

            // Vérifier les conditions supplémentaires

            if (checkTriggerConditions(card, effect, context)) {

                return true;

            }

        }

    }

    

    return false;

}



/// @function checkTriggerConditions(card, effect, context)

/// @description Vérifie les conditions spécifiques d'un déclencheur

/// @param {struct} card - La carte

/// @param {struct} effect - L'effet à vérifier

/// @param {struct} context - Le contexte

/// @returns {bool} - True si les conditions sont remplies

function checkTriggerConditions(card, effect, context) {

    // Vérifier les conditions de base

    if (variable_struct_exists(effect, "conditions")) {

        var conditions = effect.conditions;

        

        // Vérifier la condition "once_per_turn"

        if (variable_struct_exists(conditions, "once_per_turn") && conditions.once_per_turn) {

            var turnStr = variable_global_exists("current_turn") ? string(global.current_turn) : (instance_exists(oGame) ? string(oGame.nbTurn) : "0");

            var effectId = string(card.id) + "_" + string(effect.id) + "_turn_" + turnStr;

            if (variable_global_exists("used_effects") && ds_list_find_index(global.used_effects, effectId) != -1) {

                return false;

            }

        }

        

        // Vérifier la condition de LP minimum

        if (variable_struct_exists(conditions, "min_lp")) {

            if (global.hero_lp < conditions.min_lp) {

                return false;

            }

        }

        

        // Vérifier la condition de LP maximum

        if (variable_struct_exists(conditions, "max_lp")) {

            if (global.hero_lp > conditions.max_lp) {

                return false;

            }

        }

        

        // Vérifier la condition de nombre de cartes en main

        if (variable_struct_exists(conditions, "hand_size")) {

            var handSize = getHandSize();

            if (handSize != conditions.hand_size) {

                return false;

            }

        }

        

        // Vérifier la condition de type de carte ciblée
        if (variable_struct_exists(conditions, "target_type") && variable_struct_exists(context, "target")) {
            var targetType = variable_instance_exists(context.target, "type") ? context.target.type : "unknown";
            show_debug_message("### Checking target_type: expected=" + string(conditions.target_type) + ", actual=" + string(targetType));
            if (targetType != conditions.target_type) {
                show_debug_message("### target_type check failed");
                return false;
            }
        }
        // Vérifier la condition de genre de la carte ciblée (ex: "Dragon")
        if (variable_struct_exists(conditions, "target_genre") && variable_struct_exists(context, "target")) {
            var targetGenre = variable_instance_exists(context.target, "genre") ? context.target.genre : "unknown";
            show_debug_message("### Checking target_genre: expected=" + string(conditions.target_genre) + ", actual=" + string(targetGenre));
            if (targetGenre != conditions.target_genre) {
                show_debug_message("### target_genre check failed");
                return false;
            }
        }

        // Restreindre le déclenchement aux attaques initiées par cette carte
        if (variable_struct_exists(conditions, "attacker_is_self") && conditions.attacker_is_self) {
            if (!variable_struct_exists(context, "attacker") || context.attacker == noone || context.attacker != card) {
                show_debug_message("### attacker_is_self check failed");
                return false;
            }
        }
        

        // Vérifier la condition de phase

        if (variable_struct_exists(conditions, "phase")) {

            if (!variable_global_exists("current_phase") || global.current_phase != conditions.phase) {

                return false;

            }

        }



        // Vérifier le propriétaire si précisé ("Hero" ou "Enemy")

        if (variable_struct_exists(conditions, "owner")) {

            var wantHero = (conditions.owner == "Hero");

            if (!variable_instance_exists(card, "isHeroOwner") || card.isHeroOwner != wantHero) {

                return false;

            }

        }



        // Vérifier la zone attendue (ex: "Hand", "Field")

        if (variable_struct_exists(conditions, "zone")) {

            if (!variable_instance_exists(card, "zone")) {

                return false;

            }

            var expectedZone = conditions.zone;

            var cardZone = card.zone;

            // Autoriser les états de sélection comme équivalents

            if ((cardZone == "HandSelected" && expectedZone == "Hand") ||

                (cardZone == "FieldSelected" && expectedZone == "Field")) {

                // ok

            } else if (cardZone != expectedZone) {

                return false;

            }

        }



        // Condition: seulement au tour adverse par rapport au propriétaire de la carte

        if (variable_struct_exists(conditions, "opponent_turn") && conditions.opponent_turn) {

            if (!instance_exists(game)) {

                return false;

            }

            var currentPlayer = game.player[game.player_current];

            var cardOwner = (variable_instance_exists(card, "isHeroOwner") && card.isHeroOwner) ? "Hero" : "Enemy";

            if (currentPlayer == cardOwner) {

                return false;

            }

        }



        // Condition: seulement au tour du propriétaire de la carte

        if (variable_struct_exists(conditions, "owner_turn") && conditions.owner_turn) {
            if (!instance_exists(game)) {
                return false;
            }
            var currentPlayer2 = game.player[game.player_current];
            var cardOwner2 = (variable_instance_exists(card, "isHeroOwner") && card.isHeroOwner) ? "Hero" : "Enemy";
            if (currentPlayer2 != cardOwner2) {
                return false;
            }
        }

        // Default gating for manual triggers: owner turn and phase
        if (variable_struct_exists(effect, "trigger")) {
            var trig = effect.trigger;
            var needsOwnerGate = (trig == TRIGGER_START_TURN) || (trig == TRIGGER_END_TURN) || (trig == TRIGGER_MAIN_PHASE);
            if (needsOwnerGate) {
                var hasSpecifiedOwner = (variable_struct_exists(conditions, "owner_turn") && conditions.owner_turn)
                                        || (variable_struct_exists(conditions, "opponent_turn") && conditions.opponent_turn);
                if (!hasSpecifiedOwner) {
                    if (!instance_exists(game)) { return false; }
                    var currentPlayer3 = game.player[game.player_current];
                    var cardOwner3 = (variable_instance_exists(card, "isHeroOwner") && card.isHeroOwner) ? "Hero" : "Enemy";
                    if (currentPlayer3 != cardOwner3) { return false; }
                }
                if (trig == TRIGGER_MAIN_PHASE) {
                    if (!instance_exists(game)) { return false; }
                    var currentPhase = game.phase[game.phase_current];
                    // Par défaut, les effets TRIGGER_MAIN_PHASE ne sont disponibles qu'en phase "Summon"
                    if (currentPhase != "Summon") { return false; }
                }
            }
        }

        // Vérifier la présence d'un archétype sur le terrain du héros
        if (variable_struct_exists(conditions, "has_archetype_on_field")) {
            var arche = conditions.has_archetype_on_field;
            if (!has_archetype_monster_on_field(true, arche)) {
                return false;
            }
        }

        // Vérifier la présence d'un genre sur le terrain du propriétaire de la carte
        if (variable_struct_exists(conditions, "has_genre_on_field")) {
            var gn = conditions.has_genre_on_field;
            var isHero = (variable_instance_exists(card, "isHeroOwner") && card.isHeroOwner);
            if (!has_genre_monster_on_field(isHero, gn)) {
                return false;
            }
        }

        // Vérifier la présence d'un sort ennemi sur le terrain
        if (variable_struct_exists(conditions, "has_enemy_spell_on_field") && conditions.has_enemy_spell_on_field) {
            var ownerIsHero_es = (variable_instance_exists(card, "isHeroOwner") && card.isHeroOwner);
            if (!hasEnemySpellOnField(ownerIsHero_es)) {
                return false;
            }
        }

        // Condition sur le mode d'invocation (ex: "Summon" vs "SpecialSummon").
        // Accepte une chaîne (égalité stricte) ou un tableau de chaînes (appartenance).
        if (variable_struct_exists(conditions, "summon_mode")) {
            if (!variable_struct_exists(context, "summon_mode")) {
                return false;
            }
            var cm = context.summon_mode;
            var sm = conditions.summon_mode;
            if (is_array(sm)) {
                var ok = false;
                for (var i = 0; i < array_length_1d(sm); i++) {
                    if (sm[i] == cm) { ok = true; break; }
                }
                if (!ok) { return false; }
            } else {
                if (sm != cm) { return false; }
            }
        }

    }



    // Bloquer certains triggers pendant un sacrifice manuel si demandé
    if (variable_struct_exists(effect, "conditions")
        && variable_struct_exists(effect.conditions, "ignore_when_sacrifice")
        && effect.conditions.ignore_when_sacrifice) {
        if (variable_struct_exists(context, "from_sacrifice") && context.from_sacrifice) {
            return false;
        }
        if (variable_global_exists("sacrifice_in_progress") && global.sacrifice_in_progress) {
            return false;
        }
    }

    // Règle globale: par défaut, ON_SUMMON ne se déclenche que sur "Summon" (invocation normale/avec sacrifice).

    // Pour autoriser l'invocation spéciale, préciser conditions.summon_mode: "SpecialSummon" (ou un tableau incluant "SpecialSummon").

    var hasConds = variable_struct_exists(effect, "conditions");

    var hasSummonModeCond = hasConds && variable_struct_exists(effect.conditions, "summon_mode");

    if (variable_struct_exists(effect, "trigger") && effect.trigger == TRIGGER_ON_SUMMON) {

        if (!hasSummonModeCond) {

            if (variable_struct_exists(context, "summon_mode") && context.summon_mode != "Summon") {

                return false;

            }

        }

    }

    

    return true;

}



/// @function hasEffectAvailable(card, effect_type)

/// @description Vérifie si une carte possède un effet d'un type donné activable selon ses conditions

/// @param {struct} card - La carte

/// @param {string} effect_type - Type d'effet à rechercher

/// @returns {bool}

function hasEffectAvailable(card, effect_type) {

    if (!variable_struct_exists(card, "effects") || array_length(card.effects) == 0) return false;

    for (var i = 0; i < array_length(card.effects); i++) {

        var effect = card.effects[i];

        if (variable_struct_exists(effect, "effect_type") && effect.effect_type == effect_type) {

            // Si un trigger est défini, vérifier ses conditions

            if (!variable_struct_exists(effect, "trigger") || checkTriggerConditions(card, effect, {})) {

                return true;

            }

        }

    }

    return false;

}



/// @function getAvailableEffect(card)

/// @description Retourne le premier effet activable manuellement selon les conditions (phase/owner/etc.)

/// @param {struct} card - La carte

/// @returns {struct|noone} - L'effet disponible ou noone

function getAvailableEffect(card) {
    if (!variable_struct_exists(card, "effects") || array_length(card.effects) == 0) return noone;

    // Rassembler tous les effets manuels disponibles (conditions OK)
    var eligible = [];
    for (var i = 0; i < array_length(card.effects); i++) {
        var effect = card.effects[i];
        var hasManualTrigger = !variable_struct_exists(effect, "trigger") 
            || effect.trigger == TRIGGER_MAIN_PHASE 
            || effect.trigger == TRIGGER_QUICK_EFFECT;
        if (hasManualTrigger) {
            if (checkTriggerConditions(card, effect, {})) {
                array_push(eligible, effect);
            }
        }
    }
    if (array_length(eligible) == 0) return noone;

    // Priorité pour les Artéfacts: privilégier la sélection de cible (equip_select_target)
    var isArtifact = (variable_instance_exists(card, "genre") && card.genre == "Artéfact");
    if (isArtifact) {
        for (var j = 0; j < array_length(eligible); j++) {
            var e = eligible[j];
            if (variable_struct_exists(e, "effect_type") && e.effect_type == EFFECT_EQUIP_SELECT_TARGET) {
                return e;
            }
        }
    }

    // Sinon, retourner le premier éligible (comportement précédent)
    return eligible[0];
}


/// @function activateTrigger(card, triggerType, context)
/// @description Active tous les déclencheurs correspondants d'une carte
/// @param {struct} card - La carte
/// @param {string} triggerType - Le type de déclencheur
/// @param {struct} context - Le contexte de l'événement
/// @param {struct} context - Le contexte de l'événement
function activateTrigger(card, triggerType, context = {}) {
    // Garde d'existence: ignorer si la carte est manquante ou détruite
    if (card == noone || !instance_exists(card)) {
        show_debug_message("### activateTrigger: card missing/destroyed, skipping for trigger " + string(triggerType));
        return;
    }
    var cardName = variable_instance_exists(card, "name") ? card.name : "unknown";
    show_debug_message("### activateTrigger called for card: " + cardName + " with trigger: " + string(triggerType));

    if (!variable_struct_exists(card, "effects")) return;

    

    for (var i = 0; i < array_length(card.effects); i++) {
        // Si la carte a été détruite pendant une itération précédente, sortir immédiatement
        if (!instance_exists(card)) { break; }

        var effect = card.effects[i];

        

        if (variable_struct_exists(effect, "trigger") && effect.trigger == triggerType) {
            var effectTypeStr = variable_struct_exists(effect, "effect_type") ? string(effect.effect_type) : "unknown";
            show_debug_message("### Found matching trigger for effect: " + effectTypeStr);
            if (checkTriggerConditions(card, effect, context)) {
                show_debug_message("### Conditions passed, executing effect");

                // Marquer l'effet comme utilisé sera fait après exécution réussie

                

                // Debug: activation du trigger

                var cname = variable_instance_exists(card, "name") ? card.name : object_get_name(card.object_index);

                var etype = variable_struct_exists(effect, "effect_type") ? effect.effect_type : "(none)";

                show_debug_message("### activateTrigger: " + string(triggerType) + " on " + cname + " effect=" + string(etype));

                

                // Aura uniquement pour activation manuelle/phases visibles (éviter destruction/cimetière/dégâts)

                var allowAura = (triggerType == TRIGGER_MAIN_PHASE 

                    || triggerType == TRIGGER_START_TURN 

                    || triggerType == TRIGGER_END_TURN 

                    || triggerType == TRIGGER_QUICK_EFFECT);

                // Contexte peut demander la suppression explicite

                if (variable_struct_exists(context, "suppress_fx_aura") && context.suppress_fx_aura) {

                    allowAura = false;

                }

                // Option d'effet pour forcer l'aura

                if (variable_struct_exists(effect, "show_aura") && effect.show_aura) {

                    allowAura = true;

                }

                

                if (allowAura) {

                    requestFXAura(

                        card.sprite_index,

                        card.image_index,

                        card.image_xscale,

                        card.image_yscale,

                        card.image_angle,

                        600,

                        18,

                        10,

                        1.50, // ovalisation largeur, légèrement moins marqué

                        0.80, // ovalisation hauteur, légèrement moins aplati

                        card.x,

                        card.y

                    );

                }

                // Activer l'effet et savoir s'il a réussi
                var effectSucceeded = executeEffect(card, effect, context);
                // Marquer l'effet comme utilisé si la résolution a réussi
                if (effectSucceeded) {
                    markEffectAsUsed(card, effect);
                }

                // Consommer les sorts Direct (non-continus) uniquement si la résolution a réussi
                if (effectSucceeded && !is_undefined(consumeSpellIfNeeded)) {
                    consumeSpellIfNeeded(card, effect);
                    // Si la consommation a détruit la carte, arrêter l'itération pour éviter les accès invalides
                    if (!instance_exists(card)) { break; }
                }

            }

        }

    }

}



/// @function markEffectAsUsed(card, effect)

/// @description Marque un effet comme utilisé pour ce tour

/// @param {struct} card - La carte

/// @param {struct} effect - L'effet

function markEffectAsUsed(card, effect) {

    if (variable_struct_exists(effect, "conditions") && 

        variable_struct_exists(effect.conditions, "once_per_turn") && 

        effect.conditions.once_per_turn) {

        

        if (!variable_global_exists("used_effects")) {

            global.used_effects = ds_list_create();

        }

        

        var turnStr = variable_global_exists("current_turn") ? string(global.current_turn) : (instance_exists(oGame) ? string(oGame.nbTurn) : "0");

    var effectId = string(card.id) + "_" + string(effect.id) + "_turn_" + turnStr;

    ds_list_add(global.used_effects, effectId);

    }

}



/// @function resetTurnEffects()

/// @description Remet à zéro les effets "une fois par tour"

function resetTurnEffects() {

    if (variable_global_exists("used_effects")) {

        ds_list_clear(global.used_effects);

    }

}



/// @function getHandSize()

/// @description Retourne le nombre de cartes en main

/// @returns {real} - Nombre de cartes en main

function getHandSize() {

    // Adapte selon le type de structure utilisé pour la main

    if (instance_exists(oHand)) {

        if (is_array(oHand.cards)) {

            return array_length(oHand.cards);

        } else {

            return ds_list_size(oHand.cards);

        }

    }

    return 0;

}



/// @function registerTriggerEvent(triggerType, sourceCard, context)

/// @description Enregistre un événement de déclencheur pour toutes les cartes sur le terrain

/// @param {string} triggerType - Le type de déclencheur

/// @param {struct} sourceCard - La carte source de l'événement (optionnel)

/// @param {struct} context - Le contexte de l'événement

function registerTriggerEvent(triggerType, sourceCard = noone, context = {}) {

    // Log de debug sur l'événement

    var srcName = (sourceCard != noone) ? (variable_instance_exists(sourceCard, "name") ? sourceCard.name : object_get_name(sourceCard.object_index)) : "none";

    show_debug_message("### registerTriggerEvent: trigger=" + string(triggerType) + " source=" + srcName);



    // Ajouter la carte source au contexte et déclencher directement sur elle

    if (sourceCard != noone) {

        context.source = sourceCard;

        // Désactiver l'aura pour les triggers liés à la destruction/cimetière

        if (triggerType == TRIGGER_ENTER_GRAVEYARD || triggerType == TRIGGER_ON_DESTROY) {

            context.suppress_fx_aura = true;

        }

        // Si la carte source est face cachée, ne pas déclencher certains triggers immédiats
        var isFD = (variable_instance_exists(sourceCard, "isFaceDown") && sourceCard.isFaceDown);
        if (isFD && (triggerType == TRIGGER_ENTER_FIELD || triggerType == TRIGGER_ON_SUMMON)) {
            show_debug_message("### registerTriggerEvent: skip " + string(triggerType) + " on facedown card " + srcName);
        } else {
            // Déclenche l'effet sur la carte source même si elle quitte le terrain
            activateTrigger(sourceCard, triggerType, context);
        }

    }



    // Événements centrés sur la carte source: ne pas diffuser aux autres cartes

    // - ENTER_GRAVEYARD et ON_DESTROY sont déjà non diffusés

    // - ON_SUMMON et ENTER_FIELD doivent s'appliquer uniquement à la carte qui vient d'entrer

    if (triggerType == TRIGGER_ENTER_GRAVEYARD 

        || triggerType == TRIGGER_ON_DESTROY 

        || triggerType == TRIGGER_ON_SUMMON 

        || triggerType == TRIGGER_ENTER_FIELD) {

        return;

    }

    

    // Spécifique: activer les Secrets lors de l’invocation d’un monstre
    if (triggerType == TRIGGER_ON_MONSTER_SUMMON) {
        if (sourceCard != noone && instance_exists(sourceCard)) {
            activateSecretsOnMonsterSummon(sourceCard);
        }
    }

    // Vérifier tous les monstres sur le terrain
    with (oCardMonster) {
        if (zone == "Field") {
            // Gating: Only owner’s cards receive START/END turn triggers
            if (triggerType == TRIGGER_START_TURN || triggerType == TRIGGER_END_TURN) {
                var activeIsHero = instance_exists(game) ? (game.player[game.player_current] == "Hero") : true;
                if (variable_instance_exists(self, "isHeroOwner") && self.isHeroOwner != activeIsHero) {
                    continue;
                }
                // Restriction: seulement face visible
                if (variable_instance_exists(self, "isFaceDown") && self.isFaceDown) {
                    continue;
                }
            }
            activateTrigger(self, triggerType, context);
        }
    }

    

    // Vérifier les cartes magiques continues

    with (oCardMagic) {

        if (zone == "Field" && type == "Continuous") {
            // Gating: seulement cartes du joueur actif et face visible
            if (triggerType == TRIGGER_START_TURN || triggerType == TRIGGER_END_TURN) {
                var activeIsHero2 = instance_exists(game) ? (game.player[game.player_current] == "Hero") : true;
                if (variable_instance_exists(self, "isHeroOwner") && self.isHeroOwner != activeIsHero2) {
                    continue;
                }
                if (variable_instance_exists(self, "isFaceDown") && self.isFaceDown) {
                    continue;
                }
            }
            activateTrigger(self, triggerType, context);
        }
    }



    // Diffuser aux cartes en main pour les triggers globaux pertinents
    if (triggerType == TRIGGER_ON_MONSTER_SENT_TO_GRAVEYARD) {
        show_debug_message("### Broadcasting TRIGGER_ON_MONSTER_SENT_TO_GRAVEYARD to hand cards");
        if (variable_struct_exists(context, "target")) {
            var targetCard = context.target;
            var targetName = variable_instance_exists(targetCard, "name") ? targetCard.name : "unknown";
            var targetGenre = variable_instance_exists(targetCard, "genre") ? targetCard.genre : "unknown";
            show_debug_message("### Target card: " + targetName + " (genre: " + targetGenre + ")");
        }
        with (oCardMonster) {
            if (zone == "Hand" || zone == "HandSelected") {
                var cardName = variable_instance_exists(self, "name") ? self.name : "unknown";
                show_debug_message("### Checking hand card: " + cardName);
                activateTrigger(self, triggerType, context);
            }
        }
    }
}



// === FONCTIONS UTILITAIRES ===



// getTriggerName centralisé dans scripts/sTriggerLabels/sTriggerLabels.gml

// Utiliser directement getTriggerName(triggerType) depuis le script centralisé.



/// @function getTriggerLabel(triggerId)

/// @description Retourne le libellé court en FR pour un déclencheur donné

/// @param {string} triggerId - Macro TRIGGER_*

/// @returns {string}

// getTriggerLabel centralisé dans scripts/sTriggerLabels/sTriggerLabels.gml



/// @function getTriggerDetailedDescription(triggerId)

/// @description Retourne une description détaillée en FR pour un déclencheur donné

/// @param {string} triggerId - Macro TRIGGER_*

/// @returns {string}

// getTriggerDetailedDescription centralisé dans scripts/sTriggerLabels/sTriggerLabels.gml

    // (garde ignore_when_sacrifice déplacée dans checkTriggerConditions)

