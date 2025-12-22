//+------------------------------------------------------------------+
//| Sentinel                                                          |
//+------------------------------------------------------------------+
#property strict

#include <Files\File.mqh>   // For CSV logging

input int FastEMA = 47;
input int SlowEMA = 179;
input double LotSize = 1.0;
input int StopLoss = 974;    // Stop Loss in points
input int TakeProfit = 599;  // Take Profit in points
input bool TestMode = true;
input bool OneTradeAtATime = true;
input int CooldownMinutes = 5;

datetime LastTradeTime = 0;
string LogFile = "Sentinel_Log.csv";

// EMA handles
int fastHandle;
int slowHandle;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
   // Create EMA handles
   fastHandle = iMA(_Symbol, PERIOD_M1, FastEMA, 0, MODE_EMA, PRICE_CLOSE);
   slowHandle = iMA(_Symbol, PERIOD_M1, SlowEMA, 0, MODE_EMA, PRICE_CLOSE);

   if(fastHandle == INVALID_HANDLE || slowHandle == INVALID_HANDLE)
   {
      Print("Failed to create EMA handles");
      return(INIT_FAILED);
   }

   
   if(!FileIsExist(LogFile))
   {
      int handle = FileOpen(LogFile, FILE_WRITE|FILE_CSV);
      if(handle != INVALID_HANDLE)
      {
         FileWrite(handle, "Time","Symbol","Type","Price","SL","TP","FastEMA","SlowEMA","Reason");
         FileClose(handle);
      }
   }

   Print("Sentinel initialized");
   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
   double fastBuffer[2], slowBuffer[2];

   // Copy last 2 EMA values (current and previous)
   if(CopyBuffer(fastHandle, 0, 0, 2, fastBuffer) <= 0) return;
   if(CopyBuffer(slowHandle, 0, 0, 2, slowBuffer) <= 0) return;

   double FastCurr = fastBuffer[0];
   double FastPrev = fastBuffer[1];
   double SlowCurr = slowBuffer[0];
   double SlowPrev = slowBuffer[1];

   // Check cooldown
   if(TimeCurrent() - LastTradeTime < CooldownMinutes * 60)
      return;

   // Check open trades
   if(OneTradeAtATime && PositionsTotal() > 0)
      return;

   // Entry conditions
   if(FastPrev < SlowPrev && FastCurr > SlowCurr)
   {
      OpenTrade(ORDER_TYPE_BUY, FastCurr, SlowCurr, "EMA crossover BUY");
   }
   else if(FastPrev > SlowPrev && FastCurr < SlowCurr)
   {
      OpenTrade(ORDER_TYPE_SELL, FastCurr, SlowCurr, "EMA crossover SELL");
   }
}

//+------------------------------------------------------------------+
//| Open Trade Function with logging & error handling               |
//+------------------------------------------------------------------+
void OpenTrade(int type, double fastVal, double slowVal, string reason)
{
   double price = (type == ORDER_TYPE_BUY) ? SymbolInfoDouble(_Symbol, SYMBOL_ASK) : SymbolInfoDouble(_Symbol, SYMBOL_BID);
   double sl = (type == ORDER_TYPE_BUY) ? price - StopLoss*_Point : price + StopLoss*_Point;
   double tp = (type == ORDER_TYPE_BUY) ? price + TakeProfit*_Point : price - TakeProfit*_Point;

   string typeStr = (type==ORDER_TYPE_BUY?"BUY":"SELL");

   // Log the decision
   LogTrade(TimeToString(TimeCurrent(), TIME_DATE|TIME_SECONDS), _Symbol, typeStr, price, sl, tp, fastVal, slowVal, reason);

   if(TestMode)
   {
      Print("TestMode: ", typeStr, " | Price: ", price, " SL: ", sl, " TP: ", tp, " Reason: ", reason);
      LastTradeTime = TimeCurrent();
      return;
   }

   // Prepare trade request
   MqlTradeRequest request;
   MqlTradeResult result;
   ZeroMemory(request);
   ZeroMemory(result);

   request.action = TRADE_ACTION_DEAL;
   request.symbol = _Symbol;
   request.volume = LotSize;
   request.type = (ENUM_ORDER_TYPE)type;
   request.price = price;
   request.sl = sl;
   request.tp = tp;
   request.deviation = 10;

   if(!OrderSend(request, result))
   {
      Print("OrderSend failed: ", result.retcode);
      LogTrade(TimeToString(TimeCurrent(), TIME_DATE|TIME_SECONDS), _Symbol, typeStr, price, sl, tp, fastVal, slowVal, "OrderSend failed: "+IntegerToString(result.retcode));
   }
   else
   {
      LastTradeTime = TimeCurrent();
      Print(typeStr," order placed successfully at ", price);
   }
}

//+------------------------------------------------------------------+
//| Logging function to CSV                                           |
//+------------------------------------------------------------------+
void LogTrade(string time, string symbol, string type, double price, double sl, double tp, double fast, double slow, string reason)
{
   int handle = FileOpen(LogFile, FILE_READ|FILE_WRITE|FILE_CSV);
   if(handle != INVALID_HANDLE)
   {
      FileSeek(handle, 0, SEEK_END);
      FileWrite(handle, time, symbol, type, DoubleToString(price,_Digits), DoubleToString(sl,_Digits), DoubleToString(tp,_Digits), fast, slow, reason);
      FileClose(handle);
   }
}
