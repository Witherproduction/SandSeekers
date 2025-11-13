// === oContreIaGrid - Create Event ===
// Initialisation des variables pour la sélection des bots

// Configuration du tableau
grid_cols = 6;
grid_rows = 5;
total_cells = grid_cols * grid_rows; // 30 emplacements

// Variables de sélection
selected_bot = -1; // -1 = aucune sélection, 0 = aléatoire, 1-29 = bot spécifique
available_bots = []; // Liste des bots disponibles

// Rendre disponibles les bots 1 à 5 (incluant Maître du Contrôle)
for (var i = 1; i <= 5; i++) {
    array_push(available_bots, i);
}

// === SYSTÈME DE DONNÉES DES BOTS ===
// Structure: bot_data[bot_id] = {nom, description, deck_name, deck_id, difficulty}

bot_data = [];

// Initialiser les données pour chaque bot
for (var i = 0; i < total_cells; i++) {
    bot_data[i] = {};
}

// Bot 0 (Aléatoire)
bot_data[0] = {
    name: "Sélection Aléatoire",
    description: "Un adversaire sera choisi au hasard parmi tous les bots disponibles.",
    deck_name: "Deck Aléatoire",
    deck_id: -1,
    difficulty: "Variable"
};

// Bot 1 - Débutant
bot_data[1] = {
    name: "Novice",
    description: "Bot débutant utilisant des stratégies simples et directes. Parfait pour apprendre les bases du jeu.",
    deck_name: "Deck Basique",
    deck_id: 1,
    difficulty: "Facile"
};

// Bot 2 - Intermédiaire
bot_data[2] = {
    name: "Tacticien",
    description: "Bot intermédiaire avec des combos de base et une stratégie équilibrée.",
    deck_name: "Deck Équilibré",
    deck_id: 2,
    difficulty: "Moyen"
};

// Bot 3 - Agressif
bot_data[3] = {
    name: "Berserker",
    description: "Bot agressif privilégiant l'attaque rapide et les dégâts directs.",
    deck_name: "Deck Agressif",
    deck_id: 3,
    difficulty: "Moyen"
};

// Bot 4 - Défensif
bot_data[4] = {
    name: "Gardien",
    description: "Bot défensif spécialisé dans la protection et les stratégies à long terme.",
    deck_name: "Deck Défensif",
    deck_id: 4,
    difficulty: "Difficile"
};

// Bot 5 - Contrôle
bot_data[5] = {
    name: "Maître du Contrôle",
    description: "Bot expert en contrôle du terrain et manipulation des cartes adverses.",
    deck_name: "Deck Contrôle",
    deck_id: 5,
    difficulty: "Difficile"
};

// Bots 6-29 - Génériques avec variations
for (var i = 6; i < total_cells; i++) {
    var bot_type = (i % 4) + 1; // Cycle entre 4 types de base
    var bot_number = i;
    
    switch(bot_type) {
        case 1: // Type Agressif
            bot_data[i] = {
                name: "Guerrier " + string(bot_number),
                description: "Bot spécialisé dans les attaques directes et les stratégies offensives.",
                deck_name: "Deck Guerrier",
                deck_id: 10 + bot_type,
                difficulty: "Moyen"
            };
            break;
        case 2: // Type Magique
            bot_data[i] = {
                name: "Mage " + string(bot_number),
                description: "Bot utilisant la magie et les sorts pour contrôler le combat.",
                deck_name: "Deck Magique",
                deck_id: 10 + bot_type,
                difficulty: "Difficile"
            };
            break;
        case 3: // Type Support
            bot_data[i] = {
                name: "Soutien " + string(bot_number),
                description: "Bot axé sur le support et les synergies entre cartes.",
                deck_name: "Deck Support",
                deck_id: 10 + bot_type,
                difficulty: "Moyen"
            };
            break;
        case 4: // Type Hybride
            bot_data[i] = {
                name: "Hybride " + string(bot_number),
                description: "Bot polyvalent combinant plusieurs stratégies.",
                deck_name: "Deck Hybride",
                deck_id: 10 + bot_type,
                difficulty: "Difficile"
            };
            break;
    }
}

// Variables pour le calcul des positions (reprises du Draw event)
grid_height = room_height * 0.6;
cell_height = grid_height / grid_rows;
cell_width = cell_height;
cell_margin = 5;

total_width = (grid_cols * cell_width) + ((grid_cols - 1) * cell_margin);
total_height = (grid_rows * cell_height) + ((grid_rows - 1) * cell_margin);

frame_width = 400;
available_width = room_width - (2 * frame_width);
grid_x = frame_width + (available_width - total_width) / 2;
grid_y = (room_height - total_height) / 2;

// === FONCTIONS POUR LA GESTION DES DECKS ===

// Fonction pour récupérer le deck d'un bot
function get_bot_deck(bot_id) {
    if (bot_id < 0 || bot_id >= array_length(bot_data)) {
        return noone;
    }
    
    var bot_info = bot_data[bot_id];
    var deck_id = bot_info.deck_id;
    
    // Si c'est le bot aléatoire, retourner un deck aléatoire
    if (bot_id == 0) {
        return get_random_bot_deck();
    }
    
    // Retourner le deck spécifique du bot
    return create_bot_deck(deck_id, bot_info.name);
}

// Fonction pour créer un deck préconstruit pour un bot (utilise le script sBotDecks)
function create_bot_deck(deck_id, bot_name) {
    // Utiliser le script dédié pour récupérer les cartes
    return create_bot_deck_from_script(deck_id, bot_name);
}

// Fonction pour obtenir un deck aléatoire
function get_random_bot_deck() {
    var random_bot_id = irandom_range(1, total_cells - 1);
    return get_bot_deck(random_bot_id);
}

// Fonction utilitaire pour retrouver l'ID du bot à partir de l'ID du deck
function get_bot_id_from_deck(deck_id) {
    for (var i = 0; i < array_length(bot_data); i++) {
        if (bot_data[i].deck_id == deck_id) {
            return i;
        }
    }
    return 1; // Par défaut, retourner le bot 1
}