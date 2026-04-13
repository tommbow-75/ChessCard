class_name DeckSystem
extends RefCounted

const MAX_DECK_SIZE: int = 30
const MAX_COPIES_PER_CARD: int = 2

var deck: Array[CardData] = []
var hand: Array[CardData] = []
var discard_pile: Array[CardData] = []
var is_locked: bool = false

func build_deck(cards: Array) -> bool:
	if is_locked:
		push_warning("DeckSystem: deck is locked")
		return false
	if not _validate(cards):
		return false

	deck.clear()
	for c in cards:
		deck.append(c)
	deck.shuffle()
	hand.clear()
	discard_pile.clear()
	is_locked = true
	return true

func unlock() -> void:
	is_locked = false

func draw_card() -> CardData:
	if deck.is_empty():
		return null
	var card: CardData = deck.pop_back()
	hand.append(card)
	return card

func play_card(card: CardData) -> bool:
	var idx = hand.find(card)
	if idx == -1:
		return false
	hand.remove_at(idx)
	discard_pile.append(card)
	return true

func get_deck_count() -> int:
	return deck.size()

func get_discard_count() -> int:
	return discard_pile.size()

func get_hand() -> Array[CardData]:
	return hand

func _validate(cards: Array) -> bool:
	if cards.size() != MAX_DECK_SIZE:
		push_warning("DeckSystem: expected %d cards, got %d" % [MAX_DECK_SIZE, cards.size()])
		return false

	var id_count: Dictionary = {}
	for card in cards:
		var id = card.id
		if id == "":
			push_warning("DeckSystem: every card needs a non-empty id")
			return false
		id_count[id] = id_count.get(id, 0) + 1
		if id_count[id] > MAX_COPIES_PER_CARD:
			push_warning("DeckSystem: '%s' exceeds max copies %d" % [id, MAX_COPIES_PER_CARD])
			return false
	return true
