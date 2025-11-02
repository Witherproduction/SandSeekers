show_debug_message("### oFieldManagerEnemey.create - before event_inherited")
event_inherited();
show_debug_message("### oFieldManagerEnemey.create - after event_inherited")


///////////////////////////////////////////////////////////////////////
// Méthodes
///////////////////////////////////////////////////////////////////////

#region Function getCardPositionAvailableIA
getCardPositionAvailableIA = function(card) {show_debug_message("### oFieldMonster.getCardPositionAvailableIA");
	
	// Récupère la liste des positions disponibles
	var positionAvailable = ds_list_create();
    var field = getField(card.type);
    if (field == noone || !instance_exists(field)) {
        show_debug_message("### ERREUR: getCardPositionAvailableIA: terrain introuvable pour type=" + string(card.type));
        ds_list_destroy(positionAvailable);
        return -1;
    }
	for(var i = 0; i < 5; i++) {
		if(field.cards[i] == 0)
			ds_list_add(positionAvailable, i);
	}
	
	// Si on a au moins une position disponible
	if(ds_list_size(positionAvailable) > 0) {
		
		// Récupère la localisation XY d'une position aléatoire
		ds_list_shuffle(positionAvailable);
		var position = ds_list_find_value(positionAvailable, 0);
		var location = getPosLocation(card.type, position);
		ds_list_destroy(positionAvailable);
		return [location[0], location[1], position];
	}
    ds_list_destroy(positionAvailable);
	return -1;
}
#endregion
