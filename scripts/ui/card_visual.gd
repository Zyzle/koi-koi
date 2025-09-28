class_name CardVisual
extends Control

var card_data: Card
var card_index: int
var card_owner: String

signal card_clicked(card_visual: CardVisual)
signal card_matched(card_visual: CardVisual, matched_cards: Array)

func setup_card(card: Card, index: int, o: String):
	card_data = card
	card_index = index
	card_owner = o
	# Update visual representation here, e.g., set texture based on card properties
	# update_visual()