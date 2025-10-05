class_name CardVisual
extends Control

const HIGHLIGHT_SHADER_PATH = "res://shaders/card_highlight_shader.gdshader"

var _card_data: Card
var _game_state: GameState

var card_data: Card:
	get: return _card_data

var original_min_size: Vector2
var is_selected: bool = false

signal player_card_clicked(card_visual: CardVisual)
signal field_card_clicked(card_visual: CardVisual)

func _ready() -> void:
	$Visuals/CardImage.mouse_entered.connect(on_mouse_entered)
	$Visuals/CardImage.mouse_exited.connect(on_mouse_exited)
	$Visuals/CardImage.gui_input.connect(on_gui_input)
	original_min_size = custom_minimum_size


func set_game_state(state: GameState) -> void:
	_game_state = state


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


func apply_highlight() -> void:
	var shader_material = ShaderMaterial.new()
	shader_material.shader = preload(HIGHLIGHT_SHADER_PATH)
	shader_material.set_shader_parameter("color", Color.YELLOW)
	shader_material.set_shader_parameter("inner_stroke_thickness", 5.0)
	shader_material.set_shader_parameter("frequency", 8.0)
	shader_material.set_shader_parameter("phase_speed", 5.0)
	shader_material.set_shader_parameter("outer_stroke_thickness", 5.0)
	$Visuals/CardImage.material = shader_material


func remove_highlight() -> void:
	$Visuals/CardImage.material = null


func is_player_turn() -> bool:
	return _game_state._current_phase == GameState.Phase.PLAY and _game_state.current_turn == GameState.Turn.PLAYER


func on_gui_input(event) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if _card_data.is_player_card and is_player_turn():
			player_card_clicked.emit(self)
		if _card_data.is_field_card and is_player_turn():
			field_card_clicked.emit(self)


func on_mouse_entered() -> void:
	if _card_data.is_player_card and is_player_turn():
		embiggen()


func on_mouse_exited() -> void:
	if _card_data.is_player_card and is_player_turn() and not is_selected:
		unembiggen()


func set_selected(s: bool) -> void:
	is_selected = s
	if is_selected:
		apply_highlight()
	else:
		remove_highlight()
		unembiggen()


func embiggen() -> void:
	var tween = create_tween()
	tween.tween_property(self, "custom_minimum_size", original_min_size * 1.2, 0.2)


func unembiggen() -> void:
	var tween = create_tween()
	tween.tween_property(self, "custom_minimum_size", original_min_size, 0.2)