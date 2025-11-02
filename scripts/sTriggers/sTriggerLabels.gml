// === Libellés des déclencheurs (FR) ===
/// @function getTriggerLabel(triggerId)
/// @description Retourne le libellé court en FR pour un déclencheur donné
/// @param {string} triggerId - Macro TRIGGER_*
/// @returns {string}
function getTriggerLabel(triggerId) {
    if (triggerId == TRIGGER_END_TURN)       return "Finalisation";         // Fin de tour
    if (triggerId == TRIGGER_START_TURN)     return "Initialisation";       // Début de tour
    if (triggerId == TRIGGER_ON_DESTROY)     return "tombe";               // Détruit
    if (triggerId == TRIGGER_ENTER_GRAVEYARD)return "perdu";               // Envoyé au cimetière
    if (triggerId == TRIGGER_ON_DEFENSE)     return "défenseur";           // Après avoir été attaqué (se défendre)
    if (triggerId == TRIGGER_ON_SUMMON)      return "appel";               // À l'invocation (normal ou sacrifice)
    if (triggerId == TRIGGER_ON_ATTACK)      return "attaque";             // Déclaration d'attaque
    if (triggerId == TRIGGER_AFTER_ATTACK)   return "post-attaque";        // Après résolution d'une attaque
    if (triggerId == TRIGGER_AFTER_DEFENSE)  return "post-défense";        // Après résolution d'une défense
    // Par défaut: renvoyer l'identifiant brut s'il n'y a pas de mappage personnalisé
    return string(triggerId);
}

/// @function getTriggerDetailedDescription(triggerId)
/// @description Retourne une description détaillée en FR pour un déclencheur donné
/// @param {string} triggerId - Macro TRIGGER_*
/// @returns {string}
function getTriggerDetailedDescription(triggerId) {
    if (triggerId == TRIGGER_END_TURN)       return "s'active à la fin du tour du propriétaire de la carte";
    if (triggerId == TRIGGER_START_TURN)     return "s'active au début du tour du propriétaire de la carte";
    if (triggerId == TRIGGER_ON_DESTROY)     return "s'active lorsque la carte est détruite";
    if (triggerId == TRIGGER_ENTER_GRAVEYARD)return "s'active lorsque la carte est envoyée au cimetière";
    if (triggerId == TRIGGER_ON_DEFENSE)     return "s'active lorsque la carte se défend contre une attaque";
    if (triggerId == TRIGGER_ON_SUMMON)      return "s'active lorsque la carte est invoquée normalement ou par sacrifice";
    if (triggerId == TRIGGER_ON_ATTACK)      return "s'active lors de la déclaration d'une attaque";
    if (triggerId == TRIGGER_AFTER_ATTACK)   return "s'active après la résolution d'une attaque (post-dégâts)";
    if (triggerId == TRIGGER_AFTER_DEFENSE)  return "s'active après la résolution d'une défense (post-combat)";
    if (triggerId == TRIGGER_MAIN_PHASE)     return "peut être activé pendant la phase principale";
    if (triggerId == TRIGGER_CONTINUOUS)     return "effet continu actif tant que la carte est sur le terrain";
    if (triggerId == TRIGGER_ENTER_HAND)     return "s'active lorsque la carte entre dans la main";
    if (triggerId == TRIGGER_ON_LP_CHANGE)   return "s'active lorsque les points de vie changent";
    if (triggerId == TRIGGER_ON_DAMAGE)      return "s'active lorsque des dommages sont infligés";
    
    // Par défaut: description générique
    return "effet spécial de la carte";
}
