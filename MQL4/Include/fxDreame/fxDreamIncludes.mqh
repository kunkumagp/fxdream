//+------------------------------------------------------------------+
//|                                              fxDreamIncludes.mqh |
//|                        Copyright 2021, MetaQuotes Software Corp. |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, MetaQuotes Software Corp."
#property link      ""
#property strict


double GetStopLossPrice(bool isLongPosition, double entryPrice, int maxLossInPips)
{
   double stopLossPrice;
   double pipValue = GetPipValue();
   
   if(isLongPosition) //if i am in long position
   {
      stopLossPrice = entryPrice - maxLossInPips * pipValue;
   }
   else //if i am in short position
   {
      stopLossPrice = entryPrice + maxLossInPips * pipValue;
   }
   
   return stopLossPrice;
}

double GetPipValue()
{

   double returnValue;
   //if(_Digits < 4){returnValue = 0.01;}
   //if(_Digits == 4){returnValue = 0.0001;}
   //if(_Digits == 5){returnValue = 0.00001;}
   
   if(_Digits >= 4)
   {
      returnValue = 0.0001;
   }
   else
   {
      returnValue = 0.01;
   }
   
   return returnValue;
   
}

double GetLotSizeForTrade()
{
   double accountBalance = AccountBalance();
   double lotSize = accountBalance * GetPipValue();
   
   return lotSize;
}


double CalculateTakeProfit(bool isLong, double entryPrice, int pips)
{
   double takeProfitPrice;
   
   if(isLong)
   {
      takeProfitPrice = entryPrice + pips * GetPipValue();
   }
   else
   {
      takeProfitPrice = entryPrice - pips * GetPipValue();
   }
   
   return takeProfitPrice;
}

double CalculateStopLoss(bool isLong, double entryPrice, int pips)
{
   double stopLossPrice ;
    if(isLong)
   {
      stopLossPrice = entryPrice - pips * GetPipValue();
   }
   else
   {
      stopLossPrice = entryPrice + pips * GetPipValue();
   }
   
   return stopLossPrice;
   
}

double BankersRound(double value, int precision) {
   value = value * MathPow(10, precision);
   if (MathCeil(value) - value == 0.5 && value - MathFloor(value) == 0.5) {   // also could use: MathCeil(value) - value == value - MathFloor(value)
      if (MathMod(MathCeil(value), 2) == 0)
         return (MathCeil(value) / MathPow(10, precision));
      else  
         return (MathFloor(value) / MathPow(10, precision));
   }
   return (MathRound(value) / MathPow(10, precision));
}

string checkForOpening(int maxTradeCount, int tradeGap){

   double currentPrice;
   string status = "";
   if( OrdersTotal() == 0 ){
      status = "YES";
   } else if( OrdersTotal() < maxTradeCount ){
      double lastPrice = getLastOpenTradePrice();
      int pipDiff = MathAbs( currentPrice - lastPrice )/_Point;
      if( pipDiff > tradeGap ){
         status = "YES";
      } else {
         status = "NO";
      }
   } else {
      status = "NO";
   }

   return status;
}

string getLastOpenTradePrice() {

   double openedtrades=0;
   double breakeven_price;
   double total_average_price;
   double lastopenprice;
   int total_lots;
   datetime timeOrderOpen = 0;
   for (int i=0; i<OrdersTotal(); i++) {
      if (!OrderSelect(i,SELECT_BY_POS)) continue;
      if (OrderSymbol()!=Symbol()) continue;
      if( OrderType()!=ORDER_TYPE_BUY && OrderType()!=ORDER_TYPE_SELL ) continue;

      openedtrades++;
      total_average_price+=(OrderOpenPrice()*OrderLots());
      total_lots+=OrderLots();
      breakeven_price=(total_average_price/total_lots);

      if(timeOrderOpen > OrderOpenTime()) continue;
      timeOrderOpen = OrderOpenTime();

      
      lastopenprice=OrderOpenPrice();
      
   }
   return lastopenprice;
}
