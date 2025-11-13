// Objet pour afficher une flèche de ciblage du monstre vers le curseur

// Référence vers la carte source (monstre attaquant)
sourceCard = noone;

// Optionnel: référence vers une cible fixe (monstre équipé)
fixedTargetCard = noone;

// Position de départ (centre du monstre)
startX = 0;
startY = 0;

// Position de fin (curseur)
endX = mouse_x;
endY = mouse_y;

// Propriétés visuelles
lineWidth = 24;  // Flèche plus large (3 fois plus large)
lineColor = c_red;
arrowSize = 48; // Pointe plus grande (3 fois plus grande)

// Transparence
alpha = 1.0; // Flèche complètement opaque

// Profondeur pour afficher au-dessus de l'interface
depth = -3000; // Valeur très négative pour passer au-dessus de tout

// Fonction pour définir la carte source
function setSourceCard(card) {
    sourceCard = card;
    if (instance_exists(sourceCard)) {
        // Calcule le vrai centre de la carte en tenant compte de l'origine du sprite et de l'échelle
        var sprite_center_x = sprite_get_width(sourceCard.sprite_index) / 2 - sprite_get_xoffset(sourceCard.sprite_index);
        var sprite_center_y = sprite_get_height(sourceCard.sprite_index) / 2 - sprite_get_yoffset(sourceCard.sprite_index);
        startX = sourceCard.x + sprite_center_x * sourceCard.image_xscale;
        startY = sourceCard.y + sprite_center_y * sourceCard.image_yscale;
    }
}

// Définit une cible fixe (par exemple, le monstre équipé)
function setFixedTarget(card) {
    fixedTargetCard = card;
}

// Fonction pour mettre à jour la position de fin
function updateTarget() {
    // Si une cible fixe est définie et existe, pointer vers son centre
    if (fixedTargetCard != noone && instance_exists(fixedTargetCard)) {
        var sprite_center_x_t = sprite_get_width(fixedTargetCard.sprite_index) / 2 - sprite_get_xoffset(fixedTargetCard.sprite_index);
        var sprite_center_y_t = sprite_get_height(fixedTargetCard.sprite_index) / 2 - sprite_get_yoffset(fixedTargetCard.sprite_index);
        endX = fixedTargetCard.x + sprite_center_x_t * fixedTargetCard.image_xscale;
        endY = fixedTargetCard.y + sprite_center_y_t * fixedTargetCard.image_yscale;
    } else {
        // Sinon, suivre le curseur
        endX = mouse_x;
        endY = mouse_y;
    }
}

// Fonction pour dessiner la flèche
function drawArrow() {
    if (!instance_exists(sourceCard)) return;
    // Si une cible fixe est définie mais n'existe plus, détruire l'instance de flèche
    if (fixedTargetCard != noone && !instance_exists(fixedTargetCard)) {
        instance_destroy();
        return;
    }
    
    // Mettre à jour les positions avec le vrai centre de la carte
    var sprite_center_x = sprite_get_width(sourceCard.sprite_index) / 2 - sprite_get_xoffset(sourceCard.sprite_index);
    var sprite_center_y = sprite_get_height(sourceCard.sprite_index) / 2 - sprite_get_yoffset(sourceCard.sprite_index);
    startX = sourceCard.x + sprite_center_x * sourceCard.image_xscale;
    startY = sourceCard.y + sprite_center_y * sourceCard.image_yscale;
    updateTarget();
    
    // Calculer l'angle et la distance
    var angle = point_direction(startX, startY, endX, endY);
    var distance = point_distance(startX, startY, endX, endY);
    
    // Ne dessiner que si la distance est suffisante
    if (distance > 20) {
        draw_set_alpha(alpha);
        
        // Calculer le point d'arrêt de la ligne (avant la pointe)
        var lineEndX = endX + lengthdir_x(-arrowSize * 0.7, angle);
        var lineEndY = endY + lengthdir_y(-arrowSize * 0.7, angle);
        
        // Dessiner la ligne principale
        draw_set_color(lineColor);
        for (var i = 0; i < lineWidth; i++) {
            draw_line(startX + i - lineWidth/2, startY, lineEndX + i - lineWidth/2, lineEndY);
        }
        
        // Dessiner la pointe de la flèche
        var arrowX1 = endX + lengthdir_x(-arrowSize, angle + 30);
        var arrowY1 = endY + lengthdir_y(-arrowSize, angle + 30);
        var arrowX2 = endX + lengthdir_x(-arrowSize, angle - 30);
        var arrowY2 = endY + lengthdir_y(-arrowSize, angle - 30);
        
        draw_triangle(endX, endY, arrowX1, arrowY1, arrowX2, arrowY2, false);
        
        draw_set_alpha(1);
        draw_set_color(c_white); // Restaure la couleur par défaut
    }
}