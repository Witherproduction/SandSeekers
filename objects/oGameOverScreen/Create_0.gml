show_debug_message("### oGameOverScreen.create")

// Variables pour l'affichage
isVictory = false; // Sera défini par l'objet qui crée cette instance
alpha = 0; // Transparence pour l'animation d'apparition
targetAlpha = 0.8; // Transparence cible pour l'assombrissement
animationSpeed = 0.05; // Vitesse d'animation

// Variables pour le texte
messageText = "";
messageColor = c_white;
messageFont = -1; // Sera défini dans l'événement Draw

// Position du message (centre de l'écran)
messageX = room_width / 2;
messageY = room_height / 2;

// Variables pour le bouton "Continuer"
buttonText = "Continuer";
buttonWidth = 200;
buttonHeight = 50;
buttonX = room_width / 2;
buttonY = room_height / 2 + 120;
buttonColor = #4CAF50; // Vert
buttonTextColor = c_white;
buttonHover = false;

// La définition du message sera faite dans l'événement Draw
// pour s'assurer que isVictory est correctement définie

// Mettre cet objet au premier plan pour bloquer tous les clics
depth = -1000;

show_debug_message("### Écran de fin de partie créé - Victoire: " + string(isVictory));