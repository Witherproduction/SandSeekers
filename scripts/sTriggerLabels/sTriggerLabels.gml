/// Centralisation des noms et libellés FR des déclencheurs

/// @function getTriggerLabel(triggerId)
/// @description Retourne le libellé court FR pour un déclencheur donné
/// @param {string} triggerId - Macro TRIGGER_*
/// @returns {string}
function getTriggerLabel(triggerId) {
    if (triggerId == TRIGGER_END_TURN)        return "finalisation";   // Fin de tour
    if (triggerId == TRIGGER_START_TURN)      return "initialisation"; // Début de tour
    if (triggerId == TRIGGER_ON_DESTROY)      return "tombe";          // Détruit
    if (triggerId == TRIGGER_ENTER_GRAVEYARD) return "perdu";          // Envoyé au cimetière
    if (triggerId == TRIGGER_ON_DEFENSE)      return "défenseur";      // Se défendre
    if (triggerId == TRIGGER_ON_SUMMON)       return "appel";          // À l'invocation (normal ou sacrifice)
    // Par défaut: identifiant brut s'il n'y a pas de mappage personnalisé
    if (triggerId == TRIGGER_ON_ATTACK)       return "attaque";         // Déclaration/avant calcul
    if (triggerId == TRIGGER_AFTER_ATTACK)    return "post-attaque";    // Après résolution d'une attaque
    if (triggerId == TRIGGER_AFTER_DEFENSE)   return "post-défense";    // Après résolution d'une défense
    return string(triggerId);
}

/// @function getTriggerName(triggerId)
/// @description Les "noms" demandés sont identiques aux libellés courts
function getTriggerName(triggerId) {
    return getTriggerLabel(triggerId);
}

/// @function getTriggerDetailedDescription(triggerId)
/// @description Retourne une description FR concise pour les déclencheurs mappés
function getTriggerDetailedDescription(triggerId) {
    if (triggerId == TRIGGER_END_TURN)        return "s'active à la fin du tour";
    if (triggerId == TRIGGER_START_TURN)      return "s'active au début du tour";
    if (triggerId == TRIGGER_ON_DESTROY)      return "s'active quand la carte est détruite";
    if (triggerId == TRIGGER_ENTER_GRAVEYARD) return "s'active quand la carte est envoyée au cimetière";
    if (triggerId == TRIGGER_ON_DEFENSE)      return "s'active quand la carte défend";
    if (triggerId == TRIGGER_ON_SUMMON)       return "s'active quand la carte est invoquée";
    if (triggerId == TRIGGER_ON_ATTACK)       return "s'active lors de la déclaration d'une attaque";
    if (triggerId == TRIGGER_AFTER_ATTACK)    return "s'active après la résolution d'une attaque (post-dégâts)";
    if (triggerId == TRIGGER_AFTER_DEFENSE)   return "s'active après la résolution d'une défense (post-combat)";
    // Par défaut: description générique
    return "effet spécial";
}

/// @function normalizeEffectLabel(text)
/// @description Normalise le début d'une description d'effet en l'un des 7 libellés
/// @returns {string} - "" si aucun label reconnu
function normalizeEffectLabel(text) {
    var t = string(text);
    // Normalisation basique des accents
    t = string_replace_all(t, "é", "e");
    t = string_replace_all(t, "è", "e");
    t = string_replace_all(t, "ê", "e");
    t = string_replace_all(t, "à", "a");
    t = string_replace_all(t, "î", "i");
    t = string_lower(t);

    // Détection par préfixe (début de description)
    if (string_pos("appel specialise", t) == 1) return "appel spécialisé";
    if (string_pos("appel", t) == 1)            return "appel";
    if (string_pos("initialisation", t) == 1)   return "initialisation";
    if (string_pos("finalisation", t) == 1)     return "finalisation";
    if (string_pos("tombe", t) == 1)            return "tombe";
    if (string_pos("perdu", t) == 1 || string_pos("perdue", t) == 1) return "perdu";
    if (string_pos("defenseur", t) == 1)        return "défenseur";
    return "";
}

/// @function getEffectLabel(effect)
/// @description Retourne le libellé FR pour un effet donné, distinguant l'invocation spéciale
function getEffectLabel(effect) {
    if (!is_struct(effect)) return "";
    if (!variable_struct_exists(effect, "trigger")) return "";
    // Priorité aux labels personnalisés définis sur l'effet
    if (variable_struct_exists(effect, "label") && is_string(effect.label) && string_length(effect.label) > 0) {
        return effect.label;
    }
    var trig = effect.trigger;
    if (trig == TRIGGER_ON_SUMMON) {
        if (variable_struct_exists(effect, "conditions") && variable_struct_exists(effect.conditions, "summon_mode")) {
            var sm = effect.conditions.summon_mode;
            if (is_array(sm)) {
                for (var i = 0; i < array_length_1d(sm); i++) {
                    if (sm[i] == "SpecialSummon") return "appel spécialisé";
                }
            } else {
                if (sm == "SpecialSummon") return "appel spécialisé";
            }
        }
        return "appel";
    }
    return getTriggerLabel(trig);
}
