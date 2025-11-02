// === Affichage de l'Interface de Création de Cartes ===

// Fond de l'interface (fond gris)
draw_set_color(c_gray);
draw_set_alpha(0.9);
draw_rectangle(ui_x, ui_y, ui_x + ui_width, ui_y + ui_height, false);
draw_set_alpha(1);

// Titre
// === AFFICHAGE DE LA LISTE DES CARTES ===
if (show_card_list) {
    var list_width = 390;
    var item_height = 60;
    var visible_items = min(8, array_length(card_list));
    var list_height = visible_items * item_height + 80;
    var list_x = (room_width - list_width) / 2;
    var list_y = (room_height - list_height) / 2;
    
    // Fond de la liste
    draw_set_color(c_black);
    draw_set_alpha(0.8);
    draw_rectangle(list_x - 10, list_y - 40, list_x + list_width, list_y + list_height, false);
    draw_set_alpha(1);
    
    // Bordure
    draw_set_color(c_white);
    draw_rectangle(list_x - 10, list_y - 40, list_x + list_width, list_y + list_height, true);
    
    // Titre
    draw_set_color(c_yellow);
    draw_set_halign(fa_center);
    draw_text(list_x + list_width/2, list_y - 30, "LISTE DES CARTES");
    draw_set_halign(fa_left);
    
    // Chemin sélection: Booster > Archétype
    draw_set_color(c_yellow);
    draw_set_halign(fa_left);
    var breadcrumb = "Booster: " + (booster_selected == "" ? "(aucun)" : booster_selected) + "  >  Archétype: " + list_archetype_filter;
    draw_text(list_x + 5, list_y - 5, breadcrumb);
    
    // Boutons de scroll
    if (array_length(card_list) > visible_items) {
        var scroll_btn_x = list_x + 180;
        var scroll_up_y = list_y - 30;
        var scroll_down_y = list_y + (visible_items * item_height) + 10;
        var scroll_btn_w = 40;
        var scroll_btn_h = 20;
        
        // Bouton scroll up
        draw_set_color(card_list_scroll > 0 ? c_lime : c_gray);
        draw_rectangle(scroll_btn_x, scroll_up_y, scroll_btn_x + scroll_btn_w, scroll_up_y + scroll_btn_h, false);
        draw_set_color(c_black);
        draw_rectangle(scroll_btn_x, scroll_up_y, scroll_btn_x + scroll_btn_w, scroll_up_y + scroll_btn_h, true);
        draw_set_halign(fa_center);
        draw_text(scroll_btn_x + scroll_btn_w/2, scroll_up_y + 5, "↑");
        
        // Bouton scroll down
        draw_set_color(card_list_scroll < array_length(card_list) - visible_items ? c_lime : c_gray);
        draw_rectangle(scroll_btn_x, scroll_down_y, scroll_btn_x + scroll_btn_w, scroll_down_y + scroll_btn_h, false);
        draw_set_color(c_black);
        draw_rectangle(scroll_btn_x, scroll_down_y, scroll_btn_x + scroll_btn_w, scroll_down_y + scroll_btn_h, true);
        draw_text(scroll_btn_x + scroll_btn_w/2, scroll_down_y + 5, "↓");
        draw_set_halign(fa_left);
    }
    
    // Affichage des cartes
    for (var i = 0; i < visible_items; i++) {
        var card_index = i + card_list_scroll;
        if (card_index >= array_length(card_list)) break;
        
        var card = card_list[card_index];
        var item_y = list_y + (i * item_height);
        
        // Fond de l'item
        draw_set_color(i % 2 == 0 ? c_dkgray : c_gray);
        draw_rectangle(list_x, item_y, list_x + list_width - 20, item_y + item_height - 5, false);
        
        // Bordure de l'item
        draw_set_color(c_white);
        draw_rectangle(list_x, item_y, list_x + list_width - 20, item_y + item_height - 5, true);
        
        // Informations de la carte
        draw_set_color(c_white);
        draw_text(list_x + 5, item_y + 5, "ID: " + card.id);
        draw_text(list_x + 5, item_y + 20, "Nom: " + card.name);
        draw_text(list_x + 5, item_y + 35, "Type: " + card.type);
        
        // Bouton Modifier
        var edit_btn_x = list_x + 250;
        var edit_btn_y = item_y + 5;
        var edit_btn_w = 60;
        var edit_btn_h = 25;
        
        draw_set_color(c_blue);
        draw_rectangle(edit_btn_x, edit_btn_y, edit_btn_x + edit_btn_w, edit_btn_y + edit_btn_h, false);
        draw_set_color(c_white);
        draw_rectangle(edit_btn_x, edit_btn_y, edit_btn_x + edit_btn_w, edit_btn_y + edit_btn_h, true);
        draw_set_halign(fa_center);
        draw_text(edit_btn_x + edit_btn_w/2, edit_btn_y + 8, "Modifier");
        
        // Bouton Supprimer
        var del_btn_x = list_x + 320;
        var del_btn_y = item_y + 5;
        var del_btn_w = 70;
        var del_btn_h = 25;
        
        draw_set_color(c_red);
        draw_rectangle(del_btn_x, del_btn_y, del_btn_x + del_btn_w, del_btn_y + del_btn_h, false);
        draw_set_color(c_white);
        draw_rectangle(del_btn_x, del_btn_y, del_btn_x + del_btn_w, del_btn_y + del_btn_h, true);
        draw_text(del_btn_x + del_btn_w/2, del_btn_y + 8, "Supprimer");
        draw_set_halign(fa_left);
    }
    
    // Message si aucune carte
    if (array_length(card_list) == 0) {
        draw_set_color(c_yellow);
        draw_set_halign(fa_center);
        draw_text(list_x + list_width/2, list_y + 50, "Aucune carte trouvée");
        draw_set_halign(fa_left);
    }
}

draw_set_color(c_white);
draw_set_font(fontCardDisplay);
draw_text(ui_x + 80, ui_y + 25, "=== CRÉATEUR DE CARTES ===");

// === BOUTONS DE TYPE DE CARTE ===
draw_set_font(fontCardDisplay);

// Bouton Monstre
var btn = buttons.type_monster;
draw_set_color(card_type == "Monster" ? c_lime : c_gray);
draw_rectangle(btn.x, btn.y, btn.x + btn.width, btn.y + btn.height, false);
draw_set_color(c_black);
draw_rectangle(btn.x, btn.y, btn.x + btn.width, btn.y + btn.height, true);
draw_set_halign(fa_center);
draw_text(btn.x + btn.width/2, btn.y + 8, btn.text);

// Bouton Magie
btn = buttons.type_magic;
draw_set_color(card_type == "Magic" ? c_lime : c_gray);
draw_rectangle(btn.x, btn.y, btn.x + btn.width, btn.y + btn.height, false);
draw_set_color(c_black);
draw_rectangle(btn.x, btn.y, btn.x + btn.width, btn.y + btn.height, true);
draw_text(btn.x + btn.width/2, btn.y + 8, btn.text);

draw_set_halign(fa_left);

// === CHAMPS DE SAISIE ===
draw_set_color(c_white);
var field_names = variable_struct_get_names(field_positions);

for (var i = 0; i < array_length(field_names); i++) {
    var field_name = field_names[i];
    var field = field_positions[$ field_name];
    
    // Afficher seulement les champs pertinents selon le type
    if (card_type == "Magic" && (field_name == "attack" || field_name == "defense" || field_name == "star")) {
        continue;
    }
    
    // Label du champ
    draw_text(field.x, field.y - 25, field.label);
    
    // Fond du champ
    draw_set_color(active_field == field_name ? c_yellow : c_white);
    draw_rectangle(field.x, field.y, field.x + field.width, field.y + field.height, false);
    
    // Bordure du champ
    draw_set_color(c_black);
    draw_rectangle(field.x, field.y, field.x + field.width, field.y + field.height, true);
    
    // Texte du champ
    draw_set_color(c_black);
    var text_to_draw = input_fields[$ field_name];
    
    // Gestion du curseur clignotant
    if (active_field == field_name && cursor_blink_timer < 30) {
        text_to_draw += "|";
    }
    
    // Affichage du texte avec gestion de la zone
    if (field_name == "description") {
        // Zone de texte multiligne pour la description
        draw_text_ext(field.x + 5, field.y + 5, text_to_draw, 15, field.width - 10);
    } else {
        draw_text(field.x + 5, field.y + 5, text_to_draw);
    }
}

// === BOUTONS DE RARETÉ ===
draw_set_color(c_white);
draw_text(ui_x + 80, ui_y + 580, "Rareté:");

var rarity_buttons = ["rarity_commun", "rarity_rare", "rarity_epique", "rarity_legendaire"];
for (var i = 0; i < array_length(rarity_buttons); i++) {
    var btn_name = rarity_buttons[i];
    btn = buttons[$ btn_name];
    
    // Couleur selon la rareté sélectionnée
    var is_selected = (selected_rarity == btn.rarity);
    draw_set_color(is_selected ? getRarityColor(btn.rarity) : c_gray);
    draw_rectangle(btn.x, btn.y, btn.x + btn.width, btn.y + btn.height, false);
    
    draw_set_color(c_black);
    draw_rectangle(btn.x, btn.y, btn.x + btn.width, btn.y + btn.height, true);
    
    draw_set_halign(fa_center);
    draw_set_color(is_selected ? c_white : c_black);
    draw_text(btn.x + btn.width/2, btn.y + 5, btn.text);
}

draw_set_halign(fa_left);

// === BOUTONS D'ACTION ===
var action_buttons = ["create_card", "cancel", "load_card", "back_to_menu"];
for (var i = 0; i < array_length(action_buttons); i++) {
    var btn_name = action_buttons[i];
    btn = buttons[$ btn_name];
    
    // Couleur du bouton
    switch(btn_name) {
        case "create_card":
            draw_set_color(editing_mode ? c_yellow : c_lime);
            break;
        case "cancel":
            draw_set_color(c_orange);
            break;
        case "load_card":
            draw_set_color(c_aqua);
            break;
        case "back_to_menu":
            draw_set_color(c_red);
            break;
    }
    
    draw_rectangle(btn.x, btn.y, btn.x + btn.width, btn.y + btn.height, false);
    draw_set_color(c_black);
    draw_rectangle(btn.x, btn.y, btn.x + btn.width, btn.y + btn.height, true);
    
    draw_set_halign(fa_center);
    var display_text = btn.text;
    if (btn_name == "create_card" && editing_mode) {
        display_text = "Mettre à jour";
    }
    draw_text(btn.x + btn.width/2, btn.y + 12, display_text);
}

draw_set_halign(fa_left);

// === APERÇU DE LA CARTE ===
if (show_preview) {
    // Cadre de l'aperçu (gris) plus grand
    var preview_w = 360;
    var preview_h = 480;
    draw_set_color(c_dkgray);
    draw_rectangle(preview_x, preview_y, preview_x + preview_w, preview_y + preview_h, false);

    var preview_y_offset = preview_y + 16;

    // Titre
    draw_set_color(c_white);
    draw_set_font(fontCardDisplay);
    draw_text(preview_x + 10, preview_y_offset, "Aperçu de la carte");
    preview_y_offset += 24;

    draw_set_font(fontCardDisplay);

    // Nom et type
    draw_set_color(c_white);
    var name_text = "Nom: " + string(input_fields.name);
    draw_text_ext(preview_x + 10, preview_y_offset, name_text, 14, preview_w - 20);
    var name_h = string_height_ext(name_text, 14, preview_w - 20);
    preview_y_offset += name_h + 4;

    draw_text(preview_x + 10, preview_y_offset, "Type: " + string(card_type));
    preview_y_offset += 18;

    // Aperçu graphique du sprite de la carte (centré sur l'écran)
    if (is_string(input_fields.sprite) && string_length(input_fields.sprite) > 0) {
        var spr_id = asset_get_index(input_fields.sprite);
        if (spr_id != -1 && sprite_exists(spr_id)) {
            var spr_w = sprite_get_width(spr_id);
            var spr_h = sprite_get_height(spr_id);
            var box_w = 180;
            var box_h = 240;
            var scale = min(box_w / spr_w, box_h / spr_h) * 2; // taille doublée
            var center_x = ui_x + ui_width * 0.5;
            var center_y = ui_y + ui_height * 0.5;
            var xoff = sprite_get_xoffset(spr_id);
            var yoff = sprite_get_yoffset(spr_id);
            var draw_x = center_x + xoff * scale - spr_w * scale * 0.5;
            var draw_y = center_y + yoff * scale - spr_h * scale * 0.5;
            draw_sprite_ext(spr_id, 0, draw_x, draw_y, scale, scale, 0, c_white, 1);
        }
    }

    // Stats basiques
    draw_text(preview_x + 10, preview_y_offset, "ATK: " + string(input_fields.attack));
    preview_y_offset += 18;
    draw_text(preview_x + 10, preview_y_offset, "DEF: " + string(input_fields.defense));
    preview_y_offset += 18;

    // Description (avec retour à la ligne)
    var desc_text = "Desc: " + string(input_fields.description);
    draw_text_ext(preview_x + 10, preview_y_offset, desc_text, 14, preview_w - 20);
    var desc_h = string_height_ext(desc_text, 14, preview_w - 20);
    preview_y_offset += desc_h + 6;

    // Statut du sprite
    var spr_status = (is_string(input_fields.sprite) && string_length(input_fields.sprite) > 0) ? "Sprite: " + string(input_fields.sprite) : "Sprite: (aucun)";
    draw_text(preview_x + 10, preview_y_offset, spr_status);
    preview_y_offset += 18;
}

// === AFFICHAGE DE LA SÉLECTION DE BOOSTER ===
if (show_booster_list) {
    var booster_width = 300;
    var booster_item_height = 50;
    var visible_boosters = min(10, array_length(booster_list));
    var booster_list_height = visible_boosters * booster_item_height + 60;
    var booster_x = (room_width - booster_width) / 2;
    var booster_y = (room_height - booster_list_height) / 2;

    // Fond
    draw_set_color(c_black);
    draw_set_alpha(0.8);
    draw_rectangle(booster_x - 10, booster_y - 40, booster_x + booster_width, booster_y + booster_list_height, false);
    draw_set_alpha(1);

    // Bordure
    draw_set_color(c_white);
    draw_rectangle(booster_x - 10, booster_y - 40, booster_x + booster_width, booster_y + booster_list_height, true);

    // Titre
    draw_set_color(c_yellow);
    draw_set_halign(fa_center);
    draw_text(booster_x + booster_width/2, booster_y - 30, "SÉLECTIONNE UN BOOSTER");
    draw_set_halign(fa_left);

    // Boutons de scroll
    if (array_length(booster_list) > visible_boosters) {
        var scroll_btn_x = booster_x + 130;
        var scroll_up_y = booster_y - 30;
        var scroll_down_y = booster_y + (visible_boosters * booster_item_height) + 10;
        var scroll_btn_w = 40;
        var scroll_btn_h = 20;

        draw_set_color(booster_list_scroll > 0 ? c_lime : c_gray);
        draw_rectangle(scroll_btn_x, scroll_up_y, scroll_btn_x + scroll_btn_w, scroll_up_y + scroll_btn_h, false);
        draw_set_color(c_black);
        draw_rectangle(scroll_btn_x, scroll_up_y, scroll_btn_x + scroll_btn_w, scroll_up_y + scroll_btn_h, true);
        draw_set_halign(fa_center);
        draw_text(scroll_btn_x + scroll_btn_w/2, scroll_up_y + 5, "↑");

        draw_set_color(booster_list_scroll < array_length(booster_list) - visible_boosters ? c_lime : c_gray);
        draw_rectangle(scroll_btn_x, scroll_down_y, scroll_btn_x + scroll_btn_w, scroll_down_y + scroll_btn_h, false);
        draw_set_color(c_black);
        draw_rectangle(scroll_btn_x, scroll_down_y, scroll_btn_x + scroll_btn_w, scroll_down_y + scroll_btn_h, true);
        draw_text(scroll_btn_x + scroll_btn_w/2, scroll_down_y + 5, "↓");
        draw_set_halign(fa_left);
    }

    // Items booster
    for (var i = 0; i < visible_boosters; i++) {
        var boost_index = i + booster_list_scroll;
        if (boost_index >= array_length(booster_list)) break;
        var item_y = booster_y + (i * booster_item_height);
        var label = booster_list[boost_index];

        draw_set_color(i % 2 == 0 ? c_dkgray : c_gray);
        draw_rectangle(booster_x, item_y, booster_x + booster_width, item_y + booster_item_height - 5, false);
        draw_set_color(c_white);
        draw_rectangle(booster_x, item_y, booster_x + booster_width, item_y + booster_item_height - 5, true);
        draw_set_color(c_white);
        draw_text(booster_x + 10, item_y + 15, label);
    }

    if (array_length(booster_list) == 0) {
        draw_set_color(c_yellow);
        draw_set_halign(fa_center);
        draw_text(booster_x + booster_width/2, booster_y + 30, "Aucun booster trouvé");
        draw_set_halign(fa_left);
    }
}
// === AFFICHAGE DE LA SÉLECTION D'ARCHÉTYPE ===
if (show_archetype_list) {
    var arch_width = 300;
    var arch_item_height = 50;
    var visible_arch = min(10, array_length(archetype_list));
    var arch_list_height = visible_arch * arch_item_height + 60;
    var arch_x = (room_width - arch_width) / 2;
    var arch_y = (room_height - arch_list_height) / 2;

    // Fond
    draw_set_color(c_black);
    draw_set_alpha(0.8);
    draw_rectangle(arch_x - 10, arch_y - 40, arch_x + arch_width, arch_y + arch_list_height, false);
    draw_set_alpha(1);

    // Bordure
    draw_set_color(c_white);
    draw_rectangle(arch_x - 10, arch_y - 40, arch_x + arch_width, arch_y + arch_list_height, true);

    // Titre
    draw_set_color(c_yellow);
    draw_set_halign(fa_center);
    draw_text(arch_x + arch_width/2, arch_y - 30, "SÉLECTIONNE UN ARCHÉTYPE");
    draw_set_halign(fa_left);

    // Boutons de scroll
    if (array_length(archetype_list) > visible_arch) {
        var scroll_btn_x = arch_x + 130;
        var scroll_up_y = arch_y - 30;
        var scroll_down_y = arch_y + (visible_arch * arch_item_height) + 10;
        var scroll_btn_w = 40;
        var scroll_btn_h = 20;

        draw_set_color(archetype_list_scroll > 0 ? c_lime : c_gray);
        draw_rectangle(scroll_btn_x, scroll_up_y, scroll_btn_x + scroll_btn_w, scroll_up_y + scroll_btn_h, false);
        draw_set_color(c_black);
        draw_rectangle(scroll_btn_x, scroll_up_y, scroll_btn_x + scroll_btn_w, scroll_up_y + scroll_btn_h, true);
        draw_set_halign(fa_center);
        draw_text(scroll_btn_x + scroll_btn_w/2, scroll_up_y + 5, "↑");

        draw_set_color(archetype_list_scroll < array_length(archetype_list) - visible_arch ? c_lime : c_gray);
        draw_rectangle(scroll_btn_x, scroll_down_y, scroll_btn_x + scroll_btn_w, scroll_down_y + scroll_btn_h, false);
        draw_set_color(c_black);
        draw_rectangle(scroll_btn_x, scroll_down_y, scroll_btn_x + scroll_btn_w, scroll_down_y + scroll_btn_h, true);
        draw_text(scroll_btn_x + scroll_btn_w/2, scroll_down_y + 5, "↓");
        draw_set_halign(fa_left);
    }

    // Items archétype
    for (var i = 0; i < visible_arch; i++) {
        var arch_index = i + archetype_list_scroll;
        if (arch_index >= array_length(archetype_list)) break;
        var item_y = arch_y + (i * arch_item_height);
        var label = archetype_list[arch_index];

        draw_set_color(i % 2 == 0 ? c_dkgray : c_gray);
        draw_rectangle(arch_x, item_y, arch_x + arch_width, item_y + arch_item_height - 5, false);
        draw_set_color(c_white);
        draw_rectangle(arch_x, item_y, arch_x + arch_width, item_y + arch_item_height - 5, true);
        draw_set_color(c_white);
        draw_text(arch_x + 10, item_y + 15, label);
    }

    if (array_length(archetype_list) == 0) {
        draw_set_color(c_yellow);
        draw_set_halign(fa_center);
        draw_text(arch_x + arch_width/2, arch_y + 30, "Aucun archétype disponible");
        draw_set_halign(fa_left);
    }
}

draw_set_color(c_white);

// === MESSAGE D'ÉTAT ===
if (status_timer > 0 && status_message != "") {
    var msg_x1 = ui_x + 20;
    var msg_y1 = ui_y + ui_height - 60;
    var msg_x2 = ui_x + ui_width - 20;
    var msg_y2 = ui_y + ui_height - 20;
    draw_set_color(c_black);
    draw_set_alpha(0.6);
    draw_rectangle(msg_x1, msg_y1, msg_x2, msg_y2, false);
    draw_set_alpha(1);
    draw_set_color(c_white);
    draw_text(msg_x1 + 10, msg_y1 + 10, status_message);
}