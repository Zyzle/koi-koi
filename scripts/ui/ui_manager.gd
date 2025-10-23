class_name UIManager
extends Node

const CARD_SCENE_PATH = "res://scenes/card_visual.tscn"


@onready var player_hand_container: Hand = %PlayerHand
@onready var field_container: Field = %Field
@onready var opponent_hand_container: Hand = %OpponentHand
@onready var deck_slot: Deck = %DeckSlot
@onready var player_capture_area: CaptureArea = %PlayerCaptureArea
@onready var opponent_capture_area: CaptureArea = %OpponentCaptureArea

signal deal_finished();
# signal 

var game_manager: GameManager
var game_state: GameState
var card_registry: Dictionary[Card, CardVisual]
var deal_registry: Array[Dictionary]
var selected_card: CardVisual

func _create_card_visual(card: Card) -> CardVisual:
	var card_scene = preload(CARD_SCENE_PATH)
	var card_visual: CardVisual = card_scene.instantiate()
	card_visual.card_data = card
	
	# Pass GameState if CardVisual needs it
	if game_state:
		card_visual.set_game_state(game_state)
	
	return card_visual


## Retrieve a CardVisual from the registry
func _get_card_visual(card: Card) -> CardVisual:
	return card_registry.get(card, null)


func _highlight_matching_field_cards(card: Card) -> void:
	for child in field_container.get_cards():
		var card_visual = child
		if card == null:
			card_visual.remove_highlight()
		elif card_visual.card_data.month == card.month:
			card_visual.apply_highlight()
		else:
			card_visual.remove_highlight()


func set_game_state(state: GameState) -> void:
	game_state = state


func setup_deck_display(deck: Array[Card]) -> void:
	# Create all card visuals but keep them invisible initially
	# This prevents stacking issues in the deck container
	for card in deck:
		var card_visual = _create_card_visual(card)
		# Connect directly to GameManager (Controller) instead of UIManager
		card_visual.player_card_clicked.connect(game_manager.on_player_card_clicked)
		card_visual.field_card_clicked.connect(game_manager.on_field_card_clicked)
		card_registry[card] = card_visual
		
		# Stacking is preferred for Deck
		deck_slot.add_card(card_visual)
	

func card_dealt_to_player(card: Card) -> void:
	var card_visual = card_registry[card]
	deck_slot.remove_card(card_visual)
	card_visual.connect_events()
	deal_registry.append({card = card_visual, target = player_hand_container})


func card_dealt_to_field(card: Card) -> void:
	var card_visual = card_registry[card]
	deck_slot.remove_card(card_visual)
	card_visual.connect_events()
	deal_registry.append({card = card_visual, target = field_container})


func card_dealt_to_opponent(card: Card) -> void:
	var card_visual = card_registry[card]
	deck_slot.remove_card(card_visual)
	deal_registry.append({card = card_visual, target = opponent_hand_container})


func player_selected_card(card: Card) -> void:
	# Update visual selection state
	if selected_card:
		selected_card.set_selected(false)
	
	if card:
		# Find and select the new card
		var card_visual = _get_card_visual(card)
		if card_visual:
			card_visual.set_selected(true)
			selected_card = card_visual
			
			# Auto-play to field if in PLAY_CARD_TO_FIELD phase
			if game_state.current_turn_phase == GameState.TurnPhase.PLAY_CARD_TO_FIELD:
				# Automatically play the selected card to field since no capture is possible
				game_manager.play_card_to_field(card)
				card_visual.set_selected(false)
				selected_card = null
				return
			else:
				print("not playing card to field, state:", game_state.current_turn_phase)
	else:
		selected_card = null
		
	# Highlight matching field cards (only during capture phases)
	if game_state.current_turn_phase == GameState.TurnPhase.HAND_FIELD_CAPTURE:
		_highlight_matching_field_cards(card)
	else:
		# Clear all highlights if not in capture mode
		for child in field_container.get_cards():
			child.remove_highlight()


func process_deal_queue() -> void:
	for deal in deal_registry:
		var tween = await deal.target.add_card(deal.card, deal.target == player_hand_container)
		await tween.finished

	deal_registry.clear()
	deal_finished.emit()


func move_deck_to_field(card: Card) -> void:
	var card_visual = _get_card_visual(card)
	deck_slot.remove_card(card_visual)
	card_visual.connect_events()
	if field_container.all_slots_occupied():
		field_container.open_next_slot()
	var tween = field_container.add_card(card_visual, false)
	await tween.finished


## Handle when player plays a card from hand to field
func player_card_to_field(card: Card) -> void:
	var card_visual = _get_card_visual(card)
	if card_visual:
		card_visual.set_selected(false)
		card_visual.disconnect_events()
		player_hand_container.remove_card(card_visual)
		var tween = field_container.add_card(card_visual, false)
		await tween.finished
		card_visual.connect_events()
		field_container.clear_all_highlights()
	selected_card = null


func field_captured_by_player(player_card: Card, field_card: Card) -> void:
	var player_card_visual = _get_card_visual(player_card)
	var field_card_visual = _get_card_visual(field_card)

	player_card_visual.set_selected(false)
	player_card_visual.unembiggen(true)
	player_card_visual.disconnect_events()
	field_container.remove_card(field_card_visual)
	player_hand_container.remove_card(player_card_visual)
	selected_card = null
	
	if player_card_visual:
		var tween = player_capture_area.capture_card(player_card_visual)
		await tween.finished
	
	if field_card_visual:
		var tween = player_capture_area.capture_card(field_card_visual)
		await tween.finished

	# game_state.start_deck_move()


func field_captured_by_deck(deck_card: Card, field_card: Card) -> void:
	var deck_card_visual = _get_card_visual(deck_card)
	var field_card_visual = _get_card_visual(field_card)

	deck_card_visual.set_selected(false)
	deck_slot.remove_card(deck_card_visual)
	field_container.remove_card(field_card_visual)
	selected_card = null

	if deck_card_visual:
		var tween = player_capture_area.capture_card(deck_card_visual)
		await tween.finished

	if field_card_visual:
		var tween = player_capture_area.capture_card(field_card_visual)
		await tween.finished


## Set UI state for capture mode (player can capture from field)
func set_capture_mode() -> void:
	print("UI: Capture mode enabled")
	# Could add visual indicators here


## Set UI state for playing cards to field (no capture possible)
func set_play_to_field_mode() -> void:
	# Could add visual indicators here
	field_container.highlight_available_slot()


## Set UI state for deck capture mode (deck card can capture)
func set_deck_capture_mode() -> void:
	print("UI: Deck capture mode enabled")
	# Could add visual indicators or highlight deck card
	var top_card = deck_slot.get_top_card()
	top_card.set_selected(true)
	_highlight_matching_field_cards(top_card.card_data)


## Flip the top deck card
func flip_deck_card() -> void:
	print("UI: Flipping deck card")
	var top_card = deck_slot.get_top_card()
	if top_card:
		top_card.flip_card()


## Clean up UI state at end of turn
func end_turn_cleanup() -> void:
	print("UI: Cleaning up turn")
	if selected_card:
		selected_card.set_selected(false)
		selected_card = null
	
	# Remove all field card highlights
	for card_visual in field_container.get_cards():
		card_visual.remove_highlight()
