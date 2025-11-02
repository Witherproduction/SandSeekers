// === Barre de tri a cote du filtre ===

// Position et dimensions (elargie pour 7 boutons + bouton d'inversion)
var barWidth = 920; // Plus long pour un changement net
var barHeight = 90; // Hauteur augmentée pour un fond plus lisible
var barX = 310; // Décalé vers la gauche pour étendre par la gauche
var barY = room_height - 130; // Descendu légèrement pour meilleure position

// Dessiner le fond de la barre avec le sprite sButton (étiré sur la largeur/hauteur)
draw_sprite_stretched(sButton, 0, barX, barY, barWidth, barHeight);

// Parametres des boutons
var buttonRadius = 15; // Plus petit pour s'adapter
var buttonSpacing = 60; // Espacement légèrement réduit
// Centrer les 7 boutons + le bouton d'inversion dans la barre
var totalButtonsWidth = (7 * buttonSpacing) + (2 * buttonRadius);
var startX = barX + (barWidth - totalButtonsWidth) / 2 + buttonRadius;
var buttonY = barY + barHeight / 2;

// Couleurs (thème UI, comme les autres boutons)
var bubble_normal_color = make_color_rgb(60, 45, 25);    // marron foncé
var bubble_active_color = make_color_rgb(120, 90, 45);   // marron clair (état actif)
var border_color = make_color_rgb(230, 200, 120);        // crème dorée
var text_shadow_color = make_color_rgb(80, 50, 20);      // ombre portée
var text_main_color = make_color_rgb(230, 200, 120);     // texte crème dorée

// Dessiner les 7 boutons ronds (ajout du tri alphabétique)
var buttons = ["attack", "defense", "level", "type", "favorites", "rarity", "alpha"];
var buttonLabels = ["ATK", "DEF", "LVL", "TYPE", "FAV", "RAR", "A-Z"];

// Configurer le texte
draw_set_font(fontCardDisplay);
draw_set_halign(fa_center);
draw_set_valign(fa_middle);
var textScale = 0.85; // Réduction légère de la taille du texte

for (var i = 0; i < 7; i++) {
    var buttonX = startX + (i * buttonSpacing);
    
    // Verifier si ce bouton est actif
    var isActive = (sort_active_button == i);
    
    // Dessiner le cercle du bouton (couleur differente si actif)
    draw_set_color(isActive ? bubble_active_color : bubble_normal_color);
    draw_circle(buttonX, buttonY, buttonRadius, false);
    
    // Dessiner la bordure
    draw_set_color(border_color);
    draw_circle(buttonX, buttonY, buttonRadius, true);
    
    // Dessiner le texte (réduit) : ombre puis texte crème dorée
    draw_set_color(text_shadow_color);
    draw_text_transformed(buttonX + 2, buttonY + 2, buttonLabels[i], textScale, textScale, 0);
    draw_set_color(text_main_color);
    draw_text_transformed(buttonX, buttonY, buttonLabels[i], textScale, textScale, 0);
}

// Dessiner le bouton d'inversion de tri
var invertButtonX = startX + (7 * buttonSpacing);
draw_set_color(bubble_normal_color);
draw_circle(invertButtonX, buttonY, buttonRadius, false);
draw_set_color(border_color);
draw_circle(invertButtonX, buttonY, buttonRadius, true);

// Dessiner le symbole d'inversion (flèche haut/bas)
draw_set_color(text_main_color);
if (global.sort_descending) {
    // Flèche vers le bas (tri décroissant)
    draw_line(invertButtonX - 5, buttonY - 5, invertButtonX, buttonY + 5);
    draw_line(invertButtonX + 5, buttonY - 5, invertButtonX, buttonY + 5);
} else {
    // Flèche vers le haut (tri croissant)
    draw_line(invertButtonX - 5, buttonY + 5, invertButtonX, buttonY - 5);
    draw_line(invertButtonX + 5, buttonY + 5, invertButtonX, buttonY - 5);
}

draw_set_font(fontCardDisplay);
draw_set_halign(fa_center);
draw_set_valign(fa_middle);


// Remettre les parametres par defaut
draw_set_color(c_white);
draw_set_halign(fa_left);
draw_set_valign(fa_top);