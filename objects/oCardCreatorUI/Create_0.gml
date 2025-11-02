// === Interface de Création de Cartes ===
show_debug_message("### Initialisation de l'interface de création de cartes");

// Variables de l'interface (agrandie pour utiliser plus d'espace)
ui_width = 1600;
ui_height = 900;
ui_x = (room_width - ui_width) / 2;
ui_y = (room_height - ui_height) / 2;

// Variables des champs de saisie
input_fields = {};
active_field = "";
cursor_blink_timer = 0;

// Initialisation des champs
input_fields.card_id = "";
input_fields.name = "";
input_fields.attack = "0";
input_fields.defense = "0";
input_fields.star = "0";
input_fields.description = "";
input_fields.sprite = "";
input_fields.object_id = "";
input_fields.genre = "";
input_fields.archetype = "";
input_fields.booster = "";

// Variables de type de carte
card_type = "Monster"; // "Monster" ou "Magic"
selected_rarity = "commun"; // "commun", "rare", "epique", "legendaire"

// Variables d'aperçu
preview_card = undefined;
show_preview = true;

// Variables des boutons
buttons = {};

// Bouton Type de Carte (repositionnés pour l'interface agrandie)
buttons.type_monster = {
    x: ui_x + 80,
    y: ui_y + 60,
    width: 120,
    height: 35,
    text: "Monstre",
    active: true
};

buttons.type_magic = {
    x: ui_x + 220,
    y: ui_y + 60,
    width: 120,
    height: 35,
    text: "Magie",
    active: false
};

// Boutons de rareté (repositionnés pour l'interface agrandie)
var rarity_x = ui_x + 80;
var rarity_y = ui_y + 600;
buttons.rarity_commun = {
    x: rarity_x,
    y: rarity_y,
    width: 80,
    height: 25,
    text: "Commun",
    rarity: "commun"
};

buttons.rarity_rare = {
    x: rarity_x + 90,
    y: rarity_y,
    width: 80,
    height: 25,
    text: "Rare",
    rarity: "rare"
};

buttons.rarity_epique = {
    x: rarity_x + 180,
    y: rarity_y,
    width: 80,
    height: 25,
    text: "Épique",
    rarity: "epique"
};

buttons.rarity_legendaire = {
    x: rarity_x + 270,
    y: rarity_y,
    width: 100,
    height: 25,
    text: "Légendaire",
    rarity: "legendaire"
};

// Boutons d'action (repositionnés pour l'interface agrandie)
buttons.create_card = {
    x: ui_x + 80,
    y: ui_y + ui_height - 100,
    width: 140,
    height: 45,
    text: "Créer Carte"
};

buttons.cancel = {
    x: ui_x + 240,
    y: ui_y + ui_height - 100,
    width: 120,
    height: 45,
    text: "Annuler"
};

buttons.back_to_menu = {
    x: ui_x + 380,
    y: ui_y + ui_height - 100,
    width: 140,
    height: 45,
    text: "Menu Principal"
};

buttons.load_card = {
    x: ui_x + 540,
    y: ui_y + ui_height - 100,
    width: 140,
    height: 45,
    text: "Charger Carte"
};

// Nouveau bouton: Exporter la base vers le dossier de release
buttons.export_db = {
    x: ui_x + 700,
    y: ui_y + ui_height - 100,
    width: 180,
    height: 45,
    text: "Exporter la base"
};

// Positions des champs de saisie (espacement augmenté)
field_positions = {};
var field_x = ui_x + 80;
var field_y = ui_y + 120;
var field_spacing = 70;

field_positions.card_id = { x: field_x, y: field_y, width: 200, height: 25, label: "ID de la carte:" };
field_positions.name = { x: field_x, y: field_y + field_spacing, width: 200, height: 25, label: "Nom:" };
field_positions.attack = { x: field_x, y: field_y + field_spacing * 2, width: 80, height: 25, label: "ATK:" };
field_positions.defense = { x: field_x + 120, y: field_y + field_spacing * 2, width: 80, height: 25, label: "DEF:" };
field_positions.star = { x: field_x, y: field_y + field_spacing * 3, width: 80, height: 25, label: "Étoiles:" };
field_positions.genre = { x: field_x + 120, y: field_y + field_spacing * 3, width: 120, height: 25, label: "Genre:" };
field_positions.archetype = { x: field_x, y: field_y + field_spacing * 4, width: 200, height: 25, label: "Archétype:" };
field_positions.booster = { x: field_x + 220, y: field_y + field_spacing * 4, width: 200, height: 25, label: "Booster:" };
field_positions.sprite = { x: field_x, y: field_y + field_spacing * 5, width: 200, height: 25, label: "Sprite:" };
field_positions.object_id = { x: field_x, y: field_y + field_spacing * 6, width: 200, height: 25, label: "Objet ID:" };
field_positions.description = { x: field_x, y: field_y + field_spacing * 7 + 50, width: 300, height: 60, label: "Description:" };

// Position de l'aperçu (ajustée pour l'interface agrandie)
// Revenir à la position sur le côté droit
preview_x = ui_x + ui_width - 350;
preview_y = ui_y + 120;
// Désactiver le centrage précédemment ajouté
// preview_x = ui_x + (ui_width / 2) - 100;
// preview_y = ui_y + (ui_height / 2) - 160;

// Messages d'état
status_message = "";
status_timer = 0;

// Variables pour l'interface de gestion des cartes
show_card_list = false;
card_list = [];
card_list_scroll = 0;
list_archetype_filter = "Tous";

// Nouveau: sélection par booster
show_booster_list = false;
booster_list = [];
booster_list_scroll = 0;
booster_selected = "";
show_archetype_list = false;
archetype_list = [];
archetype_list_scroll = 0;
selected_card_for_action = "";
card_list_buttons = {};

// Mode d'édition
editing_mode = false;
editing_card_id = "";

show_debug_message("Interface de création de cartes initialisée");