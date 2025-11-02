/// @function applyDestroyByFilter(card, effect)
/// @description Détruit des cartes selon des filtres et une sélection paramétrable
/// @param {instance} card - La carte qui déclenche l'effet
/// @param {struct} effect - L'effet contenant les filtres
/// @returns {bool} - true si au moins une carte détruite
function applyDestroyByFilter(card, effect) {
    var ownerIsHero = (card != noone && instance_exists(card) && variable_instance_exists(card, "isHeroOwner")) ? card.isHeroOwner : true;

    var targetOwner = variable_struct_exists(effect, "target_owner") ? string_lower(effect.target_owner) : "enemy"; // enemy|ally|any
    var targetType  = variable_struct_exists(effect, "target_type")  ? string_lower(effect.target_type)  : "monster"; // monster|spell
    var zoneWanted  = variable_struct_exists(effect, "zone") ? effect.zone : "Field";
    var selection   = variable_struct_exists(effect, "selection") ? effect.selection : { mode: "random", count: 1 };

    var genreWanted     = variable_struct_exists(effect, "genre") ? effect.genre : undefined;
    var archetypeWanted = variable_struct_exists(effect, "archetype") ? effect.archetype : undefined;

    var candidates = [];

    // Sélectionner le pool par type
    if (targetType == "monster") {
        with (oCardMonster) {
            if (!instance_exists(self)) continue;
            if (!variable_instance_exists(self, "zone") || !(zone == "Field" || zone == "FieldSelected")) continue;

            // Filtre camp
            var isEnemy = (variable_instance_exists(self, "isHeroOwner") ? (self.isHeroOwner != ownerIsHero) : false);
            var isAlly  = (variable_instance_exists(self, "isHeroOwner") ? (self.isHeroOwner == ownerIsHero) : false);
            if (targetOwner == "enemy" && !isEnemy) continue;
            if (targetOwner == "ally"  && !isAlly)  continue;
            // any: ne filtre pas

            // Critères optionnels
            if (genreWanted != undefined && variable_instance_exists(self, "genre")) {
                if (string_lower(self.genre) != string_lower(genreWanted)) continue;
            }
            if (archetypeWanted != undefined && variable_instance_exists(self, "archetype")) {
                if (string_lower(self.archetype) != string_lower(archetypeWanted)) continue;
            }

            array_push(candidates, id);
        }
    } else if (targetType == "spell") {
        with (oCardMagic) {
            if (!instance_exists(self)) continue;
            if (!variable_instance_exists(self, "zone") || !(zone == "Field" || zone == "FieldSelected")) continue;

            var isEnemy = (variable_instance_exists(self, "isHeroOwner") ? (self.isHeroOwner != ownerIsHero) : false);
            var isAlly  = (variable_instance_exists(self, "isHeroOwner") ? (self.isHeroOwner == ownerIsHero) : false);
            if (targetOwner == "enemy" && !isEnemy) continue;
            if (targetOwner == "ally"  && !isAlly)  continue;

            array_push(candidates, id);
        }
    } else {
        // Type inconnu : fallback générique (toutes cartes parents sur le terrain)
        with (oCardParent) {
            if (!instance_exists(self)) continue;
            if (!variable_instance_exists(self, "zone") || !(zone == "Field" || zone == "FieldSelected")) continue;
            array_push(candidates, id);
        }
    }

    var n = array_length(candidates);
    if (n <= 0) {
        show_debug_message("### EFFECT_DESTROY: aucun candidat trouvé pour destruction");
        return false;
    }

    var mode  = (variable_struct_exists(selection, "mode") ? selection.mode : "random");
    var count = (variable_struct_exists(selection, "count") ? selection.count : 1);
    count = clamp(count, 1, n);

    if (mode == "random") {
        // Détruire 'count' cartes aléatoires sans répétition
        for (var i = 0; i < count; i++) {
            var remaining = array_length(candidates);
            if (remaining <= 0) break;
            var idx = irandom(remaining - 1);
            var pick = candidates[idx];
            array_delete(candidates, idx, 1);
            destroyCard(pick);
        }
        return true;
    } else {
        // Mode par défaut: détruire les 'count' premiers
        for (var j = 0; j < count; j++) {
            if (j >= n) break;
            destroyCard(candidates[j]);
        }
        return true;
    }
}