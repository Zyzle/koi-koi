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

var game_manager: GameManager
var game_state: GameState
var card_registry: Dictionary[Card, CardVisual]
var deal_registry: Array[Dictionary]
var selected_card: CardVisual


func set_game_state(state: GameState) -> void:
	game_state = state


func setup_deck_display(deck: Array[Card]) -> void:
	# Create all card visuals but keep them invisible initially
	# This prevents stacking issues in the deck container
	for card in deck:
		var card_visual = create_card_visual(card)
		# Connect directly to GameManager (Controller) instead of UIManager
		card_visual.player_card_clicked.connect(game_manager.on_player_card_clicked)
		card_visual.field_card_clicked.connect(game_manager.on_field_card_clicked)
		card_registry[card] = card_visual
		
		# Stacking is preferred for Deck
		deck_slot.add_card(card_visual)
	

func on_card_dealt_to_player(card: Card) -> void:
	var card_visual = card_registry[card]
	deck_slot.remove_card(card_visual)
	card_visual.connect_events()
	deal_registry.append({card = card_visual, target = player_hand_container})


func on_card_dealt_to_field(card: Card) -> void:
	var card_visual = card_registry[card]
	deck_slot.remove_card(card_visual)
	card_visual.connect_events()
	deal_registry.append({card = card_visual, target = field_container})


func on_card_dealt_to_opponent(card: Card) -> void:
	var card_visual = card_registry[card]
	deck_slot.remove_card(card_visual)
	deal_registry.append({card = card_visual, target = opponent_hand_container})


func player_selected_card(card: Card) -> void:
# 	# Update visual selection state
	if selected_card:
		selected_card.set_selected(false)
	
	if card:
		# Find and select the new card
		var card_visual = get_card_visual(card)
		if card_visual:
			card_visual.set_selected(true)
			selected_card = card_visual
	else:
		selected_card = null
		
	# Highlight matching field cards
	for child in field_container.get_cards():
		var card_visual = child
		if card == null:
			card_visual.remove_highlight()
		elif card_visual.card_data.month == card.month:
			card_visual.apply_highlight()
		else:
			card_visual.remove_highlight()


func process_deal_queue() -> void:
	for deal in deal_registry:
		var tween = await deal.target.add_card(deal.card, deal.target == player_hand_container)
		await tween.finished

	deal_registry.clear()
	deal_finished.emit()


func move_deck_to_field(card: Card) -> void:
	var card_visual = get_card_visual(card)
	deck_slot.remove_card(card_visual)
	card_visual.connect_events()
	var tween = field_container.add_card(card_visual, false)
	await tween.finished


func field_captured_by_player(player_card: Card, field_card: Card) -> void:
	var player_card_visual = get_card_visual(player_card)
	var field_card_visual = get_card_visual(field_card)

	player_card_visual.set_selected(false)
	player_card_visual.unembiggen(true)
	player_card_visual.disconnect_events()
	field_container.remove_card(field_card_visual)
	selected_card = null
	
	if player_card_visual:
		var tween = player_capture_area.capture_card(player_card_visual)
		await tween.finished
	
	if field_card_visual:
		var tween = player_capture_area.capture_card(field_card_visual)
		await tween.finished

	deck_slot.get_top_card().flip_card()
	game_state.start_deck_move()

	# game_state.make_deck_top_playable()


func field_captured_by_deck(deck_card: Card, field_card: Card) -> void:
	var deck_card_visual = get_card_visual(deck_card)
	var field_card_visual = get_card_visual(field_card)

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


func create_card_visual(card: Card) -> CardVisual:
	var card_scene = preload(CARD_SCENE_PATH)
	var card_visual: CardVisual = card_scene.instantiate()
	card_visual.card_data = card
	
	# Pass GameState if CardVisual needs it
	if game_state:
		card_visual.set_game_state(game_state)
	
	return card_visual


## Retrieve a CardVisual from the registry
func get_card_visual(card: Card) -> CardVisual:
	return card_registry.get(card, null)
