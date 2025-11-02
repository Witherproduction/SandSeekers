// === Variables locales pour scroll ===
var columns = 4;
var rows = 3;
var visible_cards = columns * rows; // 12 cartes visibles max
var line_size = columns; // 4 cartes = 1 ligne

var total = array_length(linkedGraveyard.cards);
var maxScroll = max(0, total - visible_cards);

if (linkedGraveyard == noone) {
    // Pas encore assigné, on attend
    exit;
}


// Scroll ligne par ligne : molette vers le haut
if (mouse_wheel_up()) {
    scrollIndex = max(0, scrollIndex - line_size);
}

// Scroll ligne par ligne : molette vers le bas
if (mouse_wheel_down()) {
    scrollIndex = min(scrollIndex + line_size, maxScroll);
}
