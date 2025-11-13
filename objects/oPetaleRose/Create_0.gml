event_inherited();  // Hérite des variables et comportement de oCardMonster

// Définit les stats spécifiques de ce monstre
name = "Pétale de rose"
attack = 0;
defense = 0;
star = 1;
genre = "Elémentaire"
archetype = "Neutre"
booster = "Chemin perdu"
rarity = "commun"
lastTurnAttack = 0;
is_player_card = true; // Définit explicitement cette carte comme appartenant au joueur
description = "Perdu : Ajoute un sort depuis votre cimetière à votre deck."

// Effet : lorsqu'elle est envoyée au cimetière, ajoute un sort de votre cimetière à votre deck
effects = [
    {
        trigger: TRIGGER_ENTER_GRAVEYARD,
        effect_type: EFFECT_SEARCH,
        search_sources: ["Graveyard"],
        destination: "Deck", // Ajoute au deck
        shuffle_deck: true, // Mélange le deck à la fin de l'effet
        search_type: "Magic", // Limite aux cartes Magie
        description: "Quand cette carte entre au cimetière : ajoutez un sort depuis votre cimetière à votre deck."
    }
];
