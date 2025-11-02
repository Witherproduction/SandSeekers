// === Gestion des clics de souris (système global) ===

// Utilisation des coordonnées globales de la souris
var mx = device_mouse_x_to_gui(0);
var my = device_mouse_y_to_gui(0);

// === BOUTONS DE TYPE DE CARTE ===
if (point_in_rectangle(mx, my, buttons.type_monster.x, buttons.type_monster.y, buttons.type_monster.width, buttons.type_monster.height)) {
    card_type = "Monster";
    show_status_message("Type de carte: Monstre");
    return;
}

if (point_in_rectangle(mx, my, buttons.type_magic.x, buttons.type_magic.y, buttons.type_magic.width, buttons.type_magic.height)) {
    card_type = "Magic";
    show_status_message("Type de carte: Magie");
    return;
}

// === BOUTONS DE RARETÉ ===
var rarity_buttons = ["rarity_commun", "rarity_rare", "rarity_epique", "rarity_legendaire"];
for (var i = 0; i < array_length(rarity_buttons); i++) {
    var btn_name = rarity_buttons[i];
    var btn = buttons[$ btn_name];
    
    if (point_in_rectangle(mx, my, btn.x, btn.y, btn.width, btn.height)) {
        selected_rarity = btn.rarity;
        show_status_message("Rareté sélectionnée: " + getRarityDisplayName(selected_rarity));
        return;
    }
}

// === BOUTONS D'ACTION ===
if (point_in_rectangle(mx, my, buttons.create_card.x, buttons.create_card.y, buttons.create_card.width, buttons.create_card.height)) {
    create_new_card();
    return;
}

if (point_in_rectangle(mx, my, buttons.cancel.x, buttons.cancel.y, buttons.cancel.width, buttons.cancel.height)) {
    reset_fields();
    show_status_message("Champs réinitialisés");
    return;
}

if (point_in_rectangle(mx, my, buttons.back_to_menu.x, buttons.back_to_menu.y, buttons.back_to_menu.width, buttons.back_to_menu.height)) {
    room_goto(rAcceuil);
    return;
}

// === CHAMPS DE SAISIE ===
var field_names = variable_struct_get_names(field_positions);
var clicked_field = "";

for (var i = 0; i < array_length(field_names); i++) {
    var field_name = field_names[i];
    var field = field_positions[$ field_name];
    
    // Ignorer les champs non pertinents pour le type de carte
    if (card_type == "Magic" && (field_name == "attack" || field_name == "defense" || field_name == "star" || field_name == "genre")) {
        continue;
    }
    
    if (point_in_rectangle(mx, my, field.x, field.y, field.width, field.height)) {
        clicked_field = field_name;
        break;
    }
}

// Activer le champ cliqué
if (clicked_field != "") {
    active_field = clicked_field;
    cursor_blink_timer = 0;
} else {
    // Clic en dehors des champs, désactiver la saisie
    active_field = "";
}