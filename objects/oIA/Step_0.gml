/// @description Step oIA - Throttle global des actions et dépilement des attaques IA
// Applique un délai global entre les actions IA (2s via IA_ACTION_DELAY_FRAMES)
// et séquence les attaques pendant la phase "Attack".

if (!instance_exists(game)) exit;

// États et compteurs globaux de l'IA
if (!variable_instance_exists(id, "iaDelayFrames")) iaDelayFrames = 0;
if (!variable_instance_exists(id, "iaNextPhasePending")) iaNextPhasePending = false;
if (!variable_instance_exists(id, "attackProcessing")) attackProcessing = false;
if (!variable_instance_exists(id, "attackDelayFrames")) attackDelayFrames = 0;

var delay_cfg = (variable_global_exists("IA_ACTION_DELAY_FRAMES") ? global.IA_ACTION_DELAY_FRAMES : 30);

// Décrément du délai global
if (iaDelayFrames > 0) iaDelayFrames -= 1;

// Transition de phase planifiée avec délai
if (iaNextPhasePending && iaDelayFrames <= 0) {
    iaNextPhasePending = false;
    game.nextPhase();
    exit; // ne pas enchaîner d'autres actions ce Step
}

// --- Séquencement d'attaque uniquement pendant la phase Attack ---
if (global.current_phase == "Attack" && attackProcessing) {
    // Délai configurable entre attaques
    if (attackDelayFrames > 0) { attackDelayFrames -= 1; exit; }

    // Attendre la fin des FX de combat si activés
    var fx_on = (variable_global_exists("USE_COMBAT_FX") && global.USE_COMBAT_FX);
    if (fx_on) {
        if (instance_number(FX_Combat) > 0) exit; // attendre la fin du combat courant
    }

    // Lancer la prochaine attaque ou planifier la clôture de la phase
    if (!iaAttackTryLaunchNext()) {
        attackProcessing = false;
        iaNextPhasePending = true;
        iaDelayFrames = delay_cfg; // attendre 2s avant nextPhase
    } else {
        attackDelayFrames = delay_cfg; // attendre 2s avant prochaine attaque
    }
}