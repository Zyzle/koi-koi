class_name GameManager
extends Node

var game_state: GameState
# var ai_player: AIPlayer
var ui_manager: UIManager
# var nework_manager: NetworkManager

func _ready():
	print("GameManager ready")
	game_state = GameState.new()
	ui_manager = get_node("../UIManager")
	ui_manager.game_manager = self
	
	# Defer initialization to ensure all nodes are ready
	call_deferred("initialize_game")

func initialize_game():
	"""Initialize the game after all nodes are ready"""
	print("Initializing game - all nodes ready")
	
	connect_signals()
	setup_new_game()

func connect_signals():
	"""Connect all game state signals to their handlers"""
	print("Connecting signals...")
	
	# Game flow signals
	game_state.phase_changed.connect(_on_phase_changed)
	game_state.turn_changed.connect(_on_turn_changed)
	
	# Card movement signals for game logic
	# game_state.card_moved_to_field.connect(_on_card_moved_to_field)
	# game_state.cards_captured.connect(_on_cards_captured)
	# game_state.cards_dealt.connect(_on_cards_dealt)
	
	# Score signals
	# game_state.score_updated.connect(_on_score_updated)
	# game_state.points_awarded.connect(_on_points_awarded)
	
	# UI signals - forward game state changes to UI
	game_state.deck_setup.connect(ui_manager.on_deck_setup)
	game_state.card_dealt_to_player.connect(ui_manager.on_card_dealt_to_player)
	game_state.card_dealt_to_field.connect(ui_manager.on_card_dealt_to_field)
	game_state.card_dealt_to_opponent.connect(ui_manager.on_card_dealt_to_opponent)
	# game_state.cards_dealt.connect(ui_manager.on_cards_dealt)
	# game_state.card_moved_to_field.connect(ui_manager.animate_card_to_field)
	# game_state.cards_captured.connect(ui_manager.animate_cards_captured)
	# game_state.score_updated.connect(ui_manager.update_scores)
	
	print("All signals connected")


# Game flow signal handlers
func _on_phase_changed(new_phase: GameState.Phase):
	print("Phase changed to: ", new_phase)
	match new_phase:
		GameState.Phase.DEAL:
			print("Dealing cards...")
			for i in range(8):
				game_state.deal_card_to_player()
				game_state.deal_card_to_opponent()
				game_state.deal_card_to_field()
		GameState.Phase.PLAY:
			print("Starting play phase")


func _on_turn_changed(new_turn: GameState.Turn):
	print("Turn changed to: ", new_turn)
	if new_turn == GameState.Turn.OPPONENT:
		# AI will make move here later
		pass


## Create a new array of all the cards in the cards db,
## then pass these to game_state via add_cards_to_deck()
## moves the current_phase to DEAL
func setup_new_game():
	print("Setting up new game...")
	var cards: Array[Card] = []
	for card in CardsDB.BASE_DECK:
		var card_instance = Card.new(card["month"], card["number"], card["type"], card["points"])
		cards.append(card_instance)
	game_state.add_cards_to_deck(cards)
	
	# Start the game flow
	game_state.current_phase = GameState.Phase.DEAL
