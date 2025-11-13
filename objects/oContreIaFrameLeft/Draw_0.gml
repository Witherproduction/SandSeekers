// === oContreIaFrameLeft - Draw Event ===
// Dessine un cadre gris à gauche de l'écran seulement si un bot est sélectionné

// Vérifier si un bot a été sélectionné dans oContreIaGrid
var grid_instance = instance_find(oContreIaGrid, 0);
if (grid_instance == noone || grid_instance.selected_bot == -1) {
    // Aucun bot sélectionné, ne pas dessiner le cadre
    exit;
}

// Configuration du cadre
var frame_width = 400;
var frame_height = room_height;
var frame_x = 0;
var frame_y = 0;

// Couleurs
var frame_color = c_ltgray;
var border_color = c_gray;
var text_color = c_black;
var title_color = c_navy;

// Dessiner le fond du cadre
draw_set_color(frame_color);
draw_rectangle(frame_x, frame_y, frame_x + frame_width, frame_y + frame_height, false);

// Dessiner la bordure droite du cadre
draw_set_color(border_color);
draw_rectangle(frame_x + frame_width - 2, frame_y, frame_x + frame_width, frame_y + frame_height, false);

// Obtenir les informations du bot depuis le système de données
var bot_id = grid_instance.selected_bot;
var bot_info = grid_instance.bot_data[bot_id];
// Rétablir le nom du bot et afficher la thématique dans la description
var theme_name = get_bot_deck_name(bot_info.deck_id);
var bot_name = bot_info.name;
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
// Ajouter l'information de profil
var profile_name = get_bot_deck_profile(bot_info.deck_id);
bot_description = bot_description + "\n\nProfil: " + profile_name;
var bot_deck = bot_info.deck_name;
var bot_difficulty = bot_info.difficulty;

// Position de départ pour le contenu
var content_x = frame_x + 20;
var content_y = frame_y + 30;
var line_height = 25;

// === TITRE ===
draw_set_color(title_color);
draw_set_halign(fa_center);
draw_set_valign(fa_top);
draw_text(frame_x + frame_width/2, content_y, "CONFIGURATION BOT");
content_y += 40;

// === NOM DU BOT ===
draw_set_color(text_color);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_text(content_x, content_y, "Nom:");
draw_set_color(title_color);
draw_text(content_x + 60, content_y, bot_name);
content_y += 40;

// === PORTRAIT DU BOT ===
draw_set_color(c_white);
var portrait_x = content_x;
var portrait_y = content_y;
var portrait_width = 120;
var portrait_height = 120;

// Fond blanc pour le portrait
draw_rectangle(portrait_x, portrait_y, portrait_x + portrait_width, portrait_y + portrait_height, false);

// Bordure du portrait
draw_set_color(border_color);
draw_rectangle(portrait_x, portrait_y, portrait_x + portrait_width, portrait_y + portrait_height, true);

// Texte placeholder
draw_set_color(c_gray);
draw_set_halign(fa_center);
draw_set_valign(fa_middle);
draw_text(portrait_x + portrait_width/2, portrait_y + portrait_height/2, "PORTRAIT\nPLACEHOLDER");

content_y += portrait_height + 30;

// === DESCRIPTION ===
draw_set_color(text_color);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_text(content_x, content_y, "Description:");
content_y += line_height;

// Dessiner la description (simple, sans retour à la ligne automatique)
draw_text_ext(content_x, content_y, bot_description, line_height, frame_width - 40);
content_y += string_height_ext(bot_description, line_height, frame_width - 40);

content_y += 20;

// === DECK UTILISÉ ===
draw_set_color(text_color);
draw_text(content_x, content_y, "Deck:");
draw_set_color(title_color);
// Afficher le nom thématique du deck
var deck_theme_name = "";
switch (bot_info.deck_id) {
    case 1:
        deck_theme_name = "deck rose noir";
        break;
    case 2:
        deck_theme_name = "deck dragon";
        break;
    case 3:
        deck_theme_name = "deck bête";
        break;
    case 4:
        deck_theme_name = "deck mort-vivant";
        break;
    default:
        deck_theme_name = bot_deck;
        break;
}
draw_text(content_x + 60, content_y, deck_theme_name);
content_y += 30;

// --- Sélecteur de difficulté (déplacé ici) ---
draw_set_color(text_color);
draw_text(content_x, content_y, "Difficulté du bot :");

var difficulty_selected = (variable_global_exists("IA_DIFFICULTY") ? global.IA_DIFFICULTY : 0);
var diff_btn_w = 140;
var diff_btn_h = 36;
var btn1_x = content_x;
var btn2_x = content_x + diff_btn_w + 10;
var btn_y  = content_y + 20; // sous le label

var mx = mouse_x;
var my = mouse_y;
var over_btn1 = (mx >= btn1_x && mx <= btn1_x + diff_btn_w && my >= btn_y && my <= btn_y + diff_btn_h);
var over_btn2 = (mx >= btn2_x && mx <= btn2_x + diff_btn_w && my >= btn_y && my <= btn_y + diff_btn_h);

var color_selected = make_color_rgb(100, 150, 255);
var color_hover    = make_color_rgb(200, 200, 200);

var col1 = (difficulty_selected == 0) ? color_selected : c_white;
var col2 = (difficulty_selected == 1) ? color_selected : c_white;
if (over_btn1 && difficulty_selected != 0) col1 = color_hover;
if (over_btn2 && difficulty_selected != 1) col2 = color_hover;

// Bouton Normal
draw_set_color(col1);
draw_rectangle(btn1_x, btn_y, btn1_x + diff_btn_w, btn_y + diff_btn_h, false);
draw_set_color(c_black);
draw_rectangle(btn1_x, btn_y, btn1_x + diff_btn_w, btn_y + diff_btn_h, true);
draw_set_halign(fa_center);
draw_set_valign(fa_middle);
draw_text(btn1_x + diff_btn_w/2, btn_y + diff_btn_h/2, "Normal");

// Bouton Difficile
draw_set_color(col2);
draw_rectangle(btn2_x, btn_y, btn2_x + diff_btn_w, btn_y + diff_btn_h, false);
draw_set_color(c_black);
draw_rectangle(btn2_x, btn_y, btn2_x + diff_btn_w, btn_y + diff_btn_h, true);
draw_set_halign(fa_center);
draw_set_valign(fa_middle);
draw_text(btn2_x + diff_btn_w/2, btn_y + diff_btn_h/2, "Difficile");

content_y = btn_y + diff_btn_h + 20;

// Remettre les alignements par défaut
draw_set_halign(fa_left);
draw_set_valign(fa_top);