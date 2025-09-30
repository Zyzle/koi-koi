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

func _init(m: int, n: int, t: CardType, p: int) -> void:
	month = m
	number = n
	type = t
	points = p
