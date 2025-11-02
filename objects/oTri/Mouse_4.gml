// === Gestion des clics sur les boutons de tri ===
// Note: L'événement Mouse_4 ne fonctionne que si on clique sur le sprite de l'objet
// Comme nous dessinons dans Draw_64, nous devons gérer les clics différemment

// Hériter de la garde de oButtonBlock pour bloquer sous le panneau d'options
event_inherited();

// Garde directe ici aussi, pour éviter toute interaction fortuite
if (instance_exists(oPanelOptions)) {
    return;
}

show_debug_message("### Mouse_4 event triggered - but this won't work for Draw_64 elements");