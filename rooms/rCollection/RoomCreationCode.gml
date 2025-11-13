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

// Musique de fond pour les rooms hors Duel
if (!variable_global_exists("bgm_asset")) {
    var _nm = "MainTheme";
    var _idx = asset_get_index(_nm);
    if (_idx == -1) { _idx = asset_get_index("sndMainTheme"); }
    global.bgm_asset = _idx;
}
if (!variable_global_exists("bgm_enabled")) global.bgm_enabled = true;
if (global.bgm_enabled && global.bgm_asset != -1) {
    if (!audio_is_playing(global.bgm_asset)) {
        audio_play_sound(global.bgm_asset, 0, true);
    }
}