// Synchroniser avec la carte sélectionnée du SelectManager
var sm = noone;
// Priorité: instance nommée "selectManager" si disponible
if (instance_exists(selectManager)) {
    sm = selectManager;
} else {
    // Fallback: première instance d'oSelectManager si nom non accessible
    var sm_found = instance_find(oSelectManager, 0);
    if (sm_found != noone && instance_exists(sm_found)) {
        sm = sm_found;
    }
}

// Met à jour uniquement si on a un SelectManager valide
if (sm != noone && instance_exists(sm)) {
    selected = sm.selected;
}

// Note: La gestion des boutons d'attaque est maintenant entièrement gérée par oUIManager
// via la fonction displayAttackButton() appelée depuis oSelectManager
