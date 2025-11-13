// === oCardMonster - Draw Event ===

// Hériter de l'affichage du parent (sprite de la carte)
event_inherited();

// Afficher les stats d'attaque et de défense seulement si la carte est sur le terrain
if (zone == "Field" || zone == "FieldSelected") {
    // Déterminer si on doit afficher les stats
    var should_show_stats = false;
    
    if (isHeroOwner) {
        // Côté héros : toujours afficher les stats
        should_show_stats = true;
    } else {
        // Côté adverse : afficher seulement si la carte est face découverte
        should_show_stats = !isFaceDown;
    }
    
    if (should_show_stats && variable_instance_exists(self, "attack") && variable_instance_exists(self, "defense")) {
        // Configuration du texte
        draw_set_font(fontCardDisplay);
        draw_set_halign(fa_center);
        draw_set_valign(fa_middle);
        
        // Position des stats (en bas de la carte), avec rotation selon orientation
        var card_width = sprite_get_width(sprite_index) * image_xscale;
        var card_height = sprite_get_height(sprite_index) * image_yscale;

        var stats_y = y + (card_height / 2) + 6;
        var attack_x = x - (card_width / 4); // Côté gauche
        var defense_x = x + (card_width / 4); // Côté droit

        // Ancien comportement: pas de rotation du texte
        
        // Déterminer les stats à afficher (effectives si disponibles)
        var dispAttack = (variable_instance_exists(self, "effective_attack") ? effective_attack : attack);
        var dispDefense = (variable_instance_exists(self, "effective_defense") ? effective_defense : defense);

        // Déterminer les couleurs selon variation (blanc = base, vert = augmenté, rouge = réduit)
        var baseAttack = attack;
        var baseDefense = defense;

        var attack_color = c_white;
        var defense_color = c_white;

        // Texte de l'attaque (blanc/vert/rouge)
        draw_set_color(attack_color);
        draw_text(attack_x, stats_y, string(dispAttack));

        // Texte de la défense (blanc/vert/rouge)
        draw_set_color(defense_color);
        draw_text(defense_x, stats_y, string(dispDefense));
        
        // Remettre les paramètres par défaut
        draw_set_color(c_white);
        draw_set_halign(fa_left);
        draw_set_valign(fa_top);
    }
}
