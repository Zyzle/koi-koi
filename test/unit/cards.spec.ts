import {beforeEach, describe, expect, it, xit} from 'angular2/testing';

import {Card, CardType, Deck} from '../../app/cards';

describe('A Card', () => {
  let card:Card;

  beforeEach(() => {
    card = new Card(1, 1, CardType.PLAIN,  1);
  });

  it('should have a suit number', () => {
    expect(card.suit).toBe(1);
  });

  it('should have a card number', () => {
    expect(card.cardNum).toBe(1);
  });

  it('should have a card tpe', () => {
    expect(card.type).toBe(CardType.PLAIN);
  })

  it('shold have a points value', () => {
    expect(card.points).toBe(1);
  });

  it('should have an svg image', () => {
    expect(card.cardPng).toEqual('1-1.png');
  });

  it('should have an id', () => {
    expect(card.id).toEqual('1-1');
  });

});

describe('A Deck', () => {
  let deck:Deck;

  beforeEach(() => {
    deck = new Deck();
  });

  it('should start with 48 cards', () => {
    expect(deck.size).toBe(48);
  });

  xit('should shuffle deck', () => {
    // need to think about how to test this
  });

  it('should deal a card and remove it', () => {
    var card:Card[] = deck.deal();
    expect(deck.size).toBe(47);
    // we know what card will be first because we havent shuffled
    expect(card[0].id).toEqual('12-4');

  });

  it('should dead n cards and remove them', () => {
    var cards:Card[] = deck.deal(4);
    expect(deck.size).toBe(44);
    // again we know the order because we havent been shuffling
    expect(cards[0].id).toEqual('12-4');
    expect(cards[1].id).toEqual('12-3');
    expect(cards[2].id).toEqual('12-2');
    expect(cards[3].id).toEqual('12-1');
  });

});

describe('Yaku', () => {

});
