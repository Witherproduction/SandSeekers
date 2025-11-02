// === Code de création de la room rCollection ===
show_debug_message("### rCollection - Room Creation Code");

// Crée l'instance de la base de données si elle n'existe pas
if (!instance_exists(oDataBase)) {
    show_debug_message("Création de oDataBase");
    instance_create_layer(0, 0, "Instances", oDataBase);
} else {
    show_debug_message("oDataBase existe déjà");
}

// Charger les decks sauvegardés depuis le fichier
show_debug_message("### Chargement des decks sauvegardés...");
load_decks_from_file();

// Note: Les autres objets (oCardViewer, oDeckList, oFiltre, oTri) sont maintenant
// placés directement dans la room via l'éditeur GameMaker

show_debug_message("### rCollection initialisée");