class_name Field
extends Node2D

var field: Array[CardVisual] = []

@onready var field_slots: Array[Slot] = [
	$Slot1,
	$Slot2,
	$Slot3,
	$Slot4,
	$Slot5,
	$Slot6,
	$Slot7,
	$Slot8,
]


func add_card(card_visual: CardVisual, _and_flip) -> Tween:
	for slot in field_slots:
		if not slot.is_occupied():
			var target_position = slot.global_position
			var start_global_pos = card_visual.global_position
			card_visual.reparent(slot)
			slot.card_visual = card_visual
			field.append(card_visual)

			card_visual.global_position = start_global_pos

			card_visual.flip_card()

			var tween = get_tree().create_tween()
			tween.tween_property(card_visual, "global_position", target_position, 0.25)
			return tween

	return null


func remove_card(card_visual: CardVisual) -> void:
	field.erase(card_visual)
	# Find the slot containing this card and clear it
	for slot in field_slots:
		if slot.card_visual == card_visual:
			slot.card_visual = null
			break

func get_cards() -> Array[CardVisual]:
	return field
