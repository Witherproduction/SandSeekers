function scr_toggle_orientation(card_instance) {
    with (card_instance) {
        toggleOrientation = function() {
            if (orientationChangedThisTurn) {
                show_debug_message("Orientation already changed this turn");
                return; // On ne change pas deux fois
            }

            if (orientation == "Defense") {
                orientation = "Attack";
                image_angle = 0;
                image_index = 0;
            }
            else if (orientation == "Attack") {
                orientation = "DefenseVisible";
                image_angle = 90;
                image_index = 0;
            }
            else if (orientation == "DefenseVisible") {
                orientation = "Attack";
                image_angle = 0;
                image_index = 0;
            }
            else if (isFaceDown) {
                // Ne rien faire si la carte est face cachée
                return;
            }

            orientationChangedThisTurn = true;
        }
    }
}
