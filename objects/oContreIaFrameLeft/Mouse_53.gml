// === oContreIaFrameLeft - Mouse Left Pressed ===
// Gère les clics sur les boutons de difficulté dans le cadre gauche

// Vérifier si un bot a été sélectionné
var grid_instance = instance_find(oContreIaGrid, 0);
if (grid_instance == noone || grid_instance.selected_bot == -1) {
    exit;
}

// Recalculer la disposition exactement comme dans Draw
var frame_width = 400;
var frame_x = 0;
var frame_y = 0;

var content_x = frame_x + 20;
var content_y = frame_y + 30;
var line_height = 25;

// Titre
content_y += 40;

// Nom du bot
content_y += 40;

// Portrait
var portrait_height = 120;
content_y += portrait_height + 30;

// Description
var bot_id = grid_instance.selected_bot;
var bot_info = grid_instance.bot_data[bot_id];
// Utiliser la même description thématique que dans Draw pour cohérence de mise en page
var theme_name = get_bot_deck_name(bot_info.deck_id);
var bot_description = "";
switch (bot_info.deck_id) {
    case 1:
        bot_description = "Un deck Rose noire utilisant uniquement des cartes d'archétype Rose noire";
        break;
    case 2:
        bot_description = "Un deck Dragon axé sur les cartes de genre Dragon";
        break;
    case 3:
        bot_description = "Un deck Bête utilisant principalement des cartes de genre Bête";
        break;
    case 4:
        bot_description = "Un deck Mort-vivant utilisant principalement des cartes de genre Mort-vivant";
        break;
    default:
        bot_description = bot_info.description;
        break;
}
// Ajouter le profil pour un calcul de hauteur identique à l'affichage
var profile_name = get_bot_deck_profile(bot_info.deck_id);
bot_description = bot_description + "\n\nProfil: " + profile_name;

content_y += line_height; // label "Description:"
var desc_h = string_height_ext(bot_description, line_height, frame_width - 40);
content_y += desc_h;
content_y += 20;

// Deck (uniquement le libellé, pas la composition)
content_y += 30;

// Label difficulté à cette position dans Draw, puis boutons en-dessous
var diff_btn_w = 140;
var diff_btn_h = 36;
var btn1_x = content_x;
var btn2_x = content_x + diff_btn_w + 10;
var btn_y  = content_y + 20; // sous le label

var mx = mouse_x;
var my = mouse_y;

// Bouton Normal
if (mx >= btn1_x && mx <= btn1_x + diff_btn_w && my >= btn_y && my <= btn_y + diff_btn_h) {
    global.IA_DIFFICULTY = 0;
    if (variable_global_exists("VERBOSE_LOGS") && global.VERBOSE_LOGS) show_debug_message("Difficulté IA: Normal");
    exit;
}
// Bouton Difficile
if (mx >= btn2_x && mx <= btn2_x + diff_btn_w && my >= btn_y && my <= btn_y + diff_btn_h) {
    global.IA_DIFFICULTY = 1;
    if (variable_global_exists("VERBOSE_LOGS") && global.VERBOSE_LOGS) show_debug_message("Difficulté IA: Difficile");
    exit;
}