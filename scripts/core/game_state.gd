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
	NONE,
	PLAYER,
	OPPONENT
}

enum TurnPhase {
	NONE, # 0
	HAND_FIELD_CAPTURE, # 1
	PLAY_CARD_TO_FIELD, # 2
	FLIP_DECK_CARD, # 3
	DECK_FIELD_CAPTURE, # 4
	TURN_END # 5
}

# Private variables for properties with setters
var _current_phase: Phase
var _current_turn: Turn
var _current_turn_phase: TurnPhase
var _players_chosen_card: Card

# Properties with automatic signal emission
var current_phase: Phase:
	get: return _current_phase
	set(value):
		if _current_phase != value:
			_current_phase = value
			phase_changed.emit(value)

var current_turn: Turn:
	get: return _current_turn
	set(value):
		if _current_turn != value:
			_current_turn = value
			turn_changed.emit(value)

var current_turn_phase: TurnPhase:
	get: return _current_turn_phase
	set(value):
		if _current_turn_phase != value:
			_current_turn_phase = value
			turn_phase_changed.emit(value)

var players_chosen_card: Card:
	get: return _players_chosen_card
	set(value):
		_players_chosen_card = value
		player_selected_card.emit(value)

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
signal turn_phase_changed(new_turn_phase: TurnPhase)
signal player_selected_card(card: Card)

# Model Events (generic)
signal card_moved(card: Card, from_to_location: String, move_also: Card)
signal deck_initialized(deck: Array[Card])


## Add a set of `Card` instances to the deck and shuffle
## emit deck_setup signal
func add_cards_to_deck(cards: Array[Card]) -> void:
	deck = cards
	deck.shuffle()
	deck_initialized.emit(deck)
	

func deal_card_to_player() -> void:
	if deck.size() == 0:
		print("Deck is empty, cannot deal to player")
		return
	var card = deck.pop_back()
	card.make_player_card()
	player_hand.append(card)
	card_moved.emit(card, "deck_player_hand", null)


func deal_card_to_opponent() -> void:
	if deck.size() == 0:
		print("Deck is empty, cannot deal to opponent")
		return
	var card = deck.pop_back()
	opponent_hand.append(card)
	card_moved.emit(card, "deck_opponent_hand", null)


func deal_card_to_field() -> void:
	if deck.size() == 0:
		print("Deck is empty, cannot deal to field")
		return
	var card = deck.pop_back()
	card.make_field_card()
	field_cards.append(card)
	card_moved.emit(card, "deck_field", null)


func is_player_turn() -> bool:
	return _current_phase == Phase.PLAY and _current_turn == Turn.PLAYER


## When capturing cards, card1 is the players chosen card, either form their hand
## or the top of the deck, card 2 is the field card being captured
func player_captured_cards(card1: Card, card2: Card) -> void:
	if field_cards.has(card2):
		# card came from the field
		field_cards.erase(card2)
	else:
		# card came from the deck
		deck.erase(card2)

	player_captured.append(card2)

	if player_hand.has(card1):
		# card came from player's hand
		player_hand.erase(card1)
		player_captured.append(card1)
		card_moved.emit(card1, "player_field_captured", card2)
	else:
		# card came from the deck
		deck.erase(card1)
		player_captured.append(card1)
		card_moved.emit(card1, "deck_field_captured", card2)


func start_deck_move() -> void:
	var card = deck[deck.size() - 1]
	# check if card is playable in field, if not add it
	if not field_cards.any(func(field_card: Card): return field_card.month == card.month):
		deal_card_to_field()
	else:
		deck.erase(card)
		players_chosen_card = card


## Start a new turn for the current player
func start_turn() -> void:
	if not is_player_turn():
		return
	
	# Check if player has any cards that can capture from field
	if can_player_capture_from_field():
		current_turn_phase = TurnPhase.HAND_FIELD_CAPTURE
	else:
		current_turn_phase = TurnPhase.PLAY_CARD_TO_FIELD


## Check if the current player has any cards that can capture from the field
func can_player_capture_from_field() -> bool:
	for hand_card in player_hand:
		for field_card in field_cards:
			if hand_card.month == field_card.month:
				return true
	return false


## Check if a specific card can capture from the field
func can_card_capture_from_field(card: Card) -> bool:
	for field_card in field_cards:
		if card.month == field_card.month:
			return true
	return false


## Advance to the next phase of the turn
func advance_turn_phase() -> void:
	match current_turn_phase:
		TurnPhase.HAND_FIELD_CAPTURE:
			# Player made a capture, now flip deck card
			current_turn_phase = TurnPhase.FLIP_DECK_CARD
			
		TurnPhase.PLAY_CARD_TO_FIELD:
			# Player played card to field, now flip deck card
			current_turn_phase = TurnPhase.FLIP_DECK_CARD
			
		TurnPhase.FLIP_DECK_CARD:
			# Check if deck card can capture
			var deck_card = deck[deck.size() - 1]
			if can_card_capture_from_field(deck_card):
				current_turn_phase = TurnPhase.DECK_FIELD_CAPTURE
			else:
				# Deck card goes to field, turn ends
				deal_card_to_field()
				current_turn_phase = TurnPhase.TURN_END
				
		TurnPhase.DECK_FIELD_CAPTURE:
			# Deck capture completed, turn ends
			current_turn_phase = TurnPhase.TURN_END
			
		TurnPhase.TURN_END:
			# Switch to opponent turn
			if current_turn == Turn.PLAYER:
				current_turn = Turn.OPPONENT
			else:
				current_turn = Turn.PLAYER
				start_turn()
