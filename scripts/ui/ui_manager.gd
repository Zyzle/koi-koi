class_name UIManager
extends Control

const CARD_SCENE_PATH = "res://scenes/card_visual.tscn"

@onready var player_hand_container: HBoxContainer = %PlayerHand
@onready var field_container: GridContainer = %Field
@onready var opponent_hand_container: HBoxContainer = %OpponentHand
@onready var deck_container: PanelContainer = %DeckContainer

var game_manager: GameManager
var card_registry: Dictionary

func _ready():
	print("UIManager _ready() called")
	

func on_deck_setup(deck: Array[Card]):
	print("Deck setup with ", deck.size(), " cards")
	print("panel container: ", deck_container)
	setup_deck_display(deck)


func setup_deck_display(deck: Array[Card]):
	# Your deck display logic here
	# deck_container.get_node("DeckSprite").texture = preload("res://assets/cardback.png")
	for card in deck:
		var card_visual = create_card_visual(card)
		card_registry[card] = card_visual
		deck_container.add_child(card_visual)
	deck_container.get_node("DeckLabel").text = str(deck.size())

	
	# for deck_node in deck_container.get_children():
	# 	print("Deck child: ", deck_node)


func on_card_dealt_to_player(card: Card):
	print("Card dealt to player: ", card)
	# get visaual representing card
	move_card_visual(card, player_hand_container)


func on_card_dealt_to_field(card: Card):
	print("Card dealt to field: ", card)
	move_card_visual(card, field_container)


func on_card_dealt_to_opponent(card: Card):
	print("Card dealt to opponent: ", card)
	move_card_visual(card, opponent_hand_container)

	
func create_card_visual(card: Card) -> CardVisual:
	var card_scene = preload(CARD_SCENE_PATH)
	var card_visual = card_scene.instantiate()
	card_visual.setup_card(card)
	return card_visual


## Retrieve a CardVisual from the registry
func get_card_visual(card: Card) -> CardVisual:
	return card_registry.get(card, null)


## Move a card visual from one container to another
func move_card_visual(card: Card, target_container: Control, animate: bool = true):
	var card_visual = get_card_visual(card)
	if not card_visual:
		print("Error: No CardVisual found for card: ", card)
		return
	
	# Get current global position for animation
	var start_pos = card_visual.global_position
	
	# Reparent to new container
	var old_parent = card_visual.get_parent()
	if old_parent:
		old_parent.remove_child(card_visual)
	target_container.add_child(card_visual)
	
	if animate:
		# Calculate end position after reparenting
		var end_pos = card_visual.global_position
		
		# Start from old position and animate to new
		card_visual.global_position = start_pos
		var tween = create_tween()
		tween.tween_property(card_visual, "global_position", end_pos, 0.5)