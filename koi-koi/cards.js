"use strict";
(function(){

    var Stack = function(deck){
        this.stack = deck;

        // shuffle using Fisher-Yates
        var m = this.stack.length, t, i;
        while (m) {
            i = Math.floor(Math.random() * m--);
            t = this.stack[m];
            this.stack[m] = this.stack[i];
            this.stack[i] = t;
        };

        console.log("shuffle done");
    };

    Stack.prototype.deal = function(){
        return this.stack.pop();
    };

    Stack.prototype.size = function(){
        return this.stack.length
    }

    var Card = function(suit, cardnum, pts){
        this.suit = suit;
        this.cardnum = cardnum;
        this.pts = pts
    };

    Card.prototype.getImage = function(){
        return this.suit + "-" + this.cardnum + ".png";
    };

    // not to be confused with the Stack, the deck is the complete list
    // of cards
    var deck = [
        new Card(1,1,1), new Card(1,2,1), new Card(1,3,5), new Card(1,4,20), // jan
        new Card(2,1,1), new Card(2,2,1), new Card(2,3,5), new Card(2,4,10), // feb
        new Card(3,1,1), new Card(3,2,1), new Card(3,3,5), new Card(3,4,20), // mar
        new Card(4,1,1), new Card(4,2,1), new Card(4,3,5), new Card(4,4,10), // apr
        new Card(5,1,1), new Card(5,2,1), new Card(5,3,5), new Card(5,4,10), // may
        new Card(6,1,1), new Card(6,2,1), new Card(6,3,5), new Card(6,4,10), // jun
        new Card(7,1,1), new Card(7,2,1), new Card(7,3,5), new Card(7,4,10), // jul
        new Card(8,1,1), new Card(8,2,1), new Card(8,3,10), new Card(8,4,20), // aug
        new Card(9,1,1), new Card(9,2,1), new Card(9,3,5), new Card(9,4,10), // sep
        new Card(10,1,1), new Card(10,2,1), new Card(10,3,5), new Card(10,4,10), // oct
        new Card(11,1,1), new Card(11,2,5), new Card(11,3,10), new Card(11,4,20), // nov
        new Card(12,1,1), new Card(12,2,1), new Card(12,3,1), new Card(12,4,20), // dec
    ];

    var stack = new Stack(deck);

})();
