/// @description Gestion des interactions du bouton Option

// Hériter de la garde de oButtonBlock
event_inherited();

// Garde directe pour s'assurer du blocage
if (instance_exists(oPanelOptions)) {
    exit;
}

// Assurer une seule instance (persistance) et positionnement par vue
var first = instance_find(oOptionButton, 0);
if (first != id) {
    instance_destroy();
    exit;
}

// Positionner en bas-droit du viewport caméra visible
var cam = noone;
if (view_enabled) {
    for (var i = 0; i < 8; i++) {
        if (view_visible[i]) { cam = view_camera[i]; break; }
    }
}

if (cam == noone) {
    // Fallback: pas de vues -> bas-droit de la room
    x = room_width - margin_x;
    y = room_height - margin_y;
} else {
    var vx = camera_get_view_x(cam);
    var vy = camera_get_view_y(cam);
    var vw = camera_get_view_width(cam);
    var vh = camera_get_view_height(cam);
    x = vx + vw - margin_x;
    y = vy + vh - margin_y;
}

// Placer sur la couche UI si disponible (utiliser l'ID de couche)
var ui_layer = layer_get_id("UI");
if (is_real(ui_layer) && ui_layer != -1) {
    layer_set_instance_layer(id, ui_layer);
}

// Déterminer dimensions pour le survol/clic (cadre réduit de 30%)
var has_sprite = (sprite_index != -1) && (sprite_width > 0) && (sprite_height > 0);
var frame_scale = 0.7; // cadre affiché à 70% dans Draw
var w = has_sprite ? sprite_width * image_xscale * frame_scale : 64 * frame_scale;
var h = has_sprite ? sprite_height * image_yscale * frame_scale : 64 * frame_scale;

// Vérifier si la souris survole le bouton
var mouse_over = point_in_rectangle(mouse_x, mouse_y, 
    x - w/2, 
    y - h/2,
    x + w/2, 
    y + h/2);

// Gestion du survol
if (mouse_over && !hover) {
    hover = true;
    image_alpha = 1.0;
    image_blend = c_ltgray;
} else if (!mouse_over && hover) {
    hover = false;
    image_alpha = 0.8;
    image_blend = c_white;
}

// Gestion du clic
if (mouse_over && mouse_check_button_pressed(mb_left)) {
    pressed = true;
    image_blend = c_gray;
}

if (pressed && mouse_check_button_released(mb_left)) {
    pressed = false;
    if (mouse_over) {
        // Créer/afficher le panneau d’options via l’objet oPanelOptions
        if (!instance_exists(oPanelOptions)) {
            var panel = instance_create_layer(room_width/2, room_height/2, "UI", oPanelOptions);
            panel.image_xscale = 1.0;
            panel.image_yscale = 1.0;
        }
        show_debug_message("Option button clicked - opening oPanelOptions");
    }
    image_blend = hover ? c_ltgray : c_white;
}