# Feature Spec: GridUI_v1_demo

> 此文件由 Git Worktree Design Skill 自動產生，供 AI Agent 作為開發指引。

## 分支資訊

| 項目 | 值 |
|------|-----|
| 分支名稱 | `feature/GridUI_v1_demo` |
| 基於分支 | `main` |
| Worktree 路徑 | `e:\GridUI_v1_demo` |
| 建立時間 | `2026-03-18T11:02:42+08:00` |

## 目標

實作一個中國象棋的網格 UI 展示 (Grid UI Demo)，包含底層的網格座標轉換系統 (`GridSystem`)、畫面上棋盤的渲染 (`GridRenderer`)，以及基礎的資料結構定義（包含卡牌與棋子資料）。此網格需要精確支援標準的 9x10 象棋盤結構，包括楚河漢界及九宮格斜線。

## 實作範圍

- [ ] 實作 `GridSystem` (網格座標系統與邏輯): 處理 9x10 座標、畫素與網格轉換 (`grid_to_pixel`, `pixel_to_grid`) 以及基本的棋子狀態記錄。
- [ ] 實作 `GridRenderer` (棋盤渲染): 使用 `_draw()` 繪製 9x10 網格，包含邊界、楚河漢界中空區、上下九宮格的交叉斜線。
- [ ] 實作資料結構定義: 完成 `card_data.gd`, `chess_piece_data.gd`, `summon_card_data.gd`, `strategy_card_data.gd` 等基礎資料定義。
- [ ] 建立 `GridDemo.tscn` 測試場景: 組合 GridSystem 與 GridRenderer，確保可以在獨立的展示場景中預覽成果。

## 驗收標準

- [ ] 網格渲染正確：能夠以正確的比例畫出 9x10 的象棋棋盤，包含楚河漢界與九宮格斜線。
- [ ] 座標轉換邏輯正確：`pixel_to_grid` 和 `grid_to_pixel` 計算無誤，能夠正確映射畫素位置到對應的網格座標。
- [ ] 能在 Godot 中成功開啟並執行 `GridDemo.tscn` 場景，且沒有報錯。

## 技術約束

- 需使用 GDScript 撰寫邏輯。
- 繪圖需使用 CanvasItem (`_draw()`) 繪製基準線條，現階段不依賴外部圖片素材。
- 資料結構需相容 Godot 的系統 (如 `Resource` 或 `RefCounted`)。

## 跨分支備註

- 本分支僅負責 UI 渲染與基礎座標系統。實際的象棋規則驗證 (例如 `XiangqiBasicRule`) 在其他分支開發，未來再進行整合。
