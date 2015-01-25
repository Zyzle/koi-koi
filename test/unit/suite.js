function containsAll(array1, array2){
    for (var i = array1.length - 1; i >= 0; i--) {
        if(array2.indexOf(array1[i]) === -1){
            return false;
        }
    }
    return true;
}

describe("Cards", function(){

    beforeEach(function(){
        this.stack = new Cards.Stack(new Cards.Deck().getNew());
    });

    describe("deck", function(){
        it("has 48 cards", function(){
            expect(new Cards.Deck().length()).toEqual(48);
        });
    });

    describe("stack", function(){
        it("should have same size as the deck", function(){
            expect(new Cards.Deck().length()).toEqual(this.stack.size());
        });

        it("should contain all the cards of the deck", function(){
            expect(containsAll(this.stack, new Cards.Deck().getNew())).toBe(true);
        });

        describe("take", function(){
            beforeEach(function(){
                this.hand = [];
                for (var i = 0; i < 8; i++) {
                    this.hand.push(this.stack.take());
                };
            });

            it("should allow us to take cards", function(){
                expect(this.hand.length).toEqual(8);
            });

            it("taken cards should no longer be in the deck", function(){
                expect(containsAll(this.hand, this.stack)).not.toBe(true);
            });

        });

    });

    describe("dealer", function(){

        beforeEach(function(){
            this.dealer = new Cards.Dealer(this.stack);
        });

        it("should deal hands of 8 cards from the stack", function(){
            var hand = this.dealer.deal();
            expect(hand.length).toEqual(8);
        });

        it("dealt cards should no longer be in the stack", function(){
            var hand = this.dealer.deal();
            expect(containsAll(hand, this.stack)).not.toBe(true);
        });

    });

});

describe("Board", function(){

    beforeEach(function(){
        this.stack = new Cards.Stack(new Cards.Deck().getNew());
        this.dealer = new Cards.Dealer(this.stack);
        this.board = new Board.Gameboard();
    });

    it("should have two players and a pot", function(){
        expect(this.board.player1).toBeDefined();
        expect(this.board.player2).toBeDefined();
        expect(this.board.pot).toBeDefined();
    });

    it("should start with players and pt empty", function(){
        expect(this.board.player1.cardCount()).toBe(0);
        expect(this.board.player2.cardCount()).toBe(0);
        expect(this.board.pot.cardCount()).toBe(0);
    });

    it("should allow players and pot to be dealt cards", function(){
        this.board.player1.giveCards(this.dealer.deal());
        expect(this.board.player1.cardCount()).toBe(8);
        this.board.player2.giveCards(this.dealer.deal());
        expect(this.board.player2.cardCount()).toBe(8);
        this.board.pot.giveCards(this.dealer.deal());
        expect(this.board.pot.cardCount()).toBe(8);
    });

});

describe ("Yaku", function(){

    beforeEach(function(){
        this.deck = new Cards.Deck();
    });

    it("Can create match results", function(){
        var mr = new Yaku.MatchResult(1, 5);
        expect(mr).toBeDefined();
    });

    it("should match 5 Brights (goko)", function(){
        var hand = [this.deck.getSpecific("1-4"), this.deck.getSpecific("3-4"),
            this.deck.getSpecific("8-4"), this.deck.getSpecific("11-4"),
            this.deck.getSpecific("12-4")];

        var matcher = new Yaku.YakuMatcher(hand);
        var result = matcher.getGoko();
        expect(result.getMatch()).toBe(Yaku.MatchType.MATCH);
        expect(result.getPoints()).toBe(10);
    });

    describe("dry 3 bright (sanko)", function(){
        beforeEach(function(){
            this.hand = [this.deck.getSpecific("1-4"), this.deck.getSpecific("3-4"),
            this.deck.getSpecific("8-4")];
            this.matcher = new Yaku.YakuMatcher(this.hand);
        });

        it("should match", function(){
            var result = this.matcher.getSanko();
            expect(result.getMatch()).toBe(Yaku.MatchType.MATCH);
            expect(result.getPoints()).toBe(5);
        });

        it("should partial match goko", function(){
            var result = this.matcher.getGoko();
            expect(result.getMatch()).toBe(0);
        });

        it("should partial match shiko", function(){
            var result = this.matcher.getShiko();
            expect(result.getMatch()).toBe(0);
        });
    });

    describe("dry 4 bright (shiko)", function(){
        beforeEach(function(){
            this.hand = [this.deck.getSpecific("1-4"), this.deck.getSpecific("3-4"),
            this.deck.getSpecific("8-4"), this.deck.getSpecific("12-4")];
            this.matcher = new Yaku.YakuMatcher(this.hand);
        });

        it("should match", function(){
            var result = this.matcher.getShiko();
            expect(result.getMatch()).toBe(Yaku.MatchType.MATCH);
            expect(result.getPoints()).toBe(8);
        });

        it("should partial match goko", function(){
            var result = this.matcher.getGoko();
            expect(result.getMatch()).toBe(Yaku.MatchType.PARTIAL);
        });

        it("should not match dry 3 bright", function(){
            var result = this.matcher.getSanko();
            expect(result.getMatch()).toBe(Yaku.MatchType.PARTIAL);
        });
    });

    describe("rain man (ameshiko)", function(){
        beforeEach(function(){
            this.hand = [this.deck.getSpecific("11-4"), this.deck.getSpecific("3-4"),
            this.deck.getSpecific("8-4"), this.deck.getSpecific("12-4")];
            this.matcher = new Yaku.YakuMatcher(this.hand);
        });

        it("should match", function(){
            var result = this.matcher.getAmeshiko();
            expect(result.getMatch()).toBe(Yaku.MatchType.MATCH);
            expect(result.getPoints()).toBe(7);
        });

        it("should partial match goko", function(){
            var result = this.matcher.getGoko();
            expect(result.getMatch()).toBe(Yaku.MatchType.PARTIAL);
        });

        it("should not match dry 4 bright", function(){
            var result = this.matcher.getShiko();
            expect(result.getMatch()).toBe(Yaku.MatchType.PARTIAL);
        });

        it("should not match dry 3 bright", function(){
            var result = this.matcher.getSanko();
            expect(result.getMatch()).toBe(Yaku.MatchType.PARTIAL);
        });
    });
});
