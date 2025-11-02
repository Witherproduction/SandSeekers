show_debug_message("### oCardMonster.Click")

// Vérifier si on est dans une room appropriée
if (room != rDuel && room != rCollection) {
    exit;
}

// Bloquer toute interaction carte si des indicateurs d’emplacement sont actifs (choix de position)
if ((instance_exists(oIndicatorParent)) || (instance_exists(oUIManager) && UIManager.selectedSummonOrSet != "")) {
    return;
}

// Vérifier si la variable globale existe avant de l'utiliser
if (variable_global_exists("isGraveyardViewerOpen") && global.isGraveyardViewerOpen) return;

// Anti-clic traversant: si la souris est sur un bouton UI, ne pas sélectionner la carte
// Utiliser instance_position pour tester le point souris contre les boutons (et non position_meeting)
if ((instance_exists(oSummon) && instance_position(mouse_x, mouse_y, oSummon) != noone)
 || (instance_exists(oSet) && instance_position(mouse_x, mouse_y, oSet) != noone)
 || (instance_exists(oPositionButton) && instance_position(mouse_x, mouse_y, oPositionButton) != noone)
 || (instance_exists(oAttack) && instance_position(mouse_x, mouse_y, oAttack) != noone)
 || (instance_exists(oEffectButton) && instance_position(mouse_x, mouse_y, oEffectButton) != noone)) {
    return;
}

// Bloquer les clics quand le menu d'action est visible, sauf cas autorisés
if (variable_global_exists("isActionMenuOpen") && global.isActionMenuOpen) {
    var allowDeckPick = instance_exists(game) && game.phase[game.phase_current] == "Pick" && zone == "Deck";
    var allowUnselectClick = instance_exists(oSelectManager) && selectManager.selected == id;
    // Autoriser viewer-only pour cartes visibles (héros et adversaire)
    var allowHeroViewerClick = instance_exists(oSelectManager) && isHeroOwner && (zone == "Hand" || zone == "Field");
    var allowEnemyViewerClick = instance_exists(oSelectManager) && !isHeroOwner && (zone == "Field") && !isFaceDown;
    if (!(allowDeckPick || allowUnselectClick || allowHeroViewerClick || allowEnemyViewerClick)) {
        return;
    }
}

// Vérifier si un bouton UI est cliqué et bloquer le traitement de la carte
var uiButtonPresent = false;
if (instance_exists(oSummon) || instance_exists(oSet) || instance_exists(oPositionButton) || instance_exists(oAttack) || instance_exists(oEffectButton)) {
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

if (uiButtonPresent) {
    return;
}

//----------------------------------
// Affichage dans rCollection
//----------------------------------

// Dans rCollection, hériter de la logique de sélection du parent
if (room == rCollection) {
    event_inherited();
    return;
}

// Phase Summon : Le changement d'orientation se fait maintenant via le bouton de position
// (Ancien système de clic direct supprimé pour éviter les changements non voulus)

// Phase Attack : gérer sélection et attaque ciblée
// Vérifier que l'objet game existe avant de l'utiliser
if (instance_exists(game) && game.player[game.player_current] == "Hero" && game.phase[game.phase_current] == "Attack") {

    // Si aucune carte sélectionnée, on sélectionne celle-ci (si c'est un monstre du héros)
    if (selectManager.selected == "" && isHeroOwner && zone == "Field" && type == "Monster") {
        selectManager.trySelect(id);
        return;
    }
    
    // Si une carte est déjà sélectionnée
    if (selectManager.selected != "") {
        var selectedCard = selectManager.selected;
        
        // Si on clique sur un monstre ennemi sur le terrain
        if (!isHeroOwner && type == "Monster" && zone == "Field") {
            // Vérifier si on est en mode attaque
            if (selectManager.attackMode) {
                show_debug_message("### Cible sélectionnée pour l'attaque: " + name);
                // Faire disparaître la flèche de ciblage avant l'animation de combat
                selectManager.destroyTargetingArrow();
                damageManager.tryAttack(id);
                // Sortir du mode attaque après l'attaque
                selectManager.attackMode = false;
                return;
            } else {
                show_debug_message("### Monstre ennemi cliqué mais pas en mode attaque - utilisez le bouton Attack d'abord");
                return;
            }
        }
        
        // Si on clique sur son propre monstre => changer sélection (désélectionner la précédente, sélectionner la nouvelle)
        if (isHeroOwner && type == "Monster" && zone == "Field") {
            selectManager.trySelect(id);
            return;
        }
    }
}


// Sinon, comportement par défaut (sélection, désélection, activation magie/piège, etc.)
event_inherited();
