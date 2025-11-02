// FX_Combat - Create
// Animation de combat: approche de l’attaquant, impact avec secousse, puis résolution

// Attendus via spawner (oDamageManager.tryAttack):
// - attacker: instance carte attaquante (oCardMonster)
// - defender: instance carte ciblée (ou noone pour attaque directe)
// - mode: "vsMonster" ou "direct"

// Sauvegarde position initiale de l’attaquant
start_x = (variable_instance_exists(self, "attacker") && attacker != noone) ? attacker.x : x;
start_y = (variable_instance_exists(self, "attacker") && attacker != noone) ? attacker.y : y;

// Déterminer cible
var tx = start_x;
var ty = start_y;
if (variable_instance_exists(self, "defender") && defender != noone) {
    tx = defender.x; ty = defender.y;
} else {
    // Attaque directe: choisir cible selon le camp de l’attaquant
    if (variable_instance_exists(self, "mode") && mode == "direct") {
        var attacker_is_hero = true;
        if (variable_instance_exists(self, "attacker") && attacker != noone && instance_exists(attacker)) {
            if (variable_instance_exists(attacker, "isHeroOwner")) {
                attacker_is_hero = attacker.isHeroOwner;
            } else {
                // Fallback: déduire le camp par la position à l’écran
                attacker_is_hero = (attacker.y >= room_height * 0.5);
            }
        }
        if (attacker_is_hero) {
            // Attaque directe du héros vers l’ennemi: viser le bouton ennemi si présent, sinon centre haut
            var btn = instance_find(oAttackDirectEnemy, 0);
            if (btn != noone) {
                tx = btn.x;
                ty = btn.y;
            } else {
                tx = room_width * 0.5;
                ty = 120;
            }
        } else {
            // Attaque directe de l’ennemi vers le héros: viser l’UI LP héros si présente, sinon centre bas
            var lpHero = instance_find(LP_Hero, 0);
            if (lpHero != noone) {
                tx = lpHero.x;
                ty = lpHero.y;
            } else {
                tx = room_width * 0.5;
                ty = room_height - 120;
            }
        }
    } else {
        // Sinon, viser l’indicateur LP ennemi si dispo, fallback au centre haut
        var lp = instance_find(LP_Enemy, 0);
        if (lp != noone) { tx = lp.x; ty = lp.y; } else { tx = room_width * 0.5; ty = 120; }
    }
}
// Cible à secouer (défenseur sinon LP ennemi)
shake_target_inst = (variable_instance_exists(self, "defender") && defender != noone) ? defender : instance_find(LP_Enemy, 0);
// Désactiver la secousse pour l’attaque directe
if (variable_instance_exists(self, "mode") && mode == "direct") {
    shake_target_inst = noone;
}
shake_target_orig_x = (shake_target_inst != noone) ? shake_target_inst.x : 0;
shake_target_orig_y = (shake_target_inst != noone) ? shake_target_inst.y : 0;

// Calcul du point d’impact à une certaine marge de la cible
var dx = tx - start_x;
var dy = ty - start_y;
var dist = max(1, point_distance(start_x, start_y, tx, ty));
var nx = dx / dist;
var ny = dy / dist;
impact_margin_px = 48;
impact_x = tx - nx * impact_margin_px;
impact_y = ty - ny * impact_margin_px;

// Durées par défaut (basées sur room_speed)
approach_frames = round(0.22 * room_speed);
shake_frames    = round(0.25 * room_speed);
return_frames   = round(0.18 * room_speed);

// Secousse: amplitude basée sur l’écart d’ATK/DEF (si défenseur présent)
shake_amp_px = 6;
shake_side = "defender"; // "attacker" | "defender" | "both"
if (variable_instance_exists(self, "defender") && defender != noone && variable_instance_exists(self, "attacker") && attacker != noone) {
    var compareVal = 0;
    if (defender.orientation == "Attack") {
        compareVal = attacker.attack - defender.attack;
    } else {
        // Defense ou DefenseVisible
        compareVal = attacker.attack - defender.defense;
    }
    if (compareVal > 0) shake_side = "defender"; else if (compareVal < 0) shake_side = "attacker"; else shake_side = "both";
    shake_amp_px = clamp(abs(compareVal) / 300, 3, 10);
}

// Sauvegardes pour restauration
attacker_orig_pos_anim = false;
if (variable_instance_exists(self, "attacker") && attacker != noone) {
    if (variable_instance_exists(attacker.id, "position_anim_active") && attacker.position_anim_active) {
        attacker_orig_pos_anim = true;
        attacker.position_anim_active = false; // verrouiller animation d’orientation pendant le combat
    }
}

defender_orig_x = (variable_instance_exists(self, "defender") && defender != noone) ? defender.x : 0;
defender_orig_y = (variable_instance_exists(self, "defender") && defender != noone) ? defender.y : 0;
attacker_orig_x = start_x;
attacker_orig_y = start_y;

// Timer/phase
_t = 0;
phase = "approach"; // approach -> impact -> resolve -> return -> done
initialized = false;