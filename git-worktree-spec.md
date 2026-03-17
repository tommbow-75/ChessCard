# Feature Spec: ChessCardDemo

> 此文件由 Git Worktree Design Skill 自動產生，供 AI Agent 作為開發指引。

## 分支資訊

| 項目 | 值 |
|------|-----|
| 分支名稱 | `feature/ChessCardDemo` |
| 基於分支 | `main` |
| Worktree 路徑 | `E:\ChessCard-ChessCardDemo` |
| 建立時間 | `2026-03-18` |

## 目標

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
