class_name UIManager
extends Control

const CARD_SCENE_PATH = "res://scenes/card_visual.tscn"

@onready var player_hand_container: HBoxContainer = %PlayerHand
@onready var field_container: GridContainer = %Field
@onready var opponent_hand_container: HBoxContainer = %OpponentHand
@onready var deck_container: PanelContainer = %DeckContainer

var game_manager: GameManager
var card_registry: Dictionary
var deal_registry: Array[Dictionary]


func _ready() -> void:
	pass
	

func on_deck_setup(deck: Array[Card]) -> void:
	setup_deck_display(deck)


func on_card_clicked(card_visual: CardVisual) -> void:
	print("UIManager detected card click: ", card_visual.card_data)
	# game_manager.handle_player_card_click(card_visual.card_data)


func setup_deck_display(deck: Array[Card]) -> void:
	# Create all card visuals but keep them invisible initially
	# This prevents stacking issues in the deck container
	for card in deck:
		var card_visual = create_card_visual(card)
		card_visual.card_clicked.connect(on_card_clicked)
		card_registry[card] = card_visual
		
		# Stacking is preferred for Deck
		deck_container.add_child(card_visual)
	
	# Update deck count display
	if deck_container.has_node("DeckLabel"):
		deck_container.get_node("DeckLabel").text = str(deck.size())


func on_card_dealt_to_player(card: Card) -> void:
	deal_registry.append({card = card, target = player_hand_container})


func on_card_dealt_to_field(card: Card) -> void:
	deal_registry.append({card = card, target = field_container})


func on_card_dealt_to_opponent(card: Card) -> void:
	deal_registry.append({card = card, target = opponent_hand_container})


func process_deal_queue() -> void:
	for deal in deal_registry:
		var tween
		if deal.target == opponent_hand_container:
			# For opponent's hand, do not flip the card
			tween = await move_card_visual(deal.card, deal.target, true, false)
		else:
			# For player and field, flip the card to show face
			tween = await move_card_visual(deal.card, deal.target, true, true)

		if tween:
			await tween.finished
			# reset z_index after animation
			var visual = get_card_visual(deal.card)
			visual.z_index = 1
	deal_registry.clear()


func create_card_visual(card: Card) -> CardVisual:
	var card_scene = preload(CARD_SCENE_PATH)
	var card_visual = card_scene.instantiate()
	card_visual.setup_card(card)
	
	return card_visual


## Retrieve a CardVisual from the registry
func get_card_visual(card: Card) -> CardVisual:
	return card_registry.get(card, null)


## Move a card visual from one container to another
func move_card_visual(card: Card, target_container: Control, animate: bool = true, and_flip: bool = false) -> Tween:
	var card_visual = get_card_visual(card)
	if not card_visual:
		print("Error: No CardVisual found for card: ", card)
		return null
	
	if animate:
		# Get current global position before reparenting
		var start_pos = card_visual.global_position
		
		# hide card until animation start
		card_visual.toggle_visibility(false)
		# Reparent to new container
		var old_parent = card_visual.get_parent()
		if old_parent:
			old_parent.remove_child(card_visual)
		target_container.add_child(card_visual)
		
		# Let container position the card, then animate from old position
		await get_tree().process_frame # Wait for layout
		var end_pos = card_visual.global_position
		
		# Animate from old position to new container position
		card_visual.global_position = start_pos
		# unhide card at start of animation
		card_visual.toggle_visibility(true)
		# ensure card_visual is on top during animation
		card_visual.z_index = 10

		if and_flip:
			card_visual.flip_card()

		var tween = create_tween()
		tween.tween_property(card_visual, "global_position", end_pos, 0.25)
		return tween
	else:
		# Simple reparenting without animation
		# this may or may not be needed
		var old_parent = card_visual.get_parent()
		if old_parent:
			old_parent.remove_child(card_visual)
		target_container.add_child(card_visual)
		return null
