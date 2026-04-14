# 謀略卡(StragetyCard)

describtion:
此md檔紀錄了謀略卡的設計概念與規則

## 一、謀略卡
用於發動一次性的戰術效果。
* `Name` (名稱)：卡牌的名稱。
* `Type` (種類)：謀略類。
* `Effect` (卡牌效果)：發動後產生的具體遊戲影響。
* `SP_Cost` (消耗謀略)：發動此卡牌需要消耗的 SP 點數。

## 二、通用規則
以下將常見的效果邏輯列出
1. `draw_card_effect.gd` : **抽**X張卡
2. `remove_piece_effect.gd` : **移除**對方X子,此效果無法獲得SP
3. `heal_morale_effect.gd` : **回復**X點士氣
4. `turn_into_effect.gd`: 將A子**變更**為B子
5. `move_rightnow_effect.gd`: **移動**己方A子
6. `stun_effect.gd`: **暈眩**對方A子，下一個回合不可移動
7. `discount_morale_effect.gd`: **扣除**X點士氣

## 三、

1. 能量射擊
* `Name` (名稱)：shooting_SC
* `Type` (種類)：謀略類。
* `Effect` (卡牌效果)：**移除**對方一子(除了General、Advisor、Elephant)，此效果無法獲得SP
* `SP_Cost` (消耗謀略)：2

2. 上馬
* `Name` (名稱)：horse_SC
* `Type` (種類)：謀略類。
* `Effect` (卡牌效果)：將1非將帥的棋子**變更**為horse
* `SP_Cost` (消耗謀略)：2

3. 鼓舞
* `Name` (名稱)：morale_boost_SC
* `Type` (種類)：謀略類。
* `Effect` (卡牌效果)：**回復**3點士氣
* `SP_Cost` (消耗謀略)：1

4. 思考
* `Name` (名稱)：thinking_SC
* `Type` (種類)：謀略類。
* `Effect` (卡牌效果)：**抽**2張卡
* `SP_Cost` (消耗謀略)：1

5. 巨石
* `Name` (名稱)：boulder_SC
* `Type` (種類)：謀略類。
* `Effect` (卡牌效果)：選擇一點，將其9宮格範圍內所有旗子全部**移除**(無論敵我，但無法移除將帥)
* `SP_Cost` (消耗謀略)：6

6. 機械化
* `Name` (名稱)：mechanized_infantry_SC
* `Type` (種類)：謀略類。
* `Effect` (卡牌效果)：將1soldier**變更**為chariot
* `SP_Cost` (消耗謀略)：3

7. 威脅
* `Name` (名稱)：threaten_SC
* `Type` (種類)：謀略類。
* `Effect` (卡牌效果)：**扣除**敵方5點士氣
* `SP_Cost` (消耗謀略)：3

8. 策反
* `Name` (名稱)：rebel_SC
* `Type` (種類)：謀略類。
* `Effect` (卡牌效果)：將1敵方棋子**變更**為己方basic棋子(除了General)
* `SP_Cost` (消耗謀略)：5

9. 調度
* `Name` (名稱)：dispatch_SC
* `Type` (種類)：謀略類。
* `Effect` (卡牌效果)：**移動**所有己方soldier一格(無論前後左右)(不可吃子)
* `SP_Cost` (消耗謀略)：5

10. 暈眩
* `Name` (名稱)：stun_SC
* `Type` (種類)：謀略類。
* `Effect` (卡牌效果)：**暈眩**敵方一子(除了General)
* `SP_Cost` (消耗謀略)：3
