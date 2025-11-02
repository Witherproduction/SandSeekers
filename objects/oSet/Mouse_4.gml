show_debug_message("### oSet.create")

if (global.isGraveyardViewerOpen) exit;
// Bloque l'interaction si le sélecteur de sacrifice est ouvert
if (variable_global_exists("isSacrificeSelectorOpen") && global.isSacrificeSelectorOpen) exit;

UIManager.selectedSummonOrSet = "Set";

// Récupère la carte sélectionnée
var selectedCard = selectManager.selected;

// Vérifie si c'est un monstre qui nécessite des sacrifices
if (selectedCard.type == "Monster") {
    var requiredLevel = getSacrificeLevel(selectedCard.star);
    
    // Si le monstre nécessite des sacrifices, utilise le sélecteur
    if (requiredLevel == 1 || requiredLevel == 2) {
        // Récupère l'instance du sélecteur de sacrifice
        var selector = instance_find(oSacrificeSelector, 0);
        if (selector == noone) {
            // Crée le sélecteur s'il n'existe pas
            selector = instance_create_layer(0, 0, "Instances", oSacrificeSelector);
        }
        
        // Initialise la sélection de sacrifice
        selector.initSacrificeSelection(
            selectedCard, 
            [],  // Position sera déterminée après les sacrifices
            UIManager.selectedSummonOrSet
        );
        
        // Cache les boutons Summon et Set
        UIManager.hideSummonAndSet();
        
        return; // Arrête ici, le sélecteur prendra le relais
    }
}

// Pour les monstres sans sacrifice ou les cartes magiques, affiche directement les indicateurs
UIManager.displayIndicator();

// Empêche la propagation du clic vers les objets en dessous
exit;
