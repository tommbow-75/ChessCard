---
name: core-engine
description: 當使用者要求「修改核心狀態機」、「調整棋盤邏輯」、「重構引擎架構」或「處理訊號(Signal)」時觸發。
version: 0.1.0
---

# ChessCard 核心引擎開發 SOP

這是一項高風險操作，修改核心引擎前，嚴格遵循以下步驟執行：

## 1. 資訊邊界對齊 (漸進式揭露)
執行任何程式碼修改前，讀取並確認以下架構文件：
* 讀取 `.agent/references/GameProcessStructure.md`，確認當前修改會影響遊戲生命週期的哪個階段。
* 讀取 `.agent/references/Class_Structure.md`，確認目標類別 (Class) 與各 Manager 之間的依賴關係。
* 若涉及棋盤座標或尋路變動，核對 `.agent/references/Board_Structure.md` 確認座標算法。

## 2. 狀態機 (State Machine) 約束
* 實作狀態切換時，檢查所有進入 (Enter) 與退出 (Exit) 的邏輯。
* 確保狀態轉換完整，不可遺漏任何 State 轉換路徑。

## 3. 訊號 (Signal) 依賴檢查
* 修改任何核心方法或銷毀物件前，列出所有受影響的 Signal (訊號) 訂閱者。
* 確認 Signal 是否有正確連線 (connect) 或斷開 (disconnect)，防止 Memory Leak 或引發意外副作用。

## 4. 交付與驗收準備
* 實作完成後，不需自行執行測試。將修改結果與程式碼路徑標記完成，交由 `engine-reviewer` 進行架構審查與核心測試。
* 若收到 `engine-reviewer` 退回的錯誤日誌與修復建議，讀取建議內容，對照架構文件並修正代碼，進入下一輪開發循環。