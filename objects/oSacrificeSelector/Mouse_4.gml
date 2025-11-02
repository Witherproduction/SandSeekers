// === oSacrificeSelector - Mouse_4 (Clic gauche) ===
// Amélioration de la détection de clic pour la sélection des sacrifices

// Ne traite les clics que si le sélecteur est visible
if(!visible) return;

// Si le GraveyardViewer est ouvert, bloquer les clics
if (variable_global_exists("isGraveyardViewerOpen") && global.isGraveyardViewerOpen) return;

// Vérifier d'abord si le clic est sur un bouton UI (éviter les conflits)
var uiButtonClicked = false;
with(oSummon) {
    if (point_in_rectangle(mouse_x, mouse_y, x, y, x + sprite_width, y + sprite_height)) {
        uiButtonClicked = true;
        break;
    }
}
with(oSet) {
    if (point_in_rectangle(mouse_x, mouse_y, x, y, x + sprite_width, y + sprite_height)) {
        uiButtonClicked = true;
        break;
    }
}
with(oPositionButton) {
    if (point_in_rectangle(mouse_x, mouse_y, x, y, x + sprite_width, y + sprite_height)) {
        uiButtonClicked = true;
        break;
    }
}

// Si un bouton UI est cliqué, ne pas traiter
if(uiButtonClicked) return;

// Calcule les positions des boutons (même calcul que dans Draw_0) en tenant compte de l'échelle du cadre
var uiSprite = sFond;
var scaleX = 0.5;
var scaleY = 0.5;
var baseW = sprite_get_width(uiSprite);
var baseH = sprite_get_height(uiSprite);
var frameW = baseW * scaleX;
var frameH = baseH * scaleY;
var windowX = (room_width - frameW) / 2;
var windowY = (room_height - frameH) / 2 - 210;

// Dimensions des boutons
var btnWidth = 100;
var btnHeight = 30;

// Calcule la zone intérieure (bbox) du cadre en tenant compte de l'échelle
var bboxLeft = sprite_get_bbox_left(uiSprite);
var bboxRight = sprite_get_bbox_right(uiSprite);
var bboxTop = sprite_get_bbox_top(uiSprite);
var bboxBottom = sprite_get_bbox_bottom(uiSprite);
var contentX1 = windowX + bboxLeft * scaleX;
var contentX2 = windowX + bboxRight * scaleX;
var contentY1 = windowY + bboxTop * scaleY;
var contentY2 = windowY + bboxBottom * scaleY;
var contentW = contentX2 - contentX1;

// Positions des boutons (synchro avec Draw_0 + marges internes et bbox)
var btnGap = 20;
var paddingBottom = 16;
var buttonLift = 48; // remonte encore les boutons
var buttonsY = contentY2 - paddingBottom - buttonLift - btnHeight/2;
var confirmBtnX = contentX1 + contentW/2 - (btnWidth/2 + btnGap/2);
var confirmBtnY = buttonsY;
var cancelBtnX = contentX1 + contentW/2 + (btnWidth/2 + btnGap/2);
var cancelBtnY = buttonsY;

// Vérifie si le clic est sur le bouton Confirmer
var canConfirm = (array_length(selectedSacrifices) >= requiredSacrificeCount);
if(canConfirm && 
   mouse_x >= confirmBtnX - btnWidth/2 && mouse_x <= confirmBtnX + btnWidth/2 &&
   mouse_y >= confirmBtnY - btnHeight/2 && mouse_y <= confirmBtnY + btnHeight/2) {
    show_debug_message("### SacrificeSelector - Bouton Confirmer cliqué");
    confirm();
    return;
}

// Vérifie si le clic est sur le bouton Annuler
if(mouse_x >= cancelBtnX - btnWidth/2 && mouse_x <= cancelBtnX + btnWidth/2 &&
   mouse_y >= cancelBtnY - btnHeight/2 && mouse_y <= cancelBtnY + btnHeight/2) {
    show_debug_message("### SacrificeSelector - Bouton Annuler cliqué");
    cancel();
    return;
}

// Détection de clic sur les monstres (sans bouton "+" dédié)
var nbCards = instance_number(oCardParent);
for(var i = 0; i < nbCards; i++) {
    var card = instance_find(oCardParent, i);
    
    // Vérifie si c'est un monstre sur le terrain du joueur
    if(card.type == "Monster" && card.zone == "Field" && card.isHeroOwner) {
        
        // Calcul des limites de la carte en tenant compte de l’origine, de l’échelle et de l’angle
        var spr = card.sprite_index;
        var w = sprite_get_width(spr) * card.image_xscale;
        var h = sprite_get_height(spr) * card.image_yscale;
        var xoff = sprite_get_xoffset(spr) * card.image_xscale;
        var yoff = sprite_get_yoffset(spr) * card.image_yscale;
        var ang = card.image_angle;
        var ca = dcos(ang);
        var sa = dsin(ang);
        // Coins locaux
        var lx1 = -xoff, ly1 = -yoff;
        var lx2 =  w - xoff, ly2 = -yoff;
        var lx3 =  w - xoff, ly3 =  h - yoff;
        var lx4 = -xoff,        ly4 =  h - yoff;
        // Coins transformés
        var x1 = card.x + lx1*ca - ly1*sa; var y1 = card.y + lx1*sa + ly1*ca;
        var x2 = card.x + lx2*ca - ly2*sa; var y2 = card.y + lx2*sa + ly2*ca;
        var x3 = card.x + lx3*ca - ly3*sa; var y3 = card.y + lx3*sa + ly3*ca;
        var x4 = card.x + lx4*ca - ly4*sa; var y4 = card.y + lx4*sa + ly4*ca;
        // Bounding box englobante des 4 points
        var card_left = min(min(x1,x2), min(x3,x4));
        var card_right = max(max(x1,x2), max(x3,x4));
        var card_top = min(min(y1,y2), min(y3,y4));
        var card_bottom = max(max(y1,y2), max(y3,y4));
        
        // Zone élargie pour faciliter le clic (marge de 10 pixels)
        var margin = 10;
        card_left -= margin;
        card_right += margin;
        card_top -= margin;
        card_bottom += margin;
        
        // Vérifie si le clic est sur cette carte (avec marge)
        if(mouse_x >= card_left && mouse_x <= card_right && 
           mouse_y >= card_top && mouse_y <= card_bottom) {
            
            show_debug_message("### SacrificeSelector - Clic sur monstre: " + card.name);
            
            // Vérifie si la carte est déjà sélectionnée
            var isSelected = false;
            for(var j = 0; j < array_length(selectedSacrifices); j++) {
                if(selectedSacrifices[j] == card) {
                    isSelected = true;
                    break;
                }
            }
            
            // Ajoute ou retire la carte des sacrifices
            if(isSelected) {
                show_debug_message("### Retrait du sacrifice: " + card.name);
                removeSacrifice(card);
            } else {
                show_debug_message("### Ajout du sacrifice: " + card.name);
                var success = addSacrifice(card);
                if(!success) {
                    show_debug_message("### Impossible d'ajouter ce sacrifice (limite atteinte ou déjà sélectionné)");
                }
            }
            
            return;
        }
    }
}

show_debug_message("### SacrificeSelector - Clic en dehors des éléments interactifs");