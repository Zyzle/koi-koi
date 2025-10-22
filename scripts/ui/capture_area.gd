class_name CaptureArea
extends Node2D

const CARD_REDUCED_SCALE = 0.5
const CARD_REDUCED_WIDTH = 90 * CARD_REDUCED_SCALE

@onready var brights: Line = $BrightsLine
@onready var ribbons: Line = $RibbonsLine
@onready var animals: Line = $AnimalsLine
@onready var plains: Line = $PlainsLine


func capture_card(card_visual: CardVisual) -> Tween:
	match card_visual.card_data.type:
		Card.CardType.BRIGHT:
			return _animate_card_capture(card_visual, brights)
		Card.CardType.RIBBON:
			return _animate_card_capture(card_visual, ribbons)
		Card.CardType.ANIMAL:
			return _animate_card_capture(card_visual, animals)
		Card.CardType.PLAIN:
			return _animate_card_capture(card_visual, plains)

	return null


func _animate_card_capture(card_visual: CardVisual, target_container: Node2D) -> Tween:
	card_visual.remove_highlight()
	var target_index = target_container.card_count()
	var target_local_position = Vector2(target_index * CARD_REDUCED_WIDTH, 0)
	var start_global_pos = card_visual.global_position
	card_visual.reparent(target_container)
	card_visual.global_position = start_global_pos
	target_container.add_card(card_visual)

	var tween = get_tree().create_tween()
	tween.tween_property(card_visual, "position", target_local_position, 0.25)
	tween.parallel().tween_property(card_visual, "scale", card_visual.scale * CARD_REDUCED_SCALE, 0.25)
	return tween