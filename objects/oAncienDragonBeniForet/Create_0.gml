event_inherited();  // Hérite des variables et comportement de oCardMonster

// Définit les stats spécifiques de ce monstre
name = "Ancien dragon béni de la forêt"
attack = 2000;
defense = 2000;
star = 3;
genre = "Dragon"
archetype = "Rose noire"
booster = "Chemin perdu"
rarity = "commun"
lastTurnAttack = 0;
is_player_card = true; // Définit explicitement cette carte comme appartenant au joueur
description = "Appel : Ajoute un dragon de votre deck à votre main. Invoque le dragon s'il est de niveau 1."

// Effet avec système de flux : Recherche un Dragon puis l'invoque s'il est niveau 1
if (!variable_instance_exists(id, "effects")) effects = [];
array_push(effects, {
    id: "ancien_dragon_beni_foret_search_and_summon",
    trigger: TRIGGER_ON_SUMMON,
    effect_type: EFFECT_SEARCH,
    search_sources: ["Deck"],
    destination: "Hand",
    search_criteria: { genre: "Dragon", type: "Monster" },
    random_select: true,
    flow: [
        { effect_type: EFFECT_TEMPO, ms: 1000 },
        {
            effect_type: EFFECT_SUMMON,
            summon_mode: "source_from_hand",
            criteria: { type: "Monster", genre: "Dragon", star_eq: 1 },
            trigger_condition: "search_success",
            description: "Invoque automatiquement le Dragon trouvé s'il est de niveau 1."
        }
    ],
    description: "Appel : Ajoute un Dragon de votre deck à votre main. Invoque le dragon s'il est de niveau 1."
});
