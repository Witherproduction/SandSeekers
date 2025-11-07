// oCardMonster - Create event
event_inherited();
type = "Monster";

// Ici tu peux ajouter d'autres variables propres aux monstres, par exemple :
attack = 0;
defense = 0;
// Système de niveau des monstres:
// 0 = jeton
// 1 = inférieur
// 2 = intermédiaire
// 3 = supérieur
star = 0;
orientation = "Attack";
isFaceDown = false;
// Ne pas forcer l'état initial en fonction de isHeroOwner ici,
// car isHeroOwner est souvent assigné après la création par oDeck/oHand.
// L'orientation et l'état face cachée seront gérés lors du placement en main/terrain.
orientationChangedThisTurn = false;
is_player_card = isHeroOwner; // Initialise is_player_card en fonction de isHeroOwner
// Initialize attack status
attackModeActivated = false;

// Attaques par tour (par défaut: 1)
if (!variable_instance_exists(id, "maxAttacksPerTurn")) maxAttacksPerTurn = 1;
attacksUsedThisTurn = 0;