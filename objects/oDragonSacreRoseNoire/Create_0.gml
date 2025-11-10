event_inherited();  // Hérite des variables et comportement de oCardMonster

// Définit les stats spécifiques de ce monstre
name = "Dragon sacré par la Rose noire"
attack = 0;
defense = 2500;
star = 2; // Niveau 1 - pas de sacrifice requis pour l'invocation
lastTurnAttack = 0;
genre = "Dragon"
archetype = "Rose noire"
booster = "Chemin perdu"
rarity = "commun"
is_player_card = true; // Définit explicitement cette carte comme appartenant au joueur
description = "Ne peut pas attaquer directement. Cette carte gagne 500 atk pour chaque monstre Rose noire dans le cimetière des 2 joueurs."

// Limitation d'exemplaires en deck (définie au niveau de l'objet)
limited = 1;

// Propriétés pour le système de dégâts générique
effective_attack = attack;
effective_defense = defense;
cannotAttackDirect = true;

// Définition des effets via le système de triggers/effects
effects = [
    {
        id: 1,
        trigger: TRIGGER_CONTINUOUS,
        effect_type: EFFECT_BOOST_ATK_PER_GRAVEYARD_ARCHETYPE,
        archetype: "Rose noire",
        boost_per_card: 500,
        description: "Gagne 500 ATK par monstre 'Rose noire' dans les cimetières."
    }
];