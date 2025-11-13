/// Aura: fonctions utilitaires pour appliquer et nettoyer les contributions de buff


function cleanupAuraSource(card, effect) {
    if (card == noone || !instance_exists(card)) return false;
    var srcKey = "aura:" + string(card.id);
    var buffPrefix = "effect:" + string(EFFECT_BUFF) + ":" + string(card.id) + ":";
    var cname = variable_instance_exists(card, "name") ? card.name : string(card.id);
    show_debug_message("### cleanupAuraSource: removing contributions from source " + cname + " (" + srcKey + ")");
    with (oCardParent) {
        if (instance_exists(self) && variable_instance_exists(self, "zone") && (zone == "Field" || zone == "FieldSelected")) {
            var isMonster2 = false;
            if (variable_instance_exists(self, "type")) {
                isMonster2 = (type == "Monster");
            } else {
                isMonster2 = object_is_ancestor(object_index, oCardMonster);
            }
            if (isMonster2) {
                buffRemoveContribution(id, srcKey);
                if (variable_instance_exists(self, "buff_contribs")) {
                    var filtered = [];
                    for (var i = 0; i < array_length(self.buff_contribs); i++) {
                        var c = self.buff_contribs[i];
                        if (is_struct(c) && variable_struct_exists(c, "key")) {
                            var k = string(c.key);
                            if (string_pos(buffPrefix, k) == 1) {
                                continue;
                            }
                        }
                        array_push(filtered, c);
                    }
                    self.buff_contribs = filtered;
                }
                buffRecompute(id);
            }
        }
    }
    return true;
}

function applyAllMonstersAuraDebuff(card, effect) {
    if (card == noone || !instance_exists(card)) return false;
    if (!variable_instance_exists(card, "zone")) return false;
    if (!(card.zone == "Field" || card.zone == "FieldSelected")) return false;
    if (variable_instance_exists(card, "isFaceDown") && card.isFaceDown) return false;

    var atk = variable_struct_exists(effect, "atk") ? effect.atk : -500;
    var def = variable_struct_exists(effect, "def") ? effect.def : -500;
    var srcKey = "aura:" + string(card.id);
    var excludeGenres = [];
    if (variable_struct_exists(effect, "exclude_genres")) {
        if (is_array(effect.exclude_genres)) excludeGenres = effect.exclude_genres; else excludeGenres = [effect.exclude_genres];
    }

    with (oCardParent) {
        if (instance_exists(self) && variable_instance_exists(self, "zone") && (zone == "Field" || zone == "FieldSelected")) {
            var isMonster = false;
            if (variable_instance_exists(self, "type")) {
                isMonster = (type == "Monster");
            } else {
                isMonster = object_is_ancestor(object_index, oCardMonster);
            }
            if (isMonster) {
                var excluded = false;
                if (array_length(excludeGenres) > 0 && variable_instance_exists(self, "genre")) {
                    var g = string_lower(self.genre);
                    for (var i = 0; i < array_length(excludeGenres); i++) {
                        if (g == string_lower(string(excludeGenres[i]))) { excluded = true; break; }
                    }
                }
                if (excluded) continue;
                buffSetContribution(id, srcKey, atk, def);
                buffRecompute(id);
            }
        }
    }
    return true;
}