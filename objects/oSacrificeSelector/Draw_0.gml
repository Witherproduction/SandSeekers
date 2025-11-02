// Ne dessine que si le sélecteur est visible
if(!visible) return;

// === INDICATEURS VISUELS SUR LES MONSTRES ===
// Dessine d'abord les indicateurs sur les monstres sélectionnables
var nbCards = instance_number(oCardParent);
for(var i = 0; i < nbCards; i++) {
    var card = instance_find(oCardParent, i);
    
    // Vérifie si c'est un monstre sur le terrain du joueur
    if(card.type == "Monster" && card.zone == "Field" && card.isHeroOwner) {
        
        // Vérifie si la carte est sélectionnée
        var isSelected = false;
        for(var j = 0; j < array_length(selectedSacrifices); j++) {
            if(selectedSacrifices[j] == card) {
                isSelected = true;
                break;
            }
        }
        
        // Vérifie si on peut encore sélectionner des sacrifices
        var canSelect = (array_length(selectedSacrifices) < requiredSacrificeCount);
        
        // Dessine un contour coloré autour du monstre
        if(isSelected) {
            // Contour vert pour les monstres sélectionnés
            draw_set_color(c_lime);
            draw_set_alpha(0.8);
            var thickness = 4;
            // Calcule les bords réels et applique l’angle du sprite
            var spr = card.sprite_index;
            var w = sprite_get_width(spr) * card.image_xscale;
            var h = sprite_get_height(spr) * card.image_yscale;
            var xoff = sprite_get_xoffset(spr) * card.image_xscale;
            var yoff = sprite_get_yoffset(spr) * card.image_yscale;
            var ang = card.image_angle;
            var ca = dcos(ang);
            var sa = dsin(ang);
            for(var t = 0; t < thickness; t++) {
                var w_t = w + 2*t;
                var h_t = h + 2*t;
                var xoff_t = xoff + t;
                var yoff_t = yoff + t;
                // Coins locaux avant rotation
                var lx1 = -xoff_t, ly1 = -yoff_t;
                var lx2 =  w_t - xoff_t, ly2 = -yoff_t;
                var lx3 =  w_t - xoff_t, ly3 =  h_t - yoff_t;
                var lx4 = -xoff_t,         ly4 =  h_t - yoff_t;
                // Applique la rotation et translate vers la position de la carte
                var x1 = card.x + lx1*ca - ly1*sa; var y1 = card.y + lx1*sa + ly1*ca;
                var x2 = card.x + lx2*ca - ly2*sa; var y2 = card.y + lx2*sa + ly2*ca;
                var x3 = card.x + lx3*ca - ly3*sa; var y3 = card.y + lx3*sa + ly3*ca;
                var x4 = card.x + lx4*ca - ly4*sa; var y4 = card.y + lx4*sa + ly4*ca;
                // Trace le contour
                draw_line(x1, y1, x2, y2);
                draw_line(x2, y2, x3, y3);
                draw_line(x3, y3, x4, y4);
                draw_line(x4, y4, x1, y1);
            }
        } else if(canSelect) {
            // Contour jaune pour les monstres sélectionnables
            draw_set_color(c_yellow);
            draw_set_alpha(0.6);
            var thickness = 2;
            // Calcule les bords réels et applique l’angle du sprite
            var spr2 = card.sprite_index;
            var w2 = sprite_get_width(spr2) * card.image_xscale;
            var h2 = sprite_get_height(spr2) * card.image_yscale;
            var xoff2 = sprite_get_xoffset(spr2) * card.image_xscale;
            var yoff2 = sprite_get_yoffset(spr2) * card.image_yscale;
            var ang2 = card.image_angle;
            var ca2 = dcos(ang2);
            var sa2 = dsin(ang2);
            for(var t2 = 0; t2 < thickness; t2++) {
                var w2_t = w2 + 2*t2;
                var h2_t = h2 + 2*t2;
                var xoff2_t = xoff2 + t2;
                var yoff2_t = yoff2 + t2;
                var lx1b = -xoff2_t, ly1b = -yoff2_t;
                var lx2b =  w2_t - xoff2_t, ly2b = -yoff2_t;
                var lx3b =  w2_t - xoff2_t, ly3b =  h2_t - yoff2_t;
                var lx4b = -xoff2_t,         ly4b =  h2_t - yoff2_t;
                var x1b = card.x + lx1b*ca2 - ly1b*sa2; var y1b = card.y + lx1b*sa2 + ly1b*ca2;
                var x2b = card.x + lx2b*ca2 - ly2b*sa2; var y2b = card.y + lx2b*sa2 + ly2b*ca2;
                var x3b = card.x + lx3b*ca2 - ly3b*sa2; var y3b = card.y + lx3b*sa2 + ly3b*ca2;
                var x4b = card.x + lx4b*ca2 - ly4b*sa2; var y4b = card.y + lx4b*sa2 + ly4b*ca2;
                draw_line(x1b, y1b, x2b, y2b);
                draw_line(x2b, y2b, x3b, y3b);
                draw_line(x3b, y3b, x4b, y4b);
                draw_line(x4b, y4b, x1b, y1b);
            }
        }
        
        // Le cadre réagit au survol/clic: suppression du bouton additionnel "+"/"✓".
    }
}

// === FENÊTRE PRINCIPALE ===
// Utilise le sprite d'interface réduit et positionne au-dessus du centre
var uiSprite = sFond;
var scaleX = 0.5; // échelle horizontale du cadre
var scaleY = 0.5; // échelle verticale du cadre
var baseW = sprite_get_width(uiSprite);
var baseH = sprite_get_height(uiSprite);
var frameW = baseW * scaleX;
var frameH = baseH * scaleY;
var windowX = (room_width - frameW) / 2;
var windowY = (room_height - frameH) / 2 - 210; // Encore plus haut dans l'écran

// Dessine le sprite de fond réduit, en ancrant correctement le coin haut-gauche
var xoff = sprite_get_xoffset(uiSprite);
var yoff = sprite_get_yoffset(uiSprite);
draw_sprite_ext(uiSprite, 0, windowX + xoff * scaleX, windowY + yoff * scaleY, scaleX, scaleY, 0, c_white, 1);

// Texte principal
draw_set_color(c_white);
draw_set_font(fontCardDisplay);
draw_set_halign(fa_center);
draw_set_valign(fa_middle);

// Marges internes et titre
var paddingTop = 16;
var paddingBottom = 16;
var paddingSide = 16;

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
var contentH = contentY2 - contentY1;

var titleYOffset = 48; // décale encore le texte vers le bas
var titleY = contentY1 + paddingTop + titleYOffset;
draw_text(contentX1 + contentW/2, titleY, "Choisir les sacrifices");

// Compteur de sacrifices
var progressText = "Sacrifices: " + string(array_length(selectedSacrifices)) + "/" + string(requiredSacrificeCount);
draw_set_color(array_length(selectedSacrifices) >= requiredSacrificeCount ? c_lime : c_white);
var progressY = titleY + 24;
draw_text(contentX1 + contentW/2, progressY, progressText);

// === BOUTONS ===
// Dimensions des boutons adaptées au cadre réduit (définies avant usage)
var btnWidth = 100;
var btnHeight = 30;

// Calcule les positions des boutons dans le cadre réduit (ancrés à la zone intérieure)
var btnGap = 20;
var buttonLift = 48; // remonte encore les boutons
var buttonsY = contentY2 - paddingBottom - buttonLift - btnHeight/2;
var confirmBtnX = contentX1 + contentW/2 - (btnWidth/2 + btnGap/2);
var confirmBtnY = buttonsY;
var cancelBtnX = contentX1 + contentW/2 + (btnWidth/2 + btnGap/2);
var cancelBtnY = buttonsY;

// Bouton Confirmer (actif seulement si assez de sacrifices)
var canConfirm = (array_length(selectedSacrifices) >= requiredSacrificeCount);

// Bouton Confirmer
draw_set_color(canConfirm ? c_green : c_dkgray);
draw_rectangle(confirmBtnX - btnWidth/2, confirmBtnY - btnHeight/2, 
               confirmBtnX + btnWidth/2, confirmBtnY + btnHeight/2, false);
draw_set_color(c_white);
draw_rectangle(confirmBtnX - btnWidth/2, confirmBtnY - btnHeight/2, 
               confirmBtnX + btnWidth/2, confirmBtnY + btnHeight/2, true);

// Bouton Annuler
draw_set_color(c_red);
draw_rectangle(cancelBtnX - btnWidth/2, cancelBtnY - btnHeight/2, 
               cancelBtnX + btnWidth/2, cancelBtnY + btnHeight/2, false);
draw_set_color(c_white);
draw_rectangle(cancelBtnX - btnWidth/2, cancelBtnY - btnHeight/2, 
               cancelBtnX + btnWidth/2, cancelBtnY + btnHeight/2, true);

// Texte des boutons
draw_set_color(c_white);
draw_set_halign(fa_center);
draw_set_valign(fa_middle);
draw_text(confirmBtnX, confirmBtnY, "Confirmer");
draw_text(cancelBtnX, cancelBtnY, "Annuler");

// Réinitialise les paramètres de dessin
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_alpha(1);