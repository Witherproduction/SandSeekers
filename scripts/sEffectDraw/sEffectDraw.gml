function drawCards(amount) {
    if (!instance_exists(oHand) || !instance_exists(oDeck)) return false;
    for (var i = 0; i < amount; i++) {
        if (array_length(oDeck.cards) > 0) {
            var drawnCard = array_pop(oDeck.cards);
            array_push(oHand.cards, drawnCard);
            registerTriggerEvent(TRIGGER_ON_CARD_DRAW, drawnCard, {});
        } else {
            loseLP(1000);
            break;
        }
    }
    return true;
}

function drawCardsFor(ownerIsHero, amount) {
    var deckInst = ownerIsHero ? deckHero : deckEnemy;
    if (!instance_exists(deckInst)) return false;
    for (var i = 0; i < amount; i++) {
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

function drawThenDiscardDrawnMonsters(card, effect, context) {
    var ownerIsHero = (is_struct(effect) && variable_struct_exists(effect, "owner_is_hero")) ? effect.owner_is_hero
                      : ((card != noone && instance_exists(card) && variable_instance_exists(card, "isHeroOwner")) ? card.isHeroOwner : true);
    var amount = (is_struct(effect) && variable_struct_exists(effect, "amount")) ? effect.amount : (variable_struct_exists(effect, "value") ? effect.value : 3);
    var handInst = ownerIsHero ? handHero : handEnemy;
    var deckInst = ownerIsHero ? deckHero : deckEnemy;
    var gyInst = ownerIsHero ? graveyardHero : graveyardEnemy;
    if (!instance_exists(handInst) || !instance_exists(deckInst) || !instance_exists(gyInst)) {
        show_debug_message("### drawThenDiscardDrawnMonsters: instances introuvables");
        return false;
    }
    var beforeSize = ds_list_size(handInst.cards);
    drawCardsFor(ownerIsHero, amount);
    var afterSize = ds_list_size(handInst.cards);
    var drawnCount = max(0, min(amount, afterSize - beforeSize));
    if (drawnCount <= 0) {
        show_debug_message("### drawThenDiscardDrawnMonsters: aucune carte piochée");
        return true;
    }
    var toDiscard = ds_list_create();
    for (var i = 0; i < drawnCount; i++) {
        var idx = afterSize - 1 - i;
        if (idx < 0) break;
        var c = ds_list_find_value(handInst.cards, idx);
        if (c != noone && instance_exists(c) && variable_instance_exists(c, "type") && c.type == "Monster") {
            ds_list_add(toDiscard, c);
        }
    }
    if (ds_list_size(toDiscard) > 0) {
        discardSpecificCardsToGraveyard(ownerIsHero, toDiscard);
    }
    ds_list_destroy(toDiscard);
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