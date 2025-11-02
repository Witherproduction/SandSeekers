// Global Mouse Left Pressed Event (dans oGraveyard)
if (global.isGraveyardViewerOpen) exit;
// Vérifier d'abord si le clic est sur un bouton UI
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

// Si aucun bouton UI n'est cliqué, traiter le clic du cimetière
if (!uiButtonClicked && point_in_rectangle(mouse_x, mouse_y, x - 32, y - 32, x + 32, y + 32)) {
    show_debug_message("Graveyard clicked");
    
    // Vérifier si le cimetière contient des cartes
    if (array_length(cards) > 0) {
        // Crée la fenêtre de visualisation du cimetière
        var viewer = instance_create_layer(x, y, "Instances", oGraveyardViewer);
global.isGraveyardViewerOpen = true;
        viewer.linkedGraveyard = id; // Donne à l'instance de viewer un accès au bon cimetière
    } else {
        show_debug_message("Cimetière vide - aucune carte à afficher");
    }
}