show_debug_message("### oSacrificeSelector.create");

///////////////////////////////////////////////////////////////////////
// Attributs
///////////////////////////////////////////////////////////////////////

// Monstre à invoquer
monsterToSummon = noone;

// Position où le monstre sera invoqué
summonPosition = [];

// Mode d'invocation (Summon/Set)
summonMode = "";

// Sacrifices sélectionnés
selectedSacrifices = [];

// Sacrifices requis
requiredSacrificeCount = 0;

// Niveau de sacrifice requis
requiredLevel = "";

// Visibilité
visible = false;
depth = -100; // Assure que le sélecteur apparaît au-dessus des cartes
// Drapeau global: sélecteur de sacrifice ouvert
global.isSacrificeSelectorOpen = false;

// Dimensions des boutons
buttonWidth = 150;
buttonHeight = 40;

///////////////////////////////////////////////////////////////////////
// Méthodes
///////////////////////////////////////////////////////////////////////

// Initialise le sélecteur de sacrifice
initSacrificeSelection = function(monster, position, mode) {
    show_debug_message("### oSacrificeSelector.initSacrificeSelection");
    
    monsterToSummon = monster;
    summonPosition = position;
    summonMode = mode;
    selectedSacrifices = [];
    
    // Détermine le niveau de sacrifice requis
    requiredLevel = getSacrificeLevel(monster.star);
    
    // Détermine le nombre de sacrifices requis
    switch(requiredLevel) {
        case 0:
            requiredSacrificeCount = 0;
            break;
        case 1:
            requiredSacrificeCount = 1;
            break;
        case 2:
            requiredSacrificeCount = 2; // Toujours 2 sacrifices pour les supérieurs
            break;
    }
    
    // Vérifie si des sacrifices sont nécessaires
    if(requiredSacrificeCount > 0) {
        // Affiche le sélecteur
        visible = true;
        // Active le verrou global pour empêcher les autres interactions
        global.isSacrificeSelectorOpen = true;
        
        // Désactive temporairement les autres contrôles
        // TODO: Désactiver les autres contrôles si nécessaire
    } else {
        // Pas de sacrifice requis, procède directement à l'invocation
        completeSummon();
    }
};

// Vérifie si un monstre peut être sélectionné comme sacrifice
canSelectAsSacrifice = function(monster) {
    // Vérifie si on n'a pas déjà atteint le nombre requis de sacrifices
    if(array_length(selectedSacrifices) >= requiredSacrificeCount) {
        return false;
    }
    
    // Vérifie si le monstre n'est pas déjà sélectionné
    for(var i = 0; i < array_length(selectedSacrifices); i++) {
        if(selectedSacrifices[i] == monster) {
            return false;
        }
    }
    
    // Accepte n'importe quel monstre sur le terrain
    return true;
};

// Ajoute un monstre aux sacrifices sélectionnés
addSacrifice = function(monster) {
    if(canSelectAsSacrifice(monster)) {
        array_push(selectedSacrifices, monster);
        
        // Vérifie si tous les sacrifices requis ont été sélectionnés
        if(array_length(selectedSacrifices) >= requiredSacrificeCount) {
            // Active le bouton de confirmation
            // (Géré visuellement dans le Draw event)
        }
        
        return true;
    }
    return false;
};

// Retire un monstre des sacrifices sélectionnés
removeSacrifice = function(monster) {
    var index = -1;
    for(var i = 0; i < array_length(selectedSacrifices); i++) {
        if(selectedSacrifices[i] == monster) {
            index = i;
            break;
        }
    }
    
    if(index != -1) {
        array_delete(selectedSacrifices, index, 1);
        return true;
    }
    return false;
};

// Annule la sélection de sacrifice
cancel = function() {
    show_debug_message("### oSacrificeSelector.cancel");
    
    // Réinitialise les variables
    monsterToSummon = noone;
    summonPosition = [];
    summonMode = "";
    selectedSacrifices = [];
    requiredSacrificeCount = 0;
    requiredLevel = "";
    visible = false;
    global.isSacrificeSelectorOpen = false;
    
    // Réactive les contrôles
    // TODO: Réactiver les contrôles si nécessaire
    
    // Arrête les indicateurs
    UIManager.stopIndicator();
    
    // Désélectionne la carte
    selectManager.unSelectAll();
};

// Confirme la sélection et procède à l'invocation
confirm = function() {
    show_debug_message("### oSacrificeSelector.confirm");
    
    // Validation: vérifier qu'on a le bon nombre de sacrifices
    if(array_length(selectedSacrifices) == requiredSacrificeCount) {
        // Effectue les sacrifices
        global.sacrifice_for_card = monsterToSummon;
        performSacrifices(selectedSacrifices, true); // true = isHeroOwner
        global.sacrifice_for_card = noone;
        
        // Maintenant afficher les indicateurs de position pour l'invocation
        UIManager.displayIndicator(monsterToSummon);
        
        // Cache le sélecteur de sacrifice
        visible = false;
        global.isSacrificeSelectorOpen = false;
    } else {
        show_debug_message("Erreur: Nombre de sacrifices incorrect. Requis: " + string(requiredSacrificeCount) + ", Sélectionnés: " + string(array_length(selectedSacrifices)));
        // Optionnel: afficher un message d'erreur à l'utilisateur
    }
};

// Finalise l'invocation après avoir choisi la position
completeSummon = function(position) {
    show_debug_message("### oSacrificeSelector.completeSummon");
    
    if(monsterToSummon != noone && array_length(position) >= 3) {
        // Invoque le monstre à la position choisie
        handHero.summon(monsterToSummon, position);
        
        // Met à jour le statut d'invocation (ne pas compter les invocations spéciales)
        if (monsterToSummon.type == "Monster" && UIManager.selectedSummonOrSet != "SpecialSummon") {
            game.hasSummonedThisTurn[0] = true;
        }
        // Reset du mode après l'opération
        UIManager.selectedSummonOrSet = "";
        
        // Réinitialise les variables
        if (variable_global_exists("sacrifice_for_card")) { global.sacrifice_for_card = noone; }
        monsterToSummon = noone;
        summonPosition = [];
        summonMode = "";
        selectedSacrifices = [];
        requiredSacrificeCount = 0;
        requiredLevel = "";
        visible = false;
        global.isSacrificeSelectorOpen = false;
        
        // Arrête les indicateurs
        UIManager.stopIndicator();
        
        // Désélectionne la carte
        selectManager.unSelectAll();
    }
};