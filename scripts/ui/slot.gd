class_name Slot
extends Node2D

var card_visual: CardVisual

func is_occupied() -> bool:
	return card_visual != null