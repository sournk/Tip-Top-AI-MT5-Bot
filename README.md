# Tip-Top-AI-MT5-Bot

Tip Top AI Expert Adviser For MetaTrader 5 uses AI generated strategy to detect entry point by Tail length algorithm.

![Settings](img/howto/005.%20Settings.png)

# Strategy Explanation

1. **The bot calculate average size of history bars.** Time frame to analyze you can set in `Signals detection timeframe` param. Also you can set how many bars the bot uses to calculation in setting `AI algo param #1" Number of bars to analyze`. 
```IMPORTANT!  It doesn't matter witch time frame is set on the chart. The bot use only its setting. So you can explore chart in any time frame without influence to the bot.``` 
2. When the size of the current candle becomes larger than the average size of historical bars multiplied by a coefficient `AI algo param #2: Tail percentage` and it is simultaneously larger than the specified parameter `AI algo param #3: Tail amount`, **the bot can enter a trade.**
3. **To detect direction to enter the bot check wick of current candle.** If upper wick size of bar is lager than twiced bar body size the bot opens BUY order. If lower wick size is lager than twiced bar body size the bot opens SELL order.

**Important thing #1.** Here is about limit to open new orders. Then wick grows the bot can open more and more orders. To limit orders count you can use `Max count of BUY/SELL orders opened at same time`  

**Important thing #2.** Sometimes upper wick candle gives the signal to buy, and after that price turns over and lower wick gives the signal to sell on the same bar. If you don't want to allow bot to open orders in different directions at the same time set `Max count orders inside one candle` to 1.

# User interface

You always can see current status of entry and direction signal in left top corner of your char.

![](img/howto/010.%20UI.png)
