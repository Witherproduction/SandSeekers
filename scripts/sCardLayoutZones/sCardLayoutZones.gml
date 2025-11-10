/// sCardLayout_get_zones(cx, cy, spr, scale)
/// Retourne un struct avec les zones rectangulaires de texte de la carte.
/// Ne dessine rien: uniquement des coordonnées et dimensions.
function sCardLayout_get_zones(cx, cy, spr, scale) {
    var w = sprite_get_width(spr) * scale;
    var h = sprite_get_height(spr) * scale;
    var tlx = cx - w * 0.5;
    var tly = cy - h * 0.5;

    // Marges internes
    var m = 8 * scale;
    var mL = m, mR = m, mT = m, mB = m;
    var ix = tlx + mL;
    var iy = tly + mT;
    var iw = w - mL - mR;
    var ih = h - mT - mB;

    // Découpage vertical simple: titre, meta, description, stats
    var title_h = ih * 0.18;
    var meta_h  = ih * 0.12;
    var desc_h  = ih * 0.48;
    var stats_h = ih * 0.14;
    var rest_h  = ih - (title_h + meta_h + desc_h + stats_h);

    // Zones horizontales pour meta: genre/archetype à gauche, coût/étoile à droite
    var meta_split = 0.75; // 75% gauche, 25% droite

    var zones = {
        card: { x: tlx, y: tly, w: w, h: h },
        inner: { x: ix, y: iy, w: iw, h: ih },
        margins: { left: mL, right: mR, top: mT, bottom: mB },
        title: { x: ix, y: iy, w: iw, h: title_h },
        meta_left: { x: ix, y: iy + title_h, w: iw * meta_split, h: meta_h },
        meta_right: { x: ix + iw * meta_split, y: iy + title_h, w: iw * (1 - meta_split), h: meta_h },
        description: { x: ix, y: iy + title_h + meta_h, w: iw, h: desc_h },
        stats: { x: ix, y: iy + title_h + meta_h + desc_h, w: iw, h: stats_h },
        footer: { x: ix, y: iy + title_h + meta_h + desc_h + stats_h, w: iw, h: rest_h }
    };

    return zones;
}

/// sCardLayout_map_fields(card) -> struct
/// Associe des champs sémantiques à des zones: name, genre, archetype, star/cost, description, atkdef
/// Utilise sprite et scale de la carte passée.
function sCardLayout_map_fields(card) {
    var spr = card.sprite_index;
    var scale = is_undefined(card.scale) ? 1 : card.scale;
    var zones = sCardLayout_get_zones(card.x, card.y, spr, scale);

    return {
        name: zones.title,
        genre: zones.meta_left,
        archetype: zones.meta_left,
        star_cost: zones.meta_right,
        description: zones.description,
        atkdef: zones.stats,
        debug_all: zones
    };
}