draw_set_font(fontStep);
draw_text_color(1650, 414, player[player_current], c_black, c_black, c_black, c_black, 1);
draw_text(1650, 410, player[player_current]);
draw_text_color(1650, 514, phase[phase_current], c_black, c_black, c_black, c_black, 1);
draw_text(1650, 510, phase[phase_current]);
draw_text_color(1650, 614, "Tour " + string(nbTurn), c_black, c_black, c_black, c_black, 1);
draw_text(1650, 610, "Tour " + string(nbTurn));
