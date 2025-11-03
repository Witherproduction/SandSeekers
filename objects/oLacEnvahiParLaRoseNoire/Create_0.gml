event_inherited();  // Hérite des variables et comportement de oCardMonster

// Définit les stats spécifiques de ce monstre
name = "Lac envahi par la Rose noire"
attack = 0;
defense = 2000;
star = 2; // Niveau 1 - pas de sacrifice requis pour l'invocation
lastTurnAttack = 0;
genre = "Démon"
archetype = "Rose noire"
rarity = "commun"
is_player_card = true; // Définit explicitement cette carte comme appartenant au joueur
description = "Défenseur : détruisez le monstre attaquant";

 effects = [
      {
          trigger: TRIGGER_AFTER_ATTACK,
           effect_type: EFFECT_DESTROY_TARGET,
           target_source: "attacker",
          label: "post-attaque",
           conditions: {
               owner: "Hero",
               zone: "Field",
               target_type: "Monster",
               opponent_turn: true
           },
           description: "Après qu'un adversaire attaque: détruisez le monstre attaquant."
       }
   ];