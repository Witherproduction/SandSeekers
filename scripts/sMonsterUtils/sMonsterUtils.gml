function sMonsterUtils(){

}

/// @function has_any_monster_on_field()
/// @description Retourne true s'il existe au moins un monstre présent sur le terrain (peu importe le camp), en excluant les monstres face cachée
/// @returns {bool}
function has_any_monster_on_field() {
    var found = false;
    with (oCardMonster) {
        if (variable_instance_exists(self, "zone") && (zone == "Field" || zone == "FieldSelected")) {
            // Exclure tous les monstres face cachée
            var isFaceDownMonster = (variable_instance_exists(self, "isFaceDown") && isFaceDown);
            if (!isFaceDownMonster) {
                found = true;
            }
        }
    }
    return found;
}