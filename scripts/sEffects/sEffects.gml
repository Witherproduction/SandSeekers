// === Script des Effets Possibles ===
// Ce script contient tous les effets possibles pour les cartes

// === CONSTANTES DES TYPES D'EFFETS ===

// Effets de base
#macro EFFECT_DRAW_CARDS "draw_cards"                   // Piocher des cartes

#macro EFFECT_DRAW_THEN_DISCARD_DRAWN_MONSTERS "draw_then_discard_drawn_monsters"
#macro EFFECT_DISCARD "discard"                          // Effet unifié de défausse paramétrable
#macro EFFECT_GAIN_LP "gain_lp"                         // Gagner des LP
#macro EFFECT_LOSE_LP "lose_lp"                         // Perdre des LP
#macro EFFECT_HEAL_SELF "heal_self"                     // Se soigner
#macro EFFECT_DAMAGE_SELF "damage_self"                 // Se blesser


// Effets de combat
#macro EFFECT_GAIN_ATTACK "gain_attack"                 // Gagner de l'ATK
#macro EFFECT_LOSE_ATTACK "lose_attack"                 // Perdre de l'ATK
#macro EFFECT_LOSE_ATTACK_PERMANENT "lose_attack_permanent" // Perdre de l'ATK de façon permanente
#macro EFFECT_GAIN_DEFENSE "gain_defense"               // Gagner de la DEF
#macro EFFECT_LOSE_DEFENSE "lose_defense"               // Perdre de la DEF
#macro EFFECT_SET_ATTACK "set_attack"                   // Définir l'ATK
#macro EFFECT_SET_DEFENSE "set_defense"                 // Définir la DEF

// Effets de ciblage
#macro EFFECT_DAMAGE_TARGET "damage_target"             // Infliger des dégâts à une cible
#macro EFFECT_HEAL_TARGET "heal_target"                 // Soigner une cible
#macro EFFECT_DESTROY_TARGET "destroy_target"           // Détruire une cible
#macro EFFECT_DESTROY_SELF "destroy_self"               // Se détruire
#macro EFFECT_DESTROY "destroy"                         // Effet générique de destruction par critères
#macro EFFECT_BANISH_TARGET "banish_target"             // Bannir une cible
#macro EFFECT_RETURN_TO_HAND "return_to_hand"           // Renvoyer en main

// Effets de zone
#macro EFFECT_DAMAGE_ALL "damage_all"                   // Dégâts à tous les monstres
#macro EFFECT_HEAL_ALL "heal_all"                       // Soigner tous les monstres
#macro EFFECT_DESTROY_ALL "destroy_all"                 // Détruire tous les monstres
#macro EFFECT_BOOST_ALL "boost_all"                     // Booster tous les monstres alliés
#macro EFFECT_WEAKEN_ALL "weaken_all"                   // Affaiblir tous les monstres ennemis

// Effets de manipulation de deck

#macro EFFECT_SHUFFLE_DECK "shuffle_deck"               // Mélanger le deck
#macro EFFECT_MILL_DECK "mill_deck"                     // Envoyer du deck au cimetière
#macro EFFECT_ADD_TO_DECK "add_to_deck"                 // Ajouter au deck

// Effets de manipulation de cimetière
#macro EFFECT_REVIVE "revive"                           // Ressusciter du cimetière
#macro EFFECT_BANISH_FROM_GRAVEYARD "banish_graveyard"  // Bannir du cimetière
#macro EFFECT_SHUFFLE_GRAVEYARD "shuffle_graveyard"     // Mélanger le cimetière dans le deck

// Effets spéciaux
#macro EFFECT_SEARCH "search"                        // Effet générique de recherche (deck, cimetière, main, terrain vers destination)
#macro EFFECT_SUMMON "summon"                        // Effet générique d'invocation (token, self, nommé, source, spell)

#macro EFFECT_CHANGE_TYPE "change_type"                 // Changer le type
#macro EFFECT_CHANGE_ATTRIBUTE "change_attribute"       // Changer l'attribut
#macro EFFECT_NEGATE_EFFECT "negate_effect"             // Annuler un effet
#macro EFFECT_COPY_EFFECT "copy_effect"                 // Copier un effet
#macro EFFECT_END_DISCARD_DESTROY_ENEMY_SPELL "end_discard_destroy_enemy_spell" // Finalisation : défausser 1, détruire 1 Magie adverse


// Effets de contrôle
#macro EFFECT_SKIP_TURN "skip_turn"                     // Passer le tour
#macro EFFECT_EXTRA_TURN "extra_turn"                   // Tour supplémentaire
#macro EFFECT_CHANGE_PHASE "change_phase"               // Changer de phase
#macro EFFECT_END_BATTLE "end_battle"                   // Terminer la phase de combat

// Effets de protection
#macro EFFECT_IMMUNITY "immunity"                       // Immunité
#macro EFFECT_PROTECTION "protection"                   // Protection
#macro EFFECT_INDESTRUCTIBLE "indestructible"           // Indestructible
#macro EFFECT_UNTARGETABLE "untargetable"               // Non-ciblable

// Effet combiné: défausser cette carte de la main pour chercher par archétype


// Effet continu: boost d'ATK basé sur l'archétype dans les cimetières
#macro EFFECT_BOOST_ATK_PER_GRAVEYARD_ARCHETYPE "boost_atk_per_graveyard_archetype"
#macro EFFECT_BOOST_ATK_PER_GRAVEYARD_GENRE "boost_atk_per_graveyard_genre"

// Effets d’équipement (nouveaux)
#macro EFFECT_EQUIP_SELECT_TARGET "equip_select_target"   // Sélectionner une cible et équiper
#macro EFFECT_EQUIP_APPLY_BUFF "equip_apply_buff"         // Appliquer le buff à la cible équipée
#macro EFFECT_EQUIP_CLEANUP "equip_cleanup"               // Nettoyer à la destruction (réinitialiser la cible)

// Effets d’aura de champ (nouveaux)
#macro EFFECT_AURA_ARCHETYPE_BUFF "aura_archetype_buff"   // Aura: buff ATK/DEF par archétype sur le terrain
#macro EFFECT_AURA_ALL_MONSTERS_DEBUFF "aura_all_monsters_debuff"   // Aura: debuff ATK/DEF pour tous les monstres sur le terrain
#macro EFFECT_AURA_CLEANUP_SOURCE "aura_cleanup_source"   // Nettoyage d’aura: retirer les contributions d’une source
#macro EFFECT_DAMAGE_OPP_PER_ARCHETYPE_ON_FIELD "damage_opp_per_archetype_on_field"   // Tombe: dégâts à l’adversaire par monstre d’un archétype sur le terrain
#macro EFFECT_DAMAGE_OPP_PER_GENRE_ON_FIELD "damage_opp_per_genre_on_field"   // Tombe: dégâts à l’adversaire par monstre d’un genre (allié) sur le terrain
// (Obsolète supprimé) Destructions aléatoires désormais gérées via EFFECT_DESTROY avec critères

// === FONCTION PRINCIPALE D'EXÉCUTION DES EFFETS ===

/// @function executeEffect(card, effect, context)
/// @description Exécute un effet spécifique
/// @param {struct} card - La carte qui active l'effet
/// @param {struct} effect - L'effet à exécuter
/// @param {struct} context - Le contexte de l'activation
function executeEffect(card, effect, context = {}) {
    if (!variable_struct_exists(effect, "effect_type")) {
        show_debug_message("Erreur : Effet sans type défini");
        return false;
    }
    
    var effectType = effect.effect_type;
    // Utiliser la valeur du contexte si elle existe, sinon celle de l'effet
    var value = variable_struct_exists(context, "value") ? context.value 
                : (variable_struct_exists(effect, "value") ? effect.value : 0);
    var target = variable_struct_exists(context, "target") ? context.target : noone;
    
    // Log de l'effet pour debug (détaillé)
    var effTrigger = variable_struct_exists(effect, "trigger") ? effect.trigger : "";
    var cardName = (card != noone && instance_exists(card) && variable_instance_exists(card, "name")) ? card.name : object_get_name(card.object_index);
    var targetDesc;
    if (target != noone && instance_exists(target)) {
        targetDesc = (variable_instance_exists(target, "name")) ? target.name : object_get_name(target.object_index);
    } else if (is_struct(target) && variable_struct_exists(target, "name")) {
        targetDesc = target.name;
    } else {
        targetDesc = "aucune cible";
    }
    var valueStr = variable_struct_exists(effect, "value") ? ("valeur=" + string(value)) : "valeur=nd";
    var cardZone = (card != noone && instance_exists(card) && variable_instance_exists(card, "zone")) ? card.zone : "unknown";
    // Réduire le spam: ignorer les logs pour les effets continus
    if (effTrigger != TRIGGER_CONTINUOUS) {
        show_debug_message("### Effet: type=" + string(effectType) + " trig=" + string(effTrigger) + " card=" + string(cardName) + " zone=" + string(cardZone) + " " + valueStr + " cible=" + string(targetDesc));
    }
    
    // Ciblage manuel si aucune cible fournie pour les effets ciblés
    var needsTarget = (effectType == EFFECT_DAMAGE_TARGET
                       || effectType == EFFECT_HEAL_TARGET
                       || effectType == EFFECT_DESTROY_TARGET
                       || effectType == EFFECT_BANISH_TARGET
                       || effectType == EFFECT_RETURN_TO_HAND
                       || effectType == EFFECT_EQUIP_SELECT_TARGET);
    if (needsTarget && target == noone) {
        // Activation manuelle uniquement (phase principale ou effet rapide) et uniquement côté Héros (jamais IA)
        var isManualActivation = (!variable_struct_exists(effect, "trigger")
                                  || effect.trigger == TRIGGER_MAIN_PHASE
                                  || effect.trigger == TRIGGER_QUICK_EFFECT);
        var ownerIsHero_ctx = (variable_struct_exists(context, "owner_is_hero")) ? context.owner_is_hero
                              : ((card != noone && instance_exists(card) && variable_instance_exists(card, "isHeroOwner")) ? card.isHeroOwner : true);
        if (isManualActivation && ownerIsHero_ctx && instance_exists(selectManager)) {
            // Attacher la carte source à l'effet pour l'utiliser dans le callback
            effect.source_card = card;
            
            // (Effet Floraison obsolète supprimé)
            
            // Définir le callback de sélection de cible (utilise self = struct de l'effet)
            effect.onTargetSelected = function(cardTarget) {
                var eff = (instance_exists(selectManager)) ? selectManager.targetingEffectId : noone;
                var src = (is_struct(eff) && variable_struct_exists(eff, "source_card")) ? eff.source_card : noone;
                if (cardTarget != noone && instance_exists(cardTarget) && (cardTarget.zone == "Field" || cardTarget.zone == "FieldSelected")) {
                    var resolved = executeEffect(src, eff, { target: cardTarget });
                    if (resolved) {
                        // Nettoyer les marqueurs de ciblage
                        clearTargetingMarkers();
                        // Marquer l'effet comme utilisé au moment où il se résout réellement
                        if (!is_undefined(markEffectAsUsed)) { markEffectAsUsed(src, eff); }
                        // Consommer les sorts Direct uniquement après résolution réussie
                        if (!is_undefined(consumeSpellIfNeeded)) { consumeSpellIfNeeded(src, eff); }
                    }
                } else {
                    var etype = (is_struct(eff) && variable_struct_exists(eff, "effect_type")) ? eff.effect_type : "unknown";
                    show_debug_message("### Cible invalide pour l'effet: " + string(etype));
                }
            };
            // Marquer l'équipement comme en cours de ciblage pour éviter destruction prématurée
            if (effectType == EFFECT_EQUIP_SELECT_TARGET && instance_exists(card)) {
                if (!variable_instance_exists(card, "equip_pending")) card.equip_pending = false;
                card.equip_pending = true;
            }
            // Activer le mode ciblage et afficher la flèche depuis la carte source
            selectManager.startTargeting(effect);
            if (instance_exists(card)) {
                selectManager.createTargetingArrow(card);
            }
            // Le processus est lancé; l'application se fera après la sélection
            // Important: ne pas signaler une réussite immédiate pour éviter la consommation prématurée des sorts Direct
            return false;
        }
    }
    
    switch(effectType) {
        // Effets de base
        case EFFECT_DRAW_CARDS:
        {
            var ownerIsHero = (card != noone && instance_exists(card) && variable_instance_exists(card, "isHeroOwner")) ? card.isHeroOwner
                               : (variable_struct_exists(context, "owner_is_hero") ? context.owner_is_hero : true);
            var ok = drawCardsFor(ownerIsHero, value);
            // Chaînage générique: exécuter les étapes du flow après la pioche
            if (ok && variable_struct_exists(effect, "flow") && is_array(effect.flow)) {
                var L = array_length(effect.flow);
                for (var k = 0; k < L; k++) {
                    var stepEff = effect.flow[k];
                    if (is_struct(stepEff) && variable_struct_exists(stepEff, "effect_type")) {
                        // Propager le propriétaire pour cohérence
                        executeEffect(card, stepEff, { owner_is_hero: ownerIsHero });
                    }
                }
            }
            return ok;
        }
        
        case EFFECT_DRAW_THEN_DISCARD_DRAWN_MONSTERS:
        {
            var ownerIsHero2 = (card != noone && instance_exists(card) && variable_instance_exists(card, "isHeroOwner")) ? card.isHeroOwner
                                : (variable_struct_exists(context, "owner_is_hero") ? context.owner_is_hero : true);
            return drawThenDiscardDrawnMonsters(card, { owner_is_hero: ownerIsHero2, amount: value }, context);
        }
            

            
        case EFFECT_GAIN_LP:
        {
            var ownerIsHero = (card != noone && instance_exists(card) && variable_instance_exists(card, "isHeroOwner")) ? card.isHeroOwner
                               : (variable_struct_exists(context, "owner_is_hero") ? context.owner_is_hero : true);
            return gainLPFor(ownerIsHero, value);
        }
            
        case EFFECT_LOSE_LP:
        {
            // Priorité à ctx.owner_is_hero si défini explicitement, sinon utiliser card.isHeroOwner
            var ownerIsHero = (variable_struct_exists(context, "owner_is_hero")) ? context.owner_is_hero 
                               : ((card != noone && instance_exists(card) && variable_instance_exists(card, "isHeroOwner")) ? card.isHeroOwner : true);
            
            // DEBUG: Logs pour tracer l'exécution
            show_debug_message("### EFFECT_LOSE_LP DEBUG ###");
            show_debug_message("- value: " + string(value));
            show_debug_message("- context.owner_is_hero exists: " + string(variable_struct_exists(context, "owner_is_hero")));
            if (variable_struct_exists(context, "owner_is_hero")) {
                show_debug_message("- context.owner_is_hero: " + string(context.owner_is_hero));
            }
            show_debug_message("- ownerIsHero final: " + string(ownerIsHero));
            show_debug_message("- Calling loseLPFor(" + string(ownerIsHero) + ", " + string(value) + ")");
            
            var result = loseLPFor(ownerIsHero, value);
            show_debug_message("- loseLPFor result: " + string(result));
            return result;
        }
            
        case EFFECT_HEAL_SELF:
            return healCard(card, value);
            
        case EFFECT_DAMAGE_SELF:
            return damageCard(card, value);
            
        // Effets de combat
        case EFFECT_GAIN_ATTACK:
            return modifyAttack(card, value, true);
            
        case EFFECT_LOSE_ATTACK:
            return modifyAttack(card, -value, true);
            
        // Débuff permanent d'ATK (peut cibler la carte ou la cible fournie)
        case EFFECT_LOSE_ATTACK_PERMANENT:
        {
            var t = (target != noone) ? target : card;
            if (t == noone) return false;
            return modifyAttack(t, -value, false);
        }
            
        case EFFECT_GAIN_DEFENSE:
            return modifyDefense(card, value, true);
            
        case EFFECT_LOSE_DEFENSE:
            return modifyDefense(card, -value, true);
            
        case EFFECT_SET_ATTACK:
            return setAttack(card, value);
            
        case EFFECT_SET_DEFENSE:
            return setDefense(card, value);
            
        case EFFECT_DISCARD:
            // Effet unifié de défausse (main uniquement) avec critères et options
            if (is_undefined(sEffectDiscard)) {
                show_debug_message("### EFFECT_DISCARD: sEffectDiscard non trouvé");
                return false;
            }
            return sEffectDiscard(card, effect, context);

        // Effets de ciblage
        case EFFECT_DAMAGE_TARGET:
            if (target != noone) return damageCard(target, value);
            break;
            
        case EFFECT_HEAL_TARGET:
            if (target != noone) return healCard(target, value);
            break;
            
        case EFFECT_DESTROY_TARGET:
            // Si aucune cible fournie, utiliser l'attaquant du contexte (ex: effets "on_destroy : détruire l'attaquant")
            if (target == noone && variable_struct_exists(context, "attacker") && instance_exists(context.attacker)) {
                target = context.attacker;
            }
            // Durcissement: si déclenché par ON_ATTACK, exiger une cible valide sur le terrain
            if (variable_struct_exists(effect, "trigger") && effect.trigger == TRIGGER_ON_ATTACK) {
                if (target == noone || !instance_exists(target) || !(variable_instance_exists(target, "zone") && (target.zone == "Field" || target.zone == "FieldSelected"))) {
                    show_debug_message("### Refus: destroy_target via ON_ATTACK sans cible valide");
                    return false;
                }
            }
            if (target != noone) {
                // Empoisonneur: flaque qui s'élargit puis destruction différée
                if (card != noone && instance_exists(card) && variable_instance_exists(card, "isPoisoner") && card.isPoisoner) {
                    spawnPoisonFX(target, card);
                    return true;
                }
                return destroyCard(target);
            }
            break;
            
        case EFFECT_DESTROY_SELF:
            return destroyCard(card);
            
        case EFFECT_BANISH_TARGET:
            if (target != noone) return banishCard(target);
            break;
            
        case EFFECT_RETURN_TO_HAND:
            if (target != noone) return returnToHand(target);
            break;
            
        // Effets personnalisés composites
        case EFFECT_END_DISCARD_DESTROY_ENEMY_SPELL:
        {
            var ownerIsHero = (card != noone && instance_exists(card) && variable_instance_exists(card, "isHeroOwner")) ? card.isHeroOwner
                               : (variable_struct_exists(context, "owner_is_hero") ? context.owner_is_hero : true);
            // Vérifier présence d’au moins une Magie adverse sur le terrain
            if (!hasEnemySpellOnField(ownerIsHero)) {
                show_debug_message("### Aucun sort adverse à détruire; effet ignoré");
                return false;
            }
            // Coût: défausser 1 carte de la main du bon propriétaire
            if (!discardFromHandToGraveyard(ownerIsHero, 1)) {
                show_debug_message("### Coût non payé (main vide); effet annulé");
                return false;
            }
            // Résolution: détruire 1 carte Magie sur le terrain adverse
            return destroyRandomEnemySpell(ownerIsHero);
        }
        
        // Composite générique: valider une cible alliée via critères, puis détruire N cartes adverses
        // (Effet composite Floraison supprimé — utiliser EFFECT_DESTROY via flow)
            
        // Effets de zone
        case EFFECT_DAMAGE_ALL:
            return damageAllMonsters(value, effect);
            
        case EFFECT_HEAL_ALL:
            return healAllMonsters(value, effect);
            
        case EFFECT_DESTROY_ALL:
            return destroyAllMonsters(effect);
            
        case EFFECT_BOOST_ALL:
            return boostAllAllies(value, effect);
            
        case EFFECT_WEAKEN_ALL:
            return weakenAllEnemies(value, effect);
            
        // Effets spéciaux
        case EFFECT_SEARCH:
            return applySearchBySpec(card, effect, context);
        case EFFECT_DESTROY:
            return applyDestroyBySpec(card, effect, context);
        case EFFECT_SUMMON:
            return applySummonBySpec(card, effect, context);

            
        case EFFECT_NEGATE_EFFECT:
            return negateEffect(target);





        // Effet combiné: défausser cette carte de la main pour chercher par archétype
        // SUPPRIMÉ - Remplacé par le système de flux avec EFFECT_DISCARD + EFFECT_SEARCH
        

         
         // Effet continu: boost d'ATK basé sur l'archétype dans les cimetières
        case EFFECT_BOOST_ATK_PER_GRAVEYARD_ARCHETYPE:
            return applyGraveyardArchetypeBoost(card, effect);
        
        // Effet continu: boost d'ATK basé sur le genre dans le cimetière du propriétaire
        case EFFECT_BOOST_ATK_PER_GRAVEYARD_GENRE:
            return applyGraveyardGenreBoost(card, effect);
            
        // Effets d’équipement
        case EFFECT_EQUIP_SELECT_TARGET:
        {
            return equipSelectTarget(card, effect, context);
        }
        
        case EFFECT_EQUIP_APPLY_BUFF:
        {
            return equipApplyBuff(card, effect, context);
        }
        
        case EFFECT_EQUIP_CLEANUP:
        {
            return equipCleanup(card, effect, context);
        }
        
        // Aura: buff ATK/DEF par archétype sur le terrain
        case EFFECT_AURA_ARCHETYPE_BUFF:
        {
            return applyArchetypeAuraBuff(card, effect);
        }
        
        case EFFECT_AURA_ALL_MONSTERS_DEBUFF:
        {
            return applyAllMonstersAuraDebuff(card, effect);
        }
        
        case EFFECT_AURA_CLEANUP_SOURCE:
        {
            return cleanupAuraSource(card, effect);
        }
        
        // Tombe: inflige des dégâts à l’adversaire pour chaque monstre d’un archétype sur le terrain
        case EFFECT_DAMAGE_OPP_PER_ARCHETYPE_ON_FIELD:
        {
            return applyDamageOpponentPerArchetypeOnField(card, effect);
        }
            
        // Tombe: inflige des dégâts à l’adversaire pour chaque monstre d’un genre allié sur le terrain
        case EFFECT_DAMAGE_OPP_PER_GENRE_ON_FIELD:
        {
            return applyDamageOpponentPerGenreOnField(card, effect);
        }
        
        // (Obsolète supprimé) utiliser EFFECT_DESTROY avec critères pour ces comportements
        
        
        default:
            show_debug_message("Effet non implémenté : " + effectType);
            return false;
    }
    
    return false;
}

// === FONCTIONS D'EFFETS DE BASE ===

// [refactor] Les helpers de pioche/mélange ont été déplacés vers `sEffectDraw.gml`.

/// @function discardCards(amount)
/// @description Fait défausser des cartes au joueur
/// @param {real} amount - Nombre de cartes à défausser
/// @returns {bool} - Succès de l'opération
function discardCards(amount) {
    if (!instance_exists(oHand) || !instance_exists(oGraveyard)) return false;
    
    var handSize = array_length(oHand.cards);
    var actualAmount = min(amount, handSize);
    
    for (var i = 0; i < actualAmount; i++) {
        if (array_length(oHand.cards) > 0) {
            var discardedCard = array_pop(oHand.cards);
            // Trouver le bon cimetière (héros)
            var gyInst = noone; with (oGraveyard) { if (isHeroOwner) { gyInst = id; break; } }
            if (gyInst != noone) {
                gyInst.addToGraveyard(discardedCard);
            } else {
                show_debug_message("### discardCards: cimetière héros introuvable, push direct évité");
            }
            
            // Déclencher l'événement d'entrée au cimetière (conservé pour compat)
            registerTriggerEvent(TRIGGER_ENTER_GRAVEYARD, discardedCard, {});
        }
    }
    
    return true;
}

/// @function gainLP(amount)
/// @description Fait gagner des LP au joueur
/// @param {real} amount - Montant de LP à gagner
/// @returns {bool} - Succès de l'opération
function gainLP(amount) {
    var lpInst = instance_find(oLP_Hero, 0);
    if (lpInst != noone) {
        var oldLP = lpInst.nbLP;
        lpInst.nbLP += amount;
        
        // Déclencher l'événement de changement de LP
        registerTriggerEvent(TRIGGER_ON_LP_CHANGE, noone, {
            old_lp: oldLP,
            new_lp: lpInst.nbLP,
            change: amount,
            owner_is_hero: true
        });
        
        return true;
    }
    return false;
}


/// @function clearTargetingMarkers()
/// @description Nettoie tous les marqueurs de ciblage des cartes
function clearTargetingMarkers() {
    with (oCardParent) {
        if (variable_instance_exists(self, "isTargetableForFloraison")) {
            self.isTargetableForFloraison = false;
        }
    }
}

/// @function loseLP(amount)
/// @description Fait perdre des LP au joueur
/// @param {real} amount - Montant de LP à perdre
/// @returns {bool} - Succès de l'opération
function loseLP(amount) {
    var lpInst = instance_find(oLP_Hero, 0);
    if (lpInst != noone) {
        var oldLP = lpInst.nbLP;
        lpInst.nbLP = max(0, oldLP - amount);
        
        // Déclencher l'événement de changement de LP
        registerTriggerEvent(TRIGGER_ON_LP_CHANGE, noone, {
            old_lp: oldLP,
            new_lp: lpInst.nbLP,
            change: -amount,
            owner_is_hero: true
        });
        
        // Vérifier la défaite
        if (lpInst.nbLP <= 0) {
            // Logique de fin de partie
            show_debug_message("Défaite ! LP = 0");
        }
        
        return true;
    }
    return false;
}

/// @function gainLPFor(ownerIsHero, amount)
/// @description Variante owner-aware pour gagner des LP (héros/ennemi)
/// @param {bool} ownerIsHero
/// @param {real} amount
/// @returns {bool}
function gainLPFor(ownerIsHero, amount) {
    if (ownerIsHero) {
        return gainLP(amount);
    } else {
        var lpInst = instance_find(oLP_Enemy, 0);
        if (lpInst != noone) {
            var oldLP = lpInst.nbLP;
            lpInst.nbLP = oldLP + amount;
            var newLP = lpInst.nbLP;
            registerTriggerEvent(TRIGGER_ON_LP_CHANGE, noone, {
                old_lp: oldLP,
                new_lp: newLP,
                change: amount,
                owner_is_hero: false
            });
            return true;
        }
    }
    return false;
}

/// @function loseLPFor(ownerIsHero, amount)
/// @description Variante owner-aware pour perdre des LP (héros/ennemi)
/// @param {bool} ownerIsHero
/// @param {real} amount
/// @returns {bool}
function loseLPFor(ownerIsHero, amount) {
    show_debug_message("### loseLPFor DEBUG ###");
    show_debug_message("- ownerIsHero: " + string(ownerIsHero));
    show_debug_message("- amount: " + string(amount));
    
    if (ownerIsHero) {
        show_debug_message("- Targeting HERO LP");
        return loseLP(amount);
    } else {
        show_debug_message("- Targeting ENEMY LP");
        var lpInst = instance_find(oLP_Enemy, 0);
        show_debug_message("- oLP_Enemy instance found: " + string(lpInst != noone));
        
        if (lpInst != noone) {
            var oldLP = lpInst.nbLP;
            show_debug_message("- Enemy old LP: " + string(oldLP));
            lpInst.nbLP = max(0, oldLP - amount);
            var newLP = lpInst.nbLP;
            show_debug_message("- Enemy new LP: " + string(newLP));
            
            registerTriggerEvent(TRIGGER_ON_LP_CHANGE, noone, {
                old_lp: oldLP,
                new_lp: newLP,
                change: -amount,
                owner_is_hero: false
            });
            if (newLP <= 0) {
                show_debug_message("Victoire ! LP ennemi = 0");
            }
            return true;
        } else {
            show_debug_message("- ERROR: oLP_Enemy instance not found!");
        }
    }
    return false;
}

// === FONCTIONS D'EFFETS DE COMBAT ===

/// @function modifyAttack(card, amount, temporary)
/// @description Modifie l'attaque d'une carte
/// @param {struct} card - La carte à modifier
/// @param {real} amount - Montant de modification
/// @param {bool} temporary - Si la modification est temporaire
/// @returns {bool} - Succès de l'opération
// [refactor] Helpers de COMBAT déplacés vers `sEffectCombat.gml` et helpers DIVERS vers `sEffectMisc.gml` (modifyAttack/Defense, setAttack/Defense, damage/heal, destroyCard, spawnPoisonFX, banishCard, returnToHand). 

// === FONCTIONS D'EFFETS DE ZONE ===

/// @function damageAllMonsters(amount, effect)
/// @description Inflige des dégâts à tous les monstres
/// @param {real} amount - Montant de dégâts
/// @param {struct} effect - L'effet source
/// @returns {bool} - Succès de l'opération
// [refactor] Effets de zone et filtre de cibles déplacés\n// damageAllMonsters/ healAllMonsters/ destroyAllMonsters -> `sEffectCombat.gml`\n// getTargetsByFilter -> `sEffectMisc.gml`
// [refactor] Les helpers d’invocation (jetons, activation de magie) sont déplacés vers `sEffectSummon.gml`.

// [refactor] Helpers miscellanés déplacés vers `sEffectMisc.gml` (negateEffect, resetTemporaryEffects, getEffectDescription).
/// getLeftmostFreeMonsterSlot déplacé vers sSummonUtils.gml

/// specialSummonNamed déplacé vers sSummonUtils.gml

// [refactor] `specialSummonSelf` est déplacé vers `sEffectSummon.gml`

// [refactor] Helpers miscellanés déplacés vers `sEffectMisc.gml` (applyGraveyardArchetypeBoost, hasEnemySpellOnField, destroyOneEnemySpell, destroyRandomEnemySpell).
