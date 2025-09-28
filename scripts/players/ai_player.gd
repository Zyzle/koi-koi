class_name AIPlayer
extends Player

enum Difficulty {
	EASY,
	MEDIUM,
	HARD
}

var difficulty: Difficulty

func make_move(game_state: GameState) -> Dictionary:
	return {}