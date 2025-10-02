class_name CardVisual
extends Control

var _card_data: Card

var card_data: Card:
	get: return _card_data

var original_min_size: Vector2

signal card_clicked(card_visual: CardVisual)
signal card_matched(card_visual: CardVisual, matched_cards: Array)

func _ready() -> void:
	connect("mouse_entered", on_mouse_entered)
	connect("mouse_exited", on_mouse_exited)
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


func _gui_input(event) -> void:
	if _card_data.is_player_card:
		# if event is InputEventMouseMotion:
		# 	self.scale = Vector2(1.1, 1.1)
		if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			card_clicked.emit(self)


func on_mouse_entered() -> void:
	if _card_data.is_player_card:
		custom_minimum_size = original_min_size * 1.2
		$Visuals/CardImage.scale = Vector2(1.2, 1.2)
		# Animate scale change
		# var tween = create_tween()
		# tween.tween_property(self, "scale", Vector2(1.1, 1.1), 0.1)
		# tween.tween_callback(update_parent_layout)


func on_mouse_exited() -> void:
	if _card_data.is_player_card:
		custom_minimum_size = original_min_size
		$Visuals/CardImage.scale = Vector2(1.0, 1.0)
		# Animate scale change
		# var tween = create_tween()
		# tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.1)
		# tween.tween_callback(update_parent_layout)


func update_parent_layout() -> void:
	# Trigger parent container to recalculate layout
	if get_parent() is Container:
		get_parent().queue_sort()