class_name Deck
extends Node

const DECK: Array[Dictionary] = [
	# January
	{"month": 1, "number": 1, "type": Card.CardType.PLAIN, "points": 0},
	{"month": 1, "number": 2, "type": Card.CardType.PLAIN, "points": 0},
	{"month": 1, "number": 3, "type": Card.CardType.RIBBON, "points": 5},
	{"month": 1, "number": 4, "type": Card.CardType.BRIGHT, "points": 20},
	# February
	{"month": 2, "number": 1, "type": Card.CardType.PLAIN, "points": 0},
	{"month": 2, "number": 2, "type": Card.CardType.PLAIN, "points": 0},
	{"month": 2, "number": 3, "type": Card.CardType.RIBBON, "points": 5},
	{"month": 2, "number": 4, "type": Card.CardType.ANIMAL, "points": 10},
	# March
	{"month": 3, "number": 1, "type": Card.CardType.PLAIN, "points": 0},
	{"month": 3, "number": 2, "type": Card.CardType.PLAIN, "points": 0},
	{"month": 3, "number": 3, "type": Card.CardType.RIBBON, "points": 5},
	{"month": 3, "number": 4, "type": Card.CardType.BRIGHT, "points": 20},
	# April
	{"month": 4, "number": 1, "type": Card.CardType.PLAIN, "points": 0},
	{"month": 4, "number": 2, "type": Card.CardType.PLAIN, "points": 0},
	{"month": 4, "number": 3, "type": Card.CardType.RIBBON, "points": 5},
	{"month": 4, "number": 4, "type": Card.CardType.ANIMAL, "points": 10},
	# May
	{"month": 5, "number": 1, "type": Card.CardType.PLAIN, "points": 0},
	{"month": 5, "number": 2, "type": Card.CardType.PLAIN, "points": 0},
	{"month": 5, "number": 3, "type": Card.CardType.RIBBON, "points": 5},
	{"month": 5, "number": 4, "type": Card.CardType.ANIMAL, "points": 10},
	# June
	{"month": 6, "number": 1, "type": Card.CardType.PLAIN, "points": 0},
	{"month": 6, "number": 2, "type": Card.CardType.PLAIN, "points": 0},
	{"month": 6, "number": 3, "type": Card.CardType.RIBBON, "points": 5},
	{"month": 6, "number": 4, "type": Card.CardType.ANIMAL, "points": 10},
	# July
	{"month": 7, "number": 1, "type": Card.CardType.PLAIN, "points": 0},
	{"month": 7, "number": 2, "type": Card.CardType.PLAIN, "points": 0},
	{"month": 7, "number": 3, "type": Card.CardType.RIBBON, "points": 5},
	{"month": 7, "number": 4, "type": Card.CardType.ANIMAL, "points": 10},
	# August
	{"month": 8, "number": 1, "type": Card.CardType.PLAIN, "points": 0},
	{"month": 8, "number": 2, "type": Card.CardType.PLAIN, "points": 0},
	{"month": 8, "number": 3, "type": Card.CardType.ANIMAL, "points": 10},
	{"month": 8, "number": 4, "type": Card.CardType.BRIGHT, "points": 20},
	# September
	{"month": 9, "number": 1, "type": Card.CardType.PLAIN, "points": 0},
	{"month": 9, "number": 2, "type": Card.CardType.PLAIN, "points": 0},
	{"month": 9, "number": 3, "type": Card.CardType.RIBBON, "points": 5},
	{"month": 9, "number": 4, "type": Card.CardType.ANIMAL, "points": 10},
	# October
	{"month": 10, "number": 1, "type": Card.CardType.PLAIN, "points": 0},
	{"month": 10, "number": 2, "type": Card.CardType.PLAIN, "points": 0},
	{"month": 10, "number": 3, "type": Card.CardType.RIBBON, "points": 5},
	{"month": 10, "number": 4, "type": Card.CardType.ANIMAL, "points": 10},
	# November
	{"month": 11, "number": 1, "type": Card.CardType.PLAIN, "points": 0},
	{"month": 11, "number": 2, "type": Card.CardType.RIBBON, "points": 5},
	{"month": 11, "number": 3, "type": Card.CardType.ANIMAL, "points": 10},
	{"month": 11, "number": 4, "type": Card.CardType.BRIGHT, "points": 20},
	# December
	{"month": 12, "number": 1, "type": Card.CardType.PLAIN, "points": 0},
	{"month": 12, "number": 2, "type": Card.CardType.PLAIN, "points": 0},
	{"month": 12, "number": 3, "type": Card.CardType.PLAIN, "points": 0},
	{"month": 12, "number": 4, "type": Card.CardType.BRIGHT, "points": 20}
]

var cards: Array[Card] = []


func _init() -> void:
	for card_data in DECK:
		var card = Card.new(card_data["month"], card_data["number"], card_data["type"], card_data["points"])
		cards.append(card)
	cards.shuffle()


func draw_card() -> Card:
	return cards.pop_back()