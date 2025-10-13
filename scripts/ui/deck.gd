class_name Deck
extends Node2D

var cards: Array[CardVisual] = []

func add_card(card_visual: CardVisual) -> void:
	cards.append(card_visual)
	add_child(card_visual)


func remove_card(card_visual: CardVisual) -> void:
	cards.erase(card_visual)


func get_top_card() -> CardVisual:
	if cards.size() > 0:
		return cards[cards.size() - 1]
	return null