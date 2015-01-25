"use strict";
var Yaku = (function(){

    var Yaku = {
        GOKO: { points: 10, cards: 5 },          // 5 brights
        AMESHIKO: { points: 7, cards: 4 },      // rain man
        SHIKO: { points: 8, cards: 4 },         // dry 4 bright
        SANKO: { points: 5, cards: 3 },         // dry 3 bright
        INOSHIKACHO: { points: 5, cards: 3 },   // boar deer butterfly
        TANE: { points: 1, cards: 5 },          // kinds
        AKATAN: { points: 5, cards: 3 },        // red poetry ribbons
        AOTAN: { points: 5, cards: 3 },         // blue ribbons
        AKATANAOTAN: { points: 10, cards: 6 },   // dueling triads
        TANZAKU: { points: 1, cards: 5 },       // ribbons
        TSUKIMIZAKE: { points: 5, cards: 2 },    // moon viewing
        HANAMIZAKE: { points: 5, cards: 2 },    // flower viewing
        KASU: { points: 1, cards: 10 },          // junk
    };

    var MatchType = {
        NO_MATCH: -1,
        PARTIAL: 0,
        MATCH: 1
    };

    if (Object.freeze){
        Object.freeze(Yaku);
        Object.freeze(MatchType);
    };

    var MatchResult = function(yaku){
        this.match = MatchType.NO_MATCH;
        this.points = 0;
        this.basePoints = yaku.points;
        this.numCards = yaku.cards;
        this.cardsMatched = 0;
    };

    MatchResult.prototype.getCardsMatched = function(){
        return this.cardsMatched;
    }

    MatchResult.prototype.addMatched = function(){
        this.cardsMatched += 1;
    }

    MatchResult.prototype.getMatch = function(){
        return this.match;
    };

    MatchResult.prototype.setMatch = function(match){
        this.match = match;
    }

    MatchResult.prototype.getPoints = function(){
        return this.points;
    };

    MatchResult.prototype.setPoints = function(points){
        this.points = points;
    }

    MatchResult.prototype.getBasePoints = function(){
        return this.basePoints;
    }


    var YakuMatcher = function(hand){
        this.hand = hand;
        this.goko = new MatchResult(Yaku.GOKO);
        this.ameshiko = new MatchResult(Yaku.AMESHIKO);
        this.shiko = new MatchResult(Yaku.SHIKO);
        this.sanko = new MatchResult(Yaku.SANKO);
        this.inoshikacho = new MatchResult(Yaku.INOSHIKACHO);
        this.tane = new MatchResult(Yaku.TANE);
        this.akatan = new MatchResult(Yaku.AKATAN);
        this.aotan = new MatchResult(Yaku.AOTAN);
        this.akatanaotan = new MatchResult(Yaku.AKATANAOTAN);
        this.tanzaku = new MatchResult(Yaku.TANZAKU);
        this.tsukimizake = new MatchResult(Yaku.TSUKIMIZAKE);
        this.hanamizake = new MatchResult(Yaku.HANAMIZAKE);
        this.kasu = new MatchResult(Yaku.KASU);

        this.doMatch = function(){
            for (var i = this.hand.length - 1; i >= 0; i--) {
                var card = this.hand[i];

                if (card.getPts() === 20){
                    this.goko.addMatched();
                    this.goko.setMatch(MatchType.PARTIAL);
                    this.ameshiko.addMatched();
                    if (this.hand[i].getId() !== '11-4'){
                        this.shiko.addMatched();
                        this.shiko.setMatch(MatchType.PARTIAL);
                        this.sanko.addMatched();
                        this.sanko.setMatch(MatchType.PARTIAL);
                    }
                    else {
                        this.ameshiko.setMatch(MatchType.PARTIAL);
                    }

                    if (this.goko.getCardsMatched() === 5){
                        this.goko.setMatch(MatchType.MATCH);
                        this.goko.setPoints(this.goko.getBasePoints());
                    }
                    else if (this.ameshiko.getCardsMatched() === 4 && this.ameshiko.getMatch() === MatchType.PARTIAL){
                        this.ameshiko.setMatch(MatchType.MATCH);
                        this.sanko.setMatch(MatchType.PARTIAL);
                        this.ameshiko.setPoints(this.ameshiko.getBasePoints());
                    }
                    else if (this.shiko.getCardsMatched() === 4 && this.ameshiko.getMatch() !== MatchType.PARTIAL){
                        this.shiko.setMatch(MatchType.MATCH);
                        this.shiko.setPoints(this.shiko.getBasePoints());
                    }
                    else if (this.sanko.getCardsMatched() === 3 && this.ameshiko.getMatch() !== MatchType.PARTIAL){
                        this.sanko.setMatch(MatchType.MATCH);
                        this.sanko.setPoints(this.sanko.getBasePoints());
                    }
                }


            }
        };

        this.doMatch();
    };

    YakuMatcher.prototype.getGoko = function(){
        return this.goko;
    };

    YakuMatcher.prototype.getSanko = function(){
        return this.sanko;
    };

    YakuMatcher.prototype.getShiko = function(){
        return this.shiko;
    };

    YakuMatcher.prototype.getAmeshiko = function(){
        return this.ameshiko;
    };

    function matchCount(hand, set){
        var count = 0;
        for (var i = hand.length - 1; i >= 0; i--) {
            if(set.indexOf(hand[i].getId()) !== -1){
                count++;
            }
        }
        return count;
    };

    var match5Bright = function(hand){
        var set = ["1-4", "3-4", "8-4", "11-4", "12-4"];
        var res = matchCount(hand, set);

        if (res === set.length){
            return new MatchResult(1, 10);
        }
        else if (res > 0){
            return new MatchResult(0, 10);
        }
        else {
            return new MatchResult(-1, 10);
        }
    };

    var matchDry3Bright = function(hand){
        var set = ["1-4", "3-4", "8-4", "12-4"];
        var res = matchCount(hand, set);

        if (res > 3){
            return new MatchResult(-1, 5);
        }
        else if (res === 3){
            return new MatchResult(1, 5);
        }
        else if (res > 0){
            return new MatchResult(0, 5);
        }
        else {
            return new MatchResult(-1, 5);
        }
    };

    var matchDry4Bright = function(hand){
        var set = ["1-4", "3-4", "8-4", "12-4"];
        var res = matchCount(hand, set);

        if (res === 4){
            return new MatchResult(1, 8);
        }
        else if (res > 0){
            return new MatchResult(0, 8);
        }
        else {
            return new MatchResult(-1, 8);
        }
    };

    return {
        MatchType: MatchType,
        MatchResult: MatchResult,
        YakuMatcher: YakuMatcher
    };

})();
