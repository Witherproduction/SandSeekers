/// @description Initialisation du panneau d’options
// Position par défaut au centre (peut être surchargée à l’instanciation)
x = room_width * 0.5;
y = room_height * 0.5;

// Échelle et apparence du cadre
image_xscale = 1.0;
image_yscale = 1.0;
image_blend = c_white;
image_alpha = 1.0;

// État interne (placeholder pour futur contenu)
is_open = true;

// Dessiner par-dessus tout
depth = -1000000

// ==== Volume slider (persistant) ====
// Charger la valeur depuis un INI (options.ini), sinon utiliser 100
var _default_vol = variable_global_exists("volume_percent") ? global.volume_percent : 100;
ini_open("options.ini");
var _ini_vol = ini_read_real("audio", "volume_percent", _default_vol);
ini_close();
global.volume_percent = clamp(_ini_vol, 0, 100);

// Copier la valeur globale en local pour l’UI
vol_value = clamp(global.volume_percent, 0, 100);
vol_dragging = false;

// Appliquer le gain maître immédiatement pour synchroniser l’audio
// Conversion 0..100 -> 0.0..1.0
var _gain = vol_value / 100;
audio_master_gain(_gain);

// Initialiser la géométrie du slider pour Draw (avant le premier Step)
var spr = asset_get_index("sFond");
if (spr != -1) {
    var sx = image_xscale;
    var sy = image_yscale;
    var w = sprite_get_width(spr);
    var h = sprite_get_height(spr);
    var ox = sprite_get_xoffset(spr);
    var oy = sprite_get_yoffset(spr);

    // Zone intérieure basée sur le bbox pour cohérence avec Step
    var bboxL = sprite_get_bbox_left(spr);
    var bboxR = sprite_get_bbox_right(spr);
    var bboxT = sprite_get_bbox_top(spr);
    var bboxB = sprite_get_bbox_bottom(spr);
    var content_x1 = x - ox * sx + bboxL * sx;
    var content_y1 = y - oy * sy + bboxT * sy;
    var content_x2 = x - ox * sx + bboxR * sx;
    var content_y2 = y - oy * sy + bboxB * sy;
    var content_w = content_x2 - content_x1;

    var slider_margin_h = 40;
    var slider_shift_x = 100;     // décalage vers la droite (+50 supplémentaire)
    var offset_x = 20;
    var label_w = 80;
    var track_w = (content_w - slider_margin_h * 2 - label_w - offset_x) * 0.6;
    var track_x1 = content_x1 + slider_margin_h + label_w + offset_x + slider_shift_x;
    var track_x2 = track_x1 + track_w;
    var track_y  = content_y1 + 170; // descendre encore plus (140 + 30)

    vol_track_x1 = track_x1;
    vol_track_x2 = track_x2;
    vol_track_y  = track_y;
    vol_label_x  = content_x1 + slider_margin_h + slider_shift_x;
    vol_label_y  = track_y; // aligner au centre de la barre
} else {
    // Valeurs de secours si le sprite n'est pas disponible
    vol_track_x1 = x - 100;
    vol_track_x2 = x + 100;
    vol_track_y  = y - 50;
    vol_label_x  = x - 180;
    vol_label_y  = y - 62;
}

// ==== Plein écran (persistant) ====
// Charger l'état depuis options.ini (section display)
ini_open("options.ini");
var _fs_default = window_get_fullscreen() ? 1 : 0; // se caler sur l'état réel
var _ini_fs = ini_read_real("display", "fullscreen", _fs_default);
ini_close();
fs_enabled = (_ini_fs >= 0.5);
// Appliquer immédiatement
window_set_fullscreen(fs_enabled);

// Initialiser la géométrie du bloc plein écran pour le premier frame Draw
var spr2 = asset_get_index("sFond");
if (spr2 != -1) {
    var sx2 = image_xscale;
    var sy2 = image_yscale;
    var ox2 = sprite_get_xoffset(spr2);
    var oy2 = sprite_get_yoffset(spr2);
    var bboxL2 = sprite_get_bbox_left(spr2);
    var bboxR2 = sprite_get_bbox_right(spr2);
    var bboxT2 = sprite_get_bbox_top(spr2);
    var bboxB2 = sprite_get_bbox_bottom(spr2);
    var content_x1_2 = x - ox2 * sx2 + bboxL2 * sx2;
    var content_y1_2 = y - oy2 * sy2 + bboxT2 * sy2;
    var content_x2_2 = x - ox2 * sx2 + bboxR2 * sx2;
    var content_y2_2 = y - oy2 * sy2 + bboxB2 * sy2;
    var content_w_2 = content_x2_2 - content_x1_2;

    var slider_margin_h = 40;
    var slider_shift_x = 100;
    var fs_top = vol_track_y + 50; // sous le slider volume
    fs_label_x = content_x1_2 + slider_margin_h + slider_shift_x;
    fs_label_y = fs_top;
    var fs_check_size = 18;
    fs_check_x1 = fs_label_x + 150;
    fs_check_y1 = fs_label_y - fs_check_size * 0.5;
    fs_check_x2 = fs_check_x1 + fs_check_size;
    fs_check_y2 = fs_check_y1 + fs_check_size;
    var fs_pad = 8;
    fs_box_x1 = fs_label_x - fs_pad;
    fs_box_y1 = fs_check_y1 - fs_pad;
    fs_box_x2 = fs_check_x2 + fs_pad;
    fs_box_y2 = fs_check_y2 + fs_pad;
} else {
    fs_label_x = x - 100;
    fs_label_y = y + 20;
    fs_check_x1 = fs_label_x + 150;
    fs_check_y1 = fs_label_y - 9;
    fs_check_x2 = fs_check_x1 + 18;
    fs_check_y2 = fs_check_y1 + 18;
    fs_box_x1 = fs_label_x - 8;
    fs_box_y1 = fs_check_y1 - 8;
    fs_box_x2 = fs_check_x2 + 8;
    fs_box_y2 = fs_check_y2 + 8;
}

// ==== Menu déroulant résolution ====
// Liste des résolutions communes
resolution_list = [
    "800x600",
    "1024x768", 
    "1280x720",
    "1366x768",
    "1600x900",
    "1920x1080",
    "2560x1440",
    "3840x2160"
];

// Variables pour le bouton Abandonner (à côté du bouton Retour)
abandon_enabled = (room == rDuel);
abandon_confirm_open = false;
abandon_confirm_block = false;

// Charger la résolution depuis options.ini
ini_open("options.ini");
var _current_w = window_get_width();
var _current_h = window_get_height();
var _default_res = string(_current_w) + "x" + string(_current_h);
var _ini_res = ini_read_string("display", "resolution", _default_res);
ini_close();

// Trouver l'index de la résolution actuelle dans la liste
resolution_selected = 0;
for (var i = 0; i < array_length(resolution_list); i++) {
    if (resolution_list[i] == _ini_res) {
        resolution_selected = i;
        break;
    }
}

// État du menu déroulant
resolution_dropdown_open = false;
resolution_hover_index = -1;

// Initialiser la géométrie du menu déroulant pour le premier frame Draw
var spr3 = asset_get_index("sFond");
if (spr3 != -1) {
    var sx3 = image_xscale;
    var sy3 = image_yscale;
    var ox3 = sprite_get_xoffset(spr3);
    var oy3 = sprite_get_yoffset(spr3);
    var bboxL3 = sprite_get_bbox_left(spr3);
    var bboxR3 = sprite_get_bbox_right(spr3);
    var bboxT3 = sprite_get_bbox_top(spr3);
    var bboxB3 = sprite_get_bbox_bottom(spr3);
    var content_x1_3 = x - ox3 * sx3 + bboxL3 * sx3;
    var content_y1_3 = y - oy3 * sy3 + bboxT3 * sy3;
    var content_x2_3 = x - ox3 * sx3 + bboxR3 * sx3;
    var content_y2_3 = y - oy3 * sy3 + bboxB3 * sy3;
    var content_w_3 = content_x2_3 - content_x1_3;

    var slider_margin_h = 40;
    var slider_shift_x = 100;
    var res_top = fs_box_y2 + 30; // sous le bloc plein écran
    res_label_x = content_x1_3 + slider_margin_h + slider_shift_x;
    res_label_y = res_top;
    var res_dropdown_w = 200;
    var res_dropdown_h = 25;
    res_dropdown_x1 = res_label_x + 120;
    res_dropdown_y1 = res_top - res_dropdown_h * 0.5;
    res_dropdown_x2 = res_dropdown_x1 + res_dropdown_w;
    res_dropdown_y2 = res_dropdown_y1 + res_dropdown_h;
    var res_pad = 8;
    res_box_x1 = res_label_x - res_pad;
    res_box_y1 = res_dropdown_y1 - res_pad;
    res_box_x2 = res_dropdown_x2 + res_pad;
    res_box_y2 = res_dropdown_y2 + res_pad;
} else {
    res_label_x = x - 100;
    res_label_y = y + 80;
    res_dropdown_x1 = res_label_x + 120;
    res_dropdown_y1 = res_label_y - 12;
    res_dropdown_x2 = res_dropdown_x1 + 200;
    res_dropdown_y2 = res_dropdown_y1 + 25;
    res_box_x1 = res_label_x - 8;
    res_box_y1 = res_dropdown_y1 - 8;
    res_box_x2 = res_dropdown_x2 + 8;
    res_box_y2 = res_dropdown_y2 + 8;
}

// ==== Bouton Abandonner (uniquement en room de duel) ====
abandon_enabled = (room == rDuel);
abandon_confirm_open = false;
abandon_btn_x1 = 0; // géométrie initialisée dans Step
abandon_btn_y1 = 0;
abandon_btn_x2 = 0;
abandon_btn_y2 = 0;
// Géométrie du bouton Retour (initialisée dans Step)
retour_btn_x1 = 0;
retour_btn_y1 = 0;
retour_btn_x2 = 0;
retour_btn_y2 = 0;
confirm_box_x1 = 0;
confirm_box_y1 = 0;
confirm_box_x2 = 0;
confirm_box_y2 = 0;
confirm_yes_x1 = 0;
confirm_yes_y1 = 0;
confirm_yes_x2 = 0;
confirm_yes_y2 = 0;
confirm_no_x1 = 0;
confirm_no_y1 = 0;
confirm_no_x2 = 0;
confirm_no_y2 = 0;