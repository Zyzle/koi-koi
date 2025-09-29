class_name CardVisual
extends Node2D

var card_data: Card


signal card_clicked(card_visual: CardVisual)
signal card_matched(card_visual: CardVisual, matched_cards: Array)

func setup_card(card: Card):
	card_data = card
	var texture_path = "res://assets/%d-%d.png" % [card_data.month, card_data.number]
	$CardImage.texture = load(texture_path)
