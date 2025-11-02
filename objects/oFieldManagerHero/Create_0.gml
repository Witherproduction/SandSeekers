show_debug_message("### oFieldManagerHero.create - before event_inherited")
event_inherited();
show_debug_message("### oFieldManagerHero.create - after event_inherited")


#region Function addIndicators
addIndicators = function(type) {show_debug_message("### oFieldManagerParent.addIndicators");
	
	(type == "Monster" ? fieldMonsterHero : fieldMagicTrapHero).addIndicators();
}
#endregion
