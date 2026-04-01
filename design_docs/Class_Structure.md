# 專案類別統整對照表 (Class Structure)

本專案採用四層核心架構：基礎資料、遊戲邏輯、效果系統與使用者介面。

## 1. 基礎資料與卡牌 (Data & Cards)

| Class 名稱 | 檔案位置 | 功能說明 |
| :--- | :--- | :--- |
| **CardData** | Scripts/card_data.gd | 基礎卡牌資料結構，定義卡牌共通屬性如 ID、名稱、類別 (召喚/謀略)、消耗 SP 等。 |
| **SummonCardData** | Scripts/summon_card_data.gd | 繼承自 `CardData`，專用於召喚棋子的卡牌。包含召喚兵種、附帶的士氣值，以及可掛載的特殊效果列表。 |
| **StrategyCardData** | Scripts/strategy_card_data.gd | 繼承自 `CardData`，專用於謀略卡。包含專屬的謀略效果列表 (StragetyEffect)。 |
| **ChessPieceData** | Scripts/chess_piece_data.gd | 中國象棋棋子的靜態資料結構，定義棋子的基礎屬性與對應的預設士氣值 (Morale)。 |

## 2. 遊戲核心邏輯 (Core Logic)

| Class 名稱 | 檔案位置 | 功能說明 |
| :--- | :--- | :--- |
| **XiangqiGame** | src/core/xiangqi/xiangqi_game.gd | 遊戲主邏輯控制器。負責管理回合、士氣、SP、處理走子與吃子的結算、召喚邏輯及謀略卡發動邏輯。 |
| **XiangqiBoard** | src/core/xiangqi/xiangqi_board.gd | 負責管理棋盤狀態的資料結構 (Dictionary mapping)，提供查詢、新增、移除特定座標上棋子的功能。 |
| **XiangqiPiece** | src/core/xiangqi/xiangqi_piece.gd | 代表單一棋子的資料狀態，記錄其陣營、種類、擁有的卡牌效果，以及是否處於負面狀態 (如暈眩)。 |
| **XiangqiRuleVerifier** | src/core/xiangqi/xiangqi_rule_verifier.gd | 靜態的走法驗證工具，負責判斷任何起點到終點的移動是否合法，並包含「天生效果攔截」與「飛將」判斷。 |
| **GridSystem** | Scripts/grid_system.gd | 網格座標系統與碰撞檢測基礎，處理 9x10 網格座標與畫素座標的雙向轉換。 |

## 3. 卡牌效果積木 (Effects)

### 核心基座
| Class 名稱 | 基礎類別 | 功能說明 |
| :--- | :--- | :--- |
| **CardEffectTiming** | Resource | 召喚卡效果的基底，定義效果觸發時機 (ONCE 一次性, BORN 天生, SUMMON 召喚)。 |
| **StragetyEffect** | Resource | 謀略卡效果的基底，定義「目標選取類型」(TargetType) 與執行邏輯。 |

### 效果實作
- **召喚卡專用效果** (繼承自 `CardEffectTiming`):
    - `CannotEatEffect` (禁吃特定棋子)
    - `DualMovementEffect` (雙重走法)
    - `ExtraMoveEffect` (吃子後再動)
    - `HealMoraleEffect` (召喚回士氣)
    - `KnightLeapEffect` (騎士躍遷)
    - `RestoreOnCaptureEffect` (吃子回士氣)
- **謀略卡專用效果** (繼承自 `StragetyEffect`):
    - `DiscountMoraleEffect` (扣除士氣)
    - `DrawCardEffect` (抽卡)
    - `HealMoraleEffect` (回復士氣)
    - `MoveRightnowEffect` (調度兵卒)
    - `RemovePieceEffect` (直接移除棋子)
    - `StunEffect` (暈眩目標)
    - `TurnIntoEffect` (改變兵種或策反)

## 4. 使用者介面 (UI)

| Class 名稱 | 檔案位置 | 功能說明 |
| :--- | :--- | :--- |
| **XiangqiGameUI** | src/ui/XiangqiGameUI.gd | 遊戲畫面主控制器，連接 `XiangqiGame`，處理滑鼠點擊輸入、選取狀態、UI 刷新與謀略卡的目標選取互動。 |
| **BoardRenderer** | src/ui/BoardRenderer.gd | 負責繪製底層的 9x10 棋盤線條、楚河漢界文字、座標軸以及「合法走步」的藍點提示。 |
| **PieceView** | src/ui/PieceView.gd | 單一棋子的視覺渲染元件，負責畫出圓形底色與棋子中文字，並根據是否暈眩改變顏色。 |
| **CardView** | src/ui/CardView.gd | 單張卡牌的視覺渲染元件，根據傳入的卡牌資料繪製卡面 (SP、名稱、兵種、效果文字)。 |
| **CardHandPanel** | src/ui/CardHandPanel.gd | 管理底部手牌列的容器，負責將 `CardView` 以水平排列方式顯示。 |
| **HintOverlay** | src/ui/HintOverlay.gd | 提示疊層，負責繪製位於棋子上方的視覺提示 (如：吃子紅點、謀略卡目標反向遮罩暗化、預覽橘點)。 |
| **GameHUD** | src/ui/GameHUD.gd | 頂部與側邊狀態列，顯示當前回合、雙方 SP 與士氣數值、警告文字以及重新開始按鈕。 |
