show_debug_message("### oCardParent.Click - room: " + string(room))

// Bloque immédiatement tout clic si le panneau d'options est présent
if (instance_exists(oPanelOptions)) return;

///////////////////////////////////////////////////////////////////////
// Controls
///////////////////////////////////////////////////////////////////////

// Vérifier si on est dans une room appropriée
if (room != rDuel && room != rCollection) {
    exit;
}

// Bloquer toute interaction carte si des indicateurs d’emplacement sont actifs (choix de position) — uniquement en Duel
if (room == rDuel) {
    if ((instance_exists(oIndicatorParent)) || (instance_exists(oUIManager) && UIManager.selectedSummonOrSet != "")) {
        return;
    }
}

// Si le GraveyardViewer est ouvert, bloquer les clics — uniquement en Duel
// Vérifier si la variable globale existe avant de l'utiliser
if (room == rDuel && variable_global_exists("isGraveyardViewerOpen") && global.isGraveyardViewerOpen) return;

// Bloquer les clics quand le menu d'action est visible — uniquement en Duel
if (room == rDuel && variable_global_exists("isActionMenuOpen") && global.isActionMenuOpen) {
    var allowDeckPick = instance_exists(game) && game.phase[game.phase_current] == "Pick" && zone == "Deck";
    var allowUnselectClick = instance_exists(oSelectManager) && selectManager.selected == id;
    // Autoriser un clic de carte héros pour afficher le viewer, même avec le menu ouvert
    var allowViewerClick = instance_exists(oSelectManager) && isHeroOwner && (zone == "Hand" || zone == "Field");
    // Autoriser un clic viewer-only sur carte adverse face visible (terrain)
    var allowEnemyViewerClick = instance_exists(oSelectManager) && !isHeroOwner && (zone == "Field") && !isFaceDown;
    if (!(allowDeckPick || allowUnselectClick || allowViewerClick || allowEnemyViewerClick)) {
        return;
    }
}

// Vérifier si un bouton UI est présent et bloque les clics — uniquement en Duel
var uiButtonPresent = false;
if (room == rDuel && (instance_exists(oSummon) || instance_exists(oSet) || instance_exists(oPositionButton) || instance_exists(oAttack) || instance_exists(oEffectButton))) {
    // Vérifier si le clic est directement sur un bouton UI
    with(oSummon) {
        var w = sprite_get_width(sprite_index) * image_xscale;
        var h = sprite_get_height(sprite_index) * image_yscale;
        var ox = sprite_get_xoffset(sprite_index) * image_xscale;
        var oy = sprite_get_yoffset(sprite_index) * image_yscale;
        var left = x - ox;
        var top = y - oy;
        var right = left + w;
        var bottom = top + h;
        if (point_in_rectangle(mouse_x, mouse_y, left, top, right, bottom)) {
            uiButtonPresent = true;
            break;
        }
    }
    with(oSet) {
        var w = sprite_get_width(sprite_index) * image_xscale;
        var h = sprite_get_height(sprite_index) * image_yscale;
        var ox = sprite_get_xoffset(sprite_index) * image_xscale;
        var oy = sprite_get_yoffset(sprite_index) * image_yscale;
        var left = x - ox;
        var top = y - oy;
        var right = left + w;
        var bottom = top + h;
        if (point_in_rectangle(mouse_x, mouse_y, left, top, right, bottom)) {
            uiButtonPresent = true;
            break;
        }
    }
    with(oPositionButton) {
        var w = sprite_get_width(sprite_index) * image_xscale;
        var h = sprite_get_height(sprite_index) * image_yscale;
        var ox = sprite_get_xoffset(sprite_index) * image_xscale;
        var oy = sprite_get_yoffset(sprite_index) * image_yscale;
        var left = x - ox;
        var top = y - oy;
        var right = left + w;
        var bottom = top + h;
        if (point_in_rectangle(mouse_x, mouse_y, left, top, right, bottom)) {
            uiButtonPresent = true;
            break;
        }
    }
    with(oAttack) {
        var w = sprite_get_width(sprite_index) * image_xscale;
        var h = sprite_get_height(sprite_index) * image_yscale;
        var ox = sprite_get_xoffset(sprite_index) * image_xscale;
        var oy = sprite_get_yoffset(sprite_index) * image_yscale;
        var left = x - ox;
        var top = y - oy;
        var right = left + w;
        var bottom = top + h;
        if (point_in_rectangle(mouse_x, mouse_y, left, top, right, bottom)) {
            uiButtonPresent = true;
            break;
        }
    }
    with(oEffectButton) {
        var w = sprite_get_width(sprite_index) * image_xscale;
        var h = sprite_get_height(sprite_index) * image_yscale;
        var ox = sprite_get_xoffset(sprite_index) * image_xscale;
        var oy = sprite_get_yoffset(sprite_index) * image_yscale;
        var left = x - ox;
        var top = y - oy;
        var right = left + w;
        var bottom = top + h;
        if (point_in_rectangle(mouse_x, mouse_y, left, top, right, bottom)) {
            uiButtonPresent = true;
            break;
        }
    }
}

// Si un bouton UI est cliqué, bloquer complètement le traitement de la carte
if (uiButtonPresent) {
    return;
}

// Bloquer uniquement pendant la distribution en phase Pick — Duel
if (room == rDuel && instance_exists(game) && game.timerEnabledPick && game.phase[game.phase_current] == "Pick")
    return;

///////////////////////////////////////////////////////////////////////
// Constructeur
///////////////////////////////////////////////////////////////////////

//----------------------------------
// Tire une carte dans le deck
//----------------------------------

// Vérifier que l'objet game existe avant de l'utiliser
if(isHeroOwner && instance_exists(game) && game.player[game.player_current] == "Hero" && game.phase[game.phase_current] == "Pick" && zone == "Deck") {
	
	deckHero.pick();
	game.nextPhase();
	nextStep.image_alpha = 1;
	return; // Evite de tester les autres actions ci-dessous
}

//----------------------------------
// Sélection / Désélection
//----------------------------------

// Vérifier que selectManager existe (uniquement dans rDuel)
if (instance_exists(oSelectManager)) {
    // On essaye de désactiver la carte que si on ne vient pas tout juste de l'activer
    var selection_result = selectManager.trySelect(id);
    show_debug_message("### Résultat de la sélection: " + string(selection_result));
    
    if(!selection_result) { // Sélectionne une carte si on clique dessus
        show_debug_message("### Tentative de désélection de carte: " + string(id));
        selectManager.tryUnselect(id); // Désélectionne une carte si on clique à nouveau dessus
    }
}

//----------------------------------
// Attaque / Cast
//----------------------------------

// Vérifier si une carte sélectionnée clique sur une cible ennemie (uniquement dans rDuel)
if (instance_exists(oSelectManager) && selectManager.selected != "") {
    // Si on clique sur une carte ennemie, déclencher l'attaque SEULEMENT si le mode attaque est activé
    if (!isHeroOwner && type == "Monster" && zone == "Field") {
        if (selectManager.attackMode) {
            show_debug_message("### Cible sélectionnée pour l'attaque: " + name);
            damageManager.tryAttack(id);
            return;
        } else {
            show_debug_message("### Monstre ennemi cliqué mais pas en mode attaque - utilisez le bouton Attack d'abord");
            return;
        }
    }
}

//----------------------------------
// Logique de sélection pour rCollection
//----------------------------------

// Logique de sélection de carte dans la collection
if (room == rCollection) {
    // Désélectionner toutes les autres cartes
    with (oCardParent) {
        isSelected = false;
    }
    
    // Sélectionner cette carte
    isSelected = true;
    
    // Utiliser le système de sélection original avec oCollectionSelectManager
    if (instance_exists(oCollectionSelectManager)) {
        with (oCollectionSelectManager) {
            selectCard(other.id);
        }
    }
}

