// === oCardParent - Draw GUI Event ===

// Afficher le message de débogage
if (variable_global_exists("debug_message") && global.debug_timer > 0) {
    draw_set_font(-1);
    draw_set_color(c_yellow);
    draw_set_halign(fa_center);
    draw_set_valign(fa_top);
    draw_text(room_width/2, 50, global.debug_message);
    draw_set_color(c_white);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    global.debug_timer--;
}