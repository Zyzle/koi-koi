extends Node2D

@export var main_game: PackedScene;

func _on_main_menu_start_game():
	start_game()


func start_game() -> void:
	var game_instance = main_game.instantiate()
	add_child(game_instance)
	move_child(game_instance, 0)
