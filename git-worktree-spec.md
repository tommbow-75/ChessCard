# Feature Spec: GridSystem

> 此文件由 Git Worktree Design Skill 自動產生，供 AI Agent 作為開發指引。

## 分支資訊

| 項目 | 值 |
|------|-----|
| 分支名稱 | `feature/GridSystem` |
| 基於分支 | `main` |
| Worktree 路徑 | `E:\ChessCard-GridSystem` |
| 建立時間 | `2026-03-18` |

## 目標

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
