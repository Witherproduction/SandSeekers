show_debug_message("### oFieldParentHero.create - before event_inherited")
event_inherited();
show_debug_message("### oFieldParentHero.create - after event_inherited")
	

///////////////////////////////////////////////////////////////////////
// Méthodes
///////////////////////////////////////////////////////////////////////

#region Function addIndicators
addIndicators = function() {show_debug_message("### oFieldParentHero.addIndicators")
	
	// Définit la liste des indicateurs à créer
	var indicators = type == "Monster" ? [oM0, oM1, oM2, oM3, oM4] : [oT0, oT1, oT2, oT3, oT4];
	
	// Créer les indicateurs
	for (var i=0;i<array_length(cards);i++)
		if(!cards[i])
			instance_create_layer(posLocation[i][0], posLocation[i][1], layer_get_id("Instances"), indicators[i]);
}
#endregion
