//+------------------------------------------------------------------+
//|                                                   EA tip top.mq4 |
//|                                     Email: skilful_coder@mail.ru |
//|                           Beknazarov Hasanboy, Uzbekistan © 2021 |
//+------------------------------------------------------------------+
#property copyright "skilful_coder ( from MQL5.com ) © 2021"
#property link "https://www.mql5.com/en/users/skilful_coder/portfolio"
#property version "1.00"
#property strict
#include <stdlib.mqh>

enum trade
  {
   a=0//Buy & Sell
   ,b=1//Buy only
   ,c=2//Sell only
  };
enum PO
  {
   d=0//Stop orders
   ,e=1//Limit orders
  };

input string EAComment             = "EA tip top";// EA Comment
input int    MagicNumber           = 123;    // Magic Number
input int    Slippage              = 3;      // Slippage
input string s_ = "====== New Settings ======";
input bool UseSmartClosing = false;
input int StartClosingOrders = 5;
input double MinProfit = 1;
input bool Activate_Modification = true;
input string s = "Candle settings";
input int M1_Candle = 1;
input bool UseM1 = true;
input int M5_Candle = 1;
input bool UseM5 = true;
input int M15_Candle = 1;
input bool UseM15 = true;
input int M30_Candle = 1;
input bool UseM30 = true;
input int H1_Candle = 1;
input bool UseH1 = true;
input int H4_Candle = 1;
input bool UseH4 = true;
input int D1_Candle = 1;
input bool UseD1 = true;
input int W1_Candle = 1;
input bool UseW1 = true;
input int MN1_Candle = 1;
input bool UseMN1 = true;
input ENUM_TIMEFRAMES TimeFrame    = PERIOD_H1;   // Time Frame
input trade  Direc                 = 0;           // Trade Direction
input bool   oldentr               = 0;           // Use Old entry method
input bool   newentr               = 1;           // Use New entry method
input PO     Pending               = 0;           // Type of Pending
input double dist                  = 10;          // X pips for pending orders
input string ______________________= "-";    //________Trade Parameters
input double Lot                   = 0.01;   // Lot Size(1000 to 20001)
input double Lot2                  = 0.02;   // Lot Size(20001 to 40001)
input bool   Exit1                 = 1;      // Exit method 1
input double TakeProfit            = 1;      // Take Profit (in $)
input bool   Exit2                 = 1;      // Exit method 2
input bool   Exit3                 = 1;      // New Exit method
input double TakeProfit2           = 1;      // Take Profit (in $)
input int    MaxOrders             = 5;      // Number of deals(from $1,000 to $10,000)
input int    MaxOrders2            = 10;     // Number of deals(from $10,000)
input int    MaxBuyOrders          = 5;
input int    MaxSellOrders         = 5;
input bool   ShowInfo              = false;  // Show Info to Chart
input ENUM_BASE_CORNER Corner      = 1;      // Info Corner
input color  Color_Info            = clrAqua;// Info Color
input bool   TradeOnMonday         = 1;      // Start on Monday
input string TimeStart             = "11:00";// Monday Start Hour
input bool   TradeOnFriday         = 1;      // Close on Friday
input string Time_Close            = "22:00";// Friday Close Hour
input string TrailingStopLoss      = "--------------------< Trailing Pending Orders >--------------------";//Trailing Pending Orders ............................................................................................................
input bool   UseTrailingStop       = 1;      // Use Trailing Pending
input double TrailingStart         = 10;     // Trailing Start points
input double TrailingStop          = 1;      // Trailing Step points
input string Time_Filter           = "--------------------< Trading Time >--------------------";// Trading Time ...........................................................................................................
input bool   Use_Time_Filter       = false;  // Use Trading Time
input string Time_Start            = "00:00";// Time Start
input string Time_End              = "23:59";// Time End
input string Line_Parameters_______= "-------------------< Weekly Line settings >-------------------";// Weekly Line settings
input ENUM_LINE_STYLE STYLE        = 2;        // Horizontal Line Style
input color  COLOR                 = clrYellow;// Horizontal Line Color
input int    WIDTH                 = 3;        // Horizontal Line Width
input ENUM_LINE_STYLE STYLE2       = 2;        // Vertical Line Style
input color  COLOR2                = clrYellow;// Vertical Line Color
input int    WIDTH2                = 3;        // Vertical Line Width
//HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH
datetime Otime;
int      Pip=1,lotdig=0;
string   text[21],prefix="",prlabs;
double   ClosingArray[100],DrawDowns=0,Bopen=0,Sopen=0,
                           DDBuffer=0,LastBuy=0,LastSell=0,Bopen2=0,Sopen2=0;
//HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
double SellPrice[];
double BuyPrice[];
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnInit()
  {
   ArrayResize(text,30);
   Otime = TimeCurrent();
   if(MarketInfo(Symbol(),MODE_LOTSTEP)==1)
      lotdig=0;
   if(MarketInfo(Symbol(),MODE_LOTSTEP)==0.1)
      lotdig=1;
   if(MarketInfo(Symbol(),MODE_LOTSTEP)==0.01)
      lotdig=2;

   double bid=MarketInfo(Symbol(),MODE_BID);
   int digits=(int)MarketInfo(Symbol(),MODE_DIGITS);

   if(digits == 4 || (bid < 1000 && digits == 2))
     {
      Pip = 1;
     }
   else
      Pip = 10;

   if(IsTesting())
      prefix = "Test" + IntegerToString(MagicNumber) + Symbol();
   else
      prefix = IntegerToString(MagicNumber) + Symbol();
   if(!IsTesting())
     {
      EventSetMillisecondTimer(800);
     }
   return;
  }
//HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   if(!IsTesting())
     {
      EventKillTimer();
      for(int i = ObjectsTotal(); i >= 0; i--)
        {
         string name = ObjectName(i);
         if(StringSubstr(name,0,4)=="Info")
           {
            ObjectDelete(name);
           }
        }
      ObjectDelete("Weekly Open");
      ObjectDelete("Weekly Time");
      ObjectDelete("Weekly Open Price");
     }
   GVDel(prefix);
   return;
  }
//OOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOO
//+------------------------------------------------------------------+
//|  Get Signals                                                     |
//+------------------------------------------------------------------+
double Lo(int shift) { double val = iLow(NULL,TimeFrame,shift); return(val);}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double Hi(int shift) { double val = iHigh(NULL,TimeFrame,shift); return(val);}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double Op(int shift) { double val = iOpen(NULL,TimeFrame,shift); return(val);}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double Cl(int shift) { double val = iClose(NULL,TimeFrame,shift); return(val);}
//HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH
//+------------------------------------------------------------------+
//| Expert timer function                                            |
//+------------------------------------------------------------------+
void OnTick()
  {
   if(IsTesting())
     {
      OnTimer();
     }
  }
//HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH
//+------------------------------------------------------------------+
//| Expert timer function                                            |
//+------------------------------------------------------------------+
void OnTimer()
  {
   RefreshRates();
   if(Bars < 10)
     {
      Print("Not enough bars for working the EA");
      return;
     }
   CheckToClose();
   HTP();
   ModifyOrder();
   if(!IsOptimization())
     {
      PrintInfo();
     }

   LastBuy  = FindLastOrder(0,"price");
   LastSell = FindLastOrder(1,"price");

   if(Pending==0)
     {
      Bopen = NormalizeDouble(Ask + (dist*pt()),_Digits);
      Sopen = NormalizeDouble(Bid - (dist*pt()),_Digits);
     }
   if(Pending==1)
     {
      Bopen2 = NormalizeDouble(Ask - (dist*pt()),_Digits);
      Sopen2 = NormalizeDouble(Bid + (dist*pt()),_Digits);
     }
//+---------------------------------------------------------------------------------+
   if(Otime != 0 && Otime < TimeCurrent())
     {
      WLine();
      WLine2();
     }
//+---------------------------------------------------------------------------------+
   if(Exit3 && CheckProfit(0)+CheckProfit(1) >= TakeProfit2)
     {
      CloseOrders(0);
      CloseOrders(1);
      Print("-----> All Buy trades closed !");
      Print("-----> All Sell trades closed !");
     }
//+---------------------------------------------------------------------------------+
//+---------------------------------------------------------------------------------+
   if(Exit2 && !Exit3 && CheckProfit(0) > TakeProfit2)
     {
      CloseOrders(0);
      Print("-----> All Buy trades closed !");
     }
//+---------------------------------------------------------------------------------+
   if(Exit2 && !Exit3 && CheckProfit(1) > TakeProfit2)
     {
      CloseOrders(1);
      Print("-----> All Sell trades closed !");
     }
   if(TradeOnFriday && DayOfWeek() == 5 && TimeCurrent() >= StrToTime(Time_Close))
     {
      Print("All closed due to the Friday time !!!");
      CloseOrders(-1);
      return;
     }
   if(TradeOnMonday && DayOfWeek() == 1 && TimeCurrent() < StrToTime(TimeStart))
     {
      return;
     }
//HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH
   if(oldentr && !newentr && GoodTime() && CurrBar() && ClosedBar() /*&&
      ((AccountBalance() <= 10000 && MaxOrders > Orders(-1)) || (AccountBalance() > 10000 && MaxOrders2 > Orders(-1)))*/)
     {
      double lotx = 0;

      if(Direc < 2 /*&& ZZDirection("buy")*/ && CountOrders("buy") < MaxBuyOrders && Modification("buy"))
        {
         if(20001 > AccountBalance())
           {
            lotx = NormalizeDouble(Lot,lotdig);
           }
         if(20001 < AccountBalance())
           {
            lotx = NormalizeDouble(Lot2,lotdig);
           }
         int Ticket = OrderSend(Symbol(), OP_BUY, lotx, Ask, Slippage*Pip, 0, 0, EAComment, MagicNumber, 0, clrBlue);
         int err = GetLastError();
         if(err != ERR_NO_ERROR)
           {
            Print("Error on Order open = ", ErrorDescription(err));
           }
        }
      if(Direc != 1 /*&& ZZDirection("sell")*/ && CountOrders("sell") < MaxSellOrders && Modification("sell"))
        {
         if(20001 > AccountBalance())
           {
            lotx = NormalizeDouble(Lot,lotdig);
           }
         if(20001 < AccountBalance())
           {
            lotx = NormalizeDouble(Lot2,lotdig);
           }
         int Ticket = OrderSend(Symbol(), OP_SELL, lotx, Bid, Slippage*Pip, 0, 0, EAComment, MagicNumber, 0, clrRed);
         int err = GetLastError();
         if(err != ERR_NO_ERROR)
           {
            Print("Error on Order open = ", ErrorDescription(err));
           }
        }
     }
//HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH
   if(newentr && !oldentr && GoodTime() /*&& ((AccountBalance() <= 10000 && MaxOrders > Orders(-1)) || (AccountBalance() > 10000 && MaxOrders2 > Orders(-1)))*/)
     {
      double lotx = 0;

      if(Modification("buy") && Direc < 2 && Pending==0 && Bopen != 0 /*&& ZZDirection("buy")*/ && CurrBar2() /*&& Orders(4) < MaxOrders && Orders(0) < MaxOrders && Orders(4) < MaxBuyOrders && Orders(0) < MaxBuyOrders*/ && CountOrders("buy") < MaxBuyOrders)
        {
         if(20001 > AccountBalance())
           {
            lotx = NormalizeDouble(Lot,lotdig);
           }
         if(20001 < AccountBalance())
           {
            lotx = NormalizeDouble(Lot2,lotdig);
           }
         int Ticket = OrderSend(Symbol(),OP_BUYSTOP,lotx,Bopen,Slippage*Pip,0,0,EAComment,MagicNumber,0,clrBlue);
         int err = GetLastError();

         if(err != ERR_NO_ERROR)
           {
            Print("Error on Order open = ", ErrorDescription(err));
           }
        }

      if(Modification("sell") && Direc != 1 && Pending==0 && Sopen != 0 /*&& ZZDirection("sell")*/ && CurrBar3() /*&& Orders(1) < MaxOrders && Orders(5) < MaxOrders && Orders(1) < MaxSellOrders && Orders(5) < MaxSellOrders*/ && CountOrders("sell") < MaxSellOrders)
        {
         if(20001 > AccountBalance())
           {
            lotx = NormalizeDouble(Lot,lotdig);
           }
         if(20001 < AccountBalance())
           {
            lotx = NormalizeDouble(Lot2,lotdig);
           }
         int Ticket = OrderSend(Symbol(),OP_SELLSTOP,lotx,Sopen,Slippage*Pip,0,0,EAComment,MagicNumber,0,clrRed);
         int err = GetLastError();
         if(err != ERR_NO_ERROR)
           {
            Print("Error on Order open = ", ErrorDescription(err));
           }
        }

      if(Modification("buy") && Direc < 2 && Pending==1 && Bopen2 != 0 /*&& ZZDirection("buy")*/ && CurrBar2() /*&& Orders(2) < MaxOrders && Orders(0) < MaxOrders && Orders(0) < MaxBuyOrders && Orders(2) < MaxBuyOrders*/ && CountOrders("buy") < MaxBuyOrders)
        {
         if(20001 > AccountBalance())
           {
            lotx = NormalizeDouble(Lot,lotdig);
           }
         if(20001 < AccountBalance())
           {
            lotx = NormalizeDouble(Lot2,lotdig);
           }
         int Ticket = OrderSend(Symbol(),OP_BUYLIMIT,lotx,Bopen2,Slippage*Pip,0,0,EAComment,MagicNumber,0,clrBlue);
         int err = GetLastError();
         if(err != ERR_NO_ERROR)
           {
            Print("Error on Order open = ", ErrorDescription(err));
           }
        }

      if(Modification("sell") && Direc != 1 && Pending==1 && Sopen2 != 0 /*&& ZZDirection("sell")*/ && CurrBar3() /*&& Orders(3) < MaxOrders && Orders(1) < MaxOrders && Orders(1) < MaxSellOrders && Orders(3) < MaxSellOrders*/ && CountOrders("sell") < MaxSellOrders)
        {
         if(20001 > AccountBalance())
           {
            lotx = NormalizeDouble(Lot,lotdig);
           }
         if(20001 < AccountBalance())
           {
            lotx = NormalizeDouble(Lot2,lotdig);
           }
         int Ticket = OrderSend(Symbol(),OP_SELLLIMIT,lotx,Sopen2,Slippage*Pip,0,0,EAComment,MagicNumber,0,clrRed);
         int err = GetLastError();
         if(err != ERR_NO_ERROR)
           {
            Print("Error on Order open = ", ErrorDescription(err));
           }
        }
     }
  }
//HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH
//+------------------------------------------------------------+
//|  Partial Close                                             |
//+------------------------------------------------------------+
void ModifyOrder()
  {
   if(!UseTrailingStop)
     {
      return;
     }

   for(int cnt=0; cnt < OrdersTotal(); cnt++)
     {
      bool select=OrderSelect(cnt,SELECT_BY_POS,MODE_TRADES);
      int ticket=OrderTicket(), OrderTyp=OrderType();
      double OrderOP=OrderOpenPrice(), Orderlots=OrderLots();

      if(OrderSymbol()==Symbol() && OrderMagicNumber()==MagicNumber)
        {
         if(OrderTyp==OP_BUYSTOP && Pending==0)
           {
            if(OrderOP - Bid > (dist*pt()) + TrailingStart*_Point)
              {
               GVSet((string)ticket,ticket);
              }

            if(GVGet((string)ticket) == ticket && OrderOP - TrailingStop*_Point > NormalizeDouble(Bid + ((dist*pt()) + (TrailingStart*_Point)),_Digits))
              {
               PC2(OrderTicket(),NormalizeDouble(Bid + ((dist*pt()) + (TrailingStart*_Point)),Digits));
              }
           }
         if(OrderTyp==OP_SELLSTOP && Pending==0)
           {
            if(Ask - OrderOP > (dist*pt()) + TrailingStart*pt())
              {
               GVSet((string)ticket,ticket);
              }

            if(GVGet((string)ticket) == ticket && OrderOP + TrailingStop*pt() < NormalizeDouble(Ask - ((dist*pt()) + (TrailingStart*_Point)),_Digits))
              {
               PC2(OrderTicket(),NormalizeDouble(Ask - ((dist*pt()) + (TrailingStart*_Point)),Digits));
              }
           }
         if(OrderTyp==OP_BUYLIMIT && Pending==1)
           {
            if(Bid - OrderOP > (dist*pt()) + TrailingStart*_Point)
              {
               GVSet((string)ticket,ticket);
              }

            if(GVGet((string)ticket) == ticket && OrderOP + TrailingStop*_Point < NormalizeDouble(Bid - ((dist*pt()) + (TrailingStart*_Point)),_Digits))
              {
               PC2(OrderTicket(),NormalizeDouble(Bid - ((dist*pt()) + (TrailingStart*_Point)),Digits));
              }
           }
         if(OrderTyp==OP_SELLLIMIT && Pending==1)
           {
            if(OrderOP - Ask > (dist*pt()) + TrailingStart*pt())
              {
               GVSet((string)ticket,ticket);
              }

            if(GVGet((string)ticket) == ticket && OrderOP - TrailingStop*pt() > NormalizeDouble(Ask + ((dist*pt()) + (TrailingStart*_Point)),_Digits))
              {
               PC2(OrderTicket(),NormalizeDouble(Ask + ((dist*pt()) + (TrailingStart*_Point)),Digits));
              }
           }
        }
     }
  }
//+-----------------------------------------------------------------------------------------------+
void PC2(int ticket,double cp)
  {
   int err;
   if(OrderSelect(ticket, SELECT_BY_TICKET,MODE_TRADES))
     {
      if(OrderSymbol() == Symbol() && OrderType() > 1)
        {
         bool modify = OrderModify(ticket, cp, 0, 0, 0, clrOrange);
         err = GetLastError();
         if(err != ERR_NO_ERROR)
           {
            Print("Error on Order Modify = ", ErrorDescription(err));
           }
        }
     }
  }
//HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH
//+------------------------------------------------------------------+
//| Disable trade in current bar(if one is already open)             |
//+------------------------------------------------------------------+
bool CurrBar2()
  {
   bool yes = 1;

   for(int i = OrdersTotal()-1; i >= 0; i--)
     {
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
        {
         if(OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber && (OrderType()==OP_BUY || OrderType()==OP_BUYSTOP || OrderType()==OP_BUYLIMIT))
           {
            if(OrderOpenTime() >= iTime(Symbol(),0,0))
               yes = 0;
           }
        }
     }
   return(yes);
  }
//HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH
//+------------------------------------------------------------------+
//| Disable trade in current bar(if one is already open)             |
//+------------------------------------------------------------------+
bool CurrBar3()
  {
   bool yes = 1;

   for(int i = OrdersTotal()-1; i >= 0; i--)
     {
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
        {
         if(OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber && (OrderType()==OP_SELL || OrderType()==OP_SELLSTOP || OrderType()==OP_SELLLIMIT))
           {
            if(OrderOpenTime() >= iTime(Symbol(),0,0))
               yes = 0;
           }
        }
     }
   return(yes);
  }
//HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH
void DeletePending()
  {
   int numPosB = Orders(0), numPosS = Orders(1);

   for(int i = 0; i < OrdersTotal(); i++)
     {
      bool Os = OrderSelect(i, SELECT_BY_POS);
      if(OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber)
        {
         if(OrderType() == OP_BUYSTOP || OrderType()==OP_BUYLIMIT)
           {
            if(numPosS > 0)
              {
               bool Od = OrderDelete(OrderTicket());
              }
           }
         if(OrderType() == OP_SELLSTOP || OrderType()==OP_SELLLIMIT)
           {
            if(numPosB > 0)
              {
               bool Od = OrderDelete(OrderTicket());
              }
           }
        }
     }
  }
//HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH
double FindLastOrder(int TPo, string ParamName)
  {
   double mOrderPrice = 0,mOrderLot = 0,mOrderProfit = 0;
   int PrevTicket = 0,CurrTicket = 0,mOrderTicket = 0,mOrderType=-1;

   for(int i = OrdersTotal() - 1; i >= 0; i--)
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
         if(OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber && (OrderType() == TPo || TPo == -1))
           {
            CurrTicket = OrderTicket();
            if(CurrTicket > PrevTicket)
              {
               PrevTicket = CurrTicket;
               mOrderPrice = OrderOpenPrice();
               mOrderTicket = OrderTicket();
               mOrderLot = OrderLots();
               mOrderType = OrderType();
               mOrderProfit = OrderProfit() + OrderSwap() + OrderCommission();
              }
           }
   if(ParamName == "price")
      return(mOrderPrice);
   else
      if(ParamName == "ticket")
         return(mOrderTicket);
      else
         if(ParamName == "lot")
            return(mOrderLot);
         else
            if(ParamName == "profit")
               return(mOrderProfit);
            else
               if(ParamName == "type")
                  return(mOrderType);

   return(0);
  }
//HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH
void WLine()
  {
   string labelname = "Weekly Open Price", linename = "Weekly Open";
   if(ObjectFind(linename) != 0 && NormalizeDouble(iOpen(NULL,PERIOD_W1,0),_Digits) > 0)
     {
      ObjectCreate(linename, OBJ_HLINE, 0, TimeCurrent(),NormalizeDouble(iOpen(NULL,PERIOD_W1,0),_Digits));
      ObjectSet(linename, OBJPROP_STYLE, STYLE);
      ObjectSet(linename, OBJPROP_COLOR, COLOR);
      ObjectSet(linename, OBJPROP_WIDTH, WIDTH);
     }
   else
     {
      ObjectMove(linename, 0, TimeCurrent(),NormalizeDouble(iOpen(NULL,PERIOD_W1,0),_Digits));
     }
   if(ObjectFind(labelname) != 0 && NormalizeDouble(iOpen(NULL,PERIOD_W1,0),_Digits) > 0)
     {
      ObjectCreate(labelname, OBJ_TEXT, 0, iTime(NULL,0,WindowFirstVisibleBar()), NormalizeDouble(iOpen(NULL,PERIOD_W1,0),_Digits));
     }
   else
     {
      ObjectMove(labelname, 0, iTime(NULL,0,WindowFirstVisibleBar()), NormalizeDouble(iOpen(NULL,PERIOD_W1,0),_Digits));
     }
   prlabs =  "                                       "+"Weekly Open Price ";
   ObjectSetText(labelname, prlabs, 7, "Arial", COLOR);
  }
//HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH
void WLine2()
  {
   string labelname = "Weekly Open Time", linename = "Weekly Time";
   if(ObjectFind(linename) != 0)
     {
      ObjectCreate(linename, OBJ_VLINE, 0, iTime(NULL,PERIOD_W1,0),0);
      ObjectSet(linename, OBJPROP_STYLE, STYLE2);
      ObjectSet(linename, OBJPROP_COLOR, COLOR2);
      ObjectSet(linename, OBJPROP_WIDTH, WIDTH2);
     }
   else
     {
      ObjectMove(linename, 0, iTime(NULL,PERIOD_W1,0),0);
     }
  }
//HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH
//+------------------------------------------------------------+
//|  Partial Close                                             |
//+------------------------------------------------------------+
void HTP()
  {
   if(!Exit1)
     {
      return;
     }
   for(int cnt=0; cnt < OrdersTotal(); cnt++)
     {
      bool select=OrderSelect(cnt,SELECT_BY_POS,MODE_TRADES);
      int ticket=OrderTicket(), OrderTyp=OrderType();
      double OrderPr=OrderProfit(),Orderlots=OrderLots();

      if(OrderSymbol()==Symbol() && OrderMagicNumber()==MagicNumber)
        {
         if(OrderTyp==OP_BUY)
           {
            if(TakeProfit > 0 && OrderPr > TakeProfit)
              {
               PC(Orderlots,NormalizeDouble(Bid,Digits),OrderTicket());
              }
           }
         if(OrderTyp==OP_SELL)
           {
            if(TakeProfit > 0 && OrderPr > TakeProfit)
              {
               PC(Orderlots,NormalizeDouble(Ask,Digits),OrderTicket());
              }
           }
        }
     }
  }
//+-----------------------------------------------------------------------------------------------+
void PC(double ol, double cp, int ticket)
  {
   int err;
   if(OrderSelect(ticket, SELECT_BY_TICKET,MODE_TRADES))
     {
      if(OrderSymbol() == Symbol() && OrderType() <= 1)
        {
         bool modify = OrderClose(ticket, ol, cp, 0, clrGold);
         err = GetLastError();
         if(err!=ERR_NO_ERROR)
           {
            Print("Error on Partial closing = ", ErrorDescription(err));
           }
        }
     }
  }
//HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH
//+------------------------------------------------------------------+
//| Check $ Profit                                                   |
//+------------------------------------------------------------------+
double CheckProfit(int type) //-1= All,0=Buy,1=Sell;
  {
   double Profitb=0,Profitsl=0;
   for(int i=OrdersTotal()-1; i>=0; i--)
     {
      bool os = OrderSelect(i,SELECT_BY_POS);
      if(OrderSymbol()==Symbol() && OrderMagicNumber() == MagicNumber)
        {
         if(OrderType()==OP_BUY)
           {
            Profitb+=OrderProfit()+OrderSwap()+OrderCommission();
           }
         if(OrderType()==OP_SELL)
           {
            Profitsl+=OrderProfit()+OrderSwap()+OrderCommission();
           }
        }
     }
   if(0==type)
     {
      return(Profitb);
     }
   if(1==type)
     {
      return(Profitsl);
     }
   if(-1==type)
     {
      return(Profitsl+Profitb);
     }
   return(0);
  }
//HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH
//+------------------------------------------------------------------+
//| Get total order                                                  |
//+------------------------------------------------------------------+
int Orders(int type)
  {
   int count=0;
//-1= All,0=Buy,1=Sell,2=BuyLimit,3=SellLimit,4=BuyStop,5=SellStop,6=AllBuy,7=AllSell,8=AllMarket,9=AllPending;
   for(int x=OrdersTotal()-1; x>=0; x--)
     {
      if(OrderSelect(x,SELECT_BY_POS,MODE_TRADES))
        {
         if(OrderSymbol()==Symbol() && (MagicNumber == 0 || OrderMagicNumber() == MagicNumber))
           {
            if(type < 0)
              {
               count++;
              }
            if(OrderType() == type && type >= 0)
              {
               count++;
              }
            if(OrderType() <= 1 && type == 8)
              {
               count++;
              }
            if(OrderType() > 1 && type == 9)
              {
               count++;
              }
            if((OrderType() == 0 || OrderType() == 2 || OrderType() == 4) && type == 6)
              {
               count++;
              }
            if((OrderType() == 1 || OrderType() == 3 || OrderType() == 5) && type == 7)
              {
               count++;
              }
           }
        }
     }
   return(count);
  }
//HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH
//+------------------------------------------------------------+
//|  Close Orders                                              |
//+------------------------------------------------------------+
bool CloseOrders(int type)
  {
//-1= All,0=Buy,1=Sell,2=BuyLimit,3=SellLimit,4=BuyStop,5=SellStop,6=All Buys,7=All Sells,8=All Market,9=All Pending;
   bool oc=0;
   for(int i=OrdersTotal()-1; i >= 0; i--)
     {
      bool os = OrderSelect(i,SELECT_BY_POS, MODE_TRADES);
      if(OrderSymbol()==Symbol() && (MagicNumber==0 || OrderMagicNumber()==MagicNumber))
        {
         if(type==-1)
           {
            if(OrderType()==0)
              {
               oc = OrderClose(OrderTicket(),OrderLots(),Bid,1000,clrGold);
              }
            if(OrderType()==1)
              {
               oc = OrderClose(OrderTicket(),OrderLots(),Ask,1000,clrGold);
              }
            if(OrderType()>1)
              {
               oc = OrderDelete(OrderTicket());
              }
           }
         if(OrderType()>1 && type==9)
           {
            oc = OrderDelete(OrderTicket());
           }
         if(OrderType()<=1 && type==8)
           {
            oc = OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),1000,clrGold);
           }
         if(OrderType()==type && type==0)
           {
            oc = OrderClose(OrderTicket(),OrderLots(),Bid,1000,clrGold);
           }
         if(OrderType()==type && type==1)
           {
            oc = OrderClose(OrderTicket(),OrderLots(),Ask,1000,clrGold);
           }
         if(OrderType()==type && OrderType()> 1)
           {
            oc = OrderDelete(OrderTicket());
           }
         if(OrderType()==0 && type==6)
           {
            oc = OrderClose(OrderTicket(),OrderLots(),Bid,1000,clrGold);
           }
         if((OrderType()==2 || OrderType()== 4) && type==6)
           {
            oc = OrderDelete(OrderTicket());
           }
         if(OrderType()==1 && type==7)
           {
            oc = OrderClose(OrderTicket(),OrderLots(),Bid,1000,clrGold);
           }
         if((OrderType()==3 || OrderType()== 5) && type==7)
           {
            oc = OrderDelete(OrderTicket());
           }
         for(int x=0; x<100; x++)
           {
            if(ClosingArray[x]==0)
              {
               ClosingArray[x]=OrderTicket();
               break;
              }
           }
        }
     }
   return(oc);
  }
//HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH
//+----------------------------------------------------------------------------------+
//| Daily Profit                                                                     |
//+----------------------------------------------------------------------------------+
double DailyProfits()
  {
   int i;
   double LastDayProfits=0;
   for(i=0; i<OrdersHistoryTotal(); i++)
     {
      bool os = OrderSelect(i,SELECT_BY_POS,MODE_HISTORY);
      if(OrderMagicNumber()==MagicNumber && TimeDayOfYear(OrderCloseTime())==DayOfYear())
        {
         LastDayProfits=LastDayProfits+OrderProfit()+OrderSwap()+OrderCommission();
        }
     }
   for(i = 0; i < OrdersTotal(); i++)
     {
      bool Os = OrderSelect(i,SELECT_BY_POS, MODE_TRADES);
      if(OrderMagicNumber()==MagicNumber && TimeDayOfYear(OrderOpenTime())==DayOfYear())
        {
         LastDayProfits=LastDayProfits+OrderProfit()+OrderSwap()+OrderCommission();
        }
     }
   return(LastDayProfits);
  }
//HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH
//+----------------------------------------------------------------------------------+
//| Current Profit                                                                   |
//+----------------------------------------------------------------------------------+
double CurrentProfit()
  {
   double Profity=0;
   for(int i = 0; i < OrdersTotal(); i++)
     {
      bool Os = OrderSelect(i, SELECT_BY_POS, MODE_TRADES);
      if(OrderSymbol()==Symbol() && (MagicNumber == 0 || OrderMagicNumber() == MagicNumber))
        {
         Profity=Profity+OrderProfit()+OrderSwap()+OrderCommission();
        }
     }
   return(Profity);
  }
//HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH
//+------------------------------------------------------------------+
//| Check Pips Profit                                                |
//+------------------------------------------------------------------+
double CheckPipsProfit(int type) //-1= All,0=Buy,1=Sell;
  {
   double Profitb=0,Profitsl=0;
   for(int i=OrdersTotal()-1; i>=0; i--)
     {
      bool os = OrderSelect(i,SELECT_BY_POS);
      if(OrderSymbol()==Symbol() && OrderMagicNumber() == MagicNumber)
        {
         if(OrderType()==OP_BUY)
           {
            Profitb=Profitb+(((MarketInfo(OrderSymbol(),MODE_BID))-OrderOpenPrice())/pt());
           }
         if(OrderType()==OP_SELL)
           {
            Profitsl=Profitsl+((OrderOpenPrice()-MarketInfo(OrderSymbol(),MODE_ASK))/pt());
           }
        }
     }
   if(0==type)
     {
      return(Profitb);
     }
   if(1==type)
     {
      return(Profitsl);
     }
   if(-1==type)
     {
      return(Profitsl+Profitb);
     }
   return(0);
  }
//HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH
//+------------------------------------------------------------------+
//| Check Pips Profit                                                |
//+------------------------------------------------------------------+
double CheckPipsProfitH(int type) //-1= All,0=Buy,1=Sell;
  {
   double Profitb=0,Profits=0;
   for(int i=OrdersHistoryTotal()-1; i>=0; i--)
     {
      bool os = OrderSelect(i,SELECT_BY_POS,MODE_HISTORY);

      if(OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber)
        {
         if(OrderType() == OP_BUY && Otime <= OrderOpenTime())
           {
            Profitb=Profitb+((OrderClosePrice()-OrderOpenPrice())/pt());
           }
         if(OrderType() == OP_SELL && Otime <= OrderOpenTime())
           {
            Profits=Profits+((OrderOpenPrice()-OrderClosePrice())/pt());
           }
        }
     }
   if(0==type)
     {
      return(Profitb);
     }
   if(1==type)
     {
      return(Profits);
     }
   if(-1==type)
     {
      return(Profits+Profitb);
     }
   return(0);
  }
//+------------------------------------------------------------------+
double Profits(int type)
  {
   double count=0;
   for(int x=OrdersHistoryTotal()-1; x>=0; x--)
     {
      if(OrderSelect(x,SELECT_BY_POS,MODE_HISTORY))
        {
         if(OrderSymbol()==Symbol() && OrderMagicNumber()==MagicNumber)
           {
            if(type < 0)
              {
               count+=(OrderProfit()+OrderSwap()+OrderCommission());
              }
            if(type == 0 && OrderProfit() > 0)
              {
               count+=(OrderProfit()+OrderSwap()+OrderCommission());
              }
            if(type == 1 && OrderProfit() < 0)
              {
               count+=(OrderProfit()+OrderSwap()+OrderCommission());
              }
           }
        }
     }
   return(count);
  }
//+------------------------------------------------------------------+
int Total(int type)
  {
   int count=0;
   for(int x=OrdersHistoryTotal()-1; x>=0; x--)
     {
      if(OrderSelect(x, SELECT_BY_POS, MODE_HISTORY))
        {
         if(OrderSymbol()==Symbol() && OrderMagicNumber()==MagicNumber && OrderType()<= 1)
           {
            if(type < 0)
              {
               count++;
              }
            if(type == 0 && OrderProfit() > 0)
              {
               count++;
              }
            if(type == 1 && OrderProfit() <= 0)
              {
               count++;
              }
           }
        }
     }
   return(count);
  }
//HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH
//+----------------------------------------------------------------------------------+
//| Get Draw Down                                                                    |
//+----------------------------------------------------------------------------------+
double DrawDown()
  {
   double DD=AccountBalance()-AccountEquity();
   if(DD>DDBuffer)
      DDBuffer=DD;
   return(DDBuffer);
  }
//HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH
//+------------------------------------------------------------------+
//| Disable trade in current bar(if one is already open)             |
//+------------------------------------------------------------------+
bool CurrBar()
  {
   bool yes = 1;

   for(int i = OrdersTotal()-1; i >= 0; i--)
     {
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
        {
         if(OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber)
           {
            if(OrderOpenTime() >= iTime(Symbol(),0,0))
               yes = 0;
           }
        }
     }
   return(yes);
  }
//HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH
//+------------------------------------------------------------------+
//| Disable trade in current bar(if one is already opened and closed)|
//+------------------------------------------------------------------+
bool ClosedBar()
  {
   bool yes = 1;

   for(int i = OrdersHistoryTotal()-1; i>=0; i--)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_HISTORY)==false)
        {
         Print("Error in history!");
         break;
        }
      if(OrderSymbol() != Symbol() || OrderType()>OP_SELL)
         continue;
      if(OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber)
        {
         if(OrderOpenTime() >= iTime(NULL,0,0))
            yes = 0;
        }
     }
   return(yes);
  }
//HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH
//+------------------------------------------------------------------+
//|  Global Variable Set                                             |
//+------------------------------------------------------------------+
datetime GVSet(string name,double value)
  {
   return(GlobalVariableSet(prefix+name,value));
  }
//+------------------------------------------------------------------+
//|  Global Variable Get                                             |
//+------------------------------------------------------------------+
double GVGet(string name)
  {
   return(GlobalVariableGet(prefix+name));
  }
//+------------------------------------------------------------------+
//|  Global Variable Delete                                          |
//+------------------------------------------------------------------+
bool GVDel(string pref)
  {
   for(int tries=0; tries<10; tries++)
     {
      int obj=GlobalVariablesTotal();
      for(int o=0; o<obj; o++)
        {
         string name=GlobalVariableName(o);
         int index=StringFind(name,pref,0);
         if(index>-1)
            GlobalVariableDel(name);
        }
     }
   return(false);
  }
//HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH
//+------------------------------------------------------------------+
//| Check Symbol Points                                              |
//+------------------------------------------------------------------+
double pt(string symbol=NULL)
  {
   string sym=symbol;
   if(symbol==NULL)
      sym=Symbol();
   double bid=MarketInfo(sym,MODE_BID);
   int digits=(int)MarketInfo(sym,MODE_DIGITS);

   if(digits<=1)
      return(1); //CFD & Indexes
   if(digits==4 || digits==5)
      return(0.0001);
   if((digits==2 || digits==3) && bid>1000)
      return(1);
   if((digits==2 || digits==3) && bid<1000)
      return(0.01);
   if(StringFind(sym,"XAU")>-1 || StringFind(sym,"xau")>-1 || StringFind(sym,"GOLD")>-1)
      return(0.1);//Gold
   return(0);
  }
//HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH
//+------------------------------------------------------------------+
//| Trade Time Settings                                              |
//+------------------------------------------------------------------+
bool GoodTime()
  {
   int hs1 = StrToInteger(StringSubstr(Time_Start, 0, 2)), ms1 = StrToInteger(StringSubstr(Time_Start, 3, 2));
   int he1 = StrToInteger(StringSubstr(Time_End, 0, 2)), me1 = StrToInteger(StringSubstr(Time_End, 3, 2));

   if(!Use_Time_Filter)
      return(true);

   if(Use_Time_Filter && hs1 < he1)
     {
      if(((TimeHour(TimeCurrent()) == hs1 && TimeMinute(TimeCurrent()) >= ms1) && TimeHour(TimeCurrent()) < he1)
         || (TimeHour(TimeCurrent()) > hs1 && TimeHour(TimeCurrent()) < he1)
         || ((TimeMinute(TimeCurrent()) <= me1 && TimeHour(TimeCurrent()) == he1) && TimeHour(TimeCurrent()) > hs1)
         || (TimeHour(TimeCurrent()) < he1 && TimeHour(TimeCurrent()) > hs1))
         return(true);
     }
   if(Use_Time_Filter && hs1 > he1)
     {
      if((TimeHour(TimeCurrent()) == hs1 && TimeMinute(TimeCurrent()) >= ms1 && TimeHour(TimeCurrent()) < 24)
         || (TimeHour(TimeCurrent()) > hs1 && TimeHour(TimeCurrent()) < 24)
         || (TimeHour(TimeCurrent()) == he1 && TimeMinute(TimeCurrent()) <= me1 && TimeHour(TimeCurrent()) >= 0)
         || (TimeHour(TimeCurrent()) < he1 && TimeHour(TimeCurrent()) >= 0))
         return(true);
     }
   return(false);
  }
//HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH
//+------------------------------------------------------------------+
//| Print info to chart                                              |
//+------------------------------------------------------------------+
void PrintInfo()
  {
   if(!ShowInfo)
     {
      return;
     }
   string Current = "NO ORDER";
   double AvP = 0, AvL = 0, PP = 0, PL = 0;
   if(Profits(0)!=0)
     {
      AvP = Profits(0)/Total(0);
     }
   if(Profits(1)!=0)
     {
      AvL = Profits(1)/Total(1);
     }
   if(Total(0)!=0)
     {
      PP = Total(0)*100/Total(-1);
     }
   if(Total(1)!=0)
     {
      PL = Total(1)*100/Total(-1);
     }
   if(CurrentProfit()!=0)
     {
      Current = DoubleToStr(CurrentProfit(),2);
     }

   if(AccountBalance()!=0)
     {
      DrawDowns = DrawDown()*100.0/AccountBalance();
     }

   if(ShowInfo)
     {
      text[1]= EAComment;
      text[2]= "-------------------------------------------";
      text[3]= "Time Current: " + TimeToStr(TimeCurrent());
      text[4]= "-------------------------------------------";
      text[5]= "Account Number: " + IntegerToString(AccountNumber());
      text[6]= "Account Leverage: " + IntegerToString(AccountLeverage());
      text[7]= "Account Balance: " + DoubleToStr(AccountBalance(), 2);
      text[8]= "Account Equity: " + DoubleToStr(AccountEquity(), 2);
      text[9]= "Free Margin: " + DoubleToStr(AccountFreeMargin(), 2);
      text[10]= "Used Margin: " + DoubleToStr(AccountMargin(), 2);
      text[11]= "Max. Draw Down: " + DoubleToStr(DrawDown(), 2)+"("+DoubleToStr(DrawDowns,2)+"%"")";
      text[12]= "Account Today Profit: " + DoubleToStr(DailyProfits(), 2);
      text[13]= "-------------------------------------------";
      text[14]= "Total Trades: " + IntegerToString(Total(-1));
      text[15]= "Profitable Trades: " + IntegerToString(Total(0))+"("+DoubleToStr(PP,2)+"%"")";
      text[16]= "Average Profit: " + DoubleToStr(AvP,2);
      text[17]= "Losing  Trades: " + IntegerToString(Total(1))+"("+DoubleToStr(PL,2)+"%"")";
      text[18]= "Average Loss: " + DoubleToStr(AvL,2);
      text[19]= "Current Profit: " + Current;
      text[20]= "-------------------------------------------";

      int i=1, k=20;
      while(i<=25)
        {
         string ChartInfo = "Info"+IntegerToString(i);
         ObjectCreate(ChartInfo, OBJ_LABEL, 0, 0, 0);
         ObjectSetText(ChartInfo, text[i], 9, "Arial", Color_Info);
         ObjectSet(ChartInfo, OBJPROP_CORNER, Corner);
         ObjectSet(ChartInfo, OBJPROP_XDISTANCE, 7);
         ObjectSet(ChartInfo, OBJPROP_YDISTANCE, k);
         i++;
         k=k+13;
        }
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool Modification(string t)
  {
   bool a = true, b = true, c = true, d = true, e = true, f = true, g = true, h = true, i = true;
   if(Activate_Modification)
     {
      if(UseM1)
        {
         if(t == "buy" && iClose(_Symbol,PERIOD_M1,M1_Candle) < iOpen(_Symbol,PERIOD_M1,M1_Candle))
            a = false;
         if(t == "sell" && iClose(_Symbol,PERIOD_M1,M1_Candle) > iOpen(_Symbol,PERIOD_M1,M1_Candle))
            a = false;
        }

      if(UseM5)
        {
         if(t == "buy" && iClose(_Symbol,PERIOD_M5,M5_Candle) < iOpen(_Symbol,PERIOD_M5,M5_Candle))
            b = false;
         if(t == "sell" && iClose(_Symbol,PERIOD_M5,M5_Candle) > iOpen(_Symbol,PERIOD_M5,M5_Candle))
            b = false;
        }

      if(UseM15)
        {
         if(t == "buy" && iClose(_Symbol,PERIOD_M15,M15_Candle) < iOpen(_Symbol,PERIOD_M15,M15_Candle))
            c = false;
         if(t == "sell" && iClose(_Symbol,PERIOD_M15,M15_Candle) > iOpen(_Symbol,PERIOD_M15,M15_Candle))
            c = false;
        }

      if(UseM30)
        {
         if(t == "buy" && iClose(_Symbol,PERIOD_M30,M30_Candle) < iOpen(_Symbol,PERIOD_M30,M30_Candle))
            d = false;
         if(t == "sell" && iClose(_Symbol,PERIOD_M30,M30_Candle) > iOpen(_Symbol,PERIOD_M30,M30_Candle))
            d = false;
        }

      if(UseH1)
        {
         if(t == "buy" && iClose(_Symbol,PERIOD_H1,H1_Candle) < iOpen(_Symbol,PERIOD_H1,H1_Candle))
            e = false;
         if(t == "sell" && iClose(_Symbol,PERIOD_H1,H1_Candle) > iOpen(_Symbol,PERIOD_H1,H1_Candle))
            e = false;
        }

      if(UseH4)
        {
         if(t == "buy" && iClose(_Symbol,PERIOD_H4,H4_Candle) < iOpen(_Symbol,PERIOD_H4,H4_Candle))
            f = false;
         if(t == "sell" && iClose(_Symbol,PERIOD_H4,H4_Candle) > iOpen(_Symbol,PERIOD_H4,H4_Candle))
            f = false;
        }

      if(UseD1)
        {
         if(t == "buy" && iClose(_Symbol,PERIOD_D1,D1_Candle) < iOpen(_Symbol,PERIOD_D1,D1_Candle))
            g = false;
         if(t == "sell" && iClose(_Symbol,PERIOD_D1,D1_Candle) > iOpen(_Symbol,PERIOD_D1,D1_Candle))
            g = false;
        }

      if(UseW1)
        {
         if(t == "buy" && iClose(_Symbol,PERIOD_W1,W1_Candle) < iOpen(_Symbol,PERIOD_W1,W1_Candle))
            h = false;
         if(t == "sell" && iClose(_Symbol,PERIOD_W1,W1_Candle) > iOpen(_Symbol,PERIOD_W1,W1_Candle))
            h = false;
        }

      if(UseMN1)
        {
         if(t == "buy" && iClose(_Symbol,PERIOD_MN1,MN1_Candle) < iOpen(_Symbol,PERIOD_MN1,MN1_Candle))
            i = false;
         if(t == "sell" && iClose(_Symbol,PERIOD_MN1,MN1_Candle) > iOpen(_Symbol,PERIOD_MN1,MN1_Candle))
            i = false;
        }

      if(a&&b&&c&&d&&e&&f&&g&&h&&i)
         return true;
      else
         return false;
     }
   return true;
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int CountOrders(string t)
  {
   int k = 0;
   for(int x=OrdersTotal()-1; x>=0; x--)
     {
      if(OrderSelect(x,SELECT_BY_POS,MODE_TRADES))
        {
         if(OrderSymbol()==Symbol() && (MagicNumber == 0 || OrderMagicNumber() == MagicNumber))
           {
            if(OrderSelect(x,SELECT_BY_POS,MODE_TRADES))
              {
               if(t == "buy" && (OrderType() == OP_BUY || OrderType() == OP_BUYSTOP))
                  k++;
               if(t == "sell" && (OrderType() == OP_SELL || OrderType() == OP_SELLSTOP))
                  k++;
              }
           }
        }
     }
   return k;
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CloseAll()
  {
   RefreshRates();
   bool checkOrderClose = true;
   int index = OrdersTotal()-1;

   while(index >=0 && OrderSelect(index,SELECT_BY_POS,MODE_TRADES)==true)
     {
      if(OrderSymbol() == _Symbol)
         checkOrderClose = OrderClose(OrderTicket(), OrderLots(), OrderClosePrice(), 6, clrNONE);
      index--;
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CheckToClose()
  {
   if(UseSmartClosing)
     {
      SortBuyOrders();
      SortSellOrders();
      CloseTrade();
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CloseTrade()
  {
   double sp = SellProfit();
   double bp = BuyProfit();
   double lossprofit = 0;
   int cnt = 0, pos = 0, t = 0;

   if(Orders(0)+Orders(1) >= StartClosingOrders && StartClosingOrders != 0)
     {
      if(sp > 0)
        {
         for(int i=0; i<ArraySize(BuyPrice); i++)
           {
            t = PriceToTicket("buy",BuyPrice[i]);
            if(t != 0 && OrderSelect(t,SELECT_BY_TICKET) && OrderProfit() < 0)
              {
               if(lossprofit+MathAbs(OrderProfit()+OrderSwap()+OrderCommission()) < sp-MinProfit)
                 {
                  lossprofit = lossprofit+MathAbs(OrderProfit()+OrderSwap()+OrderCommission());
                  cnt++;
                 }
               else
                 {
                  pos = i;
                  break;
                 }
              }
           }
         if(cnt > 0)
           {
            if(ClosePartialBuy(pos) > 0)
              {
               CloseProfitSell();
               cnt = 0;
              }
           }
        }

      if(bp > 0)
        {
         for(int i=0; i<ArraySize(SellPrice); i++)
           {
            t = PriceToTicket("sell",SellPrice[i]);
            if(t != 0 && OrderSelect(t,SELECT_BY_TICKET) && OrderProfit() < 0)
              {
               if(lossprofit+MathAbs(OrderProfit()+OrderSwap()+OrderCommission()) < bp-MinProfit)
                 {
                  lossprofit = lossprofit+MathAbs(OrderProfit()+OrderSwap()+OrderCommission());
                  cnt++;
                 }
               else
                 {
                  pos = i;
                  break;
                 }
              }
           }
         if(cnt > 0)
           {
            if(ClosePartialSell(pos) > 0)
              {
               CloseProfitBuy();
               cnt = 0;
              }
           }
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void SortBuyOrders()
  {
   int c = Orders(0);
   if(c > 0)
     {
      ArrayResize(BuyPrice,c,0);
      int k = 0;
      for(int i=0; i<OrdersTotal(); i++)
        {
         if(OrderSelect(i,SELECT_BY_POS)==false)
            continue;
         if(OrderSymbol() == _Symbol && OrderType() == OP_BUY && OrderMagicNumber() == MagicNumber)
           {
            BuyPrice[k] = OrderOpenPrice();
            k++;
           }
        }
      ArraySort(BuyPrice,WHOLE_ARRAY,0,MODE_DESCEND);
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void SortSellOrders()
  {
   int c = Orders(1);
   if(c > 0)
     {
      ArrayResize(SellPrice,c,0);
      int k = 0;
      for(int i=0; i<OrdersTotal(); i++)
        {
         if(OrderSelect(i,SELECT_BY_POS)==false)
            continue;
         if(OrderSymbol() == _Symbol && OrderType() == OP_SELL && OrderMagicNumber() == MagicNumber)
           {
            SellPrice[k] = OrderOpenPrice();
            k++;
           }
        }
      ArraySort(SellPrice,WHOLE_ARRAY,0,MODE_ASCEND);
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double SellProfit()
  {
   double k = 0;
   for(int i=0; i<OrdersTotal(); i++)
     {
      if(OrderSelect(i,SELECT_BY_POS)==false)
         continue;
      if(OrderSymbol() == _Symbol && OrderType() == OP_SELL && OrderMagicNumber() == MagicNumber && OrderProfit() > 0)
         k = k+OrderProfit()+OrderSwap()+OrderCommission();
     }
   return k;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double BuyProfit()
  {
   double k = 0;
   for(int i=0; i<OrdersTotal(); i++)
     {
      if(OrderSelect(i,SELECT_BY_POS)==false)
         continue;
      if(OrderSymbol() == _Symbol && OrderType() == OP_BUY && OrderMagicNumber() == MagicNumber && OrderProfit() > 0)
         k = k+OrderProfit()+OrderSwap()+OrderCommission();
     }
   return k;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int ClosePartialSell(int k)
  {
   RefreshRates();
   bool checkOrderClose = true;
   int  t = 0;
   int j = 0;
   for(int i=0; i<k; i++)
     {
      t=PriceToTicket("sell",SellPrice[i]);
      if(t != 0 && OrderSelect(t,SELECT_BY_TICKET))
        {
         checkOrderClose = OrderClose(OrderTicket(), OrderLots(), OrderClosePrice(), 6, clrNONE);
         if(checkOrderClose)
            j++;
        }
     }
   return j;
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int ClosePartialBuy(int k)
  {
   RefreshRates();
   bool checkOrderClose = true;
   int t = 0;
   int j = 0;
   for(int i=0; i<k; i++)
     {
      t=PriceToTicket("buy",BuyPrice[i]);
      if(t != 0 && OrderSelect(t,SELECT_BY_TICKET))
        {
         checkOrderClose = OrderClose(OrderTicket(), OrderLots(), OrderClosePrice(), 6, clrNONE);
         if(checkOrderClose)
            j++;
        }
     }
   return j;
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int PriceToTicket(string t,double p)
  {
   RefreshRates();
   int index = OrdersTotal()-1;
   while(index >=0 && OrderSelect(index,SELECT_BY_POS,MODE_TRADES)==true)
     {
      if(OrderSymbol() == _Symbol && OrderMagicNumber() == MagicNumber)
        {
         if(OrderType() == OP_BUY && t == "buy" && OrderOpenPrice() == p)
            return OrderTicket();
         if(OrderType() == OP_SELL && t == "sell" && OrderOpenPrice() == p)
            return OrderTicket();
        }
      index--;
     }
   return 0;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CloseProfitSell()
  {
   RefreshRates();
   bool checkOrderClose = true;
   int index = OrdersTotal()-1;

   while(index >=0 && OrderSelect(index,SELECT_BY_POS,MODE_TRADES)==true)
     {
      if(OrderSymbol() == _Symbol && OrderMagicNumber() == MagicNumber)
        {
         if(OrderType() == OP_SELL && OrderProfit() > 0)
            checkOrderClose = OrderClose(OrderTicket(), OrderLots(), OrderClosePrice(), 6, clrNONE);
        }
      index--;
     }
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CloseProfitBuy()
  {
   RefreshRates();
   bool checkOrderClose = true;
   int index = OrdersTotal()-1;

   while(index >=0 && OrderSelect(index,SELECT_BY_POS,MODE_TRADES)==true)
     {
      if(OrderSymbol() == _Symbol && OrderMagicNumber() == MagicNumber)
        {
         if(OrderType() == OP_BUY && OrderProfit() > 0)
            checkOrderClose = OrderClose(OrderTicket(), OrderLots(), OrderClosePrice(), 6, clrNONE);
        }
      index--;
     }
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DeletePending(string t)
  {
   RefreshRates();
   bool checkOrderClose = true;
   int index = OrdersTotal()-1;
   while(index >=0 && OrderSelect(index,SELECT_BY_POS,MODE_TRADES)==true)
     {
      if(OrderSymbol() == _Symbol && OrderMagicNumber() == MagicNumber)
        {
         if(t == "buy" && (OrderType() == OP_BUYSTOP || OrderType() == OP_BUYLIMIT))
            OrderDelete(OrderTicket(),0);
         if(t == "sell" && (OrderType() == OP_SELLSTOP || OrderType() == OP_SELLLIMIT))
            OrderDelete(OrderTicket(),0);
        }
      index--;
     }
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH
//+------------------------------------------------------------------+
//| Errors Description                                               |
//+------------------------------------------------------------------+
string ErrorDescription(int error_code)
  {
   string error_string;
//---
   switch(error_code)
     {
      //--- codes returned from trade server
      case 0:
         error_string="no error";
         break;
      case 1:
         error_string="no error, trade conditions not changed";
         break;
      case 2:
         error_string="common error";
         break;
      case 3:
         error_string="invalid trade parameters";
         break;
      case 4:
         error_string="trade server is busy";
         break;
      case 5:
         error_string="old version of the client terminal";
         break;
      case 6:
         error_string="no connection with trade server";
         break;
      case 7:
         error_string="not enough rights";
         break;
      case 8:
         error_string="too frequent requests";
         break;
      case 9:
         error_string="malfunctional trade operation (never returned error)";
         break;
      case 64:
         error_string="account disabled";
         break;
      case 65:
         error_string="invalid account";
         break;
      case 128:
         error_string="trade timeout";
         break;
      case 129:
         error_string="invalid price";
         break;
      case 130:
         error_string="invalid stops";
         break;
      case 131:
         error_string="invalid trade volume";
         break;
      case 132:
         error_string="market is closed";
         break;
      case 133:
         error_string="trade is disabled";
         break;
      case 134:
         error_string="not enough money";
         break;
      case 135:
         error_string="price changed";
         break;
      case 136:
         error_string="off quotes";
         break;
      case 137:
         error_string="broker is busy (never returned error)";
         break;
      case 138:
         error_string="requote";
         break;
      case 139:
         error_string="order is locked";
         break;
      case 140:
         error_string="long positions only allowed";
         break;
      case 141:
         error_string="too many requests";
         break;
      case 145:
         error_string="modification denied because order is too close to market";
         break;
      case 146:
         error_string="trade context is busy";
         break;
      case 147:
         error_string="expirations are denied by broker";
         break;
      case 148:
         error_string="amount of open and pending orders has reached the limit";
         break;
      case 149:
         error_string="hedging is prohibited";
         break;
      case 150:
         error_string="prohibited by FIFO rules";
         break;
      //--- mql4 errors
      case 4000:
         error_string="no error (never generated code)";
         break;
      case 4001:
         error_string="wrong function pointer";
         break;
      case 4002:
         error_string="array index is out of range";
         break;
      case 4003:
         error_string="no memory for function call stack";
         break;
      case 4004:
         error_string="recursive stack overflow";
         break;
      case 4005:
         error_string="not enough stack for parameter";
         break;
      case 4006:
         error_string="no memory for parameter string";
         break;
      case 4007:
         error_string="no memory for temp string";
         break;
      case 4008:
         error_string="non-initialized string";
         break;
      case 4009:
         error_string="non-initialized string in array";
         break;
      case 4010:
         error_string="no memory for array\' string";
         break;
      case 4011:
         error_string="too long string";
         break;
      case 4012:
         error_string="remainder from zero divide";
         break;
      case 4013:
         error_string="zero divide";
         break;
      case 4014:
         error_string="unknown command";
         break;
      case 4015:
         error_string="wrong jump (never generated error)";
         break;
      case 4016:
         error_string="non-initialized array";
         break;
      case 4017:
         error_string="dll calls are not allowed";
         break;
      case 4018:
         error_string="cannot load library";
         break;
      case 4019:
         error_string="cannot call function";
         break;
      case 4020:
         error_string="expert function calls are not allowed";
         break;
      case 4021:
         error_string="not enough memory for temp string returned from function";
         break;
      case 4022:
         error_string="system is busy (never generated error)";
         break;
      case 4023:
         error_string="dll-function call critical error";
         break;
      case 4024:
         error_string="internal error";
         break;
      case 4025:
         error_string="out of memory";
         break;
      case 4026:
         error_string="invalid pointer";
         break;
      case 4027:
         error_string="too many formatters in the format function";
         break;
      case 4028:
         error_string="parameters count is more than formatters count";
         break;
      case 4029:
         error_string="invalid array";
         break;
      case 4030:
         error_string="no reply from chart";
         break;
      case 4050:
         error_string="invalid function parameters count";
         break;
      case 4051:
         error_string="invalid function parameter value";
         break;
      case 4052:
         error_string="string function internal error";
         break;
      case 4053:
         error_string="some array error";
         break;
      case 4054:
         error_string="incorrect series array usage";
         break;
      case 4055:
         error_string="custom indicator error";
         break;
      case 4056:
         error_string="arrays are incompatible";
         break;
      case 4057:
         error_string="global variables processing error";
         break;
      case 4058:
         error_string="global variable not found";
         break;
      case 4059:
         error_string="function is not allowed in testing mode";
         break;
      case 4060:
         error_string="function is not confirmed";
         break;
      case 4061:
         error_string="send mail error";
         break;
      case 4062:
         error_string="string parameter expected";
         break;
      case 4063:
         error_string="integer parameter expected";
         break;
      case 4064:
         error_string="double parameter expected";
         break;
      case 4065:
         error_string="array as parameter expected";
         break;
      case 4066:
         error_string="requested history data is in update state";
         break;
      case 4067:
         error_string="internal trade error";
         break;
      case 4068:
         error_string="resource not found";
         break;
      case 4069:
         error_string="resource not supported";
         break;
      case 4070:
         error_string="duplicate resource";
         break;
      case 4071:
         error_string="cannot initialize custom indicator";
         break;
      case 4072:
         error_string="cannot load custom indicator";
         break;
      case 4073:
         error_string="no history data";
         break;
      case 4074:
         error_string="not enough memory for history data";
         break;
      case 4075:
         error_string="not enough memory for indicator";
         break;
      case 4099:
         error_string="end of file";
         break;
      case 4100:
         error_string="some file error";
         break;
      case 4101:
         error_string="wrong file name";
         break;
      case 4102:
         error_string="too many opened files";
         break;
      case 4103:
         error_string="cannot open file";
         break;
      case 4104:
         error_string="incompatible access to a file";
         break;
      case 4105:
         error_string="no order selected";
         break;
      case 4106:
         error_string="unknown symbol";
         break;
      case 4107:
         error_string="invalid price parameter for trade function";
         break;
      case 4108:
         error_string="invalid ticket";
         break;
      case 4109:
         error_string="trade is not allowed in the expert properties";
         break;
      case 4110:
         error_string="longs are not allowed in the expert properties";
         break;
      case 4111:
         error_string="shorts are not allowed in the expert properties";
         break;
      case 4200:
         error_string="object already exists";
         break;
      case 4201:
         error_string="unknown object property";
         break;
      case 4202:
         error_string="object does not exist";
         break;
      case 4203:
         error_string="unknown object type";
         break;
      case 4204:
         error_string="no object name";
         break;
      case 4205:
         error_string="object coordinates error";
         break;
      case 4206:
         error_string="no specified subwindow";
         break;
      case 4207:
         error_string="graphical object error";
         break;
      case 4210:
         error_string="unknown chart property";
         break;
      case 4211:
         error_string="chart not found";
         break;
      case 4212:
         error_string="chart subwindow not found";
         break;
      case 4213:
         error_string="chart indicator not found";
         break;
      case 4220:
         error_string="symbol select error";
         break;
      case 4250:
         error_string="notification error";
         break;
      case 4251:
         error_string="notification parameter error";
         break;
      case 4252:
         error_string="notifications disabled";
         break;
      case 4253:
         error_string="notification send too frequent";
         break;
      case 4260:
         error_string="ftp server is not specified";
         break;
      case 4261:
         error_string="ftp login is not specified";
         break;
      case 4262:
         error_string="ftp connect failed";
         break;
      case 4263:
         error_string="ftp connect closed";
         break;
      case 4264:
         error_string="ftp change path error";
         break;
      case 4265:
         error_string="ftp file error";
         break;
      case 4266:
         error_string="ftp error";
         break;
      case 5001:
         error_string="too many opened files";
         break;
      case 5002:
         error_string="wrong file name";
         break;
      case 5003:
         error_string="too long file name";
         break;
      case 5004:
         error_string="cannot open file";
         break;
      case 5005:
         error_string="text file buffer allocation error";
         break;
      case 5006:
         error_string="cannot delete file";
         break;
      case 5007:
         error_string="invalid file handle (file closed or was not opened)";
         break;
      case 5008:
         error_string="wrong file handle (handle index is out of handle table)";
         break;
      case 5009:
         error_string="file must be opened with FILE_WRITE flag";
         break;
      case 5010:
         error_string="file must be opened with FILE_READ flag";
         break;
      case 5011:
         error_string="file must be opened with FILE_BIN flag";
         break;
      case 5012:
         error_string="file must be opened with FILE_TXT flag";
         break;
      case 5013:
         error_string="file must be opened with FILE_TXT or FILE_CSV flag";
         break;
      case 5014:
         error_string="file must be opened with FILE_CSV flag";
         break;
      case 5015:
         error_string="file read error";
         break;
      case 5016:
         error_string="file write error";
         break;
      case 5017:
         error_string="string size must be specified for binary file";
         break;
      case 5018:
         error_string="incompatible file (for string arrays-TXT, for others-BIN)";
         break;
      case 5019:
         error_string="file is directory, not file";
         break;
      case 5020:
         error_string="file does not exist";
         break;
      case 5021:
         error_string="file cannot be rewritten";
         break;
      case 5022:
         error_string="wrong directory name";
         break;
      case 5023:
         error_string="directory does not exist";
         break;
      case 5024:
         error_string="specified file is not directory";
         break;
      case 5025:
         error_string="cannot delete directory";
         break;
      case 5026:
         error_string="cannot clean directory";
         break;
      case 5027:
         error_string="array resize error";
         break;
      case 5028:
         error_string="string resize error";
         break;
      case 5029:
         error_string="structure contains strings or dynamic arrays";
         break;
      default:
         error_string="unknown error";
     }
//---
   return(error_string);
  }
//HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH
