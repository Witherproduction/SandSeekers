function drawCards(amount) {
    if (!instance_exists(oHand) || !instance_exists(oDeck)) return false;
    for (var i = 0; i < amount; i++) {
        if (array_length(oDeck.cards) > 0) {
            var drawnCard = array_pop(oDeck.cards);
            // Respecter la limite de main: si pleine, envoyer au cimetière sans trigger
            var cap = (variable_global_exists("MAX_HAND_SIZE") ? global.MAX_HAND_SIZE : 10);
            var handCount = is_array(oHand.cards) ? array_length(oHand.cards) : ds_list_size(oHand.cards);
            if (handCount >= cap) {
                var gyInst = (variable_instance_exists(oHand, "isHeroOwner") && oHand.isHeroOwner) ? graveyardHero : graveyardEnemy;
                // FX centre grand
                var fx = instance_create_layer(drawnCard.x, drawnCard.y, "UI", oFX_Discard);
                if (fx != noone) {
                    fx.spriteGhost      = drawnCard.sprite_index;
                    // Forcer l'affichage de la face (frame 0)
                    fx.imageGhost       = 0;
                    fx.display_at_center = true;
                    // Taille standard demandée
                    fx.image_xscale     = 1;
                    fx.image_yscale     = 1;
                    fx.image_angle      = 0;
                    fx.duration_ms      = 1200;
                    fx.flame_thickness  = 12;
                    fx.depth_override   = -100000;
                }
                if (instance_exists(gyInst)) { gyInst.addToGraveyard(drawnCard, true); }
                drawnCard.zone = "Graveyard";
                instance_destroy(drawnCard);
            } else {
                array_push(oHand.cards, drawnCard);
                registerTriggerEvent(TRIGGER_ON_CARD_DRAW, drawnCard, {});
            }
        } else {
            loseLP(1000);
            break;
        }
    }
    return true;
}

function drawCardsFor(ownerIsHero, amount) {
    var deckInst = ownerIsHero ? deckHero : deckEnemy;
    var handInst = ownerIsHero ? handHero : handEnemy;
    if (!instance_exists(deckInst)) return false;
    for (var i = 0; i < amount; i++) {
        // Laisser deck.pick gérer l'overflow et l'envoi au cimetière silencieux
        if (ds_list_size(deckInst.cards) > 0) {
            deckInst.pick();
        } else {
            if (ownerIsHero) {
                loseLP(1000);
            } else if (instance_exists(oLP_Enemy)) {
                with (oLP_Enemy) { nbLP = max(0, nbLP - 1000); }
            }
            break;
        }
    }
    return true;
}


function shuffleDeck(deckInst) {
    if (!instance_exists(deckInst)) return false;
    if (!variable_instance_exists(deckInst, "cards")) return false;
    if (ds_list_size(deckInst.cards) <= 1) return true;
    ds_list_shuffle(deckInst.cards);
    if (variable_instance_exists(deckInst, "updateDisplay")) { deckInst.updateDisplay(); }
    return true;
}

function shuffleDeckFor(ownerIsHero) {
    var deckInst = ownerIsHero ? deckHero : deckEnemy;
    return shuffleDeck(deckInst);
}