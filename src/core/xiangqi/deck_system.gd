class_name DeckSystem
extends RefCounted

## DeckSystem：管理牌庫、手牌、棄牌區
## 規則：
##   - 牌庫上限 30 張（召喚卡 + 謀略卡混合）
##   - 相同 ID 至多 2 張
##   - 每回合開始抽 1 張到手牌
##   - 使用後移入棄牌區

const MAX_DECK_SIZE: int = 30
const MAX_COPIES_PER_CARD: int = 2

var deck: Array[CardData] = []
var hand: Array[CardData] = []
var discard_pile: Array[CardData] = []

## 是否已鎖定（鎖定後不可修改牌組）
var is_locked: bool = false

## 建立牌庫。傳入 30 張卡（CardData 子類皆可），成功回傳 true
func build_deck(cards: Array) -> bool:
	if is_locked:
		push_warning("DeckSystem: 牌庫已鎖定，無法重新建立")
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

## 解除鎖定（重新開始遊戲時使用）
func unlock() -> void:
	is_locked = false

## 從牌庫頂抽 1 張加入手牌，牌庫無牌時回傳 null
func draw_card() -> CardData:
	if deck.is_empty():
		return null
	var card: CardData = deck.pop_back()
	hand.append(card)
	return card

## 玩家使用一張手牌：手牌 -> 棄牌區
func play_card(card: CardData) -> bool:
	var idx = hand.find(card)
	if idx == -1:
		return false
	hand.remove_at(idx)
	discard_pile.append(card)
	return true

## 取得牌庫剩餘張數
func get_deck_count() -> int:
	return deck.size()

## 取得棄牌區張數
func get_discard_count() -> int:
	return discard_pile.size()

## 取得手牌（唯讀參考）
func get_hand() -> Array[CardData]:
	return hand

## ── 私有：驗證牌組合法性 ──────────────────────────────────────────
func _validate(cards: Array) -> bool:
	if cards.size() != MAX_DECK_SIZE:
		push_warning("DeckSystem: 牌組張數必須為 %d（目前 %d 張）" % [MAX_DECK_SIZE, cards.size()])
		return false
	var id_count: Dictionary = {}
	for card in cards:
		var id = card.id
		if id == "":
			push_warning("DeckSystem: 存在 id 為空的卡牌，請先設定 id")
			return false
		id_count[id] = id_count.get(id, 0) + 1
		if id_count[id] > MAX_COPIES_PER_CARD:
			push_warning("DeckSystem: 卡牌 '%s' 超過 %d 張上限" % [id, MAX_COPIES_PER_CARD])
			return false
	return true
