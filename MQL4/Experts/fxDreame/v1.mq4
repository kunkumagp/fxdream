//+------------------------------------------------------------------+
//|                                                           v1.mq4 |
//|                        Copyright 2021, MetaQuotes Software Corp. |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, MetaQuotes Software Corp."
#property link      ""
#property version   "1.00"
#property strict
#include <fxDreame/fxDreameIncludes.mqh>


sinput string lot_header=" ------ Settings about Lot size and type ------ ";// ------------------ 
enum lotSizeType{
   fix = 1,//Fix Lot Size
   dynamic = 2,//Dynamic
};
input lotSizeType lots_type = dynamic;//Lots Type

input double lot_size = 0.01;//Lot Size
input int max_trade_count = 5;//Max Trade Count
input int trade_gap = 300;//Differance of pips 

sinput string buy_trade_header=" ------ Settings about Buy Trades ------ ";// ------------------ 

input bool allow_buy_trade = true; //Allow Buy Trades
input bool buy_tp = true;//Allow Take Profit for Buy Trades
input int buy_tp_Count = 10;// Take Profit for Buy trades
input bool buy_sl = false;//Allow Stop Loss for Buy Trades
input int buy_sl_Count = 30;// Stop Loss for Buy trades

sinput string sell_trade_header=" ------ Settings about Sell Trades ------ ";// ------------------ 

input bool allow_sell_trade = true;//Allow Sell Trades
input bool sell_tp = true;//Allow Take Profit for Sell Trades
input int sell_tp_Count = 10;// Take Profit for Sell trades
input bool sell_sl = false;//Allow Stop Loss for Sell Trades
input int sell_sl_Count = 30;// Stop Loss for Sell trades

sinput string ma_signal_header=" ------ Moving Avarage Signal Selection ------ ";// ------------------ 

input bool allow_period_1 = true;//Allow 1st Period
input bool period_1 = 10;//1st Period

input bool allow_period_2 = true;//Allow 2st Period
input bool period_2 = 21;//2st Period

input bool allow_period_3 = false;//Allow 3st Period
input bool period_3 = 0;//3st Period

input bool allow_period_4 = false;//Allow 4st Period
input bool period_4 = 0;//4st Period


enum timeFrames{
      current = PERIOD_CURRENT,//PERIOD_CURRENT
      m1 = PERIOD_M1,//PERIOD_M1
      m5 = PERIOD_M5,//PERIOD_M5
      m15 = PERIOD_M15,//PERIOD_M15
      m30 = PERIOD_M30,//PERIOD_M30
      h1 = PERIOD_H1,//PERIOD_H1
      h4 = PERIOD_H4,//PERIOD_H4
      d1 = PERIOD_D1,//PERIOD_D1
      w1 = PERIOD_W1,//PERIOD_W1
      mn1 = PERIOD_MN1,//PERIOD_MN1
   };

input timeFrames time_frame = m15;//Selected Time Frame

string nextLine = "\n";

double stopLossPrice;
double takeProfitPrice;

void OnTick()
  {
      string ma_signal = moving_avarage(time_frame);
      string status = "";

      if(ma_signal == "BUY"){
        if(checkForOpening(max_trade_count,trade_gap) == "YES"){

          buy_sl == true ? stopLossPrice = CalculateStopLoss(true,Ask,buy_sl_Count) : stopLossPrice = NULL ;
          buy_tp == true ? takeProfitPrice = CalculateTakeProfit(true,Ask,buy_tp_Count) : takeProfitPrice = NULL ;

          OrderSend(_Symbol,OP_BUY,lot_size,Ask,3,stopLossPrice,takeProfitPrice,NULL,0,0,Green);
        }
      } else if(ma_signal == "SELL"){
        if(checkForOpening(max_trade_count,trade_gap) == "YES"){
          
          buy_sl == true ? stopLossPrice = CalculateStopLoss(false,Bid,sell_sl_Count) : stopLossPrice = NULL ;
          buy_tp == true ? takeProfitPrice = CalculateTakeProfit(false,Bid,sell_tp_Count) : takeProfitPrice = NULL ;

          OrderSend(_Symbol,OP_SELL,lot_size,Bid,3,stopLossPrice,takeProfitPrice,NULL,0,0,Red);
        }
      } 
   
  }

string moving_avarage(int timeFrame)
  {
    string signal="";
    double currentPrice = Close[0];

    double previousCandleP5 = getMAValue(5,1);
    double currentCandleP5 = getMAValue(5,0);

    double previousCandleP20 = getMAValue(20,1);
    double currentCandleP20 = getMAValue(20,0);

    if(
      previousCandleP20 > previousCandleP5 && 
      currentCandleP20 < currentCandleP5
    ){
      double currentCandleP50 = getMAValue(50,0);
      if(
        currentCandleP50 < currentCandleP5 &&
        currentCandleP50 < currentCandleP20 &&
        currentCandleP50 < currentPrice
      ){
        signal = "BUY";
      }
    } else if(
      previousCandleP20 < previousCandleP5 && 
      currentCandleP20 > currentCandleP5
    ){
      double currentCandleP50 = getMAValue(50,0);
      if(
        currentCandleP50 > currentCandleP5 &&
        currentCandleP50 > currentCandleP20 &&
        currentCandleP50 > currentPrice
      ){
        signal = "SELL";
      }
    } else {
        signal = "";
    }

    return signal;

  }

double getMAValue(int period, int candle)
  {
      return BankersRound(iMA(_Symbol,PERIOD_M30,period,0,MODE_EMA,PRICE_CLOSE,candle),5);
  }
