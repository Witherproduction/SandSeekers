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