show_debug_message("### oDeck.create")
show_debug_message(isHeroOwner)


///////////////////////////////////////////////////////////////////////
// Attributs
///////////////////////////////////////////////////////////////////////

// Assurer une graine aléatoire initialisée avant tout mélange
if (!variable_global_exists("rng_initialized") || !global.rng_initialized) {
    randomize();
    global.rng_initialized = true;
    show_debug_message("### oDeck.Create_0 - RNG initialisé (fallback)");
}

deck = ds_list_create(); // Liste des cartes devant etre creees
cards = ds_list_create(); // Liste des cartes presentes physiquement dans le deck
image_alpha = 0; // Cache l'image qui est la seulement pour bien placer le deck sur la map


///////////////////////////////////////////////////////////////////////
// Constructeur
///////////////////////////////////////////////////////////////////////

//----------------------------------
// Selectionne un deck
//----------------------------------

// Verifier si des decks personnalises ont ete selectionnes depuis rContreIa
var use_custom_decks = false;

if (isHeroOwner) {
    show_debug_message("### oDeck.Create_0 - Initializing hero deck");
    
    // Debug des variables globales
    show_debug_message("### oDeck.Create_0 - variable_global_exists(selected_player_deck): " + string(variable_global_exists("selected_player_deck")));
    if (variable_global_exists("selected_player_deck")) {
        show_debug_message("### oDeck.Create_0 - global.selected_player_deck: " + string(global.selected_player_deck));
    }
    
    // Deck du heros
    if (variable_global_exists("selected_player_deck") && global.selected_player_deck != noone) {
        // Verifier que les donnees du deck sont valides
        if (is_struct(global.selected_player_deck) && variable_struct_exists(global.selected_player_deck, "name")) {
            show_debug_message("### oDeck.Create_0 - Loading custom player deck: " + global.selected_player_deck.name);
            use_custom_decks = load_player_deck_from_data(global.selected_player_deck, deck);
            if (use_custom_decks) {
                show_debug_message("### oDeck.Create_0 - Custom deck loaded successfully with " + string(ds_list_size(deck)) + " cards");
            } else {
                show_debug_message("### oDeck.Create_0 - Failed to load custom deck, using default");
                // Charger le deck par défaut en cas d'échec
                try {
                    heroDeck(deck);
                    show_debug_message("### oDeck.Create_0 - Default heroDeck function executed as fallback, deck size: " + string(ds_list_size(deck)));
                } catch (e) {
                    show_debug_message("### oDeck.Create_0 - Error calling heroDeck function as fallback: " + string(e));
                }
            }
        } else {
            show_debug_message("### oDeck.Create_0 - Error: Invalid player deck data");
        }
    }
    
    if (!use_custom_decks) {
        show_debug_message("### oDeck.Create_0 - WARNING: No custom deck loaded, deck will be empty!");
        show_debug_message("### oDeck.Create_0 - Check global.selected_player_deck value and deck selection logic");
    }
} else {
    // Deck de l'ennemi
    if (variable_global_exists("selected_bot_deck_id") && global.selected_bot_deck_id != noone) {
        show_debug_message("### oDeck.Create_0 - Chargement du deck bot personnalise ID: " + string(global.selected_bot_deck_id));
        use_custom_decks = load_bot_deck_from_id(global.selected_bot_deck_id, deck);
    }
    
    if (!use_custom_decks) {
        show_debug_message("### oDeck.Create_0 - Loading default enemy deck");
        script_execute(enemyDeck_enemy1, deck);
    }
}
	
	
//----------------------------------
// Place les cartes sur la map
//----------------------------------
	
for(var i=0; i<ds_list_size(deck); i++) {
    var item = ds_list_find_value(deck, i);
	
	var instance = instance_create_layer(x+i/3, y-i/3, layer_get_id("Instances"), item);
	instance.image_index = 1;
	instance.image_angle = image_angle;
	instance.image_xscale = image_xscale;
	instance.image_yscale = image_yscale;
	instance.depth = -i;
	instance.isHeroOwner = isHeroOwner;
	instance.zone = "Deck";  // Initialiser la zone de la carte
	
    ds_list_add(cards, instance);
}

// Mélanger l'ordre des cartes dans le deck pour rendre la pioche non déterministe
if (ds_list_size(cards) > 1) {
    ds_list_shuffle(cards);
    show_debug_message("### oDeck.Create_0 - Deck mélangé: " + string(ds_list_size(cards)) + " cartes");
}


///////////////////////////////////////////////////////////////////////
// Methodes
///////////////////////////////////////////////////////////////////////

// Tire une carte dans le deck
#region Function pick
pick = function() { show_debug_message("### oDeck.pick");
	
	// Verifier qu'il y a des cartes dans le deck
	if (ds_list_size(cards) <= 0) {
		show_debug_message("### oDeck.pick - Error: No cards left in deck");
		return;
	}
	
	// Recupere la carte du dessus (l'index 0 etant en dessous du deck)
	var cardToPick = ds_list_find_value(cards, ds_list_size(cards)-1);
	
	// Verifier que la carte est valide
	if (cardToPick == noone || !instance_exists(cardToPick)) {
		show_debug_message("### oDeck.pick - Error: Invalid card instance");
		return;
	}
	
	// Retire la carte du deck
	ds_list_delete(cards, ds_list_size(cards)-1);
	
	// Déclenche l'événement de pioche avant l'ajout à la main
	registerTriggerEvent(TRIGGER_ON_CARD_DRAW, cardToPick, { owner_is_hero: isHeroOwner });
	
	// Ajoute la carte dans la main avec rafraîchissement différé et lance l'FX de pioche
	var handInst = (isHeroOwner ? handHero : handEnemy);
	if (instance_exists(handInst)) {
		// Masque temporairement la carte réelle pour éviter un clignotement
		cardToPick.visible = false;
		
		// Ajouter sans rafraîchir immédiatement
		handInst.addCard(cardToPick, true);
		
		// FX de pioche: glisse verticale vers la main depuis la carte empilée
		var fx = instance_create_depth(cardToPick.x, cardToPick.y, -100000, oFX_Draw);
		if (fx != noone) {
		    fx.spriteGhost       = cardToPick.sprite_index;
		    fx.imageGhost        = cardToPick.image_index;
		    fx.image_xscale      = cardToPick.image_xscale;
		    fx.image_yscale      = cardToPick.image_yscale;
		    fx.image_angle       = (isHeroOwner ? 0 : 180);
		    fx.duration_ms       = 400;
		    fx.target_x          = cardToPick.x; // Mouvement vertical dans la colonne de la carte
		    fx.target_y          = handInst.y;
		    fx.hand_to_update    = handInst;
		    fx.card_to_reveal    = cardToPick;
		} else {
		    // Fallback si l'effet n'est pas créé
		    cardToPick.visible = true;
		    if (variable_instance_exists(handInst, "updateDisplay")) { handInst.updateDisplay(); }
		}
	} else {
		// Fallback si la main n'existe pas
		(isHeroOwner ? handHero : handEnemy).addCard(cardToPick);
	}
}
#endregion

