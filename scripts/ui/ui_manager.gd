class_name UIManager
extends Control

@onready var player_hand_container: HBoxContainer = %PlayerHand
@onready var field_container: GridContainer = %Field
@onready var opponent_hand_container: HBoxContainer = %OpponentHand
@onready var deck_container: PanelContainer = %DeckContainer

var game_manager: GameManager

func _ready():
	print("UIManager _ready() called")
	

func on_deck_setup(deck: Array[Card]):
	print("Deck setup with ", deck.size(), " cards")
	print("panel container: ", deck_container)
	setup_deck_display(deck)


func setup_deck_display(deck: Array[Card]):
	# Your deck display logic here
	deck_container.get_node("DeckSprite").texture = preload("res://assets/cardback.png")
	deck_container.get_node("DeckLabel").text = str(deck.size())

func on_card_dealt_to_player(card: Card):
	print("Card dealt to player: ", card)
