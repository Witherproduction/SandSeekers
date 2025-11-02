///////////////////////////////////////////////////////////////////////
// Méthodes
///////////////////////////////////////////////////////////////////////

//----------------------------------
// Terrain
//----------------------------------

// Récupère le terrain Monstre/MagicTrap du Héro/Ennemi
#region Function getField
getField = function(type) {show_debug_message("### oFieldManagerParent.getField");
    var target = noone;
    var isHero = (variable_instance_exists(id, "isHeroOwner") && isHeroOwner);
    if (isHero) {
        target = (type == "Monster") ? fieldMonsterHero : fieldMagicTrapHero;
        if (!instance_exists(target)) {
            target = (type == "Monster") ? instance_find(oFieldMonsterHero, 0) : instance_find(oFieldMagicTrapHero, 0);
        }
    } else {
        target = (type == "Monster") ? fieldMonsterEnemy : fieldMagicTrapEnemy;
        if (!instance_exists(target)) {
            target = (type == "Monster") ? instance_find(oFieldMonsterEnemy, 0) : instance_find(oFieldMagicTrapEnemy, 0);
        }
    }
    if (!instance_exists(target)) {
        show_debug_message("### ERREUR: Champ introuvable pour type=" + string(type) + ", isHero=" + string(isHero));
        return noone;
    }
    return target;
}
#endregion


// Retourne la localisation [X, Y] d'une position d'un terrain
#region Function getCardPosition
getPosLocation = function(type, position) {show_debug_message("### oFieldManagerParent.getPosLocation");
    var field = getField(type);
    if (field == noone || !instance_exists(field)) {
        show_debug_message("### ERREUR: getPosLocation: terrain introuvable pour type=" + string(type));
        return [0, 0];
    }
    return field.posLocation[position];
}
#endregion


//----------------------------------
// Cartes
//----------------------------------

// Ajoute une carte sur le terrain
#region Function add
add = function(card) {show_debug_message("### oFieldManagerParent.add");
    var field = getField(card.type);
    if (field == noone || !instance_exists(field)) {
        show_debug_message("### ERREUR: add: terrain introuvable pour type=" + string(card.type));
        return;
    }
    field.cards[card.fieldPosition] = card;
}
#endregion


// Retire une carte
#region Function remove
remove = function(card) {show_debug_message("### oFieldManagerParent.remove");
    var field = getField(card.type);
    if (field == noone || !instance_exists(field)) {
        show_debug_message("### ERREUR: remove: terrain introuvable pour type=" + string(card.type));
        return;
    }
    field.cards[card.fieldPosition] = 0;
}
#endregion

// Récupère tous les monstres disponibles sur le terrain pour sacrifice
#region Function getMonstersOnField
getMonstersOnField = function() {
    show_debug_message("### oFieldManagerParent.getMonstersOnField");
    var monsters = [];
    var monsterField = getField("Monster");
    if (monsterField == noone || !instance_exists(monsterField)) {
        show_debug_message("### ERREUR: getMonstersOnField: terrain Monstre introuvable");
        return monsters;
    }
    for(var i = 0; i < array_length(monsterField.cards); i++) {
        var card = monsterField.cards[i];
        if(card != 0 && card.type == "Monster") {
            array_push(monsters, card);
        }
    }
    show_debug_message("### Monstres disponibles pour sacrifice: " + string(array_length(monsters)));
    return monsters;
}
#endregion
