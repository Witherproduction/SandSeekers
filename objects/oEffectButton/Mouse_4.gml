/// @description Effect Button Click

if (global.isGraveyardViewerOpen) exit;
// Bloque l'interaction si le sélecteur de sacrifice est ouvert
if (variable_global_exists("isSacrificeSelectorOpen") && global.isSacrificeSelectorOpen) exit;

// Vérifier que la carte parent existe
if (!variable_instance_exists(self, "parentCard") || parentCard == "" || !instance_exists(parentCard)) {
    show_debug_message("### oEffectButton: aucune carte parente valide");
    exit;
}

var card = parentCard;

// Récupérer l'effet activable après un éventuel retournement
var effect = getAvailableEffect(card);
// Détection d'un effet continu (permet d'afficher un bouton même sans effet manuel)
var hasContinuous = false;
if (variable_struct_exists(card, "effects")) {
    for (var ci = 0; ci < array_length(card.effects); ci++) {
        var ce = card.effects[ci];
        if (is_struct(ce) && variable_struct_exists(ce, "trigger") && ce.trigger == TRIGGER_CONTINUOUS) { hasContinuous = true; break; }
    }
}

// Si aucun effet manuel, autoriser le flux pour les cartes à effet continu (pose/retournement)
if (effect == noone && !hasContinuous) {
    show_debug_message("### oEffectButton: aucun effet disponible");
    UIManager.hideEffectButton();
    exit;
}
// Vérification runtime: ne pas activer si aucune cible/cout valide (s'applique uniquement aux effets manuels)
if (effect != noone && !hasValidTargetForEffect(card, effect)) {
    show_debug_message("### oEffectButton: aucune cible/cout valide -> annulation");
    UIManager.hideEffectButton();
    exit;
}

// Règle pour Artéfact: ne pas permettre l'activation s'il n'y a aucun monstre sur le terrain
var isArtifact = (variable_instance_exists(card, "genre") && card.genre == "Artéfact");
if (isArtifact) {
    if (!has_any_monster_on_field()) {
        show_debug_message("### oEffectButton: pas de monstre sur le terrain -> activation Artefact refusée");
        UIManager.hideEffectButton();
        exit;
    }
}

// Si carte face cachée sur le terrain: lancer l'animation de flip après validations
var isFaceDown = (variable_instance_exists(card, "isFaceDown") && card.isFaceDown);
var isOnField = (variable_instance_exists(card, "zone") && (card.zone == "Field" || card.zone == "FieldSelected"));
if (isFaceDown && isOnField) {
    // Démarrer l'animation de retournement; le Step de oCardParent mettra image_index=0 et isFaceDown=false
    card.position_anim_active = true;
    card.anim_flip_speed = (variable_global_exists("ANIM_FLIP_SPEED") ? global.ANIM_FLIP_SPEED : 0.03);
    card.anim_flip_orig_scale = card.image_xscale;
    card.anim_phase = "flip_in";
}

// Si carte Artéfact ou Direct depuis la main: d'abord poser, ensuite aura puis ciblage
var isInHand = (variable_instance_exists(card, "zone") && (card.zone == "Hand" || card.zone == "HandSelected"));
var isDirect = (variable_instance_exists(card, "genre") && card.genre == "Direct");
if ((isArtifact || isDirect || hasContinuous) && isInHand) {
    var cardType = isArtifact ? "Artefact" : (isDirect ? "Direct" : "Continu");
    show_debug_message("### oEffectButton: " + cardType + " en main -> différer exécution après placement");
    
    // Vérifier qu'il y a un slot libre sur le terrain MagicTrap
    var ownerIsHero = (variable_instance_exists(card, "isHeroOwner") && card.isHeroOwner);
    var fieldMgr = ownerIsHero ? fieldManagerHero : fieldManagerEnemy;
    var mtField = fieldMgr.getField("MagicTrap");
    var hasFreeMTSlot = false;
    if (mtField != noone && variable_struct_exists(mtField, "cards")) {
        for (var mti = 0; mti < array_length(mtField.cards); mti++) {
            if (mtField.cards[mti] == 0) { hasFreeMTSlot = true; break; }
        }
    }
    
    if (!hasFreeMTSlot) {
        show_debug_message("### oEffectButton: aucun slot MagicTrap libre -> activation refusée");
        UIManager.hideEffectButton();
        exit;
    }
    
    // Pour Artefact/Direct, stocker l'effet en attente; pour Continu, simple pose face visible
    if ((isArtifact || isDirect) && instance_exists(oSelectManager) && effect != noone) {
        selectManager.pendingEffectCard = card;
        selectManager.pendingEffect = effect;
    }
    // Pose face visible pour activer immédiatement l'effet continu
    UIManager.selectedSummonOrSet = "Summon";
    UIManager.displayIndicator(card);
    // Nettoyage UI immédiat du bouton effet pour éviter double-clic
    UIManager.hideEffectButton();
    exit;
}

// Demande de halo doré (file d’attente, un par un)
requestFXAura(
    card.sprite_index,
    card.image_index,
    card.image_xscale,
    card.image_yscale,
    card.image_angle,
    600,   // durée ~0.6s
    18,    // padding
    10,    // épaisseur
    1.50,  // scale multiplier
    0.80,  // alpha start
    card.x,
    card.y
);

// Pour les cartes déjà sur le terrain (y compris Artéfacts), exécuter l'effet manuel s'il existe
var effectResolved = false;
if (effect != noone) {
    effectResolved = executeEffect(card, effect, {});
    if (effectResolved) {
        markEffectAsUsed(card, effect);
    }
}

// Consommer les sorts Direct (non-continus) après la résolution
if (!is_undefined(consumeSpellIfNeeded) && effectResolved) {
    consumeSpellIfNeeded(card, effect);
}

// Nettoyer l'UI
UIManager.hideSummonAndSet();
UIManager.hideEffectButton();