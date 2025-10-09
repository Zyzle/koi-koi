class_name Line
extends Node2D

var line: Array[CardVisual] = []

func add_card(card: CardVisual) -> void:
	line.append(card)

func card_count() -> int:
	return line.size()