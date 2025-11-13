// === Script des Effets Possibles ===
// Ce script contient tous les effets possibles pour les cartes

// === CONSTANTES DES TYPES D'EFFETS ===

// Effets de base
#macro EFFECT_DRAW_CARDS "draw_cards"                   // Piocher des cartes

#macro EFFECT_DISCARD "discard"                          // Effet unifié de défausse paramétrable
#macro EFFECT_TEMPO "tempo"                              // Étape de délai/tempo pour les flows
#macro EFFECT_GAIN_LP "gain_lp"                         // Gagner des LP
#macro EFFECT_LOSE_LP "lose_lp"                         // Perdre des LP
#macro EFFECT_HEAL_SELF "heal_self"                     // Se soigner
#macro EFFECT_DAMAGE_SELF "damage_self"                 // Se blesser


// Effets de combat
#macro EFFECT_LOSE_ATTACK "lose_attack"                 // Perdre de l'ATK
#macro EFFECT_LOSE_ATTACK_PERMANENT "lose_attack_permanent" // Perdre de l'ATK de façon permanente
#macro EFFECT_LOSE_DEFENSE "lose_defense"               // Perdre de la DEF
#macro EFFECT_SET_ATTACK "set_attack"                   // Définir l'ATK
#macro EFFECT_SET_DEFENSE "set_defense"                 // Définir la DEF
#macro EFFECT_BUFF "buff"

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



// Effets d’équipement (nouveaux)
#macro EFFECT_EQUIP_SELECT_TARGET "equip_select_target"   // Sélectionner une cible et équiper
#macro EFFECT_EQUIP_CLEANUP "equip_cleanup"               // Nettoyer à la destruction (réinitialiser la cible)

// Effets d’aura de champ (nouveaux)
#macro EFFECT_AURA_ALL_MONSTERS_DEBUFF "aura_all_monsters_debuff"   // Aura: debuff ATK/DEF pour tous les monstres sur le terrain
#macro EFFECT_AURA_CLEANUP_SOURCE "aura_cleanup_source"   // Nettoyage d’aura: retirer les contributions d’une source
#macro EFFECT_DAMAGE_OPP_PER_ARCHETYPE_ON_FIELD "damage_opp_per_archetype_on_field"   // Tombe: dégâts à l’adversaire par monstre d’un archétype sur le terrain
#macro EFFECT_DAMAGE_OPP_PER_GENRE_ON_FIELD "damage_opp_per_genre_on_field"   // Tombe: dégâts à l’adversaire par monstre d’un genre (allié) sur le terrain

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
    // Résoudre/forcer la cible à partir de target_source si l'effet le demande
    if (variable_struct_exists(effect, "target_source")) {
        var tsrc = effect.target_source;
        if (tsrc == "attacker" && variable_struct_exists(context, "attacker") && instance_exists(context.attacker)) {
            target = context.attacker;
        } else if (tsrc == "defender" && variable_struct_exists(context, "defender") && instance_exists(context.defender)) {
            target = context.defender;
        } else if (tsrc == "summoned" && variable_struct_exists(context, "summoned") && instance_exists(context.summoned)) {
            target = context.summoned;
        }
    }
    
    // Log de l'effet pour debug (détaillé)
    var effTrigger = variable_struct_exists(effect, "trigger") ? effect.trigger : "";
    // Sécuriser la récupération du nom de la carte, même si l'instance n'existe plus
    var cardName = "unknown";
    if (card != noone) {
        if (instance_exists(card)) {
            if (variable_instance_exists(card, "name")) {
                cardName = card.name;
            } else if (variable_instance_exists(card, "object_index")) {
                cardName = object_get_name(card.object_index);
            }
        } else if (is_struct(card) && variable_struct_exists(card, "object_index")) {
            cardName = object_get_name(card.object_index);
        }
    }
    var targetDesc = "aucune cible";
    if (target != noone) {
        if (instance_exists(target)) {
            if (variable_instance_exists(target, "name")) {
                targetDesc = target.name;
            } else if (variable_instance_exists(target, "object_index")) {
                targetDesc = object_get_name(target.object_index);
            } else {
                targetDesc = "cible inconnue";
            }
        } else if (is_struct(target) && variable_struct_exists(target, "name")) {
            targetDesc = target.name;
        }
    }
    var valueStr = variable_struct_exists(effect, "value") ? ("valeur=" + string(value)) : "valeur=nd";
    var cardZone = "unknown";
    if (card != noone && instance_exists(card) && variable_instance_exists(card, "zone")) {
        cardZone = card.zone;
    } else if (is_struct(card) && variable_struct_exists(card, "zone")) {
        cardZone = card.zone;
    }
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
                       || effectType == EFFECT_EQUIP_SELECT_TARGET
                       || effectType == EFFECT_BUFF);
    if (needsTarget && target == noone) {
        // Activation manuelle uniquement (phase principale ou effet rapide) et uniquement côté Héros (jamais IA)
        var isManualActivation = (!variable_struct_exists(effect, "trigger")
                                  || effect.trigger == TRIGGER_MAIN_PHASE
                                  || effect.trigger == TRIGGER_QUICK_EFFECT
                                  || effect.trigger == TRIGGER_ON_SUMMON);
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
            // Support de la tempo: si une étape EFFECT_TEMPO est rencontrée,
            // les étapes restantes sont différées via call_later.
            if (ok && variable_struct_exists(effect, "flow") && is_array(effect.flow)) {
                var L = array_length(effect.flow);
                var idx = 0;
                while (idx < L) {
                    var stepEff = effect.flow[idx];
                    if (is_struct(stepEff) && variable_struct_exists(stepEff, "effect_type")) {
                        if (stepEff.effect_type == EFFECT_TEMPO) {
                            var frames = 0;
                            if (variable_struct_exists(stepEff, "frames")) {
                                frames = max(0, stepEff.frames);
                            } else if (variable_struct_exists(stepEff, "ms")) {
                                frames = max(0, round((stepEff.ms / 1000.0) * room_speed));
                            }
                            if (frames > 0) {
                                // Garde: éviter de replanifier si une tempo est déjà en attente (par carte)
                                var was_pending = (instance_exists(card) && variable_instance_exists(card, "_flow_tempo_pending") && card._flow_tempo_pending);
                                var cname_dbg = (card != noone && instance_exists(card) && variable_instance_exists(card, "name")) ? card.name : "unknown";
                                var effId_dbg = (is_struct(effect) && variable_struct_exists(effect, "id")) ? effect.id : -1;
                                show_debug_message("### EFFECT_TEMPO: tentative de planif pour " + cname_dbg + " effect_id=" + string(effId_dbg) + " pending=" + string(was_pending));
                                if (was_pending) {
                                    show_debug_message("### EFFECT_TEMPO: garde -> planif ignorée (déjà en attente)");
                                    break;
                                }

                                // Capturer le reste des étapes après la tempo
                                var remaining_count = L - (idx + 1);
                                var remaining = array_create(remaining_count);
                                var r = 0;
                                for (var j = idx + 1; j < L; j++) { remaining[r++] = effect.flow[j]; }
                                var owner_flag = ownerIsHero;
                                // Stocker l'état du flow sur l'instance carte
                                card._flow_remaining_steps = remaining;
                                card._flow_owner_is_hero = owner_flag;
                                card._flow_effect_id = effId_dbg;
                                card._flow_tempo_pending = true;
                                show_debug_message("### EFFECT_TEMPO: planifié pour " + string(frames) + " frames; étapes restantes=" + string(array_length(remaining)));
                                // Reprendre en re-liant le contexte à l'instance carte
                                call_later(frames, time_source_units_frames, method(card, function() {
                                    if (!instance_exists(self)) {
                                        show_debug_message("### EFFECT_TEMPO: instance carte détruite avant reprise du flow, abandon.");
                                        return;
                                    }
                                    if (!variable_instance_exists(self, "_flow_tempo_pending") || !self._flow_tempo_pending) {
                                        show_debug_message("### EFFECT_TEMPO: callback ignoré (déjà traité)");
                                        return;
                                    }
                                    self._flow_tempo_pending = false;
                                    var remaining_local = variable_instance_exists(self, "_flow_remaining_steps") ? self._flow_remaining_steps : undefined;
                                    var owner_flag_local = variable_instance_exists(self, "_flow_owner_is_hero") ? self._flow_owner_is_hero : undefined;
                                    var effId_local = variable_instance_exists(self, "_flow_effect_id") ? self._flow_effect_id : -1;
                                    var cname_local = (variable_instance_exists(self, "name")) ? self.name : "unknown";
                                    show_debug_message("### EFFECT_TEMPO: reprise du flow pour " + cname_local + " effect_id=" + string(effId_local) + ", étapes=" + string(is_array(remaining_local) ? array_length(remaining_local) : -1));
                                    if (is_array(remaining_local)) {
                                        for (var r2 = 0; r2 < array_length(remaining_local); r2++) {
                                            var step2 = remaining_local[r2];
                                            if (is_struct(step2) && variable_struct_exists(step2, "effect_type")) {
                                                show_debug_message("### EFFECT_TEMPO: exécution étape " + string(r2) + " type=" + string(step2.effect_type));
                                                executeEffect(self, step2, { owner_is_hero: owner_flag_local });
                                            }
                                        }
                                    } else {
                                        show_debug_message("### EFFECT_TEMPO: aucune étape restante trouvée.");
                                    }
                                    // Nettoyage
                                    if (variable_instance_exists(self, "_flow_remaining_steps")) self._flow_remaining_steps = undefined;
                                    if (variable_instance_exists(self, "_flow_owner_is_hero")) self._flow_owner_is_hero = undefined;
                                    if (variable_instance_exists(self, "_flow_effect_id")) self._flow_effect_id = undefined;
                                    // Destruction différée: si demandé, détruire l'instance maintenant
                                    if (variable_instance_exists(self, "_wait_destroy_on_tempo") && self._wait_destroy_on_tempo) {
                                        self._wait_destroy_on_tempo = false;
                                        if (instance_exists(self)) { instance_destroy(self); }
                                    }
                                    if (variable_instance_exists(self, "_consume_after_flow") && self._consume_after_flow) {
                                        self._consume_after_flow = false;
                                        if (!is_undefined(consumeSpellIfNeeded)) { consumeSpellIfNeeded(self, undefined); }
                                    }
                                }));
                                break; // Stopper le traitement immédiat au niveau de la tempo
                            } else {
                                // Tempo nulle: ignorer et continuer
                            }
                        } else {
                            // Étape immédiate
                            executeEffect(card, stepEff, { owner_is_hero: ownerIsHero });
                        }
                    }
                    idx++;
                }
            }
            return ok;
        }
        
        // Envoyer des cartes du deck au cimetière (Mill)
        case EFFECT_MILL_DECK:
        {
            // Déterminer le propriétaire (héros par défaut)
            var ownerIsHero = (variable_struct_exists(context, "owner_is_hero")) ? context.owner_is_hero 
                               : ((card != noone && instance_exists(card) && variable_instance_exists(card, "isHeroOwner")) ? card.isHeroOwner : true);

            // Récupérer les instances de deck et cimetière
            var deckInst = ownerIsHero ? deckHero : deckEnemy;
            var gyInst   = ownerIsHero ? graveyardHero : graveyardEnemy;

            if (!instance_exists(deckInst) || !instance_exists(gyInst)) {
                show_debug_message("### EFFECT_MILL_DECK: deck/graveyard introuvable");
                return false;
            }

            var toMill = max(0, value);
            var milled = 0;
            for (var i = 0; i < toMill; i++) {
                var dsize = ds_list_size(deckInst.cards);
                if (dsize <= 0) { break; }
                // Prendre la carte du dessus du deck (fin de liste)
                var topIdx = dsize - 1;
                var topCard = ds_list_find_value(deckInst.cards, topIdx);
                if (topCard == noone || !instance_exists(topCard)) {
                    // Supprimer l'entrée invalide pour éviter boucle infinie
                    ds_list_delete(deckInst.cards, topIdx);
                    continue;
                }
                // Retirer du deck
                ds_list_delete(deckInst.cards, topIdx);
                // Envoyer au cimetière (addToGraveyard s’occupe des triggers enter_graveyard)
                gyInst.addToGraveyard(topCard);
                // Mettre à jour la zone et détruire l’instance physique
                topCard.zone = "Graveyard";
                instance_destroy(topCard);
                milled++;
            }

            show_debug_message("### EFFECT_MILL_DECK: " + string(milled) + " carte(s) meulée" + (ownerIsHero ? " (héros)" : " (ennemi)"));
            return (milled == toMill);
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
        
            
        case EFFECT_LOSE_ATTACK:
            return modifyAttack(card, -value, true);
            
        // Débuff permanent d'ATK (peut cibler la carte ou la cible fournie)
        case EFFECT_LOSE_ATTACK_PERMANENT:
        {
            var t = (target != noone) ? target : card;
            if (t == noone) return false;
            return modifyAttack(t, -value, false);
        }
            
        

        
            
        case EFFECT_LOSE_DEFENSE:
            return modifyDefense(card, -value, true);
            
        case EFFECT_SET_ATTACK:
            return setAttack(card, value);

        case EFFECT_SET_DEFENSE:
            return setDefense(card, value);

        case EFFECT_BUFF:
        {
            var scope = variable_struct_exists(effect, "scope") ? string_lower(effect.scope) : "single";
            var mode = variable_struct_exists(effect, "mode") ? string_lower(effect.mode) : "add";
            var ownerSideB = variable_struct_exists(effect, "owner") ? string_lower(effect.owner) : "ally";
            var srcHeroB = (card != noone && instance_exists(card) && variable_instance_exists(card, "isHeroOwner")) ? card.isHeroOwner : true;
            var agg = (effect.trigger == TRIGGER_CONTINUOUS) || (variable_struct_exists(effect, "aggregate") && effect.aggregate);
            var atkVal = 0;
            var defVal = 0;
            if (variable_struct_exists(effect, "atk")) atkVal = effect.atk; else atkVal = value;
            if (variable_struct_exists(effect, "def")) defVal = effect.def; else defVal = value;

            var matchesCriteria = function(tgt) {
                if (tgt == noone || !instance_exists(tgt)) return false;
                var okc = true;
                if (variable_struct_exists(effect, "criteria")) {
                    var critB = effect.criteria;
                    if (variable_struct_exists(critB, "type")) {
                        var wt = string_lower(critB.type);
                        var isMon = object_is_ancestor(tgt.object_index, oCardMonster) || (variable_instance_exists(tgt, "type") && string_lower(tgt.type) == "monster");
                        if (wt == "monster" && !isMon) okc = false;
                    }
                    if (variable_struct_exists(critB, "genre")) {
                        var wg = string_lower(string(critB.genre));
                        var tg = variable_instance_exists(tgt, "genre") ? string_lower(string(tgt.genre)) : "";
                        if (wg != "" && tg != wg) okc = false;
                    }
                    if (variable_struct_exists(critB, "archetype")) {
                        var wa = string_lower(string(critB.archetype));
                        var ta = variable_instance_exists(tgt, "archetype") ? string_lower(string(tgt.archetype)) : "";
                        if (wa != "" && ta != wa) okc = false;
                    }
                }
                if (variable_struct_exists(effect, "owner")) {
                    var tgtHero = (instance_exists(tgt) && variable_instance_exists(tgt, "isHeroOwner")) ? tgt.isHeroOwner : srcHeroB;
                    if (ownerSideB == "ally" && (tgtHero != srcHeroB)) okc = false;
                    if (ownerSideB == "enemy" && (tgtHero == srcHeroB)) okc = false;
                }
                if (variable_struct_exists(effect, "target_zone")) {
                    var tz = string_lower(effect.target_zone);
                    var z = variable_instance_exists(tgt, "zone") ? string_lower(tgt.zone) : "";
                    if (tz == "field" && z != "field" && z != "fieldselected") okc = false;
                    if (tz == "hand" && z != "hand") okc = false;
                }
                return okc;
            };

        var applyTo = function(tgt2) {
            if (tgt2 == noone || !instance_exists(tgt2)) return false;
            if (!matchesCriteria(tgt2)) return false;
            var laAtk = atkVal;
            var laDef = defVal;
            var gotBonus = false;
            if (variable_struct_exists(effect, "bonus_if_names")) {
                var namesB = effect.bonus_if_names;
                var oname = object_get_name(tgt2.object_index);
                if (is_array(namesB)) {
                    for (var bi = 0; bi < array_length(namesB); bi++) { if (oname == namesB[bi]) { gotBonus = true; break; } }
                } else if (is_string(namesB)) { gotBonus = (oname == namesB); }
            }
            if (!gotBonus && variable_struct_exists(effect, "bonus_if_archetype")) {
                var wantedA = string_lower(string(effect.bonus_if_archetype));
                var ta2 = variable_instance_exists(tgt2, "archetype") ? string_lower(string(tgt2.archetype)) : "";
                if (wantedA != "" && ta2 == wantedA) gotBonus = true;
            }
            if (!gotBonus && variable_struct_exists(effect, "bonus_if_genre")) {
                var wantedG = string_lower(string(effect.bonus_if_genre));
                var tg2 = variable_instance_exists(tgt2, "genre") ? string_lower(string(tgt2.genre)) : "";
                if (wantedG != "" && tg2 == wantedG) gotBonus = true;
            }
            if (gotBonus) {
                var extraAdd = variable_struct_exists(effect, "extra_buff") ? effect.extra_buff : 0;
                var extraAtk = variable_struct_exists(effect, "atk_bonus") ? effect.atk_bonus : extraAdd;
                var extraDef = variable_struct_exists(effect, "def_bonus") ? effect.def_bonus : extraAdd;
                laAtk += extraAtk;
                laDef += extraDef;
            }
            if (mode == "set") {
                if (variable_struct_exists(effect, "set_atk")) setAttack(tgt2, effect.set_atk);
                if (variable_struct_exists(effect, "set_def")) setDefense(tgt2, effect.set_def);
                return true;
            }
            if (agg) {
                var srcKeyB = "effect:" + string(effect.effect_type) + ":" + string(card.id) + ":" + string(variable_struct_exists(effect, "id") ? effect.id : -1);
                if (scope == "equip") { srcKeyB = "equip:" + string(card.id); }
                else if (scope == "aura") { srcKeyB = "aura:" + string(card.id); }
                buffSetContribution(tgt2, srcKeyB, laAtk, laDef);
                buffRecompute(tgt2);
                return true;
            } else {
                if (laAtk != 0) modifyAttack(tgt2, laAtk, false);
                if (laDef != 0) modifyDefense(tgt2, laDef, false);
                return true;
            }
        };

            if (scope == "single") {
                var tgt = (target != noone) ? target : card;
                return applyTo(tgt);
            } else if (scope == "equip") {
                var tEquip = (variable_instance_exists(card, "equipped_target")) ? card.equipped_target : noone;
                return applyTo(tEquip);
            } else if (scope == "all" || scope == "aura") {
                var applied = false;
                with (oCardParent) {
                    if (!instance_exists(self)) continue;
                    if (scope == "all") {
                        var okOwn = true;
                        if (variable_struct_exists(effect, "owner")) {
                            var isHeroLocal = variable_instance_exists(self, "isHeroOwner") ? isHeroOwner : undefined;
                            if (ownerSideB == "ally" && isHeroLocal != srcHeroB) okOwn = false;
                            if (ownerSideB == "enemy" && isHeroLocal == srcHeroB) okOwn = false;
                        }
                        if (!okOwn) continue;
                    }
                    if (applyTo(id)) applied = true;
                }
                return applied;
            } else if (scope == "graveyard") {
                var totalBoost = 0;
                if (variable_struct_exists(effect, "archetype")) {
                    var arch = effect.archetype;
                    var per = variable_struct_exists(effect, "boost_per_card") ? effect.boost_per_card : 500;
                    var cnt = 0;
                    if (instance_exists(graveyardHero)) {
                        var gyh = graveyardHero.cards;
                        for (var i = 0; i < array_length(gyh); i++) { var cd = gyh[i]; if (is_struct(cd) && object_is_ancestor(cd.object_index, oCardMonster) && variable_struct_exists(cd, "archetype") && string_lower(cd.archetype) == string_lower(arch)) cnt++; }
                    }
                    if (instance_exists(graveyardEnemy)) {
                        var gye = graveyardEnemy.cards;
                        for (var j = 0; j < array_length(gye); j++) { var cd2 = gye[j]; if (is_struct(cd2) && object_is_ancestor(cd2.object_index, oCardMonster) && variable_struct_exists(cd2, "archetype") && string_lower(cd2.archetype) == string_lower(arch)) cnt++; }
                    }
                    totalBoost = cnt * per;
                    atkVal = totalBoost;
                } else if (variable_struct_exists(effect, "genre")) {
                    var gen = effect.genre;
                    var per2 = variable_struct_exists(effect, "boost_per_card") ? effect.boost_per_card : 100;
                    var gyInst = srcHeroB ? graveyardHero : graveyardEnemy;
                    var cnt2 = 0;
                    if (instance_exists(gyInst)) {
                        var gyc = gyInst.cards;
                        for (var k = 0; k < array_length(gyc); k++) { var cd3 = gyc[k]; if (is_struct(cd3) && object_is_ancestor(cd3.object_index, oCardMonster) && variable_struct_exists(cd3, "genre") && string_lower(cd3.genre) == string_lower(gen)) cnt2++; }
                    }
                    totalBoost = cnt2 * per2;
                    atkVal = totalBoost;
                }
                var tgtG = card;
                if (object_is_ancestor(card.object_index, oCardMagic) && variable_instance_exists(card, "equipped_target")) { tgtG = card.equipped_target; }
                if (agg) {
                    var srcKeyG = "effect:" + string(effect.effect_type) + ":" + string(card.id) + ":" + string(variable_struct_exists(effect, "id") ? effect.id : -1);
                    if (object_is_ancestor(card.object_index, oCardMagic)) { srcKeyG = "equip:" + string(card.id); }
                    buffSetContribution(tgtG, srcKeyG, atkVal, defVal);
                    buffRecompute(tgtG);
                    return true;
                } else {
                    if (atkVal != 0) modifyAttack(tgtG, atkVal, false);
                    if (defVal != 0) modifyDefense(tgtG, defVal, false);
                    return true;
                }
            }
            return false;
        }
            
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
        {
            var ok_search = applySearchBySpec(card, effect, context);
            if (ok_search) {
                var owner_flag_s = (card != noone && instance_exists(card) && variable_instance_exists(card, "isHeroOwner"))
                                   ? card.isHeroOwner
                                   : (variable_struct_exists(context, "owner_is_hero") ? context.owner_is_hero : true);
                var ctxs = { from_search: true, owner_is_hero: owner_flag_s };
                if (variable_struct_exists(effect, "flow") && is_array(effect.flow)) {
                    var Ls = array_length(effect.flow);
                    var idxs = 0;
                    while (idxs < Ls) {
                        var stepS = effect.flow[idxs];
                        if (is_struct(stepS) && variable_struct_exists(stepS, "effect_type")) {
                            if (stepS.effect_type == EFFECT_TEMPO) {
                                var framesS = 0;
                                if (variable_struct_exists(stepS, "frames")) {
                                    framesS = max(0, stepS.frames);
                                } else if (variable_struct_exists(stepS, "ms")) {
                                    framesS = max(0, round((stepS.ms / 1000.0) * room_speed));
                                }
                                if (framesS > 0 && instance_exists(card)) {
                                    var was_pending_s = (variable_instance_exists(card, "_flow_tempo_pending") && card._flow_tempo_pending);
                                    if (was_pending_s) { break; }
                                    var remaining_count_s = Ls - (idxs + 1);
                                    var remaining_s = array_create(remaining_count_s);
                                    var rs = 0;
                                    for (var js = idxs + 1; js < Ls; js++) { remaining_s[rs++] = effect.flow[js]; }
                                    card._flow_remaining_steps = remaining_s;
                                    card._flow_owner_is_hero = owner_flag_s;
                                    card._flow_tempo_pending = true;
                                    call_later(framesS, time_source_units_frames, method(card, function() {
                                        if (!instance_exists(self)) { return; }
                                        if (!variable_instance_exists(self, "_flow_tempo_pending") || !self._flow_tempo_pending) { return; }
                                        self._flow_tempo_pending = false;
                                        var rem_local_s = variable_instance_exists(self, "_flow_remaining_steps") ? self._flow_remaining_steps : undefined;
                                        var owner_local_s = variable_instance_exists(self, "_flow_owner_is_hero") ? self._flow_owner_is_hero : undefined;
                                        if (is_array(rem_local_s)) {
                                            for (var r2s = 0; r2s < array_length(rem_local_s); r2s++) {
                                                var step2s = rem_local_s[r2s];
                                                if (is_struct(step2s) && variable_struct_exists(step2s, "effect_type")) {
                                                    executeEffect(self, step2s, { owner_is_hero: owner_local_s });
                                                }
                                            }
                                        }
                                        if (variable_instance_exists(self, "_flow_remaining_steps")) self._flow_remaining_steps = undefined;
                                        if (variable_instance_exists(self, "_flow_owner_is_hero")) self._flow_owner_is_hero = undefined;
                                    }));
                                    break;
                                }
                            } else {
                                executeEffect(card, stepS, { owner_is_hero: owner_flag_s });
                            }
                        }
                        idxs++;
                    }
                } else if (variable_struct_exists(effect, "flow") && is_struct(effect.flow)) {
                    executeEffect(card, effect.flow, ctxs);
                } else if (variable_struct_exists(effect, "flow_next") && is_struct(effect.flow_next)) {
                    executeEffect(card, effect.flow_next, ctxs);
                }
            }
            return ok_search;
        }
        case EFFECT_DESTROY:
        {
            var ok_destroy = applyDestroyBySpec(card, effect, context);
            if (ok_destroy) {
                var owner_flag = (card != noone && instance_exists(card) && variable_instance_exists(card, "isHeroOwner"))
                                 ? card.isHeroOwner
                                 : (variable_struct_exists(context, "owner_is_hero") ? context.owner_is_hero : true);
                var ctxd = { from_destroy: true, owner_is_hero: owner_flag };
                if (variable_struct_exists(effect, "flow") && is_array(effect.flow)) {
                    var Ld = array_length(effect.flow);
                    var kd = 0;
                    while (kd < Ld) {
                        var stepD = effect.flow[kd];
                        if (is_struct(stepD) && variable_struct_exists(stepD, "effect_type")) {
                            if (stepD.effect_type == EFFECT_TEMPO) {
                                var framesD = 0;
                                if (variable_struct_exists(stepD, "frames")) {
                                    framesD = max(0, stepD.frames);
                                } else if (variable_struct_exists(stepD, "ms")) {
                                    framesD = max(0, round((stepD.ms / 1000.0) * room_speed));
                                }
                                if (framesD > 0 && instance_exists(card)) {
                                    var was_pending_d = (variable_instance_exists(card, "_flow_tempo_pending") && card._flow_tempo_pending);
                                    if (was_pending_d) { break; }
                                    var remaining_count_d = Ld - (kd + 1);
                                    var remaining_d = array_create(remaining_count_d);
                                    var rd = 0;
                                    for (var jd = kd + 1; jd < Ld; jd++) { remaining_d[rd++] = effect.flow[jd]; }
                                    card._flow_remaining_steps = remaining_d;
                                    card._flow_owner_is_hero = owner_flag;
                                    card._flow_tempo_pending = true;
                                    call_later(framesD, time_source_units_frames, method(card, function() {
                                        if (!instance_exists(self)) { return; }
                                        if (!variable_instance_exists(self, "_flow_tempo_pending") || !self._flow_tempo_pending) { return; }
                                        self._flow_tempo_pending = false;
                                        var rem_local_d = variable_instance_exists(self, "_flow_remaining_steps") ? self._flow_remaining_steps : undefined;
                                        var owner_local_d = variable_instance_exists(self, "_flow_owner_is_hero") ? self._flow_owner_is_hero : undefined;
                                        if (is_array(rem_local_d)) {
                                            for (var r2d = 0; r2d < array_length(rem_local_d); r2d++) {
                                                var step2d = rem_local_d[r2d];
                                                if (is_struct(step2d) && variable_struct_exists(step2d, "effect_type")) {
                                                    executeEffect(self, step2d, { owner_is_hero: owner_local_d, from_destroy: true });
                                                }
                                            }
                                        }
                                        if (variable_instance_exists(self, "_flow_remaining_steps")) self._flow_remaining_steps = undefined;
                                        if (variable_instance_exists(self, "_flow_owner_is_hero")) self._flow_owner_is_hero = undefined;
                                        if (variable_instance_exists(self, "_consume_after_flow") && self._consume_after_flow) {
                                            self._consume_after_flow = false;
                                            if (!is_undefined(consumeSpellIfNeeded)) { consumeSpellIfNeeded(self, undefined); }
                                        }
                                    }));
                                    break;
                                }
                            } else {
                                executeEffect(card, stepD, ctxd);
                            }
                        }
                        kd++;
                    }
                } else if (variable_struct_exists(effect, "flow") && is_struct(effect.flow)) {
                    executeEffect(card, effect.flow, ctxd);
                } else if (variable_struct_exists(effect, "flow_next") && is_struct(effect.flow_next)) {
                    executeEffect(card, effect.flow_next, ctxd);
                }
            }
            return ok_destroy;
        }
        case EFFECT_SUMMON:
            return applySummonBySpec(card, effect, context);

            
        case EFFECT_NEGATE_EFFECT:
            return negateEffect(target);





        // Effet combiné: défausser cette carte de la main pour chercher par archétype
        // SUPPRIMÉ - Remplacé par le système de flux avec EFFECT_DISCARD + EFFECT_SEARCH
        

         
         // Effet continu: boost d'ATK basé sur l'archétype dans les cimetières
        
        
        // Effet continu: boost d'ATK basé sur le genre dans le cimetière du propriétaire
        
            
        // Effets d’équipement
        case EFFECT_EQUIP_SELECT_TARGET:
        {
            return equipSelectTarget(card, effect, context);
        }
        
        
        
        case EFFECT_EQUIP_CLEANUP:
        {
            return equipCleanup(card, effect, context);
        }
        
        // Aura: buff ATK/DEF par archétype sur le terrain
        
        
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
