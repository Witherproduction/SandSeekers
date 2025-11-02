// === oDeckBuilder - Draw Event ===
// Affichage du cadre de construction de deck

// Cadre principal sans bordure (complètement transparent)

// Dessiner le titre
draw_set_color(c_black);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_text(x + 10, y + 5, "Créateur de Deck");

// Dessiner le label "Nom :"
draw_set_color(c_black);
draw_text(x + 10, y + 30, "Nom :");

// Dessiner le champ de saisie du nom
var name_display = deck_name;
if (deck_name_editing && (current_time / 500) % 2 < 1) {
    name_display += "|"; // Curseur clignotant
}

// Cadre du champ de saisie (sans bordure)
draw_set_color(c_white);
draw_rectangle(x + 50, y + 30, x + 50 + frame_width - 60, y + 30 + 25, false);

// Texte du nom
draw_set_color(c_black);
draw_text(x + 55, y + 35, name_display);

// Dessiner la zone des cartes (sans bordure)
draw_set_color(c_white);
draw_rectangle(cards_area_x, cards_area_y, cards_area_x + cards_area_width, cards_area_y + cards_area_height, false);

// Dessiner le label pour les cartes
draw_text(cards_area_x + 5, cards_area_y - 20, "Cartes du deck :");

// Dessiner les emplacements de cartes avec scroll
var line_height = 20;
var line_margin = 2;

// Construire une liste temporaire groupée et triée pour l'affichage : grouper les doublons et trier par niveau puis nom
// La variable `display_cards_list` est créée/actualisée ici et utilisée par l'événement souris si présent
{
    var grouped_map = ds_map_create();
    var grouped_keys = ds_list_create();

    for (var _i = 0; _i < array_length(cards_list); _i++) {
        var e = cards_list[_i];
        var cname = (is_struct(e) && variable_struct_exists(e, "name")) ? e.name : string(e);
        var coid = (is_struct(e) && variable_struct_exists(e, "objectId")) ? e.objectId : "";

        // Si l'entrée est juste un objectId (ex: "oNomDeCarte") stocké comme string, tenter de résoudre le vrai nom
        if (coid == "" && string_length(cname) > 0 && string_pos("o", cname) == 1) {
            var allTmp = dbGetAllCards();
            if (is_array(allTmp) && array_length(allTmp) > 0) {
                for (var _t = 0; _t < array_length(allTmp); _t++) {
                    if (variable_struct_exists(allTmp[_t], "objectId") && allTmp[_t].objectId == cname) {
                        coid = cname;
                        if (variable_struct_exists(allTmp[_t], "name")) cname = allTmp[_t].name;
                        break;
                    }
                }
            }
        }

        // Normaliser le nom (trim) et utiliser sa version en minuscules comme clé pour grouper correctement les doublons
        var norm_name = string_trim(string(cname));
        var key = string_lower(string(norm_name));
        
        // Debug pour "Baguette de la Rose noire"
        if (string_pos("baguette", key) > 0) {
            show_debug_message("### DEBUG Baguette: cname='" + string(cname) + "', norm_name='" + norm_name + "', coid='" + string(coid) + "', key='" + key + "'");
        }

        if (!ds_map_exists(grouped_map, key)) {
            // Résoudre le niveau (star/level/cost) via la base de données si possible
            var clevel = 0;
            var cardData = noone;

            // Si on a un objectId, chercher la carte correspondante dans la DB via dbGetAllCards() (évite les logs "Carte non trouvée")
            if (coid != "") {
                var allCards = dbGetAllCards();
                if (is_array(allCards) && array_length(allCards) > 0) {
                    for (var _a = 0; _a < array_length(allCards); _a++) {
                        if (variable_struct_exists(allCards[_a], "objectId") && allCards[_a].objectId == coid) {
                            cardData = allCards[_a];
                            break;
                        }
                    }
                }
            }

            // Si pas trouvé par objectId, chercher par nom
            if (cardData == noone && cname != "") {
                var matches = dbGetCardsByName(cname);
                if (is_array(matches) && array_length(matches) > 0) {
                    for (var _m = 0; _m < array_length(matches); _m++) {
                        if (variable_struct_exists(matches[_m], "name") && matches[_m].name == cname) {
                            cardData = matches[_m];
                            break;
                        }
                    }
                }
            }

            if (cardData != noone) {
                if (variable_struct_exists(cardData, "star")) clevel = cardData.star;
                else if (variable_struct_exists(cardData, "level")) clevel = cardData.level;
                else if (variable_struct_exists(cardData, "cost")) clevel = cardData.cost;
            }

            var struct_entry = { name: norm_name, objectId: coid, level: clevel, count: 1 };
            ds_map_add(grouped_map, key, struct_entry);
            ds_list_add(grouped_keys, key);
        } else {
            var existing = ds_map_find_value(grouped_map, key);
            existing.count += 1;
            ds_map_replace(grouped_map, key, existing);
            
            // Debug pour "Baguette de la Rose noire"
            if (string_pos("baguette", key) > 0) {
                show_debug_message("### DEBUG Baguette INCREMENTE: key='" + key + "', nouveau count=" + string(existing.count));
            }
        }
    }

    // Convertir en tableau
    display_cards_list = [];
    for (var _k = 0; _k < ds_list_size(grouped_keys); _k++) {
        var gk = ds_list_find_value(grouped_keys, _k);
        var item = ds_map_find_value(grouped_map, gk);
        var idx = array_length(display_cards_list);
        display_cards_list[idx] = item;
    }

    ds_list_destroy(grouped_keys);
    ds_map_destroy(grouped_map);

    // Trier par niveau croissant puis par nom alphabétique
    if (array_length(display_cards_list) > 1) {
        array_sort(display_cards_list, function(a, b) {
            var la = variable_struct_exists(a, "level") ? a.level : 0;
            var lb = variable_struct_exists(b, "level") ? b.level : 0;
            if (la < lb) return -1;
            if (la > lb) return 1;
            var na = variable_struct_exists(a, "name") ? string_lower(a.name) : "";
            var nb = variable_struct_exists(b, "name") ? string_lower(b.name) : "";
            if (na < nb) return -1;
            if (na > nb) return 1;
            return 0;
        });
    }
    
    // Mettre à jour current_slots pour refléter la liste groupée + 1 emplacement libre
    current_slots = max(array_length(display_cards_list) + 1, 1);
    if (current_slots > max_cards) {
        current_slots = max_cards;
    }
}

// Calculer les lignes visibles après mise à jour de current_slots
var visible_lines = min(current_slots, max_visible_lines);

// Afficher les lignes en utilisant la liste groupée triée
var list_to_display = display_cards_list;
for (var i = 0; i < visible_lines; i++) {
    var card_index = i + scroll_offset;
    if (card_index >= current_slots) break;
    
    var slot_x = cards_area_x + 5;
    var slot_y = cards_area_y + 5 + i * (line_height + line_margin);
    
    // Dessiner le fond de l'emplacement
    draw_set_color(c_white);
    draw_rectangle(slot_x, slot_y, slot_x + cards_area_width - 10, slot_y + line_height, false);
    
    // Dessiner la bordure
    draw_set_color(c_black);
    draw_rectangle(slot_x, slot_y, slot_x + cards_area_width - 10, slot_y + line_height, true);
    
    // Dessiner le nom de la carte si elle existe
    if (card_index < array_length(list_to_display)) {
        var entry = list_to_display[card_index];
        var display_name = entry.name;
        if (variable_struct_exists(entry, "count") && entry.count > 1) {
            display_name += " x" + string(entry.count);
        }
        draw_set_color(c_black);
        draw_set_font(fontCardDisplay);
        draw_text(slot_x + 5, slot_y + 2, display_name);
    }
}

// Dessiner les indicateurs de scroll si nécessaire
if (current_slots > max_visible_lines) {
    var scroll_indicator_x = cards_area_x + cards_area_width - 15;
    
    // Flèche vers le haut (si on peut scroller vers le haut)
    if (scroll_offset > 0) {
        draw_set_color(c_blue);
        draw_triangle(scroll_indicator_x, cards_area_y + 5, 
                     scroll_indicator_x + 10, cards_area_y + 5, 
                     scroll_indicator_x + 5, cards_area_y, false);
    }
    
    // Flèche vers le bas (si on peut scroller vers le bas)
    if (scroll_offset < current_slots - max_visible_lines) {
        draw_set_color(c_blue);
        var arrow_y = cards_area_y + cards_area_height - 10;
        draw_triangle(scroll_indicator_x, arrow_y, 
                     scroll_indicator_x + 10, arrow_y, 
                     scroll_indicator_x + 5, arrow_y + 5, false);
    }
}

// === Boutons Confirmer et Annuler ===
var buttons_y = y + frame_height + 5; // 5px sous le cadre
var button_width = 80;
var button_height = 30;
var button_spacing = 10;

// Centrer les boutons sous le cadre
var total_buttons_width = (button_width * 2) + button_spacing;
var buttons_start_x = x + (frame_width - total_buttons_width) / 2;
var confirm_button_x = buttons_start_x;
var cancel_button_x = buttons_start_x + button_width + button_spacing;

// Dessiner le bouton "Confirmer"
draw_set_color(c_green);
draw_rectangle(confirm_button_x, buttons_y, confirm_button_x + button_width, buttons_y + button_height, false);
draw_set_color(c_black);
draw_rectangle(confirm_button_x, buttons_y, confirm_button_x + button_width, buttons_y + button_height, true);

// Texte du bouton "Confirmer"
draw_set_color(c_white);
draw_set_halign(fa_center);
draw_set_valign(fa_middle);
draw_text(confirm_button_x + button_width/2, buttons_y + button_height/2, "Confirmer");

// Dessiner le bouton "Annuler"
draw_set_color(c_red);
draw_rectangle(cancel_button_x, buttons_y, cancel_button_x + button_width, buttons_y + button_height, false);
draw_set_color(c_black);
draw_rectangle(cancel_button_x, buttons_y, cancel_button_x + button_width, buttons_y + button_height, true);

// Texte du bouton "Supprimer"
draw_set_color(c_white);
draw_set_halign(fa_center);
draw_set_valign(fa_middle);
draw_text(cancel_button_x + button_width/2, buttons_y + button_height/2, "Supprimer");

// Remettre les paramètres par défaut
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_white);

// === Boîte de dialogue de confirmation ===
if (show_confirmation) {
    // Dimensions de la boîte de dialogue
    var dialog_width = 300;
    var dialog_height = 100;
    var dialog_x = x + (frame_width - dialog_width) / 2;
    var dialog_y = y + frame_height / 2 - dialog_height / 2;
    
    // Fond semi-transparent
    draw_set_alpha(0.7);
    draw_set_color(c_black);
    draw_rectangle(0, 0, room_width, room_height, false);
    draw_set_alpha(1);
    
    // Boîte de dialogue
    draw_set_color(c_white);
    draw_rectangle(dialog_x, dialog_y, dialog_x + dialog_width, dialog_y + dialog_height, false);
    draw_set_color(c_black);
    draw_rectangle(dialog_x, dialog_y, dialog_x + dialog_width, dialog_y + dialog_height, true);
    
    // Message de confirmation
    draw_set_color(c_black);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_text_ext(dialog_x + dialog_width/2, dialog_y + 30, confirmation_message, 12, dialog_width - 20);
    
    // Bouton "Oui"
    draw_set_color(c_red);
    draw_rectangle(confirmation_yes_x, confirmation_yes_y, 
                   confirmation_yes_x + confirmation_button_width, 
                   confirmation_yes_y + confirmation_button_height, false);
    draw_set_color(c_black);
    draw_rectangle(confirmation_yes_x, confirmation_yes_y, 
                   confirmation_yes_x + confirmation_button_width, 
                   confirmation_yes_y + confirmation_button_height, true);
    
    // Texte "Oui"
    draw_set_color(c_white);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_text(confirmation_yes_x + confirmation_button_width/2, 
              confirmation_yes_y + confirmation_button_height/2, "Oui");
    
    // Bouton "Non"
    draw_set_color(c_gray);
    draw_rectangle(confirmation_no_x, confirmation_no_y, 
                   confirmation_no_x + confirmation_button_width, 
                   confirmation_no_y + confirmation_button_height, false);
    draw_set_color(c_black);
    draw_rectangle(confirmation_no_x, confirmation_no_y, 
                   confirmation_no_x + confirmation_button_width, 
                   confirmation_no_y + confirmation_button_height, true);
    
    // Texte "Non"
    draw_set_color(c_white);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_text(confirmation_no_x + confirmation_button_width/2, 
              confirmation_no_y + confirmation_button_height/2, "Non");
    
    // Remettre les paramètres par défaut
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    draw_set_color(c_white);
}