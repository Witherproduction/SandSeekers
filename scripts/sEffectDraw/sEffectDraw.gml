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