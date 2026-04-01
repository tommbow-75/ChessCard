# 遊戲流程架構

## 1. xiangqi_game.gd
負責管理遊戲流程，包括棋盤狀態、玩家狀態、回合狀態等
並負責呼叫summon_manager、StrategyManage、XiangqiRuleVerifier、XiangqiBoard、XiangqiPiece等資源

### 1-1. summon_manager.gd
負責管理召喚棋子的狀態，包括棋子位置、棋子狀態等
並負責呼叫XiangqiRuleVerifier、XiangqiBoard、XiangqiPiece等資源

### 1-2. strategy_manage.gd
負責管理策略卡牌的狀態，包括卡牌位置、卡牌狀態等
並負責呼叫XiangqiRuleVerifier、XiangqiBoard、XiangqiPiece等資源

### 1-3. xiangqi_rule_verifier.gd
負責驗證棋子的走法，包括棋子位置、棋子狀態等
並負責呼叫XiangqiBoard、XiangqiPiece等資源

### 1-4. xiangqi_board.gd
負責管理棋盤的狀態，包括棋子位置、棋子狀態等
並負責呼叫XiangqiPiece等資源

### 1-5. xiangqi_piece.gd
負責管理棋子的狀態，包括棋子位置、棋子狀態等