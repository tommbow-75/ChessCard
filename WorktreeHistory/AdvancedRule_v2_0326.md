# AdvancedRule 實作變更紀錄 v2.0 (2026-03-26)

## 概述
本次依照 `StragetyCardRule.md` 實作了完整的**謀略卡 (Strategy Card)** 系統：
1. **謀略卡發動邏輯**：包含受限目標選取、SP 扣除、以及即時效果執行。
2. **目標選取 UI (Targeting System)**：具備非目標棋子暗化、合法目標 Highlight 與滑鼠 Hover 提示。
3. **負面狀態（暈眩）**：新增棋子暈眩屬性與每回合自動解暈機制。

---

## 新增檔案

### `Scripts/Stragety/`（謀略效果積木）
所有的謀略效果皆繼承自 `StragetyEffect`（位於 `Scripts/Stragety/stragety_effect.gd`）。

| 檔案 | 效果名稱 | 說明 | 備註 |
|------|----------|------|------|
| `draw_card_effect.gd` | 思考 | 抽卡 (目前僅印 Log，待牌庫系統實作) | |
| `remove_piece_effect.gd` | 能量射擊 / 巨石 | 移除敵方非將帥棋子 | 巨石支援 3x3 範圍預覽 |
| `heal_morale_effect.gd` | 鼓舞 | 回復發動方士氣 | 不需要目標 |
| `discount_morale_effect.gd` | 威脅 | 扣除敵方士氣 | 不需要目標 |
| `turn_into_effect.gd` | 上馬 / 機械化 / 策反 | 變更棋子種類或陣營 | |
| `move_rightnow_effect.gd` | 調度 | 使己方所有兵卒向前前進一步 | |
| `stun_effect.gd` | 暈眩 | 使敵方單一非將帥棋子轉為暈眩狀態 | 暈眩期間不可移動 |

---

## 修改檔案

### `src/core/xiangqi/xiangqi_piece.gd`
- 新增 `var is_stunned: bool = false`：暈眩標記。
- 新增 `var stun_duration: int = 0`：暈眩剩餘回合數（預設為 1，代表到下個己方回合開始時解除）。

### `src/core/xiangqi/xiangqi_game.gd`
- 新增 `play_strategy_card(card, target_pos)`：核心發動邏輯，負責 SP 檢查、目標合法性驗證與執行效果。
- 修改 `_start_new_turn(side)`：新增自動解暈邏輯，每當該陣營回合開始，`stun_duration` 遞減。
- 修改 `move_piece()`：新增攔截，若棋子處於 `is_stunned` 則禁止移動。

### `src/ui/XiangqiGameUI.gd`
- 新增「謀略選取模式」狀態機，處理點擊卡牌按鈕後的 UI 鎖定。
- **測試按鈕列**：於介面右側手寫建構 10 組 Debug 按鈕，方便直接測試各項法術。
- 整合 `HintOverlay` 通訊，傳遞當前合法目標與滑鼠 Hover 座標。

### `src/ui/HintOverlay.gd`
- 修改 `_draw()`：
  - **反向遮罩**：進入選取模式時，自動將全場「不可選取的棋子」暗化（繪製半透明黑圈）。
  - **多重 Hover**：支援同時繪製多個橘色淡點（供「巨石」3x3 範圍預覽使用）。

### `src/ui/PieceView.gd`
- 修改 `_draw()`：若棋子 `is_stunned`，會自動將棋子調製為暗灰色視覺效果。

---

## 修正 Bug 與優化
- **回合鎖定修正**：修正 `xiangqi_game.gd` 中重複切換 `current_turn` 導致紅方連續行動的烏龍。
- **強型別報錯**：解決 GDScript 4.x 中 `Array[Vector2i]` 無法直接用 `[]` 賦值的問題（改用 `.clear()`）。
- **座標範圍修正**：將卡牌效果中未定義的 `ROWS / COLS` 變數替換為常數 `10 / 9`。
- **介面反饋優化**：遮罩邏輯從「全格子」優化為「僅遮罩棋子」，空地不變暗，保持畫面清爽。
