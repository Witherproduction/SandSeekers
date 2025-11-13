// sAIConfig.gml — Profils d’archétypes et API de configuration des bots

// Crée un profil vide avec toutes les clés communes initialisées à des valeurs neutres
function AI_Profile_New() {
    return {
        // Priorités d’actions (0–100)
        summon_weight: 50,
        continuous_weight: 50,
        manual_effect_weight: 50,
        secret_weight: 50,
        removal_weight: 50,
        board_presence_weight: 50,
        draw_weight: 50,
        tutor_weight: 50,

        // Comportement
        risk_tolerance: 50,
        attack_bias: 50,
        defense_bias: 50,
        defense_trigger_margin: 50, // seuil d’écart d’ATK adverse pour basculer en Défense

        // Sacrifices et équipements
        sacrifice_tolerance: 50,
        equip_threshold: 50,
        equip_safe_target: true,

        // Politiques de ciblage
        target_monster_policy: "utility", // strongest | weakest | utility
        target_spell_policy: "value",     // value | tempo | none

        // Spécifiques d’archétypes
        quick_effect_reactivity: 50,
        direct_damage_bias: 50,
        lock_bias: 50,
        mill_bias: 50,
        discard_bias: 50,
        counter_bias: 50
    };
};

// Retourne un profil prédéfini selon l’archétype demandé
function AI_Config_GetProfile(style) {
    var s = string_lower(style);
    var p = AI_Profile_New();
    switch (s) {
        case "aggro":
            p.summon_weight = 90; p.continuous_weight = 60; p.manual_effect_weight = 70; p.secret_weight = 45;
            p.removal_weight = 50; p.board_presence_weight = 90; p.draw_weight = 40; p.tutor_weight = 35;
            p.risk_tolerance = 80; p.attack_bias = 85; p.defense_bias = 20; p.defense_trigger_margin = 0;
            p.sacrifice_tolerance = 60; p.equip_threshold = 70; p.equip_safe_target = true;
            p.target_monster_policy = "strongest"; p.target_spell_policy = "tempo";
            p.quick_effect_reactivity = 60; p.direct_damage_bias = 70;
            break;

        case "tempo":
            p.summon_weight = 65; p.continuous_weight = 70; p.manual_effect_weight = 75; p.secret_weight = 70;
            p.removal_weight = 70; p.board_presence_weight = 70; p.draw_weight = 55; p.tutor_weight = 45;
            p.risk_tolerance = 50; p.attack_bias = 60; p.defense_bias = 55; p.defense_trigger_margin = 50;
            p.sacrifice_tolerance = 45; p.equip_threshold = 60; p.equip_safe_target = true;
            p.target_monster_policy = "utility"; p.target_spell_policy = "tempo";
            p.quick_effect_reactivity = 80; p.direct_damage_bias = 50;
            break;

        case "control":
            p.summon_weight = 50; p.continuous_weight = 75; p.manual_effect_weight = 80; p.secret_weight = 85;
            p.removal_weight = 90; p.board_presence_weight = 60; p.draw_weight = 75; p.tutor_weight = 55;
            p.risk_tolerance = 30; p.attack_bias = 45; p.defense_bias = 75; p.defense_trigger_margin = 100;
            p.sacrifice_tolerance = 35; p.equip_threshold = 55; p.equip_safe_target = true;
            p.target_monster_policy = "strongest"; p.target_spell_policy = "value";
            p.quick_effect_reactivity = 85; p.direct_damage_bias = 35;
            break;

        case "combo":
            p.summon_weight = 55; p.continuous_weight = 70; p.manual_effect_weight = 70; p.secret_weight = 60;
            p.removal_weight = 50; p.board_presence_weight = 55; p.draw_weight = 85; p.tutor_weight = 90;
            p.risk_tolerance = 65; p.attack_bias = 55; p.defense_bias = 55; p.defense_trigger_margin = 60;
            p.sacrifice_tolerance = 30; p.equip_threshold = 65; p.equip_safe_target = true;
            p.target_monster_policy = "utility"; p.target_spell_policy = "value";
            p.quick_effect_reactivity = 70; p.direct_damage_bias = 40;
            break;

        case "burn":
            p.summon_weight = 50; p.continuous_weight = 65; p.manual_effect_weight = 80; p.secret_weight = 60;
            p.removal_weight = 45; p.board_presence_weight = 50; p.draw_weight = 60; p.tutor_weight = 55;
            p.risk_tolerance = 70; p.attack_bias = 70; p.defense_bias = 35; p.defense_trigger_margin = 20;
            p.sacrifice_tolerance = 50; p.equip_threshold = 50; p.equip_safe_target = true;
            p.target_monster_policy = "weakest"; p.target_spell_policy = "tempo";
            p.quick_effect_reactivity = 65; p.direct_damage_bias = 90;
            break;

        case "ramp":
            p.summon_weight = 60; p.continuous_weight = 70; p.manual_effect_weight = 65; p.secret_weight = 65;
            p.removal_weight = 55; p.board_presence_weight = 65; p.draw_weight = 60; p.tutor_weight = 60;
            p.risk_tolerance = 55; p.attack_bias = 55; p.defense_bias = 65; p.defense_trigger_margin = 80;
            p.sacrifice_tolerance = 65; p.equip_threshold = 55; p.equip_safe_target = true;
            p.target_monster_policy = "utility"; p.target_spell_policy = "value";
            p.quick_effect_reactivity = 60; p.direct_damage_bias = 40;
            break;

        case "stompy":
            p.summon_weight = 85; p.continuous_weight = 60; p.manual_effect_weight = 65; p.secret_weight = 55;
            p.removal_weight = 60; p.board_presence_weight = 85; p.draw_weight = 45; p.tutor_weight = 45;
            p.risk_tolerance = 65; p.attack_bias = 85; p.defense_bias = 35; p.defense_trigger_margin = 20;
            p.sacrifice_tolerance = 55; p.equip_threshold = 70; p.equip_safe_target = true;
            p.target_monster_policy = "strongest"; p.target_spell_policy = "tempo";
            p.quick_effect_reactivity = 55; p.direct_damage_bias = 55;
            break;

        case "swarm":
            p.summon_weight = 80; p.continuous_weight = 75; p.manual_effect_weight = 70; p.secret_weight = 50;
            p.removal_weight = 50; p.board_presence_weight = 90; p.draw_weight = 55; p.tutor_weight = 50;
            p.risk_tolerance = 70; p.attack_bias = 80; p.defense_bias = 40; p.defense_trigger_margin = 30;
            p.sacrifice_tolerance = 70; p.equip_threshold = 60; p.equip_safe_target = true;
            p.target_monster_policy = "weakest"; p.target_spell_policy = "tempo";
            p.quick_effect_reactivity = 60; p.direct_damage_bias = 50;
            break;

        case "sacrifice":
            p.summon_weight = 65; p.continuous_weight = 70; p.manual_effect_weight = 80; p.secret_weight = 65;
            p.removal_weight = 60; p.board_presence_weight = 70; p.draw_weight = 65; p.tutor_weight = 60;
            p.risk_tolerance = 60; p.attack_bias = 60; p.defense_bias = 55; p.defense_trigger_margin = 50;
            p.sacrifice_tolerance = 85; p.equip_threshold = 55; p.equip_safe_target = true;
            p.target_monster_policy = "utility"; p.target_spell_policy = "value";
            p.quick_effect_reactivity = 70; p.direct_damage_bias = 45;
            break;

        case "aura":
            p.summon_weight = 60; p.continuous_weight = 90; p.manual_effect_weight = 70; p.secret_weight = 60;
            p.removal_weight = 55; p.board_presence_weight = 75; p.draw_weight = 70; p.tutor_weight = 65;
            p.risk_tolerance = 55; p.attack_bias = 65; p.defense_bias = 55; p.defense_trigger_margin = 50;
            p.sacrifice_tolerance = 40; p.equip_threshold = 80; p.equip_safe_target = true;
            p.target_monster_policy = "utility"; p.target_spell_policy = "value";
            p.quick_effect_reactivity = 65; p.direct_damage_bias = 45;
            break;

        case "prison":
            p.summon_weight = 50; p.continuous_weight = 85; p.manual_effect_weight = 75; p.secret_weight = 80;
            p.removal_weight = 70; p.board_presence_weight = 60; p.draw_weight = 65; p.tutor_weight = 70;
            p.risk_tolerance = 35; p.attack_bias = 50; p.defense_bias = 80; p.defense_trigger_margin = 120;
            p.sacrifice_tolerance = 40; p.equip_threshold = 60; p.equip_safe_target = true;
            p.target_monster_policy = "utility"; p.target_spell_policy = "value";
            p.quick_effect_reactivity = 85; p.lock_bias = 90; p.direct_damage_bias = 30;
            break;

        case "mill":
            p.summon_weight = 45; p.continuous_weight = 75; p.manual_effect_weight = 75; p.secret_weight = 70;
            p.removal_weight = 55; p.board_presence_weight = 55; p.draw_weight = 80; p.tutor_weight = 70;
            p.risk_tolerance = 45; p.attack_bias = 50; p.defense_bias = 70; p.defense_trigger_margin = 90;
            p.sacrifice_tolerance = 45; p.equip_threshold = 50; p.equip_safe_target = true;
            p.target_monster_policy = "utility"; p.target_spell_policy = "value";
            p.quick_effect_reactivity = 75; p.mill_bias = 90; p.direct_damage_bias = 20;
            break;

        case "discard":
            p.summon_weight = 55; p.continuous_weight = 70; p.manual_effect_weight = 80; p.secret_weight = 75;
            p.removal_weight = 65; p.board_presence_weight = 60; p.draw_weight = 70; p.tutor_weight = 60;
            p.risk_tolerance = 45; p.attack_bias = 55; p.defense_bias = 65; p.defense_trigger_margin = 80;
            p.sacrifice_tolerance = 50; p.equip_threshold = 55; p.equip_safe_target = true;
            p.target_monster_policy = "utility"; p.target_spell_policy = "value";
            p.quick_effect_reactivity = 80; p.discard_bias = 90; p.direct_damage_bias = 30;
            break;

        case "contre":
            p.summon_weight = 50; p.continuous_weight = 70; p.manual_effect_weight = 70; p.secret_weight = 85;
            p.removal_weight = 80; p.board_presence_weight = 55; p.draw_weight = 70; p.tutor_weight = 65;
            p.risk_tolerance = 35; p.attack_bias = 50; p.defense_bias = 75; p.defense_trigger_margin = 100;
            p.sacrifice_tolerance = 40; p.equip_threshold = 55; p.equip_safe_target = true;
            p.target_monster_policy = "utility"; p.target_spell_policy = "value";
            p.quick_effect_reactivity = 90; p.counter_bias = 90; p.direct_damage_bias = 25;
            break;

        default: // balanced
            p.summon_weight = 60; p.continuous_weight = 60; p.manual_effect_weight = 60; p.secret_weight = 60;
            p.removal_weight = 60; p.board_presence_weight = 60; p.draw_weight = 60; p.tutor_weight = 55;
            p.risk_tolerance = 50; p.attack_bias = 55; p.defense_bias = 55; p.defense_trigger_margin = 60;
            p.sacrifice_tolerance = 50; p.equip_threshold = 60; p.equip_safe_target = true;
            p.target_monster_policy = "utility"; p.target_spell_policy = "value";
            p.quick_effect_reactivity = 65; p.direct_damage_bias = 50; p.lock_bias = 50; p.mill_bias = 50; p.discard_bias = 50; p.counter_bias = 50;
            break;
    }
    return p;
};

// Initialise le conteneur de profils si nécessaire
function AI_Config_EnsureInit() {
    if (!variable_global_exists("BOT_PROFILES")) {
        global.BOT_PROFILES = array_create(4, undefined);
    }
};

// Affecte un profil à un bot (par id)
function AI_Config_SetBotProfile(bot_id, style) {
    AI_Config_EnsureInit();
    global.BOT_PROFILES[bot_id] = AI_Config_GetProfile(style);
};

// Récupère le profil d’un bot, sinon renvoie un profil équilibré
function AI_Config_GetBotProfile(bot_id) {
    AI_Config_EnsureInit();
    var p = global.BOT_PROFILES[bot_id];
    if (p == undefined) return AI_Config_GetProfile("balanced");
    return p;
};

// Helper: retourne le profil actif de l’ennemi (bot_id = 1 par convention existante)
function AI_Config_GetActiveProfile() {
    return AI_Config_GetBotProfile(1);
};

// Exemple d’usage (à appeler au début du duel):
// AI_Config_SetBotProfile(1, "aggro");
// var profile = AI_Config_GetActiveProfile();
// // Passer `profile` à sAIScoring/sAITargeting/sAIActionSelect ou y accéder globalement.