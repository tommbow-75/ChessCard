# SummonCardData 卡牌設定指南

這份文件將引導你如何在 Godot 編輯器中，透過視覺化介面直接創造出各式各樣的召喚卡牌，完全不需要寫任何一行程式碼。

## 1. 創造一張新卡牌

所有的卡牌都繼承自 `SummonCardData` 這個自定義資源（Resource）腳本：

1. 在 Godot 左下方的 **FileSystem** 面板中，找一個適合存放卡牌的資料夾（例如 `res://Resources/Cards/`），點擊右鍵。
2. 選擇 **Create New** -> **Resource...**。
3. 在彈出的搜尋視窗中，輸入 **`SummonCardData`** 並雙擊選擇。
4. 將檔案命名並存檔，副檔名為 `.tres`（例如 `doctor_elephant.tres`）。

---

## 2. 卡牌欄位解說與 UI 對應

雙擊剛剛建立的 `.tres` 檔案，在右側的 **Inspector** 面板中，你可以自由填寫以下欄位，這些欄位會**直接對應到遊戲內的卡牌視覺 (`CardView`)**：

| 欄位名稱 | 功能說明 | UI 渲染位置 |
| :--- | :--- | :--- |
| **Id** | 程式內部用以辨識卡牌的獨一無二字串（如 `doctor_elephant`）。 | 不會顯示在畫面上 |
| **Card Name** | 卡牌的顯示名稱（如 `醫生象`）。 | 頂欄（紅外框）正中央 |
| **Sp Cost** | 召喚此卡牌所需扣除的 SP 點數。 | 頂欄右側的黃色圓圈內 |
| **Summon Type** | 召喚出的棋子種類（0=帥, 1=士, 2=象... 到 6=兵）。 | 決定頂欄左側紅色小圓字、以及**大圖預覽區**的文字與深淺色。 |
| **Summon Morale Value** | 這張卡牌附加的士氣對應值。 | 渲染在最底下的灰底黑字列：`Morale: XX` |
| **Effect Description** | **（重要）** 這是給玩家看的文字說明，例如：「天生：只能在指定範圍內移動，召喚時恢復 5 點士氣」。支援自動換行。 | 卡片下半部白底黑字的 `Effect:` 區塊 |

### 💡 附註：Inspector 底下的其他區塊是什麼？
在 Inspector 面板最下方，您可能還會看到下拉選單包含 **`Resource`** 與 **`RefCounted`** 區塊，這是 Godot 引擎內建的底層分類：

- **Resource 區塊**：
  - 代表這是 Godot 的通用資源檔案。
  - 裡面通常只有 `Local To Scene`（是否場景獨立）與 `Path`（檔案路徑）。由於卡牌是一種「共用的全域設定檔」，我們通常**不需要去更動這些數值**（保持 `Local To Scene` 為 **Off** 即可）。
- **RefCounted 區塊**：
  - 這是 Godot 的記憶體管理機制（參照計數）。
  - 代表只要遊戲系統還有在使用這張卡牌，它就不會被從記憶體中清掉。這邊只是底層顯示，**完全不需要設定**。

### 💡 附註：設定好之後要怎麼存檔？ metadata 又是什麼？
- **如何存檔**：
  只要在 Inspector 調整完這張卡的數值，記得按下 **`Ctrl + S`**（或是回到 FileSystem 面板在該 `.tres` 檔案點右鍵選 Save），把這張卡牌的修改儲存起來就可以了！
- **Metadata（元資料）**：
  這是 Godot 提供讓開發者「臨時外掛變數」的功能（類似一個可以隨意塞 `Key: Value` 的隱形背包）。不過因為我們已經在腳本裡把所有需要的變數（SP、士氣、名稱等）都**明確定義好**了，所以您可以直接忽略這個按鈕，**不需要新增任何 Metadata**！

---

## 3. 掛載遊戲邏輯 (Special Effects)

你前面填寫的 **Effect Description** 只是「文字說明」，若要讓卡牌在遊戲裡真的擁有特殊效果，必須在 **Special Effects** 陣列中掛載效果積木：

1. 點擊 **Special Effects** 旁邊的箭頭展開陣列。
2. 點擊 **Add Element**。
3. 在出現的 `[empty]` 框格點擊，選擇 **New Resource** 或 **Quick Load** 來載入你實作好的積木（如 `KnightLeapEffect.new()` 或是拖曳 `knight_leap_effect.gd` 產生的子腳本）。
4. 各積木可能會在 Inspector 中有自己的參數（例如 `RestoreOnCaptureEffect` 可以設定要回多少血），請在此處一併調整。

> **💡 UI 小彩蛋：**
> 卡片預設只有黑框的 `summon` 標籤。但如果系統在你的 `Special Effects` 陣列中偵測到任何名稱含有 `"movement"` 或 `"leap"` 的效果積木，畫面上會**自動**在 `summon` 旁邊浮現一個藍框藍字的 **「特殊走法」** 標籤！

---

## 4. 如何在遊戲中測試？

當前開發階段，如果你想馬上看到做好的卡牌長什麼樣子：
1. 打開 `src/ui/XiangqiGameUI.gd`。
2. 找到 `_setup_demo_hand()` 這個函式。
3. 將裡面寫死的 `_make_card.call(...)` 替換成直接載入你剛剛做好的 resource：
   ```gdscript
   var my_card = preload("res://Resources/Cards/doctor_elephant.tres")
   cards.append(my_card)
   ```
4. F5 執行遊戲即可看到完美的卡牌渲染！
