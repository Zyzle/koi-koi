class_name CardVisual
extends Control

var _card_data: Card

var card_data: Card:
	get: return _card_data

var original_min_size: Vector2

signal card_clicked(card_visual: CardVisual)
signal card_matched(card_visual: CardVisual, matched_cards: Array)

func _ready() -> void:
	$Visuals/CardImage.mouse_entered.connect(on_mouse_entered)
	$Visuals/CardImage.mouse_exited.connect(on_mouse_exited)
	$Visuals/CardImage.gui_input.connect(on_gui_input)
	original_min_size = custom_minimum_size


func setup_card(card: Card) -> void:
	_card_data = card
	update_visual()


func toggle_visibility(vis: bool) -> void:
	$Visuals.visible = vis


func update_visual() -> void:
	var texture_path = "res://assets/%d-%d.png" % [_card_data.month, _card_data.number]
	$Visuals/CardImage.texture = load(texture_path)


func flip_card() -> void:
	# use scene defined animation for card flip
	get_node("Visuals/AnimationPlayer").play("card_flip")


func on_gui_input(event) -> void:
	if _card_data.is_player_card:
		if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			card_clicked.emit(self)


func on_mouse_entered() -> void:
	if _card_data.is_player_card:
		var tween = create_tween()
		tween.tween_property(self, "custom_minimum_size", original_min_size * 1.2, 0.2)


func on_mouse_exited() -> void:
	if _card_data.is_player_card:
		var tween = create_tween()
		tween.tween_property(self, "custom_minimum_size", original_min_size, 0.2)
