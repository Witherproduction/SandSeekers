event_inherited();  // Hérite des variables et comportement de oCardMonster

// Définit les stats spécifiques de ce monstre
name = "Chevalier squelette réanimé"
attack = 1000;
defense = 1000;
star = 2;
genre = "Mort-vivant"
archetype = "Neutre"
booster = "Chemin perdu"
rarity = "commun"
lastTurnAttack = 0;
is_player_card = true; // Définit explicitement cette carte comme appartenant au joueur
description = "Tombe : Invoque un Squelette réanimé depuis votre main, deck ou cimetière."

// Ajout de l'effet (même fonctionnement que la version Rose noire):
// À la destruction, invoquez spécialement un "Squelette réanimé" depuis la main, le deck ou le cimetière
effects = [
    {
        trigger: TRIGGER_ON_DESTROY,
        effect_type: EFFECT_SUMMON,
        summon_mode: "named",
        target_object: "oSqueletteReanime",
        description: "À la destruction : Invoquez spécialement un Squelette réanimé depuis la main, le deck ou le cimetière."
    }
];
