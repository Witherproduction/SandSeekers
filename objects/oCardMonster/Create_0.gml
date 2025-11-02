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
if (!isHeroOwner) {
    isFaceDown = true;
    orientation = "Defense";
    image_angle = 270; // Face cachée
}
orientationChangedThisTurn = false;
is_player_card = isHeroOwner; // Initialise is_player_card en fonction de isHeroOwner
// Initialize attack status
attackModeActivated = false;

// Attaques par tour (par défaut: 1)
if (!variable_instance_exists(id, "maxAttacksPerTurn")) maxAttacksPerTurn = 1;
attacksUsedThisTurn = 0;

scr_toggle_orientation(self)