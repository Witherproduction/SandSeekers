// === Initialisation des variables de tri ===

// Mode de tri par defaut
if (!variable_global_exists("sort_mode")) {
    global.sort_mode = "none";
}

// Ordre de tri (true = décroissant, false = croissant)
if (!variable_global_exists("sort_descending")) {
    global.sort_descending = true;
}

// Variable pour indiquer le bouton actif
sort_active_button = "none";