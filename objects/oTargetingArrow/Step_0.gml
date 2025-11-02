// Mettre à jour la flèche de ciblage en temps réel
if (instance_exists(sourceCard)) {
    updateTarget();
} else {
    // Si la carte source n'existe plus, détruire la flèche
    instance_destroy();
}