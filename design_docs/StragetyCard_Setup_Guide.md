# 謀略卡 (Strategy Card) 建立指南

本指南說明如何透過 Godot Inspector 建立與配置全新的謀略卡資源（`StrategyCardData`），並結合**六層式效果積木架構**。

## 1. 建立資源文件
1. 在 Godot **FileSystem** 面板中，選擇資料夾（例如 `Resources/Cards/Strategy/`）。
2. 右鍵點擊並選擇 **Create New → Resource...**。
3. 在搜尋框輸入 `StrategyCardData` 並選取。
4. 將資源儲存為 `.tres` 檔案（例如 `shooting_SC.tres`）。

## 2. 基礎屬性配置 (CardData)
當您選中該 `.tres` 檔案後，在 **Inspector** 中會看到以下欄位：

*   **Id**: 唯一的內部識別碼 (例如 `SC_001`)。
*   **Card Name**: 卡牌顯示名稱 (例如 `能量射擊`)。
*   **Category**: 預設為 `STRATEGY`。
*   **Sp Cost**: 發動此卡所需的 SP 點數 (例如 `2`)。
*   **Effect Description**: 卡牌介面上顯示的效果描述文字。

## 3. 配置六層式效果積木 (Special Effects)
謀略卡的功能是透過 `Special Effects` 陣列中的 `StrategyEffectTiming` 資源來實踐。每個效果積木都遵循以下六層定義：

### Level 1: 觸發時機 (`StrategyEffectTiming`)
點擊 **Add Element** 並建立一個 `StrategyEffectTiming` 資源，設定其觸發模式：
- **IMMEDIATE**: 發動卡牌時立刻觸發（通常用於指定玩家的數值，如：抽牌）。
- **TARGETED**: 發動卡牌後，需先由玩家在棋盤上選取目標才觸發。

### Level 2: 目標類型 (`Target Type`)
決定玩家要點選什麼？
- **Player**: 指定玩家（通常搭配 IMMEDIATE，如回復士氣）。
- **Piece**: 指定棋盤上的棋子。
- **Cell**: 指定棋盤上的空格或座標點（如放置巨石）。

### Level 3: 適用方 (`Effect Target`)
決定效果對誰生效？
- **Self**: 僅對己方生效。
- **Enemy**: 僅對敵方生效。
- **Any**: 對雙方皆可生效。

### Level 4: 棋子過濾器 (`Target Piece Mask`)
如果目標是棋子，可複選要影響的兵種。若不勾選則代表全選（預設）。
- 勾選 `Soldier`, `Horse`... 等，可精確限制效果僅能施放於特定棋子。

### Level 5: 作用範圍 (`Target Mode`)
決定效果影響的範圍大小：
- **Single**: 僅影響點選的那一格。
- **Area 3x3**: 影響點選位置及周圍 1 格（共 9 格）。
- **None**: 無範圍（通常用於 Player 類型）。

### Level 6: 具體邏輯效果 (`Logic Effect`)
這是最終執行的功能，請在對應的欄位掛載具體的 `.gd` 腳本（例如 `RemovePieceEffect`, `HealMoraleEffect`）。

---

## 4. 實戰範例：建立「射日弓」
1. **Card Name**: `射日弓`
2. **Special Effects**: 新增一個 `StrategyEffectTiming`：
   - **Level 1**: `TARGETED`
   - **Level 2 (TargetType)**: `Piece`
   - **Level 3 (EffectTarget)**: `Enemy`
   - **Level 4 (PieceMask)**: 勾選除了 `General` 以外的所有棋子。
   - **Level 5 (TargetMode)**: `Single`
   - **Level 6 (LogicEffect)**: 掛載 `RemovePieceEffect` 並設定數值。

---
> [!TIP]
> 這種模組化設計讓您可以輕鬆創造複雜卡牌。例如要製作「全場震懾」，只需將 `Target Mode` 設為 `Area 3x3` 或擴充全場邏輯，並掛載 `StunEffect` 即可！
