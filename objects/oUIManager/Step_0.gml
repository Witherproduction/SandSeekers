// === oUIManager - Step Event ===
// Maintient le verrou uniquement quand les boutons d’action sont réellement visibles
// et uniquement pendant les phases Summon/Attack du duel.

var anyActionUI = false;

// Vérifie les instances suivies par oUIManager (visibles et alpha > 0)
if (instanceSummon != "" && instance_exists(instanceSummon) && instanceSummon.visible && instanceSummon.image_alpha > 0) {
    anyActionUI = true;
} else if (instanceSet != "" && instance_exists(instanceSet) && instanceSet.visible && instanceSet.image_alpha > 0) {
    anyActionUI = true;
} else if (instanceEffectButton != "" && instance_exists(instanceEffectButton) && instanceEffectButton.visible && instanceEffectButton.image_alpha > 0) {
    anyActionUI = true;
} else if (instancePositionButton != "" && instance_exists(instancePositionButton) && instancePositionButton.visible && instancePositionButton.image_alpha > 0) {
    anyActionUI = true;
} else if (instanceAttackButton != "" && instance_exists(instanceAttackButton) && instanceAttackButton.visible && instanceAttackButton.image_alpha > 0) {
    anyActionUI = true;
}

// Le verrou ne s’applique que pendant les phases d’action en duel
var inActionPhase = instance_exists(game) && (game.phase[game.phase_current] == "Summon" || game.phase[game.phase_current] == "Attack");

// Verrouiller/déverrouiller en une fois par frame
global.isActionMenuOpen = anyActionUI && inActionPhase;