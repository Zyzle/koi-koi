class_name Card
## Represents a single Hanafuda card
extends RefCounted

## Card types
enum CardType {
	PLAIN,
	ANIMAL,
	RIBBON,
	BRIGHT
}

var month: int
var number: int
var type: CardType
var points: int
var is_player_card: bool = false

func _init(m: int, n: int, t: CardType, p: int) -> void:
	month = m
	number = n
	type = t
	points = p


func make_player_card() -> void:
	is_player_card = true