// === Zone du cadre GraveyardViewer basée sur sFond centré ===
var sprFond = sFond;
var fondW = sprite_get_width(sprFond);
var fondH = sprite_get_height(sprFond);
var centerX = room_width * 0.5;
var centerY = room_height * 0.5;
// Échelle du viewer augmentée de 10% (doit matcher Draw)
var frameScale = 1.1;
var scaledW = fondW * frameScale;
var scaledH = fondH * frameScale;
var background_x1 = centerX - scaledW * 0.5;
var background_y1 = centerY - scaledH * 0.5;
var background_x2 = centerX + scaledW * 0.5;
var background_y2 = centerY + scaledH * 0.5;

// Si le clic est en dehors du cadre du GraveyardViewer, ne rien faire
if (!(mouse_x >= background_x1 && mouse_x <= background_x2 &&
      mouse_y >= background_y1 && mouse_y <= background_y2)) {
    exit; // Sortir du script pour bloquer le clic
}

// Bouton fermeture (haut-droite du cadre)
var close_margin = 20;
var close_w = 30;
var close_h = 30;
var btn_x1 = background_x2 - close_margin - close_w;
var btn_y1 = background_y1 + close_margin;
var btn_x2 = btn_x1 + close_w;
var btn_y2 = btn_y1 + close_h;

// Si la souris est dans la zone du bouton
if (mouse_x >= btn_x1 && mouse_x <= btn_x2 && mouse_y >= btn_y1 && mouse_y <= btn_y2) {
    // Supprime ce viewer
    instance_destroy();
    global.isGraveyardViewerOpen = false;
}

// Paramètres identiques au draw pour connaître la disposition
var columns = 4;
var rows = 3;
var spacing = 20;
var scale = 0.25;             // Échelle d'affichage des cartes (identique au draw)

var base_card_w = 100; // Default if no cards
var base_card_h = 140; // Default if no cards

if (array_length(linkedGraveyard.cards) > 0) {
    var first_cardData = linkedGraveyard.cards[0];
    base_card_w = sprite_get_width(first_cardData.sprite_index);
    base_card_h = sprite_get_height(first_cardData.sprite_index);
}

// Taille d'une carte pour la détection de clic
var card_w = base_card_w * scale;
var card_h = base_card_h * scale;
var card_w_click = card_w;
var card_h_click = card_h;

// Aligné avec Draw: zone intérieure du cadre
var inner_margin = 40;
var start_x = background_x1 + inner_margin;
var start_y = background_y1 + inner_margin;

// Vérification de sécurité
if (linkedGraveyard == noone || !instance_exists(linkedGraveyard)) {
    return;
}

var list = linkedGraveyard.cards;
var total = array_length(list);

// Si le cimetière est vide, ne rien faire
if (total == 0) {
    return;
}

var count = min(total - scrollIndex, columns * rows);

// Parcourir les cartes affichées et vérifier si la souris est dessus
for (var i = 0; i < count; i++) {
    var col = i mod columns;
    var row = i div columns;

    var draw_x_top_left = start_x + col * (card_w + spacing);
    var draw_y_top_left = start_y + row * (card_h + spacing);

    // Adjust draw_x and draw_y to be the center of the card, as the sprite origin is centered
    var draw_x = draw_x_top_left + card_w / 2;
    var draw_y = draw_y_top_left + card_h / 2;

    // Ajuster la position de la zone cliquable pour la centrer sur la carte affichée
    var click_x = draw_x - card_w_click / 2;
    var click_y = draw_y - card_h_click / 2;

    // Vérifier si la souris est sur la carte en utilisant la zone cliquable
                if (mouse_x >= click_x && mouse_x <= click_x + card_w_click &&
                    mouse_y >= click_y && mouse_y <= click_y + card_h_click) {

            var cardData = list[total - 1 - (i + scrollIndex)];
            
            // Vérifier que les données de carte existent
            if (cardData != undefined) {
                selectedCard = cardData;
                show_debug_message("Carte sélectionnée: " + cardData.name);

                // Désélectionner toute carte actuellement sélectionnée sur le terrain/ main
                // pour éviter deux previews superposés (viewer + sélection terrain)
                if (instance_exists(selectManager)) {
                    selectManager.unSelectAll();
                } else {
                    var sm = instance_find(oSelectManager, 0);
                    if (sm != noone && instance_exists(sm)) {
                        with (sm) { unSelectAll(); }
                    }
                }
            }

            // Optionnel : stopper la boucle une fois la carte sélectionnée
            break;
        }
    }
    // Si aucune carte n'est survolée, réinitialiser selectedCard
    if (selectedCard != noone && (mouse_x < start_x || mouse_x > start_x + columns * (card_w + spacing) ||
        mouse_y < start_y || mouse_y > start_y + rows * (card_h + spacing))) {
        selectedCard = noone;
        }
