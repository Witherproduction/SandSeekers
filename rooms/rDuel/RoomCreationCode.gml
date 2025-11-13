// Arrêter la musique de fond en Duel
if (variable_global_exists("bgm_asset") && global.bgm_asset != -1) {
    if (audio_is_playing(global.bgm_asset)) {
        audio_stop_sound(global.bgm_asset);
    }
}