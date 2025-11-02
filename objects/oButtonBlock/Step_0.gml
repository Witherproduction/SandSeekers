// === oButtonBlock - Step Event ===
// Garde globale pour bloquer les interactions des boutons si oPanelOptions est ouvert

// Bloquer toutes les interactions si le panneau d'options est ouvert
if (instance_exists(oPanelOptions)) {
    exit;
}

// Ne pas appeler event_inherited() car c'est l'objet parent