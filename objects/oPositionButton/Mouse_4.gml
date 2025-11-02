show_debug_message("### oPositionButton.Click");
if (global.isGraveyardViewerOpen) exit;
show_debug_message("parentCard: " + string(parentCard));

// Vérifier que la carte parente existe
if (parentCard == noone || !instance_exists(parentCard)) {
    show_debug_message("ERROR: parentCard is invalid or doesn't exist");
    return;
}

// Si une animation est déjà en cours, on ne bloque plus : on va recibler
if (variable_instance_exists(parentCard, "position_anim_active") && parentCard.position_anim_active) {
    show_debug_message("Animation already active: retargeting to new orientation");
}

show_debug_message("parentCard exists, preparing animated position change");

// Déclencher une animation sur la carte parente
with (parentCard) {
    show_debug_message("Inside parentCard, orientation: " + string(orientation));
    show_debug_message("orientationChangedThisTurn: " + string(orientationChangedThisTurn));
    
    // Vérifier si on peut changer l'orientation
    if (orientationChangedThisTurn) {
        show_debug_message("Orientation already changed this turn");
    } else {
        // Paramètres d'animation (ralentis via constantes globales)
        position_anim_active = true;
        anim_rotate_speed = (variable_global_exists("ANIM_ROTATE_SPEED") ? global.ANIM_ROTATE_SPEED : 6);
        anim_flip_speed = (variable_global_exists("ANIM_FLIP_SPEED") ? global.ANIM_FLIP_SPEED : 0.03);
        anim_flip_orig_scale = image_xscale;
        anim_pre_delay_frames = (variable_global_exists("ANIM_ROTATE_PRE_DELAY_FRAMES") ? global.ANIM_ROTATE_PRE_DELAY_FRAMES : 6);
        
        // Angles cibles selon le camp (héros vs ennemi)
        var atk_angle = (variable_instance_exists(id, "isHeroOwner") && isHeroOwner) ? 0 : 180;
        var def_vis_angle = (variable_instance_exists(id, "isHeroOwner") && isHeroOwner) ? 90 : 270;
        
        // Selon l'état actuel, définir la séquence et les cibles
        if (orientation == "Defense") {
            // Révéler immédiatement pour éviter les écrasements visuels
            image_index = 0;
            if (variable_instance_exists(id, "isFaceDown")) isFaceDown = false;
            // Séquence flip -> rotate vers l'attaque
            anim_phase = "flip_in";
            target_angle = atk_angle;                // Attaque (0° héros, 180° ennemi)
            target_orientation = "Attack";
        }
        else if (orientation == "Attack") {
            // Attaque -> Défense visible
            anim_phase = "rotate";
            target_angle = def_vis_angle;            // Défense visible
            target_orientation = "DefenseVisible";
            image_index = 0;                         // s'assurer que la carte est face visible
            if (variable_instance_exists(id, "isFaceDown")) isFaceDown = false;
        }
        else if (orientation == "DefenseVisible") {
            // Défense visible -> Attaque
            anim_phase = "rotate";
            target_angle = atk_angle;                // Attaque
            target_orientation = "Attack";
            image_index = 0;
            if (variable_instance_exists(id, "isFaceDown")) isFaceDown = false;
        }

        // Si on recible une animation déjà active de type rotation, réinitialiser proprement la phase
        if (position_anim_active && anim_phase == "rotate") {
            if (variable_instance_exists(id, "anim_init_rotate")) anim_init_rotate = false;
        }
    }
}

show_debug_message("Position change animation started for card: " + string(parentCard.name));

// Empêche la propagation du clic vers les objets en dessous
exit;