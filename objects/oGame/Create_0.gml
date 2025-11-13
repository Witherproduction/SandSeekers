show_debug_message("### oGame.create")

///////////////////////////////////////////////////////////////////////
// Attributs
///////////////////////////////////////////////////////////////////////

// Charger et appliquer les options utilisateur au lancement du jeu
if (!variable_global_exists("options_loaded") || !global.options_loaded) {
    // Volume
    ini_open("options.ini");
    var _ini_vol = ini_read_real("audio", "volume_percent", 100);
    ini_close();
    global.volume_percent = clamp(_ini_vol, 0, 100);
    audio_master_gain(global.volume_percent / 100);

    // Plein écran
    ini_open("options.ini");
    var _fs_default = window_get_fullscreen() ? 1 : 0;
    var _ini_fs = ini_read_real("display", "fullscreen", _fs_default);
    ini_close();
    var _fs_enabled = (_ini_fs >= 0.5);
    window_set_fullscreen(_fs_enabled);

    // Résolution (appliquée uniquement en mode fenêtré)
    ini_open("options.ini");
    var _current_w = window_get_width();
    var _current_h = window_get_height();
    var _default_res = string(_current_w) + "x" + string(_current_h);
    var _res_str = ini_read_string("display", "resolution", _default_res);
    ini_close();

    if (!_fs_enabled) {
        var _xpos = string_pos("x", _res_str);
        if (_xpos > 0) {
            var _new_w = real(string_copy(_res_str, 1, _xpos - 1));
            var _new_h = real(string_copy(_res_str, _xpos + 1, string_length(_res_str) - _xpos));
            window_set_size(_new_w, _new_h);
            window_center();
        }
    }

    global.options_loaded = true;
}

// Initialiser le générateur pseudo-aléatoire une seule fois par session
if (!variable_global_exists("rng_initialized") || !global.rng_initialized) {
    randomize();
    global.rng_initialized = true;
    show_debug_message("### RNG initialisé avec randomize() pour cette session");
}

timerPick = 0.5;
timerEnabledPick = true;
global.isGraveyardViewerOpen = false;

// === Animation globals ===
if (!variable_global_exists("ANIM_ROTATE_SPEED")) global.ANIM_ROTATE_SPEED = 6;      // deg/step
if (!variable_global_exists("ANIM_FLIP_SPEED")) global.ANIM_FLIP_SPEED = 0.03;        // scale/step
if (!variable_global_exists("ANIM_ROTATE_PRE_DELAY_FRAMES")) global.ANIM_ROTATE_PRE_DELAY_FRAMES = 6; // frames

// Activer l’animation de combat via FX_Combat
if (!variable_global_exists("USE_COMBAT_FX")) global.USE_COMBAT_FX = true;

// Niveau de difficulté IA: 0=Normal, 1=Difficile
if (!variable_global_exists("IA_DIFFICULTY")) global.IA_DIFFICULTY = 0;

// Ajouter un flag global pour contrôler la verbosité des logs (par défaut désactivé)
if (!variable_global_exists("VERBOSE_LOGS")) global.VERBOSE_LOGS = false;

// Limite de taille de main (IA et Héros)
if (!variable_global_exists("MAX_HAND_SIZE")) global.MAX_HAND_SIZE = 10;

// Variable pour sauvegarder la room précédente avant d'entrer dans rDuel
if (!variable_global_exists("previous_room_before_duel")) {
    global.previous_room_before_duel = rMode; // Valeur par défaut
}

// Initialiser les variables globales des cimetières
// Ces variables seront assignées aux instances réelles dans la room rDuel
global.graveyardHero = noone;
global.graveyardEnemy = noone;

// Fonction pour initialiser les cimetières (appelée après création de la room)
initializeGraveyards = function() {
    // Trouver les cimetières par leurs coordonnées exactes (comme dans oDamageManager)
    with (oGraveyard) {
        if (abs(x - 1514.7029) < 1 && abs(y - 688.0) < 1) {
            global.graveyardHero = id;
            isHeroOwner = true;
        } else if (abs(x - 452.9149) < 1 && abs(y - 282.0) < 1) {
            global.graveyardEnemy = id;
            isHeroOwner = false;
        }
    }
    
    if (variable_global_exists("VERBOSE_LOGS") && global.VERBOSE_LOGS) {
        show_debug_message("### Cimetières initialisés - Hero: " + string(global.graveyardHero) + ", Enemy: " + string(global.graveyardEnemy));
    }
}

phase = ["Pick", "Summon", "Attack"];
player = ["Hero", "Enemy"];
phase_current = 0;
global.current_phase = phase[phase_current];
player_current = 0;
nbTurn = 1;
timerIA = 0;
timerEnabledIA = false;


// Limites par joueur
hasSummonedThisTurn = [false, false];

// Assurer la présence de la base de données des cartes (singleton)
if (!instance_exists(oDataBase)) {
    instance_create_layer(864, 32, "Instances", oDataBase);
    show_debug_message("### oGame: oDataBase créé automatiquement");
}

///////////////////////////////////////////////////////////////////////
// Méthodes


#region Function nextPhase
nextPhase = function() {
    show_debug_message("### oGame.nextPhase")

    if (phase[phase_current] == "Attack") {
        // Fin du tour: déclenche les effets de fin
        registerTriggerEvent(TRIGGER_END_TURN, noone, {});
        player_current = (player_current + 1) % 2;
        nextStep.image_alpha = 0.5;
        nbTurn++;
    }

    phase_current = (phase_current + 1) % 3;
    global.current_phase = phase[phase_current];

    // Réinitialisation des états au début du tour
  if (phase[phase_current] == "Pick") {
    hasSummonedThisTurn[player_current] = false;

    // Réinitialise orientation pour tous les monstres du joueur actif
 with (oCardMonster) {
    if ((isHeroOwner && oGame.player[oGame.player_current] == "Hero") ||
        (!isHeroOwner && oGame.player[oGame.player_current] == "Enemy")) {
        orientationChangedThisTurn = false;
        if (variable_instance_exists(id, "attacksUsedThisTurn")) attacksUsedThisTurn = 0;
    }
}

    // Début du tour: déclenche les effets de début
    registerTriggerEvent(TRIGGER_START_TURN, noone, {});

}
    if (player[player_current] == "Enemy") {
        timerIA = 1;
        timerEnabledIA = true;
    }
}
#endregion
