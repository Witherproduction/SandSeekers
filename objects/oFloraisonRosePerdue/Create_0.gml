event_inherited();  // Hérite des variables et comportement de oCardMagic

// Définit les stats spécifiques de ce sort
name = "Floraison de la Rose Noire"
genre = "Direct"
archetype = "Rose noire"
rarity = "commun"
booster = "Chemin perdu"
is_player_card = true;

description = "Sélectionnez 1 carte 'Rose noire' que vous contrôlez ; détruisez-la, puis détruisez jusqu'à 2 cartes sur le terrain adverse (monstres ou magies).";

// Effet en deux parties via flow: 1) détruire une Rose noire alliée sélectionnée, 2) détruire jusqu'à 2 cartes adverses
effects = [
    {
        id: 1,
        trigger: TRIGGER_MAIN_PHASE,
        // Étape 1 (moderne): détruire 1 carte 'Rose noire' alliée via filtre
        effect_type: EFFECT_DESTROY,
        owner: "ally",
        target_zone: "Field",
        target_types: ["Monster", "Magic"], // au cas où une magie 'Rose noire' existe
        select_mode: "filter",
        criteria: { archetype: "Rose noire" },
        value: 1,
        random_select: false,
        description: "Détruisez 1 carte 'Rose noire' que vous contrôlez.",
        // Étape 2 en flow: détruire jusqu'à 2 cartes adverses (monstres ou magies) sur le terrain
        flow: [
            {
                id: 2,
                effect_type: EFFECT_DESTROY,
                owner: "enemy",
                target_zone: "Field",
                target_types: ["Monster", "Magic"],
                value: 2,
                random_select: true,
                description: "Puis détruisez jusqu'à 2 cartes sur le terrain adverse (monstres ou magies)."
            }
        ]
    }
];