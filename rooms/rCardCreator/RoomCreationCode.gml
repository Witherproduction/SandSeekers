// === Code de création de la room rCardCreator ===
show_debug_message("### rCardCreator - Room Creation Code");

// Crée l'instance de la base de données si elle n'existe pas
if (!instance_exists(oDataBase)) {
    show_debug_message("Création de oDataBase dans rCardCreator");
    instance_create_layer(0, 0, "UI", oDataBase);
} else {
    show_debug_message("oDataBase existe déjà dans rCardCreator");
}

show_debug_message("### rCardCreator initialisée");