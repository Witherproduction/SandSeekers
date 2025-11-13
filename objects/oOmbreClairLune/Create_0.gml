event_inherited();  // Hérite des variables et comportement de oCardMonster

// Définit les stats spécifiques de ce monstre
name = "Ombre du Clair-de-lune"
attack = 0;
defense = 0;
star = 1;
genre = "Mort-vivant"
archetype = "Neutre"
booster = "Chemin perdu"
rarity = "commun"
lastTurnAttack = 0;
is_player_card = true; // Définit explicitement cette carte comme appartenant au joueur
description = "Perdu : Pioche une carte puis défausse une carte de votre main."
// Description mise à jour et ajout des effets cimetière
description = "Tombe : piochez 1 carte puis défaussez au hasard 1 carte de votre main.";

effects = [
    {
        trigger: TRIGGER_ENTER_GRAVEYARD,
        effect_type: EFFECT_DRAW_CARDS,
        value: 1,
        flow: [
            { effect_type: EFFECT_TEMPO, ms: 1000 },
            { effect_type: EFFECT_DISCARD, selection: { mode: "random", count: 1 }, description: "Puis défaussez au hasard 1 carte de votre main." }
        ],
        description: "Quand cette carte entre au cimetière : piochez 1 carte, puis défaussez au hasard 1 carte de votre main."
    }
];
