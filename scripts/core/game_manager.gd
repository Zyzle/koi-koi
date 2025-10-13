class_name GameManager
extends Node

var game_state: GameState
# var ai_player: AIPlayer
var ui_manager: UIManager
# var nework_manager: NetworkManager

func _ready() -> void:
	game_state = GameState.new()
	ui_manager = get_node("../UIManager")
	ui_manager.game_manager = self
	
	# Defer initialization to ensure all nodes are ready
	call_deferred("initialize_game")


func initialize_game() -> void:
	# Pass GameState to UIManager
	ui_manager.set_game_state(game_state)
	connect_signals()
	setup_new_game()


func connect_signals() -> void:
	# Game flow signals
	game_state.phase_changed.connect(on_phase_changed)
	game_state.turn_changed.connect(on_turn_changed)
	ui_manager.deal_finished.connect(on_deal_finished)
	
	# Card movement signals for game logic
	# game_state.card_moved_to_field.connect(_on_card_moved_to_field)
	# game_state.cards_captured.connect(_on_cards_captured)
	# game_state.cards_dealt.connect(_on_cards_dealt)
	
	# Score signals
	# game_state.score_updated.connect(_on_score_updated)
	# game_state.points_awarded.connect(_on_points_awarded)
	
	# Model events - Controller translates to UI actions
	game_state.deck_initialized.connect(on_deck_initialized)
	game_state.card_moved.connect(on_card_moved)
	game_state.player_selected_card.connect(on_player_selected_card)
	# game_state.cards_dealt.connect(ui_manager.on_cards_dealt)
	# game_state.card_moved_to_field.connect(ui_manager.animate_card_to_field)
	# game_state.cards_captured.connect(ui_manager.animate_cards_captured)
	# game_state.score_updated.connect(ui_manager.update_scores)


# Game flow signal handlers
func on_phase_changed(new_phase: GameState.Phase) -> void:
	print("Phase changed to: ", new_phase)
	match new_phase:
		GameState.Phase.DEAL:
			print("Dealing cards...")
			for i in range(8):
				game_state.deal_card_to_player()
				game_state.deal_card_to_opponent()
				game_state.deal_card_to_field()
			ui_manager.process_deal_queue()
		GameState.Phase.PLAY:
			print("Starting play phase")
			game_state.current_turn = GameState.Turn.PLAYER


func on_turn_changed(new_turn: GameState.Turn) -> void:
	print("Turn changed to: ", new_turn)
	if new_turn == GameState.Turn.OPPONENT:
		# AI will make move here later
		pass


func on_deal_finished() -> void:
	game_state.current_phase = GameState.Phase.PLAY


# Controller methods - handle user input and decide what to do
func on_player_card_clicked(clicked_card_visual: CardVisual) -> void:
	print("GameManager: Player clicked card: ", clicked_card_visual.card_data)
	# Game logic decides what happens
	if ui_manager.selected_card == clicked_card_visual:
		# Deselect
		game_state.players_chosen_card = null
	else:
		# Select new card
		game_state.players_chosen_card = clicked_card_visual.card_data


func on_field_card_clicked(clicked_card_visual: CardVisual) -> void:
	# make sure it's the players turn and they have chosen a card
	if game_state.is_player_turn() and game_state.players_chosen_card != null:
		# ensure the clicked card is a correct match
		var player_card = game_state.players_chosen_card
		var field_card = clicked_card_visual.card_data

		if player_card.month != field_card.month:
			return
		else:
			game_state.players_chosen_card = null
			game_state.player_captured_cards(player_card, field_card)
		

# Model event handlers - Controller translates to specific UI actions
func on_deck_initialized(deck: Array[Card]) -> void:
	ui_manager.setup_deck_display(deck)


## Handle card moved events from GameState and pass to UI manager
## card is the Card instance that moved
## from_to_location is a string in the format "from_to", e.g. "deck_player_hand"
## move_also is used when a card is moved to the field and needs to animate
func on_card_moved(card: Card, from_to_location: String, move_also: Card) -> void:
	match from_to_location:
		"deck_player_hand":
			ui_manager.on_card_dealt_to_player(card)
		"deck_opponent_hand":
			ui_manager.on_card_dealt_to_opponent(card)
		"deck_field":
			if game_state.current_phase == GameState.Phase.DEAL:
				ui_manager.on_card_dealt_to_field(card)
			else:
				ui_manager.move_deck_to_field(card)
		"player_field_captured":
			ui_manager.field_captured_by_player(card, move_also)
		"deck_field_captured":
			ui_manager.field_captured_by_deck(card, move_also)
		"opponent_field_captured":
			pass


func on_player_selected_card(card: Card) -> void:
	ui_manager.player_selected_card(card)


## Create a new array of all the cards in the cards db,
## then pass these to game_state via add_cards_to_deck()
## moves the current_phase to DEAL
func setup_new_game() -> void:
	var cards: Array[Card] = []
	for card in CardsDB.BASE_DECK:
		var card_instance = Card.new(card["month"], card["number"], card["type"], card["points"])
		cards.append(card_instance)
	game_state.add_cards_to_deck(cards)
	
	# Start the game flow
	game_state.current_phase = GameState.Phase.DEAL
