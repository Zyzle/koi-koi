class_name WinLosePanel
extends NinePatchRect

const WIN_CALLOUT_TEXTURE_PATH = "res://assets/callout_blue.png"
const LOSE_CALLOUT_TEXTURE_PATH = "res://assets/callout_red.png"
const DRAW_CALLOUT_TEXTURE_PATH = "res://assets/callout_tan.png"

@onready var callout: NinePatchRect = %Callout
@onready var wld_label: Label = %WLDLabel
@onready var opponent_score_label: Label = %OpponentScoreLabel
@onready var player_score_label: Label = %PlayerScoreLabel

signal next_pressed

var game_state: GameState

func _ready():
	opponent_score_label.text = "%d pts" % game_state.opponent_running_score
	player_score_label.text = "%d pts" % game_state.player_running_score

	if game_state.round_wins[game_state.round_number - 1] == 1:
		callout.texture = load(WIN_CALLOUT_TEXTURE_PATH)
		wld_label.text = "You Win!"
	elif game_state.round_wins[game_state.round_number - 1] == 2:
		callout.texture = load(LOSE_CALLOUT_TEXTURE_PATH)
		wld_label.text = "You Lose!"
	else:
		callout.texture = load(DRAW_CALLOUT_TEXTURE_PATH)
		wld_label.text = "Draw!"


func _on_texture_button_pressed():
	next_pressed.emit()


func set_game_state(state: GameState) -> void:
	game_state = state