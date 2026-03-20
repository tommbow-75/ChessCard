# 功能規格書：ChessUI_v1

> 此文件由 AI Agent 自動產生，供開發與驗收作為基準參考指引。

## 分支資訊

| 項目 | 值 |
|------|-----|
| 分支名稱 | `feature/ChessUI_v1` |
| 基於分支 | `main` |
| Worktree 路徑 | `e:\ChessUI_v1_demo` |

## 目標

**專注實作中國象棋基本棋子的可視化基礎介面 Demo (v1)**。
透過 Godot 內建 UI 控制節點（ColorRect、Label），快速打樣出紅黑雙方 14 種棋子的外觀展示，作為後續複雜 UI 或 Sprite 替換的基礎墊腳石。

## 實作範圍

- [x] 建立並設定基礎展示場景 (`PieceDemo.tscn`) 與腳本 (`PieceDemo.gd`)
- [x] 定義 14 種象棋字元陣列存放雙方棋子名稱 (帥, 仕, 像, 俥, 傌, 炮, 兵, 將, 士, 象, 車, 馬, 包, 卒)
- [x] 動態生成對應數量的 `ColorRect` 作為棋子底框
- [x] 使用 `Label` 搭配字體設定顯示棋子名稱，並依照陣營套用不同顏色 (紅 / 黑)
- [x] 完成棋子的行列陣列排版演算法顯示

## 驗收標準

- 執行 `PieceDemo.tscn` 時，能正常渲染出 14 顆帶有紅色與黑色字體的棋子。
- 文本能正確置中對齊，無任何 GDScript 報錯。

## 技術約束

- 先以 Godot Control 節點 (`ColorRect`, `Label`) 的純 UI 實作為主，尚未套用複雜的 Texture 或 Shader。
- 需相容 Godot 4 基礎文字調整設定。

## 跨分支備註

- 本分支著重於 UI 預想圖與呈現，無直接相依。
- 未來可以將此 UI 顯示機制與 `feature/GridSystem` 或 `feature/XiangBasicRule` 的內部資料結構 (如 `ChessDemo`) 進行綁定，進而變成可互動實體。
