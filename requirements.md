# Tip Top AI MT5 Bot Requirements

Task source: [mq5.com/freelance](https://www.mql5.com/en/job/206738/discussion?id=974925)

## Specification to pocket complain EN
I agree to create EA only for $30 for spec bellow. Only deadline for this deal is 30.10.23.

Short spec:
1. The bot checks current day candle using "tail length detection algorithm" (see AI code) to detect entry point.
2. The bot opens an order then entry point detected in trend way using color of current day candle (red - sell, green - buy).
3. Lot size, TP, SL are the bot settings.
4. Open order count is the bot setting with max count of orders opened

## AI Entry Point Detection Algorithm

Code provided by [Hussein Al Fallooji](https://www.mql5.com/en/users/hushuk/feedbacks).

```
def analyze_data(price_data, tail_percentage, tail_amount, average_tail_percentage):
    average_tail = []
    entry_points = []

    for candle in price_data:
        tail_length = abs(candle['high'] - candle['low'])
        average_tail.append(tail_length)

    historical_average_tail = sum(average_tail) / len(average_tail)

    for i, candle in enumerate(price_data):
        if i == 0:
            continue

        tail_length = abs(candle['high'] - candle['low'])

        if (tail_length > historical_average_tail * average_tail_percentage) and (tail_length > tail_amount):
            entry_points.append({'date': candle['date'], 'entry_point': candle['open']})

    return entry_points

# Historical price data
price_data = [
    {'date': '2023-01-01', 'open': 1.2000, 'high': 1.2100, 'low': 1.1950, 'close': 1.2050},
    {'date': '2023-01-02', 'open': 1.2050, 'high': 1.2150, 'low': 1.2000, 'close': 1.2100},
    # More data included here
]

# Tail percentage and tail amount used as entry criteria
tail_percentage = 1.5  # You can change these values
tail_amount = 0.0020  # You can change these values

# Average tail percentage for determining strong tails
average_tail_percentage = 1.2  # You can change these values

entry_points = analyze_data(price_data, tail_percentage, tail_amount, average_tail_percentage)
print(entry_points)
```

```
def analyze_candle_tail(candle):
    # Calculate the price difference between open and close
    price_difference = abs(candle['open'] - candle['close'])
    
    # Calculate the length of the upper wick and lower wick
    upper_wick = candle['high'] - max(candle['open'], candle['close'])
    lower_wick = min(candle['open'], candle['close']) - candle['low']
    
    # Determine the tail type based on defined rules
    if upper_wick > price_difference * 2:
        tail_type = 'Long Upper Wick'
    elif lower_wick > price_difference * 2:
        tail_type = 'Long Lower Wick'
    elif upper_wick > price_difference * 0.5:
        tail_type = 'Short Upper Wick'
    elif lower_wick > price_difference * 0.5:
        tail_type = 'Short Lower Wick'
    else:
        tail_type = 'No Tail'
    
    return tail_type

# Example of using the function to analyze a candle
candle = {'open': 1.2000, 'high': 1.2100, 'low': 1.1950, 'close': 1.2050}
tail_type = analyze_candle_tail(candle)
print("Tail Type:", tail_type)
```

```
def execute_trading_strategy(candle, tail_type):
    if tail_type == 'Long Upper Wick':
        # Execute a sell trade
        print("Sell Decision")
    elif tail_type == 'Long Lower Wick':
        # Execute a buy trade
        print("Buy Decision")
    else:
        # Does not match any of the defined rules
        print("No Trading Decision")

# Example of using the function
candle = {'open': 1.2000, 'high': 1.2100, 'low': 1.1950, 'close': 1.2050}
tail_type = analyze_candle_tail(candle)
execute_trading_strategy(candle, tail_type)
```