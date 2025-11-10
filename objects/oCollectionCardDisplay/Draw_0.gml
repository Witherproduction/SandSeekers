// === oCollectionCardDisplay - Draw Event ===

// Affiche la carte sélectionnée uniquement dans rCollection
if (room == rCollection && selectedCard != noone && instance_exists(selectedCard)) {
    // Position pour l'affichage agrandi (utilise la position de l'instance)
    var display_x = x;
    var display_y = y;
    var display_scale = 0.6;
    
    // Fond semi-transparent derrière la carte
    draw_set_alpha(0.8);
    draw_set_color(c_black);
    var card_width = sprite_get_width(selectedCard.sprite_index) * display_scale;
    var card_height = sprite_get_height(selectedCard.sprite_index) * display_scale;
    draw_rectangle(display_x - card_width/2 - 10, display_y - card_height/2 - 10, 
                   display_x + card_width/2 + 10, display_y + card_height/2 + 10, false);
    draw_set_alpha(1);
    
    // Affichage de la carte
    draw_sprite_ext(selectedCard.sprite_index, selectedCard.image_index, 
                    display_x, display_y, display_scale, display_scale, 0, c_white, 1);
    
    // --- Bordure de rareté ---
    if (variable_instance_exists(selectedCard, "rarity")) {
        var rarity_color = getRarityColor(selectedCard.rarity);
        var glow_intensity = getRarityGlowIntensity(selectedCard.rarity);
        
        if (glow_intensity > 0) {
            // Dessiner une bordure colorée selon la rareté
            draw_set_color(rarity_color);
            draw_set_alpha(glow_intensity);
            
            var border_thickness = 6;
            for (var i = 1; i <= border_thickness; i++) {
                draw_rectangle(display_x - card_width/2 - i, display_y - card_height/2 - i, 
                              display_x + card_width/2 + i, display_y + card_height/2 + i, true);
            }
            
            draw_set_alpha(1);
            draw_set_color(c_white);
        }
    }
    
    // --- Affichage de l'étoile de favori ---
    // Vérifier si la carte est en favoris
    var card_id = selectedCard.name;
    
    if (is_card_favorite(card_id)) {
            // Position de l'étoile en haut à gauche de la carte
            var star_x = display_x - card_width/2 + 15;
            var star_y = display_y - card_height/2 + 15;
            var star_size = 12;
            
            // Dessiner l'étoile jaune (même méthode que le bouton)
            draw_set_color(c_yellow);
            draw_set_alpha(1);
            
            // Points extérieurs et intérieurs de l'étoile
            var points = 5;
            var outer_radius = star_size;
            var inner_radius = star_size * 0.5;
            var angle = -pi/2; // départ en haut

            var verts = array_create(points * 2);
            for (var p = 0; p < points * 2; p++) {
                var radius = (p % 2 == 0) ? outer_radius : inner_radius;
                var vx = star_x + lengthdir_x(radius, radtodeg(angle + p * pi / points));
                var vy = star_y + lengthdir_y(radius, radtodeg(angle + p * pi / points));
                verts[p] = [vx, vy];
            }

            // Tracer les triangles de l'étoile
            for (var t = 1; t < array_length(verts) - 1; t++) {
                draw_triangle(verts[0][0], verts[0][1], verts[t][0], verts[t][1], verts[t+1][0], verts[t+1][1], false);
            }

            draw_set_color(c_white);
    }

    // --- Rectangles de validation des champs (coords = coin haut-gauche puis coin bas-droite, à scale 1.0) ---
    {
        var spr = selectedCard.sprite_index;
        var s = display_scale;
        var cw = sprite_get_width(spr) * s;
        var ch = sprite_get_height(spr) * s;
        var tlx = display_x - cw * 0.5;
        var tly = display_y - ch * 0.5;

        // Coordonnées de base (scale 1.0), chaque champ: (x1,y1) = haut-gauche, (x2,y2) = bas-droite
        // Remplacez les *_x2/*_y2 par vos valeurs exactes si différentes des tailles par défaut.
        // Coordonnées exactes fournies (haut-gauche -> bas-droite) à l'échelle 1.0
        // name
        var name_x1 = 24,  name_y1 = 16;  var name_x2 = 387, name_y2 = 59;
        // star
        var star_x1 = 388, star_y1 = 16;  var star_x2 = 438, star_y2 = 60;
        // genre: mêmes dimensions que archetype et collé à sa gauche
        // archetype: x1=228, y1=369, x2=422, y2=419 -> w=194, h=50
        // décalé de 5 px à gauche pour laisser une marge avec archetype
        var genre_x1 = 29, genre_y1 = 394; var genre_x2 = 223, genre_y2 = 419;
        // archetype
        var arch_x1  = 228, arch_y1  = 394; var arch_x2  = 422, arch_y2  = 419;
        // description
        var desc_x1  = 23,  desc_y1  = 438; var desc_x2  = 421, desc_y2  = 592;
        // ATK
        var atk_x1   = 303, atk_y1   = 594; var atk_x2   = 348, atk_y2   = 609;
        // DEF
        var def_x1   = 383, def_y1   = 594; var def_x2   = 421, def_y2   = 608;

        // Utilisation directe des x2/y2 fournis pour tous les champs
        // (les tailles par défaut sont supprimées pour éviter d'écraser vos coordonnées)

        // Dessin des rectangles (haut-gauche -> bas-droite), avec mise à l'échelle et offset carte
        // Masqués par défaut; activer via global.show_green_frames
        if (variable_global_exists("show_green_frames") && global.show_green_frames) {
            draw_set_color(c_lime);
            draw_set_alpha(1);
            // name
            draw_rectangle(tlx + name_x1 * s, tly + name_y1 * s, tlx + name_x2 * s, tly + name_y2 * s, false);
            // star
            draw_rectangle(tlx + star_x1 * s, tly + star_y1 * s, tlx + star_x2 * s, tly + star_y2 * s, false);
            // genre
            draw_rectangle(tlx + genre_x1 * s, tly + genre_y1 * s, tlx + genre_x2 * s, tly + genre_y2 * s, false);
            // archetype
            draw_rectangle(tlx + arch_x1 * s, tly + arch_y1 * s, tlx + arch_x2 * s, tly + arch_y2 * s, false);
            // description
            draw_rectangle(tlx + desc_x1 * s, tly + desc_y1 * s, tlx + desc_x2 * s, tly + desc_y2 * s, false);
            // ATK
            draw_rectangle(tlx + atk_x1 * s, tly + atk_y1 * s, tlx + atk_x2 * s, tly + atk_y2 * s, false);
            // DEF
            draw_rectangle(tlx + def_x1 * s, tly + def_y1 * s, tlx + def_x2 * s, tly + def_y2 * s, false);
            draw_set_color(c_white);
        }
    }

    // --- Texte auto-ajusté dans les zones ---
    {
        var s = display_scale;
        var spr = selectedCard.sprite_index;
        var cw = sprite_get_width(spr) * s;
        var ch = sprite_get_height(spr) * s;
        var tlx = display_x - cw * 0.5;
        var tly = display_y - ch * 0.5;
        // Détection carte magique pour masquer coût et ATK/DEF
    var is_magic = object_is_ancestor(selectedCard.object_index, oCardMagic) || (variable_instance_exists(selectedCard, "type") && string_lower(string(selectedCard.type)) == "magic");

        // Utiliser la police de carte
        if (font_exists(fontCardText)) draw_set_font(fontCardText);
        draw_set_color(c_black);

        // Fonction utilitaire de calcul d'échelle pour une ligne
        var fit_line = function(text, max_px, rw, rh) {
            var base_line_h = string_height("Ag");
            var w0 = string_width(text);
            var h0 = base_line_h;
            var s_max = (h0 > 0) ? max_px / h0 : 1;
            var s_w = (w0 > 0) ? rw / w0 : s_max;
            var s_h = (h0 > 0) ? rh / h0 : s_max;
            return min(s_max, s_w, s_h);
        };

        // Fonction utilitaire pour texte multilignes (description)
        // Version itérative qui tient compte de la largeur pour converger sur la hauteur disponible
        var fit_block = function(text, max_px, rw, rh) {
            var base_line_h = string_height("Ag");
            var s = (base_line_h > 0) ? max_px / base_line_h : 1; // cap max
            // Itératif: calcule la hauteur avec séparation non-scalée et largeur rw/s
            for (var it = 0; it < 3; it++) {
                var sep = base_line_h;                 // séparation à l'échelle 1
                var w_eff = (s > 0) ? (rw / s) : rw;   // largeur efficace pour le wrap à scale 1
                var h = string_height_ext(text, sep, w_eff); // hauteur à scale 1
                if (h <= 0) break;
                var s_h = rh / h;                      // scale pour que h*s <= rh
                s = min(s, s_h);
            }
            return s;
        };

        // Marges internes
        var pad = 0;

        // --- NAME ---
        if (variable_instance_exists(selectedCard, "name")) {
            var tx = string(selectedCard.name);
            var mar = 7;
            var rw = (name_x2 - name_x1) * s - pad * 2 - mar * 2;
            var rh = (name_y2 - name_y1) * s - pad * 2;
            // Taille par défaut et coordonnées non arrondies
            var scale = fit_line(tx, 20, rw, rh);
            var left = tlx + name_x1 * s + pad + mar;
            var top  = tly + name_y1 * s + pad;
            draw_text_transformed(left, top + 2, tx, scale, scale, 0);
        }

        // --- STAR (coût) ---
        if (!is_magic && variable_instance_exists(selectedCard, "star")) {
            var tx = string(selectedCard.star);
            var rw = (star_x2 - star_x1) * s - pad * 2;
            var rh = (star_y2 - star_y1) * s - pad * 2;
            var scale = fit_line(tx, 20, rw, rh);
            var left = tlx + star_x1 * s + pad;
            var top  = tly + star_y1 * s + pad;
            var wsc  = string_width(tx) * scale;
            var cx   = left + max(0, (rw - wsc) * 0.5);
            draw_text_transformed(cx, top + 2, tx, scale, scale, 0);
        }

        // --- GENRE ---
        if (variable_instance_exists(selectedCard, "genre")) {
            var tx = string(selectedCard.genre);
            var mar = 7;
            var rw = (genre_x2 - genre_x1) * s - pad * 2 - mar * 2;
            var rh = (genre_y2 - genre_y1) * s - pad * 2;
            var scale = fit_line(tx, 16, rw, rh);
            draw_text_transformed(tlx + genre_x1 * s + pad + mar, tly + genre_y1 * s + pad + 2, tx, scale, scale, 0);
        }

        // --- ARCHETYPE ---
        if (variable_instance_exists(selectedCard, "archetype")) {
            var tx = string(selectedCard.archetype);
            var mar = 7;
            var rw = (arch_x2 - arch_x1) * s - pad * 2 - mar * 2;
            var rh = (arch_y2 - arch_y1) * s - pad * 2;
            var scale = fit_line(tx, 16, rw, rh);
            draw_text_transformed(tlx + arch_x1 * s + pad + mar, tly + arch_y1 * s + pad + 2, tx, scale, scale, 0);
        }

        // --- DESCRIPTION (justifiée) ---
        if (variable_instance_exists(selectedCard, "description")) {
            var tx = string(selectedCard.description);
            var mar = 7;
            var rw = (desc_x2 - desc_x1) * s - pad * 2 - mar * 2;
            var rh = (desc_y2 - desc_y1) * s - pad * 2;
            // Calcul d'échelle pour remplir la hauteur (cap 24px pour plus de lisibilité)
            var scale = fit_block(tx, 24, rw, rh);
            var left = tlx + desc_x1 * s + pad + mar;
            var top  = tly + desc_y1 * s + pad;
            var base_h = string_height("Ag");
            var line_h = base_h * scale;
            var space_w = string_width(" ") * scale;
            var dy = top + 2;

            var paragraphs = string_split(tx, "\n");
            for (var p = 0; p < array_length(paragraphs); p++) {
                var words = string_split(paragraphs[p], " ");
                var i = 0;
                while (i < array_length(words)) {
                    var line_words = [];
                    var count = 0;
                    var line_w = 0;
                    // Compose la ligne
                    while (i < array_length(words)) {
                        var w = words[i];
                        var ww = string_width(w) * scale;
                        var plus_space = (count > 0) ? space_w : 0;
                        if (line_w + plus_space + ww <= rw) {
                            line_words[count] = w;
                            count += 1;
                            line_w += plus_space + ww;
                            i += 1;
                        } else {
                            break;
                        }
                    }

                    // Justifie toutes les lignes sauf la dernière du paragraphe
                    // Justification contrôlée: limiter l'espace ajouté pour éviter les trous
                    var gaps = max(0, count - 1);
                    var extra_gap = 0;
                    if (gaps > 0 && i < array_length(words)) {
                        var extra = rw - line_w;
                        var extra_raw = (extra > 0) ? (extra / gaps) : 0;
                        var max_extra_ratio = 0.5; // au plus +50% de l'espace normal
                        extra_gap = min(extra_raw, string_width(" ") * scale * max_extra_ratio);
                    }

                    var dx = left;
                    for (var j = 0; j < count; j++) {
                        var wj = line_words[j];
                        draw_text_transformed(dx, dy, wj, scale, scale, 0);
                        var wjw = string_width(wj) * scale;
                        if (j < count - 1) {
                            dx += wjw + space_w + extra_gap;
                        } else {
                            dx += wjw;
                        }
                    }

                    dy += line_h;
                    if (dy + line_h > top + rh) break;
                }
            }
        }

        // --- ATK ---
        if (!is_magic && variable_instance_exists(selectedCard, "attack")) {
            var tx = string(selectedCard.attack);
            var rw = (atk_x2 - atk_x1) * s - pad * 2;
            var rh = (atk_y2 - atk_y1) * s - pad * 2;
            // Taille fixe: 12 px de hauteur de ligne, centrage H/V
            var base_line_h = string_height("Ag");
            var scale = (base_line_h > 0) ? 12 / base_line_h : 1;
            var left = tlx + atk_x1 * s + pad;
            var top  = tly + atk_y1 * s + pad - 2;
            var wsc  = string_width(tx) * scale;
            var hsc  = base_line_h * scale;
            var cx   = left + max(0, (rw - wsc) * 0.5);
            var cy   = top  + max(0, (rh - hsc) * 0.5);
            draw_text_transformed(cx, cy, tx, scale, scale, 0);
        }

        // --- DEF ---
        if (!is_magic && variable_instance_exists(selectedCard, "defense")) {
            var tx = string(selectedCard.defense);
            var rw = (def_x2 - def_x1) * s - pad * 2;
            var rh = (def_y2 - def_y1) * s - pad * 2;
            // Taille fixe: 12 px de hauteur de ligne, centrage H/V
            var base_line_h = string_height("Ag");
            var scale = (base_line_h > 0) ? 12 / base_line_h : 1;
            var left = tlx + def_x1 * s + pad;
            var top  = tly + def_y1 * s + pad - 2;
            var wsc  = string_width(tx) * scale;
            var hsc  = base_line_h * scale;
            var cx   = left + max(0, (rw - wsc) * 0.5);
            var cy   = top  + max(0, (rh - hsc) * 0.5);
            draw_text_transformed(cx, cy, tx, scale, scale, 0);
        }
    }

    // --- Texte du viewer désactivé temporairement ---
    // Ancien panneau d’informations (nom, rareté, ATK/DEF, description) supprimé
    // pour repartir étape par étape.

    // Bloc 2 (description simplifiée) désactivé
}
