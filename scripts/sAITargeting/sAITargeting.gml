/// sAITargeting.gml — Sélection de cibles pour effets et équipements

/// Choisit la meilleure cible générique pour un effet ciblé (détruire, bannir, renvoyer, etc.)
function AI_Targeting_ChooseBestTarget(effectType) {
    var best = noone; var bestScore = -100000;
    var dif = (variable_global_exists("IA_DIFFICULTY") ? global.IA_DIFFICULTY : 0);
    var profile = AI_Config_GetActiveProfile();

    // Monstres héros
    for (var i = 0; i < array_length(fieldMonsterHero.cards); i++) {
        var cand = fieldMonsterHero.cards[i];
        if (cand != 0 && instance_exists(cand)) {
            var atk = variable_instance_exists(cand, "attack") ? cand.attack : 0;
            var def = variable_instance_exists(cand, "defense") ? cand.defense : 0;
            var eatk = variable_struct_exists(cand, "effective_attack") ? cand.effective_attack : atk;
            var edef = variable_struct_exists(cand, "effective_defense") ? cand.effective_defense : def;
            var sc = max(atk, def);
            if (dif == 1) {
                var scHard = max(eatk, edef);
                if (variable_instance_exists(cand, "orientation") && cand.orientation == "Attack") scHard += 80;
                sc = scHard;
            }
            // Ajuster selon la politique de ciblage du profil
            if (profile.target_monster_policy == "strongest") {
                sc = max(eatk, edef);
            } else if (profile.target_monster_policy == "weakest") {
                sc = -max(eatk, edef);
            } else {
                // utility: légère prime aux orientations ou effets utiles
                if (variable_instance_exists(cand, "orientation") && cand.orientation == "Attack") sc += 40;
            }
            if (sc > bestScore) { bestScore = sc; best = cand; }
        }
    }
    // Magies/Pièges si aucun monstre sélectionné
    if (best == noone) {
        var mt = fieldManagerHero.getField("MagicTrap");
        if (mt != noone && variable_struct_exists(mt, "cards")) {
            for (var j = 0; j < array_length(mt.cards); j++) {
                var m = mt.cards[j];
                if (m != 0 && instance_exists(m)) {
                    var sc2 = ((dif == 1) ? 150 : 100) * (profile.removal_weight / 50.0);
                    if (sc2 > bestScore) { bestScore = sc2; best = m; }
                }
            }
        }
    }
    return best;
}

/// Choisit la meilleure cible pour un effet d’équipement (Artéfact), en évitant les cibles susceptibles d’être sacrifiées
function AI_Targeting_ChooseBestEquipTargetFor(card, effect) {
    var best = noone; var bestScore = -100000;
    // Par défaut, autoriser les deux camps (aligné avec equipSelectTarget)
    var allyOnly = variable_struct_exists(effect, "ally_only") ? effect.ally_only : false;
    var allowedGenres = variable_struct_exists(effect, "allowed_genres") ? effect.allowed_genres : undefined;
    var profile = AI_Config_GetActiveProfile();

    // Anticipation: si l’IA a en main un monstre nécessitant des sacrifices,
    // éviter d’équiper les cibles les plus susceptibles d’être sacrifiées.
    var plannedSacrificeCount = 0;
    if (ds_exists(handEnemy.cards, ds_type_list)) {
        var hsizeX = ds_list_size(handEnemy.cards);
        for (var hx = 0; hx < hsizeX; hx++) {
            var cHand = ds_list_find_value(handEnemy.cards, hx);
            if (cHand != 0 && instance_exists(cHand) && cHand.type == "Monster" && variable_instance_exists(cHand, "star")) {
                var lvl = getSacrificeLevel(cHand.star);
                if (lvl == 1) plannedSacrificeCount = max(plannedSacrificeCount, 1);
                else if (lvl == 2) plannedSacrificeCount = max(plannedSacrificeCount, 2);
            }
        }
    }
    var likelySacrifices = [];
    if (plannedSacrificeCount > 0) {
        // Collecter nos monstres et trier par stats effectives croissantes
        var poolOwn = [];
        for (var si = 0; si < array_length(fieldMonsterEnemy.cards); si++) {
            var m = fieldMonsterEnemy.cards[si];
            if (m != 0 && instance_exists(m) && m.type == "Monster") {
                var eatkM = variable_struct_exists(m, "effective_attack") ? m.effective_attack : (variable_instance_exists(m, "attack") ? m.attack : 0);
                var edefM = variable_struct_exists(m, "effective_defense") ? m.effective_defense : (variable_instance_exists(m, "defense") ? m.defense : 0);
                array_push(poolOwn, { card: m, score: eatkM + edefM });
            }
        }
        // Tri croissant
        for (var a = 0; a < array_length(poolOwn) - 1; a++) {
            for (var b = a + 1; b < array_length(poolOwn); b++) {
                if (poolOwn[a].score > poolOwn[b].score) { var tmp = poolOwn[a]; poolOwn[a] = poolOwn[b]; poolOwn[b] = tmp; }
            }
        }
        // Sélectionner les N plus faibles comme candidats aux sacrifices
        var limit = min(plannedSacrificeCount, array_length(poolOwn));
        for (var k = 0; k < limit; k++) { array_push(likelySacrifices, poolOwn[k].card); }
    }

    // Évaluer d'abord nos propres monstres (candidats doivent être des monstres)
    for (var i = 0; i < array_length(fieldMonsterEnemy.cards); i++) {
        var cand = fieldMonsterEnemy.cards[i];
        if (cand != 0 && instance_exists(cand)) {
            var isMonsterByAncestry = object_is_ancestor(cand.object_index, oCardMonster);
            var isMonsterByType = (variable_instance_exists(cand, "type") && string_lower(cand.type) == "monster");
            if (!(isMonsterByAncestry || isMonsterByType)) continue;
            if (!(variable_instance_exists(cand, "zone") && (cand.zone == "Field" || cand.zone == "FieldSelected"))) continue;
            if (variable_instance_exists(cand, "orientation") && variable_instance_exists(cand, "isFaceDown")) {
                if (cand.orientation == "Defense" && cand.isFaceDown) continue;
            }
            // Genres autorisés éventuels
            if (allowedGenres != undefined) {
                var g = variable_instance_exists(cand, "genre") ? cand.genre : "";
                var okGenre = false;
                if (is_array(allowedGenres)) {
                    for (var gi = 0; gi < array_length(allowedGenres); gi++) {
                        if (string_lower(g) == string_lower(allowedGenres[gi])) { okGenre = true; break; }
                    }
                } else if (is_string(allowedGenres)) {
                    okGenre = (string_lower(g) == string_lower(allowedGenres));
                }
                if (!okGenre) continue;
            }
            var atk = variable_instance_exists(cand, "attack") ? cand.attack : 0;
            var def = variable_instance_exists(cand, "defense") ? cand.defense : 0;
            var eatk = variable_struct_exists(cand, "effective_attack") ? cand.effective_attack : atk;
            var edef = variable_struct_exists(cand, "effective_defense") ? cand.effective_defense : def;
            var sc = eatk + edef;
            // Pénaliser nos cibles susceptibles d’être sacrifiées si la sécurité est requise
            if (profile.equip_safe_target) {
                for (var p = 0; p < array_length(likelySacrifices); p++) {
                    if (likelySacrifices[p] == cand) { sc -= 100000; break; }
                }
            }
            // Préférer équiper nos monstres quand ally_only == false
            if (!allyOnly) { sc += 500; }
            if (sc > bestScore) { bestScore = sc; best = cand; }
        }
    }

    // Si l’effet autorise l’adversaire, évaluer ensuite les monstres du héros (candidats doivent être des monstres)
    if (!allyOnly) {
        for (var j = 0; j < array_length(fieldMonsterHero.cards); j++) {
            var cand2 = fieldMonsterHero.cards[j];
            if (cand2 != 0 && instance_exists(cand2)) {
                var isMonsterByAncestry2 = object_is_ancestor(cand2.object_index, oCardMonster);
                var isMonsterByType2 = (variable_instance_exists(cand2, "type") && string_lower(cand2.type) == "monster");
                if (!(isMonsterByAncestry2 || isMonsterByType2)) continue;
                if (!(variable_instance_exists(cand2, "zone") && (cand2.zone == "Field" || cand2.zone == "FieldSelected"))) continue;
                if (variable_instance_exists(cand2, "orientation") && variable_instance_exists(cand2, "isFaceDown")) {
                    if (cand2.orientation == "Defense" && cand2.isFaceDown) continue;
                }
                // Genres autorisés éventuels
                if (allowedGenres != undefined) {
                    var g2 = variable_instance_exists(cand2, "genre") ? cand2.genre : "";
                    var okGenre2 = false;
                    if (is_array(allowedGenres)) {
                        for (var gi2 = 0; gi2 < array_length(allowedGenres); gi2++) {
                            if (string_lower(g2) == string_lower(allowedGenres[gi2])) { okGenre2 = true; break; }
                        }
                    } else if (is_string(allowedGenres)) {
                        okGenre2 = (string_lower(g2) == string_lower(allowedGenres));
                    }
                    if (!okGenre2) continue;
                }
                var atk2 = variable_instance_exists(cand2, "attack") ? cand2.attack : 0;
                var def2 = variable_instance_exists(cand2, "defense") ? cand2.defense : 0;
                var eatk2 = variable_struct_exists(cand2, "effective_attack") ? cand2.effective_attack : atk2;
                var edef2 = variable_struct_exists(cand2, "effective_defense") ? cand2.effective_defense : def2;
                var sc2 = eatk2 + edef2;
                // Pénalité pour équiper un monstre adverse
                sc2 -= 1000;
                if (sc2 > bestScore) { bestScore = sc2; best = cand2; }
            }
        }
    }
    return best;
}