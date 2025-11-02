event_inherited();  // Hérite des variables et comportement de oCardMonster

// Définit les stats spécifiques de ce monstre
name = "Chevalier squelette réanimé par la Rose"
attack = 2000;
defense = 2000;
star = 2; // Niveau 1 - pas de sacrifice requis pour l'invocation
lastTurnAttack = 0;
genre = "Mort-Vivant"
archetype = "Rose noire"
booster = "Chemin perdu"
rarity = "commun"
is_player_card = true; // Définit explicitement cette carte comme appartenant au joueur
description = "Tombe : invoquez specialement un Squelette possede par la Rose noire depuis votre deck, cimetière ou main."

// Effet déclenché : À la destruction, invoquer spécialement le Squelette par nom/objet
effects = [
    {
        trigger: TRIGGER_ON_DESTROY,
        effect_type: EFFECT_SUMMON,
    summon_mode: "named",
        // On cible par objet pour fiabilité
        target_object: "oSquelettePossedeParLaRoseNoire",
        description: "Tombe : Invoquez spécialement un Squelette possédé par la Rose noire depuis main/deck/cimetière."
    }
];
