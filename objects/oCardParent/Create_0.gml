// S'assurer que les propriétés de carte existent
if (!variable_instance_exists(id, "type")) type = "";
if (!variable_instance_exists(id, "attack")) attack = 0;
if (!variable_instance_exists(id, "defense")) defense = 0;
if (!variable_instance_exists(id, "star")) star = 0;
if (!variable_instance_exists(id, "name")) name = "";
if (!variable_instance_exists(id, "description")) description = "";
if (!variable_instance_exists(id, "booster")) booster = "";

// Champs additionnels pour l'affichage dynamique
if (!variable_instance_exists(id, "genre")) genre = "";
if (!variable_instance_exists(id, "archetype")) archetype = "";
// Coût/ATK/DEF alternatifs si utilisés ailleurs
if (!variable_instance_exists(id, "atk")) atk = attack; // miroir
if (!variable_instance_exists(id, "def")) def = defense; // miroir
if (!variable_instance_exists(id, "cost")) cost = star; // miroir
// Limite par défaut
if (!variable_instance_exists(id, "limited")) limited = 3;

// Variables de sélection
isSelected = false;
isHovered = false;
isTargetableForFloraison = false;