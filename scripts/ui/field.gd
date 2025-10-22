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
	$Slot9, # extra, starts hidden
	$Slot10, # extra, starts hidden
	$Slot11, # extra, starts hidden
	$Slot12 # extra, starts hidden
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


func all_slots_occupied() -> bool:
	for slot in field_slots.filter(func(s): return s.visible):
		if not slot.is_occupied():
			return false
	return true


func show_extra_slots() -> void:
	$Slot9.visible = true
	$Slot10.visible = true


func highlight_available_slot() -> void:
	if all_slots_occupied():
		show_extra_slots()
	for slot in field_slots:
		if not slot.is_occupied():
			slot.apply_highlight()
			return


func clear_all_highlights() -> void:
	for slot in field_slots:
		slot.remove_highlight()