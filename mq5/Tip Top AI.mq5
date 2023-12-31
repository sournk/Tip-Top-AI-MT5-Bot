//+------------------------------------------------------------------+
//|                                                   Tip Top AI.mq5 |
//|                                                  Denis Kislitsyn |
//|                                             https://kislitsyn.me |
//+------------------------------------------------------------------+

#include <Arrays\ArrayObj.mqh>

#include <Trade\PositionInfo.mqh>
#include <Trade\Trade.mqh>
#include <Trade\SymbolInfo.mqh>
#include <Trade\AccountInfo.mqh>
#include <Trade\HistoryOrderInfo.mqh>

#include <DKStdLib\Common\DKStdLib.mqh>
#include <DKStdLib\Logger\DKLogger.mqh>
#include <DKStdLib\NewBarDetector\DKNewBarDetector.mqh>
#include <DKStdLib\Analysis\DKChartAnalysis.mqh>
#include <DKStdLib\Drawing\DKChartDraw.mqh>

enum ENUM_TAIL_TYPE {
  ENUM_TAIL_TYPE_NO_TAIL,           // No tail
  ENUM_TAIL_TYPE_LONG_UPPER_WICK,   // Long upper wick
  ENUM_TAIL_TYPE_LONG_LOWER_WICK,   // Long lower wick
  ENUM_TAIL_TYPE_SHORT_UPPER_WICK,  // Short upper wick  
  ENUM_TAIL_TYPE_SHORT_LOWER_WICK   // Short lower wick
  
};


#property script_show_inputs

string BOT_GLOBAL_PREFIX = "TTA";

input   group                    "ENTRY"
input   bool                     InputBuyEnabled                      = true;                                 // BUY enabled
input   bool                     InputSellEnabled                     = true;                                 // SELL enabled
input   int                      InputBuyOpenSameTimeOrderCount       = 1;                                    // Max count of BUY orders opened at same time
input   int                      InputSellOpenSameTimeOrderCount      = 1;                                    // Max count of SELL orders opened at same time
input   int                      InputMaxOrderCountInOneBar           = 2;                                    // Max count orders inside one candle
input   ENUM_MM_TYPE             InputMMType                          = ENUM_MM_TYPE_FIXED_LOT;               // Money Managment (MM) type
input   double                   InputMMValue                         = 0.01;                                 // MM value for whole zone
input   ulong                    InputSlippage                        = 2;                                    // Max slippage for operation, points

input   group                    "EXIT"
input   int                      InputTakeProfitDistance              = 300;                                  // Take profit distance, points
input   int                      InputStoplossDistance                = 100;                                  // Stop loss distance, points
input   double                   InputMaxProfitToCloseAll             = 0;                                    // Max profit when all orders close (0 - disabled)

input   group                    "STRATEGY"
input   ENUM_TIMEFRAMES          InputTimeframe                       = PERIOD_H1;                            // Signals detection timeframe 
input   int                      InputHistoricalBarsCount             = 365;                                  // AI algo param #1: Number of bars to analyze
input   double                   InputTailPercentage                  = 1.5;                                  // AI algo param #2: Tail percentage
input   double                   InputTailAmount                      = 0.0020;                               // AI algo param #3: Tail amount
input   double                   InputAvaerageTailPercentage          = 1.2;                                  // AI algo param #4: Average tail percentage
input   double                   InputWickToBodyRatio                 = 2;                                    // AI algo param #5: Long wick is X times longer then body

input   group                    "MISC"
sinput  LogLevel                 InputLogLevel                        = LogLevel(INFO);                       // Log level
        int                      InputMagic                           = 20231106;                             // Magic


DKLogger Logger;

CAccountInfo      accountInfo;
CSymbolInfo       symbolInfo;
CTrade            tradeInfo;
CPositionInfo     positionInfo;
CHistoryOrderInfo ßhistoryInfo;

CArrayObj     supportZones;
CArrayObj     resistanceZones;

DKNewBarDetector* newBarDetectorZonesUpdate;

int startCount = 0;
int orderCountOnCurrentBar = 0;

string lastEntryStatus = "";

//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| EA STRATEGY
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+

bool IsEntryAvaliableNow(){
  MqlRates mqlRates[];
  
  if(CopyRates(symbolInfo.Name(), InputTimeframe, 0, InputHistoricalBarsCount + 1, mqlRates) > 0) {
    //ArrayPrint(mql_rates);
    double historical_average_tail = 0;
    // Start from 1 to skip current 0 bar 
    for (int i = 1; i < ArraySize(mqlRates); i++)
      historical_average_tail += MathAbs(mqlRates[i].high - mqlRates[i].low);
      
    historical_average_tail = historical_average_tail / InputHistoricalBarsCount;
   
    double tail_length = MathAbs(mqlRates[0].high - mqlRates[0].low);

    if (tail_length > historical_average_tail * InputAvaerageTailPercentage && tail_length > InputTailAmount) {
      lastEntryStatus = StringFormat("Entry Formula is TRUE: (LAST_BAR_SIZE > HISTORICAL_BAR_SIZE * AI_ALGO_PARAM_#4_AVG_TAIL_PERS) && (LAST_BAR_SIZE > AI_ALGO_PARAM_#3_TAIL_AMOUNT)\n" + 
                                     "Entry Calculation is TRUE: (%f > %f * %f) && (%f > %f)", 
                                     tail_length,
                                     historical_average_tail,
                                     InputAvaerageTailPercentage,
                                     tail_length,
                                     InputTailAmount); 
      return true;
    }
    else
      lastEntryStatus = StringFormat("Entry Formula is FALSE: (LAST_BAR_SIZE > HISTORICAL_BAR_SIZE * AI_ALGO_PARAM_#4_AVG_TAIL_PERS) && (LAST_BAR_SIZE > AI_ALGO_PARAM_#3_TAIL_AMOUNT)\n" + 
                                     "Entry Calculation is FALSE: (%f > %f * %f) && (%f > %f)", 
                                     tail_length,
                                     historical_average_tail,
                                     InputAvaerageTailPercentage,
                                     tail_length,
                                     InputTailAmount);     
   }
  else
    Logger.Error(StringFormat("Getting rates error: ERROR_CODE=%d", GetLastError())); 
    
  return false;
}

ENUM_TAIL_TYPE GetCurrentCandleTailType() {
  MqlRates mqlRates[];
  
  if(CopyRates(symbolInfo.Name(), InputTimeframe, 0, 1, mqlRates) <= 0) 
    return ENUM_TAIL_TYPE_NO_TAIL; 
  
  // Calculate the price difference between open and close
  double price_difference = MathAbs(mqlRates[0].open - mqlRates[0].close);
  
  // Calculate the length of the upper wick and lower wick
  double upper_wick = mqlRates[0].high - MathMax(mqlRates[0].open, mqlRates[0].close);
  double lower_wick = MathMin(mqlRates[0].open, mqlRates[0].close) - mqlRates[0].low;
  
  // Determine the tail type based on defined rules
  if (upper_wick > price_difference * InputWickToBodyRatio) return ENUM_TAIL_TYPE_LONG_UPPER_WICK;
  if (lower_wick > price_difference * InputWickToBodyRatio) return ENUM_TAIL_TYPE_LONG_LOWER_WICK;
  if (upper_wick > price_difference * 0.5) return ENUM_TAIL_TYPE_SHORT_UPPER_WICK;
  if (lower_wick > price_difference * 0.5) return ENUM_TAIL_TYPE_SHORT_LOWER_WICK;
  
  return ENUM_TAIL_TYPE_NO_TAIL;
}

int CountBotOpenOrder(ENUM_POSITION_TYPE aPositionType) {
  int orderCount = 0;
 
  for(int i = 0; i < PositionsTotal(); i++) {
   if(positionInfo.SelectByIndex(i))
     if (positionInfo.Symbol() == symbolInfo.Name() && positionInfo.Magic() == InputMagic && positionInfo.PositionType() == aPositionType)
      orderCount++;
  }  
  return orderCount;
}

ulong OpenPosition(double aLot, ENUM_POSITION_TYPE aPositionType) {
  aLot = NormalizeLot(symbolInfo.Name(), aLot);
  if(aLot <= 0) {
    Logger.Error("Open position error with lot 0");
    return(0);
  }

  bool openRes;
  if(POSITION_TYPE_BUY == aPositionType) {
    double price1 = SymbolInfoDouble(_Symbol,SYMBOL_ASK);
    double sl1 = price1 - PointsToPrice(symbolInfo.Name(), InputStoplossDistance);
    double tp1 = price1 + PointsToPrice(symbolInfo.Name(), InputTakeProfitDistance);
    openRes = tradeInfo.Buy(aLot, 
                            symbolInfo.Name(), 
                            0, 
                            sl1, 
                            tp1, 
                            BOT_GLOBAL_PREFIX);
  }

  if(POSITION_TYPE_SELL == aPositionType) {
    double price = SymbolInfoDouble(_Symbol,SYMBOL_BID);
    double sl = price + PointsToPrice(symbolInfo.Name(), InputStoplossDistance);
    double tp = price - PointsToPrice(symbolInfo.Name(), InputTakeProfitDistance);
    Logger.Debug("Tring to open");
    openRes = tradeInfo.Sell(aLot, 
                            symbolInfo.Name(), 
                            0, 
                            sl, 
                            tp, 
                            BOT_GLOBAL_PREFIX);
  }

  if(openRes) {
    ulong Ticket = tradeInfo.ResultDeal();
    if(Ticket != 0) {
      Logger.Info(StringFormat("Position opened: TICKET=%I64u; DIR=%s; LOT=%f",
                               Ticket,
                               EnumToString(aPositionType),
                               aLot));
      return(Ticket);
    }
  }

  Logger.Error(StringFormat("Open position error: RETCODE=%d; DIR=%s; LOT=%f",
                            tradeInfo.ResultRetcode(),
                            EnumToString(aPositionType),
                            aLot));
  return(0);
}


ulong Trade() {
  if (orderCountOnCurrentBar >= InputMaxOrderCountInOneBar) return 0;

  ENUM_TAIL_TYPE currCandleWickType = GetCurrentCandleTailType();
  ENUM_POSITION_TYPE currSignal;
  string currSignalName = "UNKNOWN";

  ulong openPosTicket = 0;
  bool isEntryAvaliable = IsEntryAvaliableNow();
  if (isEntryAvaliable) {
    double startLot = CalculateLots(symbolInfo.Name(), InputMMType, InputMMValue, InputStoplossDistance);
    startLot = NormalizeDouble(startLot, 2);  
    
    if (InputBuyEnabled && currCandleWickType == ENUM_TAIL_TYPE_LONG_UPPER_WICK) {
      currSignal = POSITION_TYPE_SELL;
      currSignalName = "SELL";
      if (CountBotOpenOrder(POSITION_TYPE_SELL) < InputSellOpenSameTimeOrderCount) 
        openPosTicket = OpenPosition(startLot, currSignal);
    }
    
    if (InputSellEnabled && currCandleWickType == ENUM_TAIL_TYPE_LONG_LOWER_WICK){
      currSignal = POSITION_TYPE_BUY;
      currSignalName = "BUY";
      if (CountBotOpenOrder(POSITION_TYPE_BUY) < InputBuyOpenSameTimeOrderCount) 
        openPosTicket = OpenPosition(startLot, currSignal);
    }
  }
  
  if (openPosTicket != 0) orderCountOnCurrentBar++;
  
  string currCandleWickTypeName = EnumToString(currCandleWickType);

  StringReplace(currCandleWickTypeName, "ENUM_TAIL_TYPE_", "");
  Comment(StringFormat("STEP #1/2: ENTRY DETECTION - %s\n%s\n\n" +
                       "STEP #2/2: DIRECTION DETECTION - %s\nCurrent bar wink type: %s\nWait status: LONG_UPPER_WICK or LONG_LOWER_WICK",
                       (isEntryAvaliable) ? "ENTRY AVALIABLE" : "NO ENTRY",
                       lastEntryStatus,
                       currSignalName,
                       currCandleWickTypeName));
  
  
  
  return openPosTicket;
}

int CloseOrdersByMaxProfit() {
  int ordersClosed = 0;
  
  if (InputMaxProfitToCloseAll > 0 )
    if (accountInfo.Profit() >= InputMaxProfitToCloseAll)  {
       Logger.Info(StringFormat("Max profit achived: %f >= %f", 
                                accountInfo.Profit(),
                                InputMaxProfitToCloseAll));
                                
       for (int i = PositionsTotal() - 1; i >= 0; i--) 
          if (positionInfo.SelectByIndex(i)) 
            if (positionInfo.Symbol() == symbolInfo.Name() && positionInfo.Magic() == InputMagic) {
              Logger.Info(StringFormat("Closing order by max overall profit: ORDER_ID=%I64u", positionInfo.Ticket()));
              tradeInfo.PositionClose(positionInfo.Ticket());       
              ordersClosed++;        
              Sleep(100); 
            }      
    }
  return ordersClosed;
}

//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| EA EVENTS
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit() {
  Logger.Name = __FILE__;
  Logger.Level = InputLogLevel;
  if(MQL5InfoInteger(MQL5_DEBUGGING)) Logger.Level = LogLevel(DEBUG);
  
  //string expar = (string)InputMagic;
  //datetime expiration = StringToTime(expar);
  //if (TimeCurrent() > StringToTime((string)InputMagic) + 14 * 24 * 60 * 60) {
  //  MessageBox("Developer version is expired", "Error", MB_OK && MB_ICONERROR);
  //  return(INIT_FAILED);
  //}

  // Проверим режим счета. Нужeн ОБЯЗАТЕЛЬНО ХЕДЖИНГОВЫЙ счет
  if(accountInfo.MarginMode() != ACCOUNT_MARGIN_MODE_RETAIL_HEDGING) {
    Logger.Critical("Only hedge account is avaliable: ACCOUNT_MARGIN_MODE_RETAIL_HEDGING");
    return(INIT_FAILED);
  }

  if(!symbolInfo.Name(Symbol())) {
    Logger.Critical(StringFormat("Symbol set error %s", Symbol()));
    return(INIT_FAILED);
  }
  
  if (!RefreshRates(symbolInfo.Name())) { 
    Logger.Critical(StringFormat("Refresh rate error %s", Symbol()));
    return(INIT_FAILED);
  }  

  tradeInfo.SetExpertMagicNumber(InputMagic);
  tradeInfo.SetMarginMode();
  tradeInfo.SetTypeFillingBySymbol(symbolInfo.Name());
  tradeInfo.SetDeviationInPoints(InputSlippage);

  if (CheckPointer(newBarDetectorZonesUpdate) == POINTER_INVALID) newBarDetectorZonesUpdate = new DKNewBarDetector(symbolInfo.Name());
  newBarDetectorZonesUpdate.AddTimeFrame(InputTimeframe);

  startCount++;
  Logger.Info(StringFormat("Init succeed: START_COUNT=%d", startCount));

  return(INIT_SUCCEEDED);
}
  
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason) {
  if (reason != REASON_CHARTCHANGE) delete newBarDetectorZonesUpdate;
}
  
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick() {  
  if(!IsAutoTradingEnabled()) return;
  if(!RefreshRates(symbolInfo.Name())) return;
  
  if (newBarDetectorZonesUpdate.CheckNewBarAvaliable(InputTimeframe)) {
    Logger.Debug(StringFormat("New bar detected: TF=%s", EnumToString(InputTimeframe)));
    orderCountOnCurrentBar = 0;
  }
  
  Trade();
  CloseOrdersByMaxProfit();    
}
//+------------------------------------------------------------------+
