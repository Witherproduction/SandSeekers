event_inherited();  // Hérite des variables et comportement de oCardMonster

// Définit les stats spécifiques de ce monstre
name = "Pétale de la Rose Noire"
attack = 0;
defense = 0;
star = 1; // Niveau 1 - pas de sacrifice requis pour l'invocation
lastTurnAttack = 0;
genre = "Elementaire"
archetype = "Rose noire"
rarity = "commun"
is_player_card = true; // Définit explicitement cette carte comme appartenant au joueur
description = "Perdue : ajoutez aléatoirement une carte 'Rose noire' depuis votre cimetière à votre deck."

// Effet: lorsqu'elle entre au cimetière, récupérer aléatoirement une carte correspondant aux critères depuis le cimetière vers le deck
if (!variable_instance_exists(id, "effects")) effects = [];
array_push(effects, {
    id: "petale_gy_search_to_deck",
    trigger: TRIGGER_ENTER_GRAVEYARD,
    effect_type: EFFECT_SEARCH,
    search_location: "Graveyard", // Recherche dans le cimetière
    destination: "Deck", // Ajoute au deck
    search_criteria: { archetype: "Rose noire", type: "Magic" },
    shuffle_deck: true, // Mélange le deck après l'ajout
    
});