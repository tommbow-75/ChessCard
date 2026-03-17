# Feature Spec: XiangBasicRule
# Feature Spec: ChessCardDemo
# Feature Spec: GridSystem

> 此文件由 Git Worktree Design Skill 自動產生，供 AI Agent 作為開發指引。

## 分支資訊

| 項目 | 值 |
|------|-----|
| 分支名稱 | `feature/XiangBasicRule` |
| 基於分支 | `main` |
| Worktree 路徑 | `E:\ChessCard-XiangBasicRule` |
| 分支名稱 | `feature/ChessCardDemo` |
| 基於分支 | `main` |
| Worktree 路徑 | `E:\ChessCard-ChessCardDemo` |
| 分支名稱 | `feature/GridSystem` |
| 基於分支 | `main` |
| Worktree 路徑 | `E:\ChessCard-GridSystem` |
| 建立時間 | `2026-03-18` |

## 目標

**先專注實作出能夠運行「標準中國象棋基本規則」的 Demo 核心模組**。

## 實作範圍

- [x] 實作棋子移動驗證介面 (判斷給定起點與終點是否為合法走法)
- [x] 實作車的走子判斷 (不可越子)
- [x] 實作馬的走子判斷 (走日，並加入拐馬腳判斷)
- [x] 實作象的走子判斷 (走田，並加入塞象眼判斷，不可過河)
- [x] 實作士的走子判斷 (九宮格內斜走)
- [x] 實作將/帥的走子判斷 (九宮格內直走，加入王見王判斷)
- [x] 實作炮的走子判斷 (隔子打)
- [x] 實作兵/卒的走子判斷 (過河前只能向前，過河後可左右)
- [x] 實作吃子原則：判斷目標格是否為敵方棋子
- [x] 實作基本勝負判斷：帥/將被吃掉作為勝負判斷點

## 驗收標準

- 能讓兩方交替回合進行移動。
- 所有的棋子移動皆須通過基本規則合法性驗證。

## 技術約束

- 先以純邏輯實作為主。

## 跨分支備註

- 需依賴 `feature/GridSystem` 的座標系統與界線判斷。
- 需依賴 `feature/ChessCardDemo` 裡的棋子資料定義。
- 士氣與卡牌 SP 等機制會於後續階段整合。
基於 Godot 框架，定義並實作基礎的象棋（ChessDemo）與卡牌（CardDemo）資料結構與物件。

## 實作範圍

- [x] 定義象棋物件 (ChessDemo) 的基本資料結構 (包含 ID, 種類, 陣營)
- [x] 將士氣值屬性加入象棋物件 (帥將30、其餘大子10、兵卒5)
- [x] 定義卡牌物件 (CardDemo) 的基本資料結構，區分「召喚卡」與「謀略卡」
- [x] 實作卡牌的必要屬性：效果、花費 SP、(召喚卡專屬) 士氣值與兵種對應

## 驗收標準

- 可於 Godot 中成功建立並存取這些物件或 Resource。

## 技術約束

- 需使用 Godot 支援的類別 (例如 Node 或 Resource) 來實作資料結構。
- 程式碼需能相容後續 `XiangBasicRule` 與 `GridSystem` 呼叫。

## 跨分支備註

- 本分支可獨立開發，無相依。這些資料結構後續會被 `XiangBasicRule` 大量使用。
實作 Godot 遊戲中的中國象棋網格座標轉換系統與碰撞/邊界檢測基礎。

## 實作範圍

- [x] 定義標準 9x10 (或 10x9) 象棋盤格的二維邏輯陣列或 Vector2 座標系統
- [x] 實作視窗像素座標 (Pixel Position) 與網格座標 (Grid Position) 的雙向轉換函數
- [x] 實作邊界檢驗函數 (確保座標位於 9x10 範圍內)
- [x] 實作網格內容檢索函數 (設定/獲取特定座標上的棋子或空狀態)

## 驗收標準

- 提供輔助函數檢驗座標是否在合法的棋盤邊界內。
- 能正確返回指定網格上的內容。

## 技術約束

- 需要與 Godot 2D 座標系統相容 (如 Vector2 的使用)。

## 跨分支備註

- 本分支可獨立開發，無相依。將作為走子驗證 (`XiangBasicRule`) 的基底。
