# 功能規格書：XiangqiGameUI_v1

> 此文件由 AI Agent 自動產生，供開發與驗收作為基準參考指引。

## 分支資訊

| 項目 | 值 |
|------|-----|
| 分支名稱 | `basic_demo`（未另開 worktree） |
| 基於分支 | `main`（整合 ChessUI_v1、GridUI_v1、XiangBasicRule） |
| 建立時間 | `2026-03-20T11:24:00+08:00` |

## 目標

整合已有的三個功能模組（棋子視覺 ChessUI_v1、棋盤渲染 GridUI_v1、規則驗證 XiangBasicRule），建立**可雙人互動遊玩**的標準象棋場景，以滑鼠點選方式進行完整對弈。

## 實作範圍

- [x] 建立 `src/ui/BoardRenderer.gd`：繼承 GridUI_v1 棋盤渲染邏輯，新增選中高亮（橘色外框）、合法走步藍點提示、桁架形十字位置標示（兵/卒/炮/包起始格）
- [x] 建立 `src/ui/PieceView.gd`：基於 ChessUI_v1 棋子概念，以 `_draw()` 繪製圓形底色 + 漢字，置中對齊修正（使用 `get_ascent` / `get_descent`），紅黑雙色區分，修正馬車字元對調問題
- [x] 建立 `src/ui/XiangqiGameUI.gd`：主控制器，連接 `XiangqiGame` 核心邏輯，處理滑鼠點選、棋子選取、走子驗證、回合切換、棋盤重建
- [x] 建立 `src/ui/GameHUD.gd`：CanvasLayer 介面，顯示目前回合（紅/黑）、勝利訊息、重新開始按鈕
- [x] 建立 `src/ui/HintOverlay.gd`：吃子紅點疊層，獨立節點排於 `PiecesLayer` 之後，確保紅點繪製在棋子上方
- [x] 建立 `Scenes/XiangqiGameScene.tscn`：組合以上所有節點，場景結構如下：
  ```
  Node2D [XiangqiGameUI]
  ├── BoardRenderer   ← 棋盤 + 藍點（空格提示）
  ├── PiecesLayer     ← 所有棋子視覺節點
  ├── HintOverlay     ← 吃子紅點（棋子上方）
  └── HUD [CanvasLayer]
      └── Panel / VBox
          ├── TurnLabel
          ├── StatusLabel
          └── RestartButton
  ```
- [x] 修改 `project.godot`：設定 `run/main_scene` 指向 `XiangqiGameScene.tscn`

## 驗收標準

- [x] 執行主場景後，棋盤正確渲染（9×10 格、楚河漢界斷線、九宮格斜線、兵卒炮包位置的括弧標示）
- [x] 點選己方棋子，顯示橘色選取高亮與合法走步藍點提示
- [x] 點選合法空格，棋子移動並切換回合
- [x] 點選可吃之敵方棋子，顯示紅點提示（疊在棋子上方）；點選後執行吃子
- [x] 吃掉對方「將/帥」，顯示勝利訊息
- [x] 點選「重新開始」按鈕，棋盤與狀態完整重置

## 技術約束

- 使用 GDScript + Godot 4.6
- 繪圖全以 `CanvasItem._draw()` 實作，不依賴外部圖片素材
- 核心規則驗證完全委派給現有的 `XiangqiRuleVerifier`（static func）
- 渲染層級：BoardRenderer（底） → PiecesLayer → HintOverlay → HUD（頂）

## 已知設計決策

| 決策 | 說明 |
|------|------|
| 馬(index 3) / 車(index 4) | 配合 `XiangqiPiece.PieceType` enum 順序排列 |
| HintOverlay 獨立節點 | 解決吃子紅點被 PiecesLayer 覆蓋的 z-order 問題 |
| 括弧形位置標示 | 忠實還原真實象棋盤樣式，邊界格自動省略對應側 |

## 跨模組依賴

| 依賴模組 | 用途 |
|----------|------|
| `XiangqiGame` (src/core/xiangqi) | 遊戲狀態管理、走子執行、勝負判斷 |
| `XiangqiBoard` (src/core/xiangqi) | 棋盤資料查詢 |
| `XiangqiRuleVerifier` (src/core/xiangqi) | 合法走步驗證（含飛將規則） |
| `XiangqiPiece` (src/core/xiangqi) | 棋子 Side / PieceType 定義 |
