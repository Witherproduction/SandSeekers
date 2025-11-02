// === oFiltre - Create Event ===
show_debug_message("### oFiltre.create");

// Variables pour le filtrage
filterText = ""; // Texte de filtrage saisi par l'utilisateur
isTyping = false; // Indique si l'utilisateur est en train de taper

// Position et dimensions de la barre de filtre (fond avec sButton)
// Alignement visuel par rapport à la barre de tri (oTri) actuellement :
// oTri: barX=310, barY=room_height-130, barWidth=920, barHeight=90
filterBarWidth = 550; // Réduit de 10px en longueur
filterBarHeight = 100; // Légèrement moins haut
filterBarY = room_height - 130;
filterBarX = 310 - filterBarWidth + 200; // Décale tout l'objet vers la droite de 200px au total

// Position et taille de la zone de saisie (centrée dans la barre de filtre)
filterBoxWidth = 300;
filterBoxHeight = 40;
filterBoxX = filterBarX + (filterBarWidth - filterBoxWidth) / 2;
filterBoxY = filterBarY + (filterBarHeight - filterBoxHeight) / 2;

// Couleurs (thème assorti à la barre de tri)
boxColor = make_color_rgb(60, 45, 25);       // fond sombre du champ
borderColor = make_color_rgb(230, 200, 120); // crème dorée pour la bordure
textColor = make_color_rgb(230, 200, 120);   // texte crème dorée
activeColor = make_color_rgb(120, 90, 45);   // éclaircir en mode actif

// Police
filterFont = fontCardDisplay;

show_debug_message("### oFiltre initialisé");