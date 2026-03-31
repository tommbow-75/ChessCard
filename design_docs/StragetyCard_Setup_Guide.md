# 謀略卡 (Strategy Card) 建立指南

本指南說明如何透過 Godot Inspector 建立與配置全新的謀略卡資源（`StrategyCardData`）。

## 1. 建立資源文件
1. 在 Godot **FileSystem** 面板中，選擇資料夾（例如 `Resources/Cards/Strategy/`）。
2. 右鍵點擊並選擇 **Create New → Resource...**。
3. 在搜尋框輸入 `StrategyCardData` 並選取。
4. 將資源儲存為 `.tres` 檔案（例如 `shooting_SC.tres`）。

## 2. 基礎屬性配置 (CardData)
當您選中該 `.tres` 檔案後，在 **Inspector** 中會看到以下欄位：

*   **Id**: 唯一的內部識別碼 (例如 `SC_001`, `shooting_SC`)。
*   **Card Name**: 卡牌在遊戲中顯示的名稱 (例如 `能量射擊`)。
*   **Category**: 預設設為 `STRATEGY`。
*   **Sp Cost**: 發動此卡所需的 SP 點數 (例如 `2`)。
*   **Effect Description**: 在卡牌介面上顯示的效果描述文字。

## 3. 設定特殊效果 (Special Effects)
謀略卡的實際功能是由 `Special Effects` 陣列定義的：

1. 點擊 **Special Effects** 右側的 **Add Element**。
2. 點擊新產生的欄位 **[empty]**。
3. 選擇 **New [對應效果類別]** (例如 `New RemovePieceEffect`)。
   *   *註：所有效果腳本位於 `Scripts/Stragety/` 下。*

### 常見效果類別及其參數：

| 效果類別 | 功能說明 | 關鍵 Inspector 參數 |
| :--- | :--- | :--- |
| **HealMoraleEffect** | 回復我方士氣 | `Heal Amount` (數值) |
| **DiscountMoraleEffect** | 扣除敵方士氣 | `Damage Amount` (數值) |
| **StunEffect** | 暈眩目標棋子 | (無額外參數) |
| **RemovePieceEffect** | 移除/摧毀棋子 | `Target Type` (決定範圍或單體) |
| **DrawCardEffect** | 抽牌 | `Draw Amount` (張數) |
| **TurnIntoEffect** | 變換子力/策反 | `Behavior` (下拉選單選擇變換規則) |
| **MoveRightnowEffect** | 立即移動己方棋子 | (通常用於「調度」) |

## 4. 目標選取類型 (Target Type) 設定
每個效果（Effect）中都有 `Target Type` 選項，決定發動卡牌時 UI 應如何引導玩家：

*   `NONE`: 不需要點選目標，發動即生效（例如：抽牌、補士氣）。
*   `SINGLE_ENEMY_NON_GENERAL`: 玩家必須點選一個**敵方**且**非將帥**的棋子才可以發動。
*   `AREA_3X3_ANY`: 點選地圖上任何一格，影響該點周圍 3x3 範圍（例如：巨石）。
*   `ANY_NON_GENERAL`: 點選任何一個非將帥棋子（不分敵我）。
*   `ANY_SOLDIER`: 點選任何一個兵或卒。

## 5. 實戰範例：建立「策反 (Rebel)」
1. 建立 `StrategyCardData` 資源。
2. **Card Name**: `策反`
3. **SP Cost**: `5`
4. **Special Effects**:
    *   新增 `TurnIntoEffect`。
    *   將 `Behavior` 設為 `ENEMY_NON_GENERAL_TO_ALLY`。
    *   將 `Target Type` 設為 `SINGLE_ENEMY_NON_GENERAL`。

---
> [!TIP]
> 如果想要設計多重效果（例如「抽一張牌並回復 3 點士氣」），只需在 `Special Effects` 陣列中同時加入 `DrawCardEffect` 與 `HealMoraleEffect` 即可！
