// S'assurer que les propriétés de carte existent
if (!variable_instance_exists(id, "type")) type = "";
if (!variable_instance_exists(id, "attack")) attack = 0;
if (!variable_instance_exists(id, "defense")) defense = 0;
if (!variable_instance_exists(id, "star")) star = 0;
if (!variable_instance_exists(id, "name")) name = "";
if (!variable_instance_exists(id, "description")) description = "";
if (!variable_instance_exists(id, "booster")) booster = "";

// Variables de sélection
isSelected = false;
isHovered = false;
isTargetableForFloraison = false;