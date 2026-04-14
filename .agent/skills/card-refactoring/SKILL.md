---
name: card-refactoring
description: 當使用者要求「修改卡牌邏輯」、「新增卡牌效果」時觸發。
version: 0.1.0
---

# ChessCard 卡牌效果開發 SOP

這是一項高風險操作，修改核心引擎前，嚴格遵循以下步驟執行：

## 1. 資訊邊界對齊 (漸進式揭露)
執行任何程式碼修改前，讀取並確認以下架構文件：
* 讀取 `.agent/references/GameProcessStructure.md`，確認當前修改會影響遊戲生命週期的哪個階段。
* 讀取 `.agent/references/Class_Structure.md`，確認目標類別 (Class) 與各 Manager 之間的依賴關係。
* 若涉及棋盤座標或尋路變動，核對 `.agent/references/Board_Structure.md` 確認座標算法。

## 2. 卡牌種類製作
* 先確認使用者想製作召喚卡/謀略卡
* 製作召喚卡，讀取 `reference/SummonCardRule.md`，確認使用者提供規格是否完整，若不完整，引導使用者補齊規格
* 製作謀略卡，讀取 `reference/StrategyCardRule.md`，確認使用者提供規格是否完整，若不完整，引導使用者補齊規格

## 3. 訊號 (Signal) 依賴檢查
* 製作召喚卡，確認 `CardEffectTiming` 是否有相同邏輯，若有，回報使用者並提出優化方案，若無，則製作
* 製作謀略卡，確認 `StragetyEffect` 是否有相同邏輯，若有，回報使用者並提出優化方案，若無，則製作

## 4. 交付與驗收準備
* 實作完成後，不需自行執行測試。將修改結果與程式碼路徑標記完成，交由 `rule-reviewer` 進行架構審查與核心測試。
* 若收到 `rule-reviewer` 退回的錯誤日誌與修復建議，讀取建議內容，對照架構文件並修正代碼，進入下一輪開發循環。