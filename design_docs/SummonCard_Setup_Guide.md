# 召喚卡 (Summon Card) 建立指南

本指南引導您如何在 Godot 編輯器中實體化全新的召喚卡牌（`SummonCardData`），並掛載具備**六層式模組化效果**的特殊能力。

## 1. 創造一張新卡牌
1. 在 Godot **FileSystem** 面板中，選擇資料夾（例如 `Resources/Cards/Summon/`）。
2. 右鍵點擊並選擇 **Create New → Resource...**。
3. 在搜尋框中輸入 **`SummonCardData`** 並雙擊選擇。
4. 將檔案命名並存檔，副檔名為 `.tres`（例如 `doctor_elephant.tres`）。

## 2. 基礎屬性配置 (SummonCardData)
當您選取 `.tres` 檔案後，在 **Inspector** 中可調整以下設定：

*   **Id**: 內部識別碼 (例如 `SM_001`, `doctor_elephant`)。
*   **Card Name**: 卡牌顯示名稱 (例如 `醫生象`)。
*   **Sp Cost**: 召喚此卡牌所需的 SP 點數。
*   **Summon Type**: 召喚出的棋子種類（依象棋規則定義）。
*   **Summon Morale Value**: 這張卡牌附帶的預設士氣值（Morale）。
*   **Effect Description**: 卡片顯示在 UI 上的效果文字說明。

## 3. 設定召喚卡專用效果 (Special Effects)
召喚卡的特殊能力是透過 `Special Effects` 陣列中的 `SummonEffectTiming` 資源來定義。每個效果都整合了 **三個觸發階段** 與 **六層式架構**。

### Level 1: 觸發階段 (`SummonEffectTiming.Timing`)
這是召喚卡最重要的特性，決定效果在何時生效：
- **SUMMON**: 召喚出棋子的那一瞬間觸發效果。
- **BORN**: 棋子存在於場上時，獲得一個**持續性**的能力（通常搭配被動效果）。
- **ONCE**: 棋子存在場上且可手動發動一次的能力。

### Level 2~6: 目標與邏輯定義
一旦進入觸發階段，系統會依序檢查下列層級：
- **Level 2 (Target Type)**: 指定玩家、棋子或棋盤格。
- **Level 3 (Effect Target)**: 指定己方、敵方或雙方。
- **Level 4 (Piece Mask)**: 過濾特定兵種。
- **Level 5 (Target Mode)**: 單體或範圍 (Area 3x3)。
- **Level 6 (Logic Effect)**: 掛載具體的效果邏輯（例如 `CannotEatEffect`, `HealMoraleEffect`）。

---

## 4. 實戰範例：建立「精銳士」
1. **Summon Type**: `ADVISOR` (士/仕)
2. **Special Effects**: 新增一個 `SummonEffectTiming`：
   - **Timing**: `BORN` (代表天生技)
   - **Level 2 (TargetType)**: `Piece`
   - **Level 3 (EffectTarget)**: `Self`
   - **Level 4 (PieceMask)**: 勾選 `General` (將/帥)
   - **Level 5 (TargetMode)**: `Area 3x3`
   - **Level 6 (LogicEffect)**: 掛載 `ProtectMoraleEffect`。
   - **說明**: 只要精銳士在場，周圍 3x3 的將帥受到保護。

---

## 5. UI 自動標籤功能 (CardView Layout)
*   **Summon 標籤**：所有 SummonCard 預設皆會顯示此黑框標籤。
*   **特殊走法標籤**：系統若偵測到 `Special Effects` 中包含與「移動 (Movement)」或「躍遷 (Leap)」相關的邏輯效果（例如 `KnightLeapEffect`），UI 會自動在卡面左上角浮現藍框標籤，提示玩家此棋子具備非典型的走法。

---
> [!IMPORTANT]
> 每次修改完 `.tres` 資源，記得按下 **`Ctrl + S`** 儲存檔案，遊戲邏輯才會即時更新！
