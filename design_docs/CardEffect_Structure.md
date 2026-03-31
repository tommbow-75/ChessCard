# 卡牌效果gd檔案架構
此檔案重新設計了卡牌與棋子的效果觸發結構

## level 1. 效果基底
describe: 效果基底，區分成謀略卡&召喚卡；也決定出牌時的**效果觸發時機**，所有效果都繼承自此檔案

summon_effect_timing.gd: **召喚卡**基底，出牌時，分為3種觸發時機
 - SUMMON: 召喚時觸發
 - BORN: 棋子存在棋盤時，持續觸發
 - ONCE: 棋子存在棋盤時，能夠發動1次，用完即失效

strategy_effect_timing.gd: **謀略卡**基底，出牌時，分為2種觸發時機
 - IMMEDIATE: 立刻觸發(只能搭配target_type.player)
 - TARGETED: 選擇目標後，立刻觸發


## level 2. 適用範圍
describe: 出卡後，決定效果**指定目標類型**

target_type.gd: 決定效果指定目標類型
 - player : 指定玩家數值
 - piece : 指定棋子
 - cell : 指定棋盤


## level 3. 適用方
describe: 決定效果作用的**陣營**

effect_target.gd: 決定效果作用的陣營
 - self：己方
 - enemy：敵方
 - any：雙方


## level 4. 效果對象
describe: 決定效果作用的piece_type

target_piece_mask.gd: 可複選，用於過濾所有範圍內所有棋子，只留下符合條件的棋子
 - general
 - advisor
 - elephant
 - horse
 - chariot
 - cannon
 - soldier
 - none


## level 5. 效果作用範圍
target_mode.gd: 決定效果作用的範圍
 - single : 單一格
 - area_3x3 : 3x3 範圍
 - none : 無


## level 6. 效果
describe: 所有效果的邏輯

heal_morale_effect.gd: **回復**士氣
 - value: 回復數值

draw_card_effect.gd: **抽**卡
 - value: 抽卡數值

discount_morale_effect.gd: **扣除**士氣
 - value: 扣除數值
.
.
.
以此類推



### 範例
1. shooting_SC
 - level 1. strategy_effect_timing.gd
   - TARGETED
 - level 2. target_type.gd
   - piece
 - level 3. effect_target.gd
   - enemy   
 - level 4. target_piece_mask.gd
   - horse
   - chariot
   - cannon
   - soldier
 - level 5. target_mode.gd
   - single
 - level 6. remove_piece_effect.gd
   - 直接觸發移除邏輯

2. trash_cannon_SC
 - level 1. summon_effect_timing.gd
   - BORN
 - level 2. target_type.gd
   - piece
 - level 3. effect_target.gd
   - enemy
 - level 4. target_piece_mask.gd
   - general
 - level 5. target_mode.gd
   - none
 - level 6. cannot_attack_effect.gd
   - 直接套用無法吃子邏輯

3. doctor_elephant_SC
 - level 1. summon_effect_timing.gd
   - SUMMON
 - level 2. target_type.gd
   - player
 - level 3. effect_target.gd
   - self
 - level 4. target_piece_mask.gd
   - none
 - level 5. target_mode.gd
   - none
 - level 6. heal_morale_effect.gd
   - value: 5

4. boulder_SC
 - level 1. strategy_effect_timing.gd
   - TARGETED
 - level 2. target_type.gd
   - cell
 - level 3. effect_target.gd
   - any
 - level 4. target_piece_mask.gd
   - advisor
   - elephant
   - horse
   - chariot
   - cannon
   - soldier
 - level 5. target_mode.gd
   - area_3x3
 - level 6. remove_piece_effect.gd
   - 直接觸發移除邏輯
