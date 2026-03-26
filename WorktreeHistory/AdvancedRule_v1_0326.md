# AdvancedRule 實作變更紀錄 v1.0 (2026-03-26)

## 概述
本次依照 `AdvancedRule.md` 實作了三大系統：
1. **SP（謀略點數）** 的獲得邏輯
2. **士氣（Morale）** 的扣除邏輯
3. **卡牌效果屬性（天生 / 一次性 / 召喚）** 的觸發邏輯

---

## 新增檔案

### `Scripts/Effects/`（效果積木）

| 檔案 | 效果時機 | 說明 | 使用卡牌 |
|------|----------|------|----------|
| `heal_morale_effect.gd` | SUMMON（召喚） | 召喚時立即回復指定量士氣 | 醫生象（+5） |
| `restore_on_capture_effect.gd` | BORN（天生） | 每次吃子後回復指定量士氣 | 猛將（+2） |
| `cannot_eat_effect.gd` | BORN（天生） | 禁止吃指定種類的目標（可設定 `forbidden_target`） | 垃圾炮（不可吃將帥） |
| `extra_move_effect.gd` | ONCE（一次性） | 吃子後可額外再移動一次 | 火焰車 |
| `knight_leap_effect.gd` | ONCE（一次性） | 允許棋子使用一次超距跳躍 (±1,±3) / (±3,±1) | 騎士 |
| `dual_movement_effect.gd` | BORN（天生） | 天生同時擁有另一種棋子的走法（可設定 `extra_piece_type`） | 鐵衛（ADVISOR + GENERAL） |

所有效果積木皆繼承自 `CardEffectTiming`（位於 `Scripts/card_EffectTiming.gd`）。

### `tests/test_advanced_rules.gd`
共 9 個測試案例的自動化測試腳本（`@tool`），涵蓋：
- SP 每回合 +1、吃卒 +1、吃車 +2
- 士氣被吃自扣
- 召喚合法性（SP 不足、格子被佔、非入場區）
- `cannot_eat_effect` 攔截
- `restore_on_capture_effect` 天生回血

---

## 修改檔案

### `Scripts/Effects/card_EffectTiming.gd`
- Enum 由 `ALWAYS` 改為 `BORN`，對應規格書「天生」用語

### `Scripts/summon_card_data.gd`
- 新增 `@export var special_effects: Array[CardEffectTiming] = []`
- 允許在 Godot Inspector 面板直接掛載效果積木

### `src/core/xiangqi/xiangqi_piece.gd`
- 新增 `var special_effects: Array = []`：存放從卡牌複製的效果列表
- 新增 `var knight_leap_available: bool = false`：騎士一次性躍遷標記

### `src/core/xiangqi/xiangqi_game.gd`
新增狀態變數：
- `sp_red / sp_black`（謀略點數）
- `morale_red / morale_black`（初始各 100）
- `pending_extra_move`（火焰車再走標記）

新增函式：

| 函式 | 說明 |
|------|------|
| `start_turn()` | 回合開始，當手玩家 +1 SP |
| `get_sp(side)` | 取得指定陣營當前 SP |
| `get_morale(side)` | 取得指定陣營當前士氣 |
| `summon_piece(card, pos, side)` | 召喚邏輯（SP 檢查、格子檢查、入場區檢查、觸發 SUMMON 效果） |
| `_grant_capture_sp(type, side)` | 依吃子種類給對應 SP |
| `_deduct_capture_morale(type, side)` | 依被吃子種類扣除士氣 |
| `_trigger_born_capture_effects(piece)` | 觸發棋子天生吃子效果 |
| `_trigger_and_consume_once_effects(piece)` | 觸發一次性效果後從列表移除 |

`move_piece()` 修改：吃子後依序執行 SP 獎勵 → 士氣扣除 → 天生效果 → 一次性效果，並處理 `pending_extra_move`。

### `src/core/xiangqi/xiangqi_rule_verifier.gd`
在 `is_valid_move()` 中新增三層天生效果攔截：
1. **`CannotEatEffect`**：在目標格判斷前擋下禁吃目標
2. **`DualMovementEffect`**：若原本走法無效，追加第二種棋子走法判斷
3. **`knight_leap_available`**：若標記為 true，追加超距跳躍合法性判斷

新增輔助靜態函式：
- `_check_by_piece_type()`：依棋子種類分派走法驗證
- `_check_knight_leap()`：超距跳躍驗證

---

## 召喚規則說明

| 規則 | 說明 |
|------|------|
| SP 消耗 | 召喚時扣除 `card.sp_cost`，SP 不足則無法召喚 |
| 入場區限制 | 紅方限 `y=6~9`，黑方限 `y=0~3` |
| 格子佔用 | 目標格有任何棋子則無法召喚 |
| 士氣扣除時機 | **召喚當下不扣除士氣**；棋子被吃子時，由擁有方扣除對應士氣值 |
