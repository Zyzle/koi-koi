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
	game_state.phase_changed.connect(_on_phase_changed)
	game_state.turn_changed.connect(_on_turn_changed)
	ui_manager.deal_finished.connect(_on_deal_finished)
	
	# Card movement signals for game logic
	# game_state.card_moved_to_field.connect(_on_card_moved_to_field)
	# game_state.cards_captured.connect(_on_cards_captured)
	# game_state.cards_dealt.connect(_on_cards_dealt)
	
	# Score signals
	# game_state.score_updated.connect(_on_score_updated)
	# game_state.points_awarded.connect(_on_points_awarded)
	
	# Model events - Controller translates to UI actions
	game_state.deck_initialized.connect(_on_deck_initialized)
	game_state.card_moved.connect(_on_card_moved)
	game_state.player_selected_card.connect(on_player_selected_card)
	# game_state.cards_dealt.connect(ui_manager.on_cards_dealt)
	# game_state.card_moved_to_field.connect(ui_manager.animate_card_to_field)
	# game_state.cards_captured.connect(ui_manager.animate_cards_captured)
	# game_state.score_updated.connect(ui_manager.update_scores)


# Game flow signal handlers
func _on_phase_changed(new_phase: GameState.Phase) -> void:
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


func _on_turn_changed(new_turn: GameState.Turn) -> void:
	print("Turn changed to: ", new_turn)
	if new_turn == GameState.Turn.OPPONENT:
		# AI will make move here later
		pass


func _on_deal_finished() -> void:
	game_state.current_phase = GameState.Phase.PLAY


# Controller methods - handle user input and decide what to do
func on_player_card_clicked(clicked_card_visual: CardVisual) -> void:
	print("GameManager: Player clicked card: ", clicked_card_visual.card_data)
	# Game logic decides what happens
	if ui_manager.selected_card == clicked_card_visual:
		# Deselect
		game_state.player_choose_card(null)
	else:
		# Select new card
		game_state.player_choose_card(clicked_card_visual.card_data)


func on_field_card_clicked(clicked_card_visual: CardVisual) -> void:
	print("GameManager: Player clicked field card: ", clicked_card_visual.card_data)
	# TODO: Implement card matching logic
	pass


# Model event handlers - Controller translates to specific UI actions
func _on_deck_initialized(deck: Array[Card]) -> void:
	ui_manager.on_deck_setup(deck)


func _on_card_moved(card: Card, _from_location: String, to_location: String) -> void:
	match to_location:
		"player_hand":
			ui_manager.on_card_dealt_to_player(card)
		"opponent_hand":
			ui_manager.on_card_dealt_to_opponent(card)
		"field":
			ui_manager.on_card_dealt_to_field(card)


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
