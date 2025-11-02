// === Utilitaires de message d'état (placé en tête pour disponibilité) ===
function show_status_message(message) {
    status_message = message;
    status_timer = 180; // ~3 secondes à 60 FPS
}

// === Logique de l'Interface de Création de Cartes ===

// === SYSTÈME DE CLIC GLOBAL ===
if (mouse_check_button_pressed(mb_left)) {
    var mx = mouse_x;
    var my = mouse_y;
    
    // === BOUTONS DE TYPE DE CARTE ===
    if (point_in_rectangle(mx, my, buttons.type_monster.x, buttons.type_monster.y, 
                          buttons.type_monster.x + buttons.type_monster.width, 
                          buttons.type_monster.y + buttons.type_monster.height)) {
        card_type = "Monster";
        buttons.type_monster.active = true;
        buttons.type_magic.active = false;
        show_status_message("Type: Monstre sélectionné");
    }
    
    if (point_in_rectangle(mx, my, buttons.type_magic.x, buttons.type_magic.y, 
                          buttons.type_magic.x + buttons.type_magic.width, 
                          buttons.type_magic.y + buttons.type_magic.height)) {
        card_type = "Magic";
        buttons.type_monster.active = false;
        buttons.type_magic.active = true;
        show_status_message("Type: Magie sélectionné");
    }
    
    // === BOUTONS DE RARETÉ ===
    var rarity_buttons = ["rarity_commun", "rarity_rare", "rarity_epique", "rarity_legendaire"];
    for (var i = 0; i < array_length(rarity_buttons); i++) {
        var btn_name = rarity_buttons[i];
        var btn = buttons[$ btn_name];
        if (point_in_rectangle(mx, my, btn.x, btn.y, btn.x + btn.width, btn.y + btn.height)) {
            selected_rarity = btn.rarity;
            show_status_message("Rareté: " + btn.text + " sélectionnée");
            break;
        }
    }
    
    // === BOUTONS D'ACTION ===
    if (point_in_rectangle(mx, my, buttons.create_card.x, buttons.create_card.y, 
                          buttons.create_card.x + buttons.create_card.width, 
                          buttons.create_card.y + buttons.create_card.height)) {
        // Créer et sauvegarder la carte
        create_new_card();
    }
    
    if (point_in_rectangle(mx, my, buttons.cancel.x, buttons.cancel.y, 
                          buttons.cancel.x + buttons.cancel.width, 
                          buttons.cancel.y + buttons.cancel.height)) {
        // Fermer la carte en cours et réinitialiser l'édition
        reset_fields();
        show_card_list = false;
        show_booster_list = false;
        show_status_message("Carte fermée");
    }
    
    if (point_in_rectangle(mx, my, buttons.back_to_menu.x, buttons.back_to_menu.y, 
                          buttons.back_to_menu.x + buttons.back_to_menu.width, 
                          buttons.back_to_menu.y + buttons.back_to_menu.height)) {
        room_goto(rAcceuil);
    }
    
    if (point_in_rectangle(mx, my, buttons.load_card.x, buttons.load_card.y, 
                          buttons.load_card.x + buttons.load_card.width, 
                          buttons.load_card.y + buttons.load_card.height)) {
        // Ouvrir la sélection (booster ou archétype) selon le contexte
        if (show_booster_list || show_card_list || show_archetype_list) {
            // Fermer toute sélection ouverte
            show_booster_list = false;
            show_card_list = false;
            show_archetype_list = false;
            show_status_message("Sélection masquée");
        } else {
            // Si un booster est déjà choisi, ouvrir directement la sélection d'archétypes
            if (booster_selected != "") {
                load_archetype_list();
                show_archetype_list = true;
                show_booster_list = false;
                show_card_list = false;
                show_status_message("Sélectionne un archétype");
            } else {
                // Sinon, ouvrir la sélection des boosters
                load_booster_list();
                list_archetype_filter = "Tous";
                show_archetype_list = false;
                show_booster_list = true;
                show_card_list = false;
                show_status_message("Sélectionne un booster");
            }
        }
    }
    
    // === ACTIVATION DES CHAMPS DE SAISIE ===
    var field_clicked = false;
    var prev_active_field = active_field;
    var field_names = ["card_id", "name", "attack", "defense", "star", "genre", "archetype", "booster", "sprite", "object_id", "description"];
    for (var i = 0; i < array_length(field_names); i++) {
        var field_name = field_names[i];
        var field = field_positions[$ field_name];
        if (point_in_rectangle(mx, my, field.x, field.y, field.x + field.width, field.y + field.height)) {
            // Ignorer les champs non pertinents pour les cartes magiques
            if (card_type == "Magic" && (field_name == "attack" || field_name == "defense" || field_name == "star")) {
                continue;
            }
            // Déclencher l'auto-remplissage si on quitte object_id par clic
            if (prev_active_field == "object_id" && field_name != "object_id" && input_fields.object_id != "") {
                auto_fill_fields_from_object(input_fields.object_id);
            }
            active_field = field_name;
            field_clicked = true;
            show_status_message("Champ actif: " + field.label);
            break;
        }
    }
    
    // Si aucun champ n'a été cliqué, désactiver la saisie
    if (!field_clicked) {
        // Si on quitte object_id en cliquant hors des champs, auto-remplir
        if (prev_active_field == "object_id" && input_fields.object_id != "") {
            auto_fill_fields_from_object(input_fields.object_id);
        }
        active_field = "";
    }
    
    // === GESTION DES CLICS DANS LA LISTE DES CARTES ===
    if (show_card_list && array_length(card_list) > 0 && !show_booster_list && !show_archetype_list) {
        var list_width = 390; // aligné avec Draw_0.gml
        var item_height = 60;
        var visible_items = min(8, array_length(card_list));
        var list_height = visible_items * item_height + 80;
        var list_x = (room_width - list_width) / 2;
        var list_y = (room_height - list_height) / 2;
        
        // Zones cliquables du breadcrumb (Booster et Archétype)
        var crumb_y1 = list_y - 30;
        var crumb_y2 = list_y - 10;
        var booster_area_x1 = list_x;
        var booster_area_x2 = list_x + (list_width / 2);
        var arch_area_x1 = booster_area_x2;
        var arch_area_x2 = list_x + list_width;
        
        // Clic sur "Booster: ..." -> ouvre la sélection des boosters
        if (point_in_rectangle(mx, my, booster_area_x1, crumb_y1, booster_area_x2, crumb_y2)) {
            load_booster_list();
            booster_selected = booster_selected; // garde le booster affiché dans le breadcrumb
            list_archetype_filter = list_archetype_filter; // garde le filtre courant
            show_booster_list = true;
            show_card_list = false;
            show_archetype_list = false;
            show_status_message("Sélectionne un booster");
        }
        // Clic sur "Archétype: ..." -> ouvre la sélection d'archétype pour le booster courant
        else if (point_in_rectangle(mx, my, arch_area_x1, crumb_y1, arch_area_x2, crumb_y2)) {
            if (booster_selected != "") {
                load_archetype_list();
                show_archetype_list = true;
                show_card_list = false;
                show_booster_list = false;
                show_status_message("Sélectionne un archétype");
            } else {
                show_status_message("Choisis d'abord un booster");
            }
        }
        else {
            // Sélection via liste d'archétypes (voir show_archetype_list)
            for (var i = 0; i < visible_items; i++) {
                var card_index = i + card_list_scroll;
                if (card_index >= array_length(card_list)) break;
                
                var card = card_list[card_index];
                var item_y = list_y + (i * item_height);
                
                // Clic sur la ligne de l'item pour charger en modification
                if (point_in_rectangle(mx, my, list_x, item_y, list_x + list_width - 20, item_y + item_height - 5)) {
                    show_card_list = false; // fermer la liste immédiatement
                    load_card_for_editing(card.id);
                    break;
                }
                
                // Bouton Modifier
                var edit_btn_x = list_x + 250;
                var edit_btn_y = item_y + 5;
                var edit_btn_w = 60;
                var edit_btn_h = 25;
                
                if (point_in_rectangle(mx, my, edit_btn_x, edit_btn_y, edit_btn_x + edit_btn_w, edit_btn_y + edit_btn_h)) {
                    show_card_list = false; // fermer également via le bouton
                    load_card_for_editing(card.id);
                    break;
                }
                
                // Bouton Supprimer
                var del_btn_x = list_x + 320;
                var del_btn_y = item_y + 5;
                var del_btn_w = 70;
                var del_btn_h = 25;
                
                if (point_in_rectangle(mx, my, del_btn_x, del_btn_y, del_btn_x + del_btn_w, del_btn_y + del_btn_h)) {
                    delete_card(card.id);
                }
            }
            
            // Gestion du scroll
            var scroll_up_y = list_y - 30;
            var scroll_down_y = list_y + (visible_items * item_height) + 10;
            var scroll_btn_x = list_x + 180;
            var scroll_btn_w = 40;
            var scroll_btn_h = 20;
            
            if (point_in_rectangle(mx, my, scroll_btn_x, scroll_up_y, scroll_btn_x + scroll_btn_w, scroll_up_y + scroll_btn_h)) {
                if (card_list_scroll > 0) {
                    card_list_scroll--;
                }
            }
            
            if (point_in_rectangle(mx, my, scroll_btn_x, scroll_down_y, scroll_btn_x + scroll_btn_w, scroll_down_y + scroll_btn_h)) {
                if (card_list_scroll < array_length(card_list) - visible_items) {
                    card_list_scroll++;
                }
            }
        }
    }
    
    // === GESTION DES CLICS DANS LA LISTE DES BOOSTERS ===
    if (show_booster_list && array_length(booster_list) > 0) {
        var booster_width = 300;
        var booster_item_height = 50;
        var visible_boosters = min(10, array_length(booster_list));
        var booster_list_height = visible_boosters * booster_item_height + 60;
        var booster_x = (room_width - booster_width) / 2;
        var booster_y = (room_height - booster_list_height) / 2;
        
        for (var i = 0; i < visible_boosters; i++) {
            var boost_index = i + booster_list_scroll;
            if (boost_index >= array_length(booster_list)) break;
            var item_y = booster_y + (i * booster_item_height);
            if (point_in_rectangle(mx, my, booster_x, item_y, booster_x + booster_width, item_y + booster_item_height)) {
                var boost_name = booster_list[boost_index];
                booster_selected = boost_name;
                list_archetype_filter = "Tous";
                load_archetype_list();
                show_booster_list = false;
                show_archetype_list = true;
                show_card_list = false;
                show_status_message("Sélectionne un archétype");
                exit; // éviter le double-traitement du clic dans la même frame
            }
        }

        // Scroll boutons
        var scroll_up_y = booster_y - 30;
        var scroll_down_y = booster_y + (visible_boosters * booster_item_height) + 10;
        var scroll_btn_x = booster_x + 130;
        var scroll_btn_w = 40;
        var scroll_btn_h = 20;
        
        if (point_in_rectangle(mx, my, scroll_btn_x, scroll_up_y, scroll_btn_x + scroll_btn_w, scroll_up_y + scroll_btn_h)) {
            if (booster_list_scroll > 0) booster_list_scroll--;
        }
        if (point_in_rectangle(mx, my, scroll_btn_x, scroll_down_y, scroll_btn_x + scroll_btn_w, scroll_down_y + scroll_btn_h)) {
            if (booster_list_scroll < array_length(booster_list) - visible_boosters) booster_list_scroll++;
        }
    }
    // === GESTION DES CLICS DANS LA LISTE DES ARCHÉTYPES ===
    if (show_archetype_list && array_length(archetype_list) > 0) {
        var arch_width = 300;
        var arch_item_height = 50;
        var visible_arch = min(10, array_length(archetype_list));
        var arch_list_height = visible_arch * arch_item_height + 60;
        var arch_x = (room_width - arch_width) / 2;
        var arch_y = (room_height - arch_list_height) / 2;
        
        for (var i = 0; i < visible_arch; i++) {
            var arch_index = i + archetype_list_scroll;
            if (arch_index >= array_length(archetype_list)) break;
            var item_y = arch_y + (i * arch_item_height);
            if (point_in_rectangle(mx, my, arch_x, item_y, arch_x + arch_width, item_y + arch_item_height)) {
                var arch_name = archetype_list[arch_index];
                list_archetype_filter = arch_name;
                show_archetype_list = false;
                if (booster_selected != "") {
                    load_card_list_by_booster(booster_selected);
                } else {
                    load_card_list();
                }
                show_card_list = true;
                break;
            }
        }
        
        // Scroll boutons
        var scroll_up_y = arch_y - 30;
        var scroll_down_y = arch_y + (visible_arch * arch_item_height) + 10;
        var scroll_btn_x = arch_x + 130;
        var scroll_btn_w = 40;
        var scroll_btn_h = 20;
        
        if (point_in_rectangle(mx, my, scroll_btn_x, scroll_up_y, scroll_btn_x + scroll_btn_w, scroll_up_y + scroll_btn_h)) {
            if (archetype_list_scroll > 0) archetype_list_scroll--;
        }
        if (point_in_rectangle(mx, my, scroll_btn_x, scroll_down_y, scroll_btn_x + scroll_btn_w, scroll_down_y + scroll_btn_h)) {
            if (archetype_list_scroll < array_length(archetype_list) - visible_arch) archetype_list_scroll++;
        }
    }
}

// === Décrémenter le timer du message d'état ===
if (status_timer > 0) {
    status_timer--;
    if (status_timer <= 0) {
        status_message = "";
    }
}



// Charger les boosters disponibles
function load_booster_list() {
    booster_list = [];
    booster_list_scroll = 0;
    var all_cards = dbGetAllCards();
    
    // Ajouter d'abord l'option "Aucun" pour les cartes sans booster
    var has_cards_without_booster = false;
    for (var i = 0; i < array_length(all_cards); i++) {
        var c = all_cards[i];
        var has_boost = variable_struct_exists(c, "booster") && c.booster != "";
        if (!has_boost) {
            has_cards_without_booster = true;
            break;
        }
    }
    
    if (has_cards_without_booster) {
        booster_list[0] = "Aucun";
    }
    
    // Utiliser une map pour éviter les doublons
    var seen = ds_map_create();
    for (var i = 0; i < array_length(all_cards); i++) {
        var c = all_cards[i];
        var has_boost = variable_struct_exists(c, "booster") && c.booster != "";
        if (has_boost) {
            if (!ds_map_exists(seen, c.booster)) {
                ds_map_add(seen, c.booster, true);
                var idx = array_length(booster_list);
                booster_list[idx] = c.booster;
            }
        }
    }
    ds_map_destroy(seen);
}

// Charger la liste des cartes filtrées par booster
function load_card_list_by_booster(boost_name) {
    booster_selected = boost_name;
    card_list = [];
    card_list_scroll = 0;
    var all_cards = dbGetAllCards();
    
    for (var i = 0; i < array_length(all_cards); i++) {
        var c = all_cards[i];
        
        // Appliquer filtre d'archétype si défini (hors "Tous")
        var pass_arch = true;
        if (list_archetype_filter != "Tous") {
            var arch = variable_struct_exists(c, "archetype") ? c.archetype : "";
            pass_arch = string_lower(arch) == string_lower(list_archetype_filter);
        }
        if (!pass_arch) continue;
        
        if (boost_name == "Aucun") {
            // Afficher les cartes sans booster ou avec booster vide
            var has_boost = variable_struct_exists(c, "booster") && c.booster != "";
            if (!has_boost) {
                var idx = array_length(card_list);
                card_list[idx] = c;
            }
        } else {
            // Afficher les cartes avec le booster spécifique
            if (variable_struct_exists(c, "booster") && c.booster == boost_name) {
                var idx = array_length(card_list);
                card_list[idx] = c;
            }
        }
    }
    
    // Tri alphabétique A→Z par nom
    sort_card_list_alpha();
}

// Tri alphabétique de card_list par nom
function sort_card_list_alpha() {
    var n = array_length(card_list);
    for (var i = 0; i < n - 1; i++) {
        for (var j = i + 1; j < n; j++) {
            var a = string_lower(card_list[i].name);
            var b = string_lower(card_list[j].name);
            if (a > b) {
                var t = card_list[i];
                card_list[i] = card_list[j];
                card_list[j] = t;
            }
        }
    }
}

// Fonction pour auto-remplir les champs depuis un objet
function auto_fill_fields_from_object(obj_name) {
    try {
        // Normaliser l'entrée (trim) et conserver l'original pour debug
        var raw_name = string(obj_name);
        var obj_name_trimmed = string_trim(raw_name);
        obj_name = obj_name_trimmed;
        show_debug_message("[AutoFill] raw='" + raw_name + "' trimmed='" + obj_name + "'");
        
        // Tentative 1: nom tel quel
        var obj_index = asset_get_index(obj_name);
        show_debug_message("[AutoFill] try exact '" + obj_name + "' => " + string(obj_index));
        
        // Tentative 2: ajouter préfixe 'o' si manquant
        if (obj_index == -1) {
            if (string_copy(obj_name, 1, 1) != "o") {
                var alt_name_o = "o" + obj_name;
                var alt_index_o = asset_get_index(alt_name_o);
                show_debug_message("[AutoFill] try prefixed '" + alt_name_o + "' => " + string(alt_index_o));
                if (alt_index_o != -1) {
                    obj_index = alt_index_o;
                    obj_name = alt_name_o;
                }
            }
        }
        
        // Tentative 3: supprimer préfixe 'o' si présent et échoue
        if (obj_index == -1) {
            if (string_copy(obj_name, 1, 1) == "o") {
                var alt_name_no = string_delete(obj_name, 1, 1);
                var alt_index_no = asset_get_index(alt_name_no);
                show_debug_message("[AutoFill] try de-prefixed '" + alt_name_no + "' => " + string(alt_index_no));
                if (alt_index_no != -1) {
                    obj_index = alt_index_no;
                    obj_name = alt_name_no;
                }
            }
        }
        
        if (obj_index == -1) {
            show_status_message("Objet introuvable: " + obj_name);
            return false;
        }
        
        // Créer une instance temporaire pour lire ses variables
        var inst = instance_create_layer(0, 0, "Instances", obj_index);
        
        // Remplir les champs si disponibles
        if (variable_instance_exists(inst, "name")) {
            input_fields.name = inst.name;
        }
        if (variable_instance_exists(inst, "attack")) {
            input_fields.attack = string(inst.attack);
        }
        if (variable_instance_exists(inst, "defense")) {
            input_fields.defense = string(inst.defense);
        }
        if (variable_instance_exists(inst, "star")) {
            input_fields.star = string(inst.star);
        }
        if (variable_instance_exists(inst, "description")) {
            input_fields.description = inst.description;
        }
        if (variable_instance_exists(inst, "genre")) {
            input_fields.genre = inst.genre;
        }
        if (variable_instance_exists(inst, "archetype")) {
            input_fields.archetype = inst.archetype;
        }
        if (variable_instance_exists(inst, "booster")) {
            input_fields.booster = inst.booster;
        }
        
        // Tentative de trouver un sprite en utilisant conventions
        var spr_name = "s" + string_delete(obj_name, 1, 1);
        var spr_index = asset_get_index(spr_name);
        if (spr_index == -1) {
            spr_name = input_fields.sprite; // conserver l'existant si non trouvé
        }
        if (spr_name != undefined && spr_name != "") {
            input_fields.sprite = spr_name;
        }
        
        // Toujours mettre l'object_id saisi
        input_fields.object_id = obj_name;
        
        // Détruire l'instance temporaire
        with (inst) instance_destroy();
        
        show_status_message("Champs remplis depuis l'objet: " + obj_name);
        return true;
    } catch (e) {
        show_status_message("Autoremplissage impossible: " + string(e));
        return false;
    }
}

// Charger la liste des archétypes disponibles (basé sur le booster sélectionné)
function load_archetype_list() {
    archetype_list = [];
    archetype_list_scroll = 0;
    
    // Toujours proposer "Tous"
    var idx = array_length(archetype_list);
    archetype_list[idx] = "Tous";
    
    var all_cards = dbGetAllCards();
    var seen = ds_map_create();
    ds_map_add(seen, "tous", true); // clés en minuscules pour déduplication insensible à la casse
    var has_neutre = false;
    
    for (var i = 0; i < array_length(all_cards); i++) {
        var c = all_cards[i];
        // Filtrer par booster selon l'état (inclut cas spécial "Aucun")
        var pass_booster = true;
        if (booster_selected != "") {
            if (booster_selected == "Aucun") {
                var has_boost = variable_struct_exists(c, "booster") && c.booster != "";
                pass_booster = !has_boost;
            } else {
                var boost_val = variable_struct_exists(c, "booster") ? c.booster : "";
                pass_booster = string_lower(boost_val) == string_lower(booster_selected);
            }
        }
        if (!pass_booster) continue;
        
        var arch = variable_struct_exists(c, "archetype") ? string(c.archetype) : "";
        arch = string_trim(arch);
        var key = string_lower(arch);
        if (key == "") {
            has_neutre = true;
            continue;
        }
        if (!ds_map_exists(seen, key)) {
            ds_map_add(seen, key, true);
            var j = array_length(archetype_list);
            archetype_list[j] = arch; // conserver l'affichage tel que saisi pour la première occurrence
        }
    }
    
    if (has_neutre && !ds_map_exists(seen, "neutre")) {
        var k = array_length(archetype_list);
        archetype_list[k] = "Neutre";
    }
    
    ds_map_destroy(seen);
}

// === SAISIE CLAVIER SUR CHAMP ACTIF ===
if (!show_card_list && !show_booster_list && !show_archetype_list) {
    if (active_field != "") {
        // Échapper pour arrêter la saisie sur le champ
        if (keyboard_check_pressed(vk_escape)) {
            if (active_field == "object_id" && input_fields.object_id != "") {
                auto_fill_fields_from_object(input_fields.object_id);
            }
            active_field = "";
        }
        
        // Entrée pour valider et arrêter la saisie
        if (keyboard_check_pressed(vk_enter)) {
            if (active_field == "object_id" && input_fields.object_id != "") {
                auto_fill_fields_from_object(input_fields.object_id);
            }
            active_field = "";
        }
        
        // Effacement avec Backspace (supprime le dernier caractère)
        if (keyboard_check_pressed(vk_backspace)) {
            var cur = string(input_fields[$ active_field]);
            if (string_length(cur) > 0) {
                input_fields[$ active_field] = string_delete(cur, string_length(cur), 1);
            }
        }
        
        // Suppr pour vider complètement le champ
        if (keyboard_check_pressed(vk_delete)) {
            input_fields[$ active_field] = "";
        }
        
        // Saisie de caractères: consommer keyboard_string pour éviter la répétition continue
        if (keyboard_string != "") {
            var len = string_length(keyboard_string);
            for (var i = 1; i <= len; i++) {
                var ch = string_char_at(keyboard_string, i);
                var is_numeric_field = (active_field == "attack") || (active_field == "defense") || (active_field == "star");
                var is_id_field = (active_field == "card_id");
                if (is_numeric_field) {
                    if (ch >= "0" && ch <= "9") {
                        input_fields[$ active_field] = string(input_fields[$ active_field]) + ch;
                    }
                } else if (is_id_field) {
                    var o = ord(ch);
                    var is_letter = (o >= ord("A") && o <= ord("Z")) || (o >= ord("a") && o <= ord("z"));
                    var is_digit = (o >= ord("0") && o <= ord("9"));
                    var is_allowed = is_letter || is_digit || (ch == "_") || (ch == "-");
                    if (is_allowed) {
                        input_fields[$ active_field] = string(input_fields[$ active_field]) + ch;
                    }
                } else {
                    input_fields[$ active_field] = string(input_fields[$ active_field]) + ch;
                }
            }
            keyboard_string = ""; // vider le buffer pour éviter rrrr en continu
        }
    }
}

// === CHARGER UNE CARTE POUR MODIFICATION ===
function load_card_for_editing(card_id) {
    var card = dbGetCard(card_id);
    if (card == undefined) {
        show_status_message("Carte introuvable: " + string(card_id));
        return false;
    }
    
    // Peupler les champs d'entrée
    input_fields.card_id = string(card.id);
    input_fields.name = string(card.name);
    input_fields.attack = string(variable_struct_exists(card, "attack") ? card.attack : 0);
    input_fields.defense = string(variable_struct_exists(card, "defense") ? card.defense : 0);
    input_fields.star = string(variable_struct_exists(card, "star") ? card.star : 0);
    input_fields.genre = string(variable_struct_exists(card, "genre") ? card.genre : "");
    input_fields.archetype = string(variable_struct_exists(card, "archetype") ? card.archetype : "");
    input_fields.booster = string(variable_struct_exists(card, "booster") ? card.booster : "");
    input_fields.sprite = string(variable_struct_exists(card, "sprite") ? card.sprite : "");
    input_fields.object_id = string(variable_struct_exists(card, "objectId") ? card.objectId : "");
    input_fields.description = string(variable_struct_exists(card, "description") ? card.description : "");
    
    // Type et rareté
    if (variable_struct_exists(card, "type")) card_type = card.type;
    if (variable_struct_exists(card, "rarity")) selected_rarity = card.rarity;
    
    show_status_message("Carte chargée: " + input_fields.name);
    editing_mode = true; // activer le mode édition pour permettre la modification
    return true;
}

// === SUPPRIMER UNE CARTE ===
function delete_card(card_id) {
    var ok = dbRemoveCard(card_id);
    if (ok) {
        save_cards_database_to_file();
        show_status_message("Carte supprimée: " + string(card_id));
        // Recharger la liste selon le contexte actuel
        if (booster_selected != "") {
            load_card_list_by_booster(booster_selected);
        } else {
            load_card_list();
        }
        show_card_list = true;
        return true;
    } else {
        show_status_message("Suppression impossible: " + string(card_id));
        return false;
    }
}

// === CHARGER LA LISTE DES CARTES (FILTRAGE ARCHÉTYPE/BOOSTER) ===
function load_card_list() {
    card_list = [];
    card_list_scroll = 0;
    var all_cards = dbGetAllCards();
    
    for (var i = 0; i < array_length(all_cards); i++) {
        var c = all_cards[i];
        
        // Filtre d'archétype
        var pass_arch = true;
        if (list_archetype_filter != "Tous") {
            var arch = variable_struct_exists(c, "archetype") ? c.archetype : "";
            if (string_lower(list_archetype_filter) == "neutre") {
                pass_arch = arch == "" || arch == undefined;
            } else {
                pass_arch = string_lower(arch) == string_lower(list_archetype_filter);
            }
        }
        if (!pass_arch) continue;
        
        // Filtre booster si présent
        var pass_booster = true;
        if (booster_selected != "") {
            if (booster_selected == "Aucun") {
                var has_boost = variable_struct_exists(c, "booster") && c.booster != "";
                pass_booster = !has_boost;
            } else {
                var boost_val = variable_struct_exists(c, "booster") ? c.booster : "";
                pass_booster = string_lower(boost_val) == string_lower(booster_selected);
            }
        }
        if (!pass_booster) continue;
        
        var idx = array_length(card_list);
        card_list[idx] = c;
    }
    
    sort_card_list_alpha();
}

// === RÉINITIALISER LES CHAMPS ===
function reset_fields() {
    input_fields.card_id = "";
    input_fields.name = "";
    input_fields.attack = "0";
    input_fields.defense = "0";
    input_fields.star = "0";
    input_fields.genre = "";
    input_fields.archetype = "";
    input_fields.booster = "";
    input_fields.sprite = "";
    input_fields.object_id = "";
    input_fields.description = "";
    selected_rarity = "commun";
    card_type = "Monster";
    active_field = "";
    show_status_message("Champs réinitialisés");
}

// === CRÉER/Sauvegarder UNE NOUVELLE CARTE ===
function create_new_card() {
    var new_id = string(input_fields.card_id);
    if (new_id == "") {
        show_status_message("ID invalide pour la carte");
        return false;
    }
    var new_name = string(input_fields.name);
    var rarity = string(selected_rarity);
    var genre = string(input_fields.genre);
    var archetype = string(input_fields.archetype);
    var booster = string(input_fields.booster);
    var sprite = string(input_fields.sprite);
    var objectId = string(input_fields.object_id);
    var description = string(input_fields.description);
    var type_local = card_type;
    var attack = real(input_fields.attack);
    var defense = real(input_fields.defense);
    var star = real(input_fields.star);
    
    var card_data = {
        id: new_id,
        name: new_name,
        type: type_local,
        attack: (type_local == "Monster") ? attack : 0,
        defense: (type_local == "Monster") ? defense : 0,
        star: (type_local == "Monster") ? star : 0,
        description: description,
        sprite: sprite,
        objectId: objectId,
        rarity: rarity,
        genre: genre,
        archetype: archetype,
        booster: booster
    };
    
    add_card_and_save(new_id, card_data);
    show_status_message("Carte créée/sauvegardée: " + new_name);
    return true;
}