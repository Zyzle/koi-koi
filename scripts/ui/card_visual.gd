class_name CardVisual
extends Control

var card_data: Card

signal card_clicked(card_visual: CardVisual)
signal card_matched(card_visual: CardVisual, matched_cards: Array)

func setup_card(card: Card):
	card_data = card
	update_visual()

func update_visual():
	var texture_path = "res://assets/%d-%d.png" % [card_data.month, card_data.number]
	$CardImage.texture = load(texture_path)

func _gui_input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		card_clicked.emit(self)
