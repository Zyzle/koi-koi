class_name GameState
extends Resource

enum Phase {
	NONE,
	START,
	DEAL,
	PLAY,
	DRAW,
	SCORE,
	ROUND_END
}

enum Turn {
	PLAYER,
	OPPONENT
}

# Private variables for properties with setters
var _current_phase: Phase
var _current_turn: Turn

# Properties with automatic signal emission
var current_phase: Phase:
	get: return _current_phase
	set(value):
		print("Setting current_phase to ", value)
		if _current_phase != value:
			_current_phase = value
			phase_changed.emit(value)

var current_turn: Turn:
	get: return _current_turn
	set(value):
		if _current_turn != value:
			_current_turn = value
			turn_changed.emit(value)

# Regular properties
var round_number: int
var player_hand: Array[Card]
var opponent_hand: Array[Card]
var field_cards: Array[Card]
var deck: Array[Card]
var player_captured: Array[Card]
var opponent_captured: Array[Card]
var player_score: int
var opponent_score: int

# Game Flow Signals
signal phase_changed(new_phase: Phase)
signal turn_changed(new_turn: Turn)
signal round_started(round_number: int)
signal game_ended(winner: Turn)

# Card Movement Signals
signal card_dealt_to_player(card: Card)
signal card_dealt_to_opponent(card: Card)
signal card_dealt_to_field(card: Card)
signal deck_setup(deck: Array[Card])


## Add a set of `Card` instances to the deck and shuffle
## emit deck_setup signal
func add_cards_to_deck(cards: Array[Card]) -> void:
	deck = cards
	deck.shuffle()
	deck_setup.emit(deck)
	

func deal_card_to_player() -> void:
	if deck.size() == 0:
		print("Deck is empty, cannot deal to player")
		pass
	var card = deck.pop_front()
	player_hand.append(card)
	card_dealt_to_player.emit(card)


func deal_card_to_opponent() -> void:
	if deck.size() == 0:
		print("Deck is empty, cannot deal to opponent")
		pass
	var card = deck.pop_front()
	opponent_hand.append(card)
	card_dealt_to_opponent.emit(card)


func deal_card_to_field() -> void:
	if deck.size() == 0:
		print("Deck is empty, cannot deal to field")
		pass
	var card = deck.pop_front()
	field_cards.append(card)
	card_dealt_to_field.emit(card)
