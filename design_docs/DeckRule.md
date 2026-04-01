# 牌庫規則 (Deck Rules)

## 一、牌庫組成
| 規則 | 說明 |
| :--- | :--- |
| 牌庫張數上限 | **30 張** |
| 相同 ID 上限 | **同一張卡（相同 `id`）至多 2 張** |
| 牌庫種類 | 謀略卡（`StrategyCardData`）召喚卡（`SummonCardData`）混和 |

每位玩家（紅方／黑方）各有一組獨立的牌庫、手牌、棄牌區。

---

## 二、建立牌庫
使用 `DeckSystem.build_deck(cards: Array[StrategyCardData])` 建立牌庫：
- 傳入正好 **30 張**卡牌的陣列。
- 系統會驗證每個 `id` 的出現次數是否超過 2 張。
- 驗證通過後自動**洗牌**。
- 若驗證失敗，回傳 `false` 且牌庫不會被建立。

---

## 三、抽牌規則
| 時機 | 行為 |
| :--- | :--- |
| 每回合開始（`_start_new_turn`） | 當前玩家自動從牌庫頂**抽 1 張卡**加入手牌 |
| 牌庫無牌時 | 不抽牌（`draw_card()` 返回 `null`） |

> [!NOTE]
> 「抽牌」卡效果（`DrawCardEffect`）為**額外抽牌**，與每回合固定抽牌各自獨立計算。

---

## 四、棄牌規則
| 時機 | 行為 |
| :--- | :--- |
| 使用謀略卡成功（`play_strategy_card`） | 該卡牌從手牌移入**棄牌區** |

- 棄牌區的牌**不會自動重新洗回牌庫**（本版本規則）。
- 可透過 `DeckSystem.get_discard_count()` 查詢棄牌區張數。

---

## 五、相關 API 摘要

**`DeckSystem`** (`src/core/xiangqi/deck_system.gd`)

| 方法 | 說明 |
| :--- | :--- |
| `build_deck(cards)` | 建立並驗證牌庫，回傳 `bool` |
| `draw_card()` | 抽 1 張到手牌，回傳 `StrategyCardData` |
| `play_card(card)` | 從手牌移入棄牌區，回傳 `bool` |
| `get_hand()` | 取得手牌陣列（唯讀） |
| `get_deck_count()` | 牌庫剩餘張數 |
| `get_discard_count()` | 棄牌區張數 |

---

## 六、常見限制整理
- **空 ID**：id 為空字串的卡牌無法通過驗證。
- **超出上限**：同 id 超過 2 張時 `build_deck` 返回 `false` 並印出警告。
- **張數不符**：總張數非 30 張時 `build_deck` 返回 `false` 並印出警告。

---

## 七、棄牌區 (Discard Pile)**(尚未實作)**
- 預設在棋盤右側，滑鼠移到該區域時，會顯示該玩家的棄牌區；點擊即可展開視窗
- 按照時間順序，記錄被使用的卡牌