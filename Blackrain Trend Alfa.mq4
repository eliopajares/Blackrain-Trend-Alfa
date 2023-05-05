//+-------------------------------------------+
//|                  Blackrain Trend Alfa     |
//|                 Property of: Elio Pajares |
//|                   v0.0.1   17 - 04 - 2023 |
//+-------------------------------------------+
#property description "Blackrain Trend Alfa"
#property copyright "Copyright © 2023, Elio Pajares"
// #property link        "http://www.blackrainalgo.com"

//+------------------------------------------------------------------+
//| DESCRIPTION                                                      |
//+------------------------------------------------------------------+

// ##########################################
// ## Walk Forward Pro Header Start (MQL4) ##
// ##########################################
#import "TSMWFP.ex4"
void WFA_Initialise();
void WFA_UpdateValues();
void WFA_PerformCalculations(double &dCustomPerformanceCriterion);
#import
// ########################################
// ## Walk Forward Pro Header End (MQL4) ##
// ########################################

//+------------------------------------------------------------------+
//| INPUT PARAMETERS                                                 |
//+------------------------------------------------------------------+

input int magic_number = 12345; // change magic number when same EA used in the same account to avoid overlap issues with open orders
// input string pair          = "EURUSD"; //currency pair

extern string data_1 = "==== SL, TP, TS ====";
input bool AllowOrders = true;
input int orders = 1;
input int spread = 20; // value in points
// input double   StopLoss      = 20; // SL is used Lotsize calculation via % balance at risk
// input double   TakeProfit    = 40; // TP is unlimited
input ENUM_TIMEFRAMES LOW_TF = PERIOD_H1;
input ENUM_TIMEFRAMES MED_TF = PERIOD_H4;
input ENUM_TIMEFRAMES HIGH_TF = PERIOD_D1;
input int time_between_trades = 3600; // value in seconds of the time between a loss trade and a new one,  -1 for not using this

extern string data_2 = "==== Management of trade setup ====";
input bool MANAGEMENT_TRADE = false;
input bool breakeven_trade = false;
input bool close_trade = false; //
// input int      rsi_inv_upper    = 10;
// input int      rsi_inv_lower    = 90;
input int stoch_invalidation_upper = 80;
input int stoch_invalidation_lower = 20;
// input int      pips_invalidation= 5;
input bool TRAILING = false;      //
input bool trailing_pips = false; //
input double TrailingStop = 20;   //
input bool trailing_RR = false;   //
input double TS_RRratio_step = 2; // TS step in regards RR ratio
input double TS_RRratio_sl = 1;   // TS stoploss distance in regards RR ratio
input bool CloseOnDuration = false;
input int MaxDurationHours = 1000; // in hours
input int MaxDurationMin = 0;      // in minutes
input bool CloseFridays = false;
// input bool     retrace         = false;
// input double   PipsStick     = 40;
// input double   PipsRetrace   = 20;

extern string data_3 = "==== Money management ====";
input double Lots = 0.1;
input bool MM = true;
input double Risk = 0.25;
input double RR = 3;
input double addtional_SL_pips = 0;
input double maxlots = 1;

extern string data_4 = "==== EMA parameters ====";
input int EMA_Fast = 10;
input int EMA_Slow = 20;
input int macd_signal = 7;

// input          ENUM_TIMEFRAMES LOW_TF = PERIOD_M5;
// input int      MA_count      = 8;
// input int      MA_Period_H1  = 7;

// extern string  data_5 = "==== RSI parameters ====";
// input int      RSIperiod      = 7; //RSI period
////input int      RSIUpper       = 70; // RSI Upper limit
////input int      RSILower       = 30; // RSI Lower limit
// input int      RSI_range      = 30;

extern string data_5 = "==== Stochastic parameters ====";
input int KPeriod = 14; // K Period
input int DPeriod = 7;  // D Period
input int Slowing = 9;  // Slowing value
// input int      StochUpper     = 70; // Stochastic Upper limit
// input int      StochLower     = 30; // Stochastic Lower limit
input int Stoch_range_low = 30;
input int Stoch_range_med = 20;

// extern string data_6 = "==== SAR parameters ====";
// input double SAR_step_low = 0.04;   // SAR Step parameter
// input double SAR_step_med = 0.04;   // SAR Step parameter
// input double SAR_step_high = 0.005; // SAR Step parameter
// input double SAR_max = 0.2;         // SAR max parameter

extern string data_7 = "==== Days to Trade ====";
input bool Sunday = true;
input bool Monday = true;
input bool Tuesday = true;
input bool Wednesday = true;
input bool Thursday = true;
input bool Friday = true;

extern string data_8 = "==== Hours to Trade ====";
input int StartHourTrade = 0; // 0 for beginning of the day
input int EndHourTrade = 23;  // 23 for end of the day

extern string data_9 = "==== Days to Trade ====";
input bool January = true;
input bool February = true;
input bool March = true;
input bool April = true;
input bool May = true;
input bool June = true;
input bool July = true;
input bool August = true;
input bool September = true;
input bool October = true;
input bool November = true;
input bool December = true;

// extern string data_6 = "==== News ====";
// input bool   ActivateNews      = false;
// input int    MinsBeforeNews    = 60;
// input int    MinsAfterNews     = 60;
// input bool   IncludeHighNews   = true;
// input bool   IncludeMediumNews = false;
// input bool   IncludeLowNews    = false;
// input bool   IncludeSpeakNews  = true;
// input bool   IncludeHolidays   = false;
// input int    DSTOffsetHours    = 0;

//+------------------------------------------------------------------+
//| DECLARATION OF VARIABLES                                         |
//+------------------------------------------------------------------+

// int CurrentTime;
int Slippage = 3;
int vSlippage;
int ticket;
int total;
// int count_1,count_2;
int current_spread;
// int RSIUpper,RSILower;
int StochUpper_low, StochLower_low;
int StochUpper_med, StochLower_med;

double LotDigits = 2;
double vPoint;
double stochastic_low_0_main, stochastic_low_1_main;
double stochastic_low_0_signal, stochastic_low_1_signal;
double stochastic_med_0_main, stochastic_med_1_main;
double stochastic_med_0_signal, stochastic_med_1_signal;
double ma_low_20_0, ma_low_20_1, ma_low_20_2;
double macd_main_low_0, macd_main_low_1, macd_main_low_2, macd_signal_low_0, macd_signal_low_1, macd_signal_low_2;
double open_low_20_0, open_low_20_1;
double close_low_20_0, close_low_20_1;
double SL, TP, diff;
// string data_parameters;
// string data_news;
//
// bool NewsTime;
// bool OpenBar;

//+------------------------------------------------------------------+
//|  INIT FUNCTION                                                   |
//+------------------------------------------------------------------+

int OnInit()
{

   // ## Walk Forward Pro OnInit() code start (MQL4) ##
   if (MQLInfoInteger(MQL_TESTER))
      WFA_Initialise();
   // ## Walk Forward Pro OnInit() code end (MQL4) ##

   // CurrentTime= Time[0];

   //+------------------------------------------------------------------+
   //|  Detect 3/5 digit brokers for Point and Slippage                 |
   //+------------------------------------------------------------------+

   if (Point == 0.00001)
   {
      vPoint = 0.0001;
      vSlippage = Slippage * 10;
   }
   else
   {
      if (Point == 0.001)
      {
         vPoint = 0.01;
         vSlippage = Slippage * 10;
      }
      else
         vPoint = Point;
      vSlippage = Slippage;
   }

   StochUpper_low = 100 - Stoch_range_low;
   StochLower_low = Stoch_range_low;

   StochUpper_med = 100 - Stoch_range_med;
   StochLower_med = Stoch_range_med;

   return (0);
}

//+------------------------------------------------------------------+
//|  MAIN PROGRAM                                                    |
//+------------------------------------------------------------------+

void OnTick()
{

   // ## Walk Forward Pro OnTick() code start (MQL4) ##
   if (MQLInfoInteger(MQL_TESTER))
      WFA_UpdateValues();
   // ## Walk Forward Pro OnTick() code end (MQL4) ##

   //+------------------------------------------------------------------+
   //| PARAMETERS IN SCREEN                                             |
   //+------------------------------------------------------------------+

   //   if(IsTesting())
   //      {
   //      return;
   //      }
   //      else
   //      {
   //      if (ActivateNews)
   //         {
   //         if (NewsHandling() == 1)
   //            {
   //            NewsTime = TRUE;
   //            }
   //            else
   //            {
   //            NewsTime = FALSE;
   //            }
   //         }
   //
   //      double nTickValue=MarketInfo(Symbol(),MODE_TICKVALUE);
   //      data_parameters =
   //           "\n                              Blackrain Scalper 0.0.1"
   //         + "\n                              magic number = " + magic_number
   //         + "\n                              stoploss = " + StopLoss
   //         + "\n                              takeprofit = " + TakeProfit
   //         + "\n                              trailingstop = " + TrailingStop
   //         //+ "\n                              PipsStick = " + PipsStick
   //         //+ "\n                              PipsRetrace = " + PipsRetrace
   //         + "\n                              risk = " + Risk + "%"
   //         + "\n                              lots = " + GetLots() /*init_lots*/
   //         //+ "\n                              Balance = " + AccountBalance()
   //         //+ "\n                              nTik = " + nTickValue
   //         ;
   //
   //      //Assembly of parameters shown in screen
   //
   //      if (ActivateNews)
   //         {
   //         if (NewsTime)
   //            {
   //             data_parameters = data_parameters + data_news
   //             + "\n                              TRADING NOT ALLOWED, NEWS TIME!";
   //            }
   //            else
   //            {
   //            if (!NewsTime)
   //               {
   //               data_parameters = data_parameters + data_news
   //               + "\n                              TRADING ALLOWED, NO NEWS TIME";
   //               }
   //            }
   //         }
   //      }
   //
   //      Comment(data_parameters);

   //+------------------------------------------------------------------+
   //| INITIAL DATA CHECKS                                              |
   //+------------------------------------------------------------------+

   // if(Bars<100)
   //   {
   //    Print("bars less than 100");
   //    return;
   //   }

   // if(AccountFreeMargin()<(1000*Lots))
   //   {
   //    Print("We have no money. Free Margin = ",AccountFreeMargin());
   //    return;
   //   }

   //+------------------------------------------------------------------+
   //| BUY / SELL OPERATIONS                                            |
   //+------------------------------------------------------------------+

   total = CountOrder_symbol_magic();
   current_spread = MarketInfo(Symbol(), MODE_SPREAD);

   // if(total<orders && NewsTime == false)
   if (total < orders && NewBar() == true && DayToTrade() == true && HourToTrade() == true && MonthToTrade() == true && NoFridayEvening() == true && AllowOrders == true && TimeBetweenOrders() == true && current_spread <= spread)
   // if(total<orders && DayToTrade()==true && HourToTrade()==true && MonthToTrade()==true && AllowOrders==true)
   {

      // stochastic_low_1_signal = iStochastic(Symbol(), LOW_TF, KPeriod, DPeriod, Slowing, MODE_SMA, 0, MODE_SIGNAL, 1);

      // stochastic_med_0_main = iStochastic(Symbol(), MED_TF, KPeriod, DPeriod, Slowing, MODE_SMA, 0, MODE_MAIN, 0);
      // stochastic_med_1_main = iStochastic(Symbol(), MED_TF, KPeriod, DPeriod, Slowing, MODE_SMA, 0, MODE_MAIN, 1);

      macd_main_low_0 = iMACD(Symbol(), LOW_TF, EMA_Fast, EMA_Slow, macd_signal, 0, MODE_MAIN, 0);
      macd_main_low_1 = iMACD(Symbol(), LOW_TF, EMA_Fast, EMA_Slow, macd_signal, 0, MODE_MAIN, 1);
      macd_signal_low_0 = iMACD(Symbol(), LOW_TF, EMA_Fast, EMA_Slow, macd_signal, 0, MODE_SIGNAL, 0);
      macd_signal_low_1 = iMACD(Symbol(), LOW_TF, EMA_Fast, EMA_Slow, macd_signal, 0, MODE_SIGNAL, 1);

      ma_low_20_0 = iMA(Symbol(), LOW_TF, 20, 0, MODE_EMA, PRICE_CLOSE, 0);
      ma_low_20_1 = iMA(Symbol(), LOW_TF, 20, 0, MODE_EMA, PRICE_CLOSE, 1);

      open_low_20_1 = iOpen(Symbol(), LOW_TF, 1);
      close_low_20_1 = iClose(Symbol(), LOW_TF, 1);

      //--- check for BUY position

      if (
          open_low_20_1 < ma_low_20_1 && close_low_20_1 > ma_low_20_1                    // price crosses the Slow EMA line in the previous bar (opening position is at the current bar)
          && macd_main_low_0 > macd_signal_low_0 && macd_main_low_1 >= macd_signal_low_1 // MACD current and previous bar, check there are at least 2 consecutive bars where main is higher than the signal line
          && macd_main_low_0 < 0                                                         // check MACD main is still negative
          // && stochastic_low_1_signal<StochLower_low // stochastic signal line below threshold, smoother than main line
          && Stoch_low_Previous_Bars_Oversold() == true && Stoch_med_Previous_Bars_Oversold() == true
          // && stochastic_med_0_main>stochastic_med_1_main // check on higher timeframe, Stochastic should be growing
          // && stochastic_med_0_main<StochLower_med

          // EMA cross // (easy, indicators or MACD)
          // add the shape of the candle?
          // alternatively, price crossing EMA 20 in H1, should come from stochastic saturated, and Stoch in H4 in saturated area as well

      )
      {
         SL = Lower_Price_Previous_Bars() - addtional_SL_pips * vPoint;
         diff = Ask - SL;
         TP = RR * diff + Ask;
         //   closeall();
         // closeall_sell();
         ticket = OrderSend(Symbol(), OP_BUY, GetLots(SL), Ask, vSlippage, SL, TP, "Blackrain Trend Alfa", magic_number, 0, Green);

         if (ticket > 0)
         {
            if (OrderSelect(ticket, SELECT_BY_TICKET, MODE_TRADES))
               Print("BUY order opened at ", OrderOpenPrice());
         }
         else
            Print("Error opening BUY order : ", GetLastError());
      }

      //--- check for SELL position

      if (
          open_low_20_1 > ma_low_20_1 && close_low_20_1 < ma_low_20_1                    // price crosses the Slow EMA line in the previous bar (opening position is at the current bar)
          && macd_main_low_0 < macd_signal_low_0 && macd_main_low_1 <= macd_signal_low_1 // MACD current and previous bar, check there are at least 2 consecutive bars where main is lower than the signal line
          && macd_main_low_0 > 0                                                         // check MACD main is still positive
          // && stochastic_low_1_signal>StochUpper_low
          && Stoch_low_Previous_Bars_Overbought() == true && Stoch_med_Previous_Bars_Overbought() == true
          // && stochastic_med_0_main<stochastic_med_1_main
          // && stochastic_med_0_main>StochUpper_med

      )
      {
         SL = Higher_Price_Previous_Bars() + addtional_SL_pips * vPoint;
         diff = SL - Bid;
         TP = Bid - RR * diff;
         //   closeall();
         // closeall_buy();
         ticket = OrderSend(Symbol(), OP_SELL, GetLots(SL), Bid, vSlippage, SL, TP, "Blackrain Trend Alfa", magic_number, 0, Red);

         if (ticket > 0)
         {
            if (OrderSelect(ticket, SELECT_BY_TICKET, MODE_TRADES))
               Print("SELL order opened at ", OrderOpenPrice());
         }
         else
            Print("Error opening SELL order : ", GetLastError());
         return;
      }

      return;
   }

   //+------------------------------------------------------------------+
   //| MANAGE OPEN ORDERS: TRAILING & BREAKEVEN                         |
   //+------------------------------------------------------------------+

   // Trailing stop   PARTIAL CLOSE WHEN PRICE MOVE TrailingStop VALUE
   if (TRAILING == true && CountOrder_symbol_magic() > 0)
   {
      if (trailing_pips == true)
      {
         TS_pips();
      }
      if (trailing_RR == true)
      {
         TS_RRratio();
      }
   }
   // test
   //+------------------------------------------------------------------+
   //| MANAGEMENT OF OPEN TRADES                                        |
   //+------------------------------------------------------------------+

   // if(total>0 && NewBar())
   if (total > 0)
   {
      for (int cnt = OrdersTotal() - 1; cnt >= 0; cnt--)
      {
         if (!OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES))
            continue;
         // Print("ERROR on OrderSelect, ticket: ",OrderTicket(),", Error: ",GetLastError());
         // continue;
         {
            if (OrderType() <= OP_SELL && OrderSymbol() == Symbol() && OrderMagicNumber() == magic_number) // check for order types, symbol and magic number
            {
               if (MANAGEMENT_TRADE == true)
               {
                  // stochastic_med_0_main = iStochastic(Symbol(), MED_TF, KPeriod, DPeriod, Slowing, MODE_SMA, 0, MODE_MAIN, 0);
                  // stochastic_med_1_main = iStochastic(Symbol(), MED_TF, KPeriod, DPeriod, Slowing, MODE_SMA, 0, MODE_MAIN, 1);
                  // stochastic_med_0_signal = iStochastic(Symbol(), MED_TF, KPeriod, DPeriod, Slowing, MODE_SMA, 0, MODE_SIGNAL, 0);
                  // stochastic_med_1_signal = iStochastic(Symbol(), MED_TF, KPeriod, DPeriod, Slowing, MODE_SMA, 0, MODE_SIGNAL, 1);

                  stochastic_low_0_main = iStochastic(Symbol(), LOW_TF, KPeriod, DPeriod, Slowing, MODE_SMA, 0, MODE_MAIN, 0);
                  stochastic_low_1_main = iStochastic(Symbol(), LOW_TF, KPeriod, DPeriod, Slowing, MODE_SMA, 0, MODE_MAIN, 1);
                  stochastic_low_0_signal = iStochastic(Symbol(), LOW_TF, KPeriod, DPeriod, Slowing, MODE_SMA, 0, MODE_SIGNAL, 0);
                  stochastic_low_1_signal = iStochastic(Symbol(), LOW_TF, KPeriod, DPeriod, Slowing, MODE_SMA, 0, MODE_SIGNAL, 1);

                  // macd_main_low_0 = iMACD(Symbol(), LOW_TF, EMA_Fast, EMA_Slow, macd_signal, 0, MODE_MAIN, 0);
                  macd_main_low_1 = iMACD(Symbol(), LOW_TF, EMA_Fast, EMA_Slow, macd_signal, 0, MODE_MAIN, 1);
                  macd_main_low_2 = iMACD(Symbol(), LOW_TF, EMA_Fast, EMA_Slow, macd_signal, 0, MODE_MAIN, 2);
                  // macd_signal_low_0 = iMACD(Symbol(), LOW_TF, EMA_Fast, EMA_Slow, macd_signal, 0, MODE_SIGNAL, 0);
                  // macd_signal_low_1 = iMACD(Symbol(), LOW_TF, EMA_Fast, EMA_Slow, macd_signal, 0, MODE_SIGNAL, 1);

                  // ma_low_20_0 = iMA(Symbol(), LOW_TF, 20, 0, MODE_EMA, PRICE_CLOSE, 0);
                  // ma_low_20_1 = iMA(Symbol(), LOW_TF, 20, 0, MODE_EMA, PRICE_CLOSE, 1);
                  // ma_low_20_2 = iMA(Symbol(), LOW_TF, 20, 0, MODE_EMA, PRICE_CLOSE, 2);

                  // open_low_20_1 = iOpen(Symbol(), LOW_TF, 1);
                  // close_low_20_1 = iClose(Symbol(), LOW_TF, 1);

                  // Conditions to move SL to breakeven

                  // if (breakeven_trade == true && ((stochastic_med_0_signal > stoch_invalidation_upper && OrderType() == OP_BUY) || (stochastic_med_0_signal < stoch_invalidation_lower && OrderType() == OP_SELL)))
                  if (breakeven_trade == true && ((OrderType() == OP_BUY && macd_main_low_1 > 0 && macd_main_low_2 < 0 && Bid > OrderOpenPrice()) || (OrderType() == OP_SELL && macd_main_low_1 < 0 && macd_main_low_2 > 0 && Ask < OrderOpenPrice())))
                  {
                     BE(); // this is not efficient because the BE() function also loops for all open orders. Not a big issue for only 1 order, but needs optimization if multiple orders are running
                  }

                  // Conditions to close a trade that is winning

                  // Close BUY trades if winning
                  if (close_trade == true && OrderType() == OP_BUY && Bid > OrderOpenPrice() && (stochastic_low_0_signal > stoch_invalidation_upper && stochastic_low_0_signal > stochastic_low_0_main && stochastic_low_1_signal < stochastic_low_1_main))
                  // if (close_trade == true && OrderType() == OP_BUY && macd_main_low_1 < 0 && macd_main_low_2 > 0)
                  {
                     closeall();
                  }

                  // Close SELL trades if winning
                  if (close_trade == true && OrderType() == OP_SELL && Ask < OrderOpenPrice() && (stochastic_low_0_signal < stoch_invalidation_lower && stochastic_low_0_signal < stochastic_low_0_main && stochastic_low_1_signal > stochastic_low_1_main))
                  // if (close_trade == true && OrderType() == OP_SELL && macd_main_low_1 > 0 && macd_main_low_2 < 0)
                  {
                     closeall();
                  }

                  // // Conditions to close a trade that is loosing

                  // // Close BUY trades if the setup is invalid
                  // if (close_trade == true && OrderType() == OP_BUY && (stochastic_low_0_signal > stoch_invalidation_upper && stochastic_low_0_signal > stochastic_low_0_main && stochastic_low_1_signal < stochastic_low_1_main))
                  // // if (close_trade == true && OrderType() == OP_BUY && macd_main_low_1 < 0 && macd_main_low_2 > 0)
                  // {
                  //    closeall();
                  // }

                  // // Close SELL trades if the setup is invalid
                  // if (close_trade == true && OrderType() == OP_SELL && (stochastic_low_0_signal < stoch_invalidation_lower && stochastic_low_0_signal < stochastic_low_0_main && stochastic_low_1_signal > stochastic_low_1_main))
                  // // if (close_trade == true && OrderType() == OP_SELL && macd_main_low_1 > 0 && macd_main_low_2 < 0)
                  // {
                  //    closeall();
                  // }
               }

               // Close trades due to their duration
               if (CloseOnDuration == true)
               {
                  int MaxDuration = (MaxDurationHours * 60 * 60) + (MaxDurationMin * 60); // transform hours to seconds
                  int Duration = TimeCurrent() - OrderOpenTime();

                  if (Duration >= MaxDuration) // add condition to be applied only is price is lower or higher than open price, check both situations!!
                  {
                     if (OrderType() == OP_BUY && Bid > OrderOpenPrice())
                     {
                        if (!OrderClose(OrderTicket(), OrderLots(), OrderClosePrice(), 3, clrMagenta))
                           Print("BUY order ERROR on close due to duration: ", OrderTicket(), ", Error: ", GetLastError());
                        else
                           Print("BUY order closed due to duration of the trade");
                     }
                     if (OrderType() == OP_SELL && Ask < OrderOpenPrice())
                     {
                        if (!OrderClose(OrderTicket(), OrderLots(), OrderClosePrice(), 3, clrMagenta))
                           Print("SELL order ERROR on close due to duration: ", OrderTicket(), ", Error: ", GetLastError());
                        else
                           Print("SELL order closed due to duration of the trade");
                     }
                  }
               }

               // Close trades on Fridays evening
               if (CloseFridays == true)
               {
                  if (DayOfWeek() == 5 && Hour() >= 21 && Minute() >= 59)
                  {
                     if (!OrderClose(OrderTicket(), OrderLots(), OrderClosePrice(), 3, clrMagenta))
                        Print("Order ERROR on close on Friday: ", OrderTicket(), ", Error: ", GetLastError());
                     else
                        Print("Trade closed due to End Of The Week");
                  }
               }

               // Use retrace function to give the price a bit more room to operate. If a limit is exceeded, TP is used as nearby SL. The hard-SL is set on SL parameter
               //  if(retrace==true)
               //     {
               //     if(OrderType()==OP_BUY && (OrderOpenPrice()-Bid)>vPoint*PipsStick && Bid<OrderOpenPrice() && OrderTakeProfit()>OrderOpenPrice())
               //        {
               //        if(!OrderModify(OrderTicket(),OrderOpenPrice(),OrderStopLoss(),OrderOpenPrice()-vPoint*PipsRetrace,0,Green))
               //           Print("OrderModify error is due to RETRACE, error ",GetLastError());
               //           else
               //           Print("RETRACE done");
               //        }
               //     if(OrderType()==OP_SELL && (Ask-OrderOpenPrice())>vPoint*PipsStick && Ask>OrderOpenPrice() && OrderTakeProfit()<OrderOpenPrice())
               //        {
               //        if(!OrderModify(OrderTicket(),OrderOpenPrice(),OrderStopLoss(),OrderOpenPrice()+vPoint*PipsRetrace,0,Green))
               //           //Print("OrderModify error ",GetLastError());
               //           Print("OrderModify error is due to RETRACE, error ",GetLastError());
               //           else
               //           Print("RETRACE done");
               //        }
               //     }
            }
         }
      }
   }
}

double OnTester()
{
   // ## Walk Forward Pro OnTester() code start (MQL4)- When NOT calculating your own Custom Performance Criterion ##
   double dCustomPerformanceCriterion = NULL; // This means the default Walk Forward Pro Custom Perf Criterion will be used
   WFA_PerformCalculations(dCustomPerformanceCriterion);

   return (dCustomPerformanceCriterion);
   // ## Walk Forward Pro OnTester() code end (MQL5) - When NOT calculating your own Custom Performance Criterion ##
}

//+------------------------------------------------------------------+
//| MONEY MANAGEMENT                                                 |
//+------------------------------------------------------------------+

double GetLots(double SL_price) // Calculate the lots using the right currency conversion
{
   double minlot = MarketInfo(Symbol(), MODE_MINLOT);
   double maxlot = MarketInfo(Symbol(), MODE_MAXLOT);
   double lots;
   int correction;

   if (MM)
   {

      double LotSize = 1;
      double dist_SL;
      double point = Point;
      if ((Digits == 3) || (Digits == 5))
      {
         point *= 10;
      }

      double PipValue = (((MarketInfo(Symbol(), MODE_TICKVALUE) * point) / MarketInfo(Symbol(), MODE_TICKSIZE)) * LotSize); // calculation of pip value

      if (Digits == 3) // correction for 3 digits pairs (JPY)
         correction = 100;

      if (Digits == 5) // correction for 5 digits pairs
         correction = 10000;

      dist_SL = MathAbs((Bid - SL_price) * correction);
      // Print("Bid price is ",Bid);
      // Print("SL price is ",SL_price);
      // Print("Correction is ", correction);
      // Print("Distance to SL is ", dist_SL);

      lots = NormalizeDouble((AccountBalance() * Risk / 100) / (dist_SL * PipValue), LotDigits);
      // Print("Calculated lots: ",lots);

      // correction for the limits
      if (lots < minlot)
         lots = minlot;
      if (lots > maxlots)
         lots = maxlots;
   }
   else
   {
      if (lots < minlot)
         lots = minlot;
      if (lots > maxlots)
         lots = maxlots;
      // lots = NormalizeDouble(Lots, LotDigits);
   }
   return (lots);
}

//+------------------------------------------------------------------+
//| CHECK NEW BAR BY OPEN TIME                                       |
//+------------------------------------------------------------------+
bool NewBar()
{
   static datetime lastbar;
   datetime curbar = Time[0];
   if (lastbar != curbar)
   {
      lastbar = curbar;
      return (true);
   }
   else
   {
      return (false);
   }
}

// bool NewBar() //This is not really a start of the bar, it is to check there is only one trade per bar? Check!!!
//    {
//    static datetime previousTime = 0;
//    datetime currentTime = Time[0];
//    if(previousTime!=currentTime)
//       {
//          previousTime=currentTime;
//          return true;
//       }
//    return false;
//    }

// bool NewBar()
// {
//    static int LasatNumberOfBars; // Static counterfor the last number of bars

//    bool NewBarAppeared = false; // we create a boolean output for the return value

//    if (Bars > LasatNumberOfBars)
//    {
//       NewBarAppeared = true;

//       LasatNumberOfBars = Bars;
//    }
//    return (NewBarAppeared);
// }

bool Stoch_low_Previous_Bars_Oversold()
{
   bool Stoch_check = false;
   double stoch;

   for (int cnt = 0; cnt <= 20; cnt++)
   {
      stoch = iStochastic(Symbol(), LOW_TF, KPeriod, DPeriod, Slowing, MODE_SMA, 0, MODE_MAIN, cnt);
      if (stoch < StochLower_low)
      {
         Stoch_check = true;
      }
   }
   return (true);
}

bool Stoch_low_Previous_Bars_Overbought()
{
   bool Stoch_check = false;
   double stoch;

   for (int cnt = 0; cnt <= 20; cnt++)
   {
      stoch = iStochastic(Symbol(), LOW_TF, KPeriod, DPeriod, Slowing, MODE_SMA, 0, MODE_MAIN, cnt);
      if (stoch > StochUpper_low)
      {
         Stoch_check = true;
      }
   }
   return (true);
}

bool Stoch_med_Previous_Bars_Oversold()
{
   bool Stoch_check = false;
   double stoch;

   for (int cnt = 0; cnt <= 20; cnt++)
   {
      stoch = iStochastic(Symbol(), MED_TF, KPeriod, DPeriod, Slowing, MODE_SMA, 0, MODE_MAIN, cnt);
      if (stoch < StochLower_med)
      {
         Stoch_check = true;
         // Print("Stoch value is ",stoch," and cnt=",cnt);
         break;
      }
   }
   // Print("Stoch value is ",stoch," and cnt=",cnt);
   return (true);
}

bool Stoch_med_Previous_Bars_Overbought()
{
   bool Stoch_check = false;
   double stoch;

   for (int cnt = 0; cnt <= 20; cnt++)
   {
      stoch = iStochastic(Symbol(), MED_TF, KPeriod, DPeriod, Slowing, MODE_SMA, 0, MODE_MAIN, cnt);
      if (stoch > StochUpper_med)
      {
         Stoch_check = true;
         // Print("Stoch value is ",stoch," and cnt=",cnt);
         break;
      }
   }
   // Print("Stoch value is ",stoch," and cnt=",cnt);
   return (true);
}

double Higher_Price_Previous_Bars()
{
   double price = 0;
   double new_price;

   for (int cnt = 0; cnt <= 30; cnt++)
   {
      new_price = iHigh(Symbol(), LOW_TF, cnt);

      if (new_price > price)
      {
         price = new_price;
      }
   }
   // Print("The StopLoss calculated in High_Price is ",price);
   return (price);
}

double Lower_Price_Previous_Bars()
{
   double price = 1000000000;
   double new_price;

   for (int cnt = 0; cnt <= 30; cnt++)
   {
      new_price = iLow(Symbol(), LOW_TF, cnt);

      if (new_price < price)
      {
         price = new_price;
      }
   }
   // Print("The StopLoss calculated in Low_Price is ",price);
   return (price);
}

//+------------------------------------------------------------------+
//| BREAKEVEN                                                        |
//+------------------------------------------------------------------+
void BE()
{
   int cnt;
   int ordertotal;

   ordertotal = OrdersTotal();

   for (cnt = ordertotal - 1; cnt >= 0; cnt--)
   {
      if (!OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES))
         continue;
      if (OrderType() == OP_BUY && OrderSymbol() == Symbol() && OrderMagicNumber() == magic_number)
      {
         // if(Bid>OrderOpenPrice()+BreakevenStop*vPoint)
         if (Bid > OrderOpenPrice())
         {
            // if(OrderStopLoss()<=OrderOpenPrice())
            if (OrderStopLoss() < OrderOpenPrice())
            {
               // if(!OrderModify(OrderTicket(),OrderOpenPrice(),OrderOpenPrice()+BreakevenDelta*vPoint,OrderTakeProfit(),0,Green))
               if (!OrderModify(OrderTicket(), OrderOpenPrice(), OrderOpenPrice(), OrderTakeProfit(), 0, Green))
                  Print("OrderModify error ", GetLastError());
               return;
            }
         }
      }
      if (OrderType() == OP_SELL && OrderSymbol() == Symbol() && OrderMagicNumber() == magic_number)
      {
         // if(Ask<OrderOpenPrice()-BreakevenStop*vPoint)
         if (Ask < OrderOpenPrice())
         {
            // if(OrderStopLoss()>=OrderOpenPrice())
            if (OrderStopLoss() > OrderOpenPrice())
            {
               // if(!OrderModify(OrderTicket(),OrderOpenPrice(),OrderOpenPrice()-BreakevenDelta*vPoint,OrderTakeProfit(),0,Green))
               if (!OrderModify(OrderTicket(), OrderOpenPrice(), OrderOpenPrice(), OrderTakeProfit(), 0, Green))
                  Print("OrderModify error ", GetLastError());
               return;
            }
         }
      }
   }
}

//+------------------------------------------------------------------+
//| CHECK IF TIME OF PREVIOUS ORDER                                  |
//+------------------------------------------------------------------+
bool TimeBetweenOrders()
{
   bool OpenOrder = true;

   if (ticket > 0)
   {
      if (OrderSelect(ticket, SELECT_BY_TICKET, MODE_HISTORY))
      {
         // if(((TimeCurrent()-OrderCloseTime())<=time_between_trades) && OrderSymbol()==Symbol()) //time in seconds
         if (((TimeCurrent() - OrderOpenTime()) <= time_between_trades) && OrderSymbol() == Symbol()) // time in seconds
         {
            datetime a = TimeCurrent();
            datetime b = OrderCloseTime();
            Print("Can't open a new trade, too early");
            // Print(a);
            // Print(b);
            Print("Time between old order and new one ", a - b, " seconds");
            OpenOrder = false;
         }
      }
   }
   return (OpenOrder);
}

//+------------------------------------------------------------------+
//| CLOSE ALL ORDERS                                                 |
//+------------------------------------------------------------------+
void closeall()
{
   int cnt;
   int ordertotal;

   ordertotal = OrdersTotal();

   for (cnt = ordertotal - 1; cnt >= 0; cnt--)
   {
      if (!OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES))
         continue;
      if ((OrderType() == OP_BUY || OrderType() == OP_SELL) && OrderSymbol() == Symbol() && OrderMagicNumber() == magic_number)
      {
         if (!OrderClose(OrderTicket(), OrderLots(), OrderClosePrice(), 3, CLR_NONE))
            Print("Order Close failed at 'closeall': ", OrderTicket(), " Error: ", GetLastError());
      }
   }
}

//+------------------------------------------------------------------+
//| CLOSE ALL BUY ORDERS                                             |
//+------------------------------------------------------------------+
void closeall_buy()
{
   int cnt;
   int ordertotal;

   ordertotal = OrdersTotal();

   for (cnt = ordertotal - 1; cnt >= 0; cnt--)
   {
      if (!OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES))
         continue;
      if (OrderType() == OP_BUY && OrderSymbol() == Symbol() && OrderMagicNumber() == magic_number)
      {
         if (!OrderClose(OrderTicket(), OrderLots(), OrderClosePrice(), 3, CLR_NONE))
            Print("Order Close failed at 'closeall_buy': ", OrderTicket(), " Error: ", GetLastError());
      }
   }
}

//+------------------------------------------------------------------+
//| CLOSE ALL SELL ORDERS                                            |
//+------------------------------------------------------------------+
void closeall_sell()
{
   int cnt;
   int ordertotal;

   ordertotal = OrdersTotal();

   for (cnt = ordertotal - 1; cnt >= 0; cnt--)
   {
      if (!OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES))
         continue;
      if (OrderType() == OP_SELL && OrderSymbol() == Symbol() && OrderMagicNumber() == magic_number)
      {
         if (!OrderClose(OrderTicket(), OrderLots(), OrderClosePrice(), 3, CLR_NONE))
            Print("Order Close failed at 'closeall_sell': ", OrderTicket(), " Error: ", GetLastError());
      }
   }
}

//+------------------------------------------------------------------+
//| COUNT OPEN ORDERS BY SYMBOL AND MAGIC NUMBER                     |
//+------------------------------------------------------------------+
int CountOrder_symbol_magic()
{
   int cnt;
   int order_total;
   int ordertotal;

   order_total = 0;
   ordertotal = OrdersTotal();

   for (cnt = ordertotal - 1; cnt >= 0; cnt--)
   {
      if (!OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES))
         continue;
      if ((OrderType() == OP_BUY || OrderType() == OP_SELL) && OrderSymbol() == Symbol() && OrderMagicNumber() == magic_number)
      {
         order_total++;
      }
   }
   return (order_total);
}

//+------------------------------------------------------------------+
//| COUNT BUY ORDERS BY SYMBOL AND MAGIC NUMBER                      |
//+------------------------------------------------------------------+
int CountBuyOrder_symbol_magic()
{
   int cnt;
   int order_total;
   int ordertotal;

   order_total = 0;
   ordertotal = OrdersTotal();

   for (cnt = ordertotal - 1; cnt >= 0; cnt--)
   {
      if (!OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES))
         continue;
      if (OrderType() == OP_BUY && OrderSymbol() == Symbol() && OrderMagicNumber() == magic_number)
      {
         order_total++;
      }
   }
   return (order_total);
}

//+------------------------------------------------------------------+
//| COUNT SELL ORDERS BY SYMBOL AND MAGIC NUMBER                     |
//+------------------------------------------------------------------+
int CountSellOrder_symbol_magic()
{
   int cnt;
   int order_total;
   int ordertotal;

   order_total = 0;
   ordertotal = OrdersTotal();

   for (cnt = ordertotal - 1; cnt >= 0; cnt--)
   {
      if (!OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES))
         continue;
      if (OrderType() == OP_SELL && OrderSymbol() == Symbol() && OrderMagicNumber() == magic_number)
      {
         order_total++;
      }
   }
   return (order_total);
}

//+------------------------------------------------------------------+
//| TRAILING STOP BY PIPS                                            |
//+------------------------------------------------------------------+
void TS_pips()
{
   int cnt;
   int ordertotal;
   double TS;

   ordertotal = OrdersTotal();

   // if((TrailingStop)>=TakeProfit-5)
   //    {
   //    TS=TakeProfit-5;
   //    }
   //    else
   //    {
   //    TS=TrailingStop;
   //    }

   // Print("TS IS: ",TS);

   for (cnt = ordertotal - 1; cnt >= 0; cnt--)
   {
      if (!OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES))
         continue;
      if (OrderType() == OP_BUY && OrderSymbol() == Symbol() && OrderMagicNumber() == magic_number)
      {
         // if((Bid-OrderOpenPrice())>TrailingStop*vPoint)
         if ((Bid - OrderOpenPrice()) > TS * vPoint)
         {
            // if(OrderStopLoss()<(Bid-TrailingStop*vPoint))
            if (OrderStopLoss() < (Bid - TS * vPoint))
            {
               // if(!OrderModify(OrderTicket(),OrderOpenPrice(),Bid-TrailingStop*vPoint,OrderTakeProfit(),0,Green))
               if (!OrderModify(OrderTicket(), OrderOpenPrice(), Bid - TS * vPoint, OrderTakeProfit(), 0, Green))
                  Print("OrderModify error is because TS, error ", GetLastError());
               return;
            }
         }
      }
      if (OrderType() == OP_SELL && OrderSymbol() == Symbol() && OrderMagicNumber() == magic_number)
      {
         // if((OrderOpenPrice()-Ask)>TrailingStop*vPoint)
         if ((OrderOpenPrice() - Ask) > TS * vPoint)
         {
            // if(OrderStopLoss()>(Ask+TrailingStop*vPoint))
            if (OrderStopLoss() > (Ask + TS * vPoint))
            {
               // if(!OrderModify(OrderTicket(),OrderOpenPrice(),Ask+TrailingStop*vPoint,OrderTakeProfit(),0,Green))
               if (!OrderModify(OrderTicket(), OrderOpenPrice(), Ask + TS * vPoint, OrderTakeProfit(), 0, Green))
                  Print("OrderModify error is because TS, error ", GetLastError());
               return;
            }
         }
      }
   }
}

//+------------------------------------------------------------------+
//| TRAILING STOP BY RISK-REWARD RATIO                               |
//+------------------------------------------------------------------+
void TS_RRratio()
{
   int cnt;
   int ordertotal;
   // int shift_bar;

   double dist_open_to_initSL;

   ordertotal = OrdersTotal();
   // ordertotal=CountOrder_symbol_magic();

   for (cnt = ordertotal - 1; cnt >= 0; cnt--) // deberia funcionar en combinación con piramidar: no funciona pq una vez cumplidas las condiciones no las aplica a cada order abierta
   {
      if (!OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES))
         continue;
      if (OrderType() == OP_BUY && OrderSymbol() == Symbol() && OrderMagicNumber() == magic_number)
      {
         // shift_bar = iBarShift(Symbol(), LOW_TF, OrderOpenTime(), false);
         // dist_open_to_initSL = OrderOpenPrice() - MathMin(iSAR(Symbol(), LOW_TF, SAR_step_med, SAR_max, shift_bar), iSAR(Symbol(), LOW_TF, SAR_step_med, SAR_max, shift_bar + 1));
         dist_open_to_initSL = OrderOpenPrice() - OrderStopLoss();
         // Print("Distancia al SL: ",dist_open_to_initSL);
         if ((Bid - OrderOpenPrice()) > TS_RRratio_step * dist_open_to_initSL) // solo funciona para la primera vez ya que compara con el precio de apertura, el parametro determina la distancia per el primer movimiento de SL
         {
            if (OrderStopLoss() < (Bid - (TS_RRratio_step + TS_RRratio_sl) * dist_open_to_initSL)) // creo que esta condicion es correcta, procede si el SL està a 3R de distancia del precio
            {
               if (!OrderModify(OrderTicket(), OrderOpenPrice(), Bid - TS_RRratio_sl * dist_open_to_initSL, OrderTakeProfit(), 0, Green)) // esto tambien parece correcto, mueve el SL a 1R de distancia del precio actual
                  Print("OrderModify error is because TS, error ", GetLastError());
               return;
            }
         }
      }
      if (OrderType() == OP_SELL && OrderSymbol() == Symbol() && OrderMagicNumber() == magic_number)
      {
         // shift_bar = iBarShift(Symbol(), LOW_TF, OrderOpenTime(), false);
         // dist_open_to_initSL = MathMax(iSAR(Symbol(), LOW_TF, SAR_step_med, SAR_max, shift_bar), iSAR(Symbol(), LOW_TF, SAR_step_med, SAR_max, shift_bar + 1)) - OrderOpenPrice();
         dist_open_to_initSL = OrderStopLoss() - OrderOpenPrice();

         if ((OrderOpenPrice() - Ask) > TS_RRratio_step * dist_open_to_initSL)
         {
            if (OrderStopLoss() > (Ask + (TS_RRratio_step + TS_RRratio_sl) * dist_open_to_initSL))
            {
               if (!OrderModify(OrderTicket(), OrderOpenPrice(), Ask + TS_RRratio_sl * dist_open_to_initSL, OrderTakeProfit(), 0, Green))
                  Print("OrderModify error is because TS, error ", GetLastError());
               return;
            }
         }
      }
   }
}

////+------------------------------------------------------------------+
////| NEWS TIME FUNCTION                                               |
////+------------------------------------------------------------------+
// bool NewsHandling()
//   {
//    //static int PrevMinute = -1;
//    //   if (Minute() != PrevMinute)
//    //     {
//    //     PrevMinute = Minute();
//         //int minutesSincePrevEvent = iCustom(NULL, 0, "FFCal", true, true, false, true, true, 1, 0);
//         //int minutesUntilNextEvent = iCustom(NULL, 0, "FFCal", true, true, false, true, true, 1, 1);
//
//         //int minutesSincePrevEvent = iCustom(NULL, 0, "FFCal", IncludeHighNews, IncludeMediumNews, IncludeLowNews, IncludeSpeakNews, 1, DSTOffsetHours, 1, 0);
//         //int minutesUntilNextEvent = iCustom(NULL, 0, "FFCal", IncludeHighNews, IncludeMediumNews, IncludeLowNews, IncludeSpeakNews, 1, DSTOffsetHours, 1, 1);
//
//   int minutesAfterPrevEvent = iCustom(NULL, 0, "FFC", true, IncludeHighNews, IncludeMediumNews, IncludeLowNews, IncludeSpeakNews, IncludeHolidays,"","", true, 4, 0, 1);
//   int minutesBeforeNextEvent = iCustom(NULL, 0, "FFC", true, IncludeHighNews, IncludeMediumNews, IncludeLowNews, IncludeSpeakNews, IncludeHolidays,"","", true, 4, 0, 0);
//
//   data_news =
//   "\n                              Minutes Before next News Event = " + minutesBeforeNextEvent
//   +"\n                              Minutes After previous News Event = " + minutesAfterPrevEvent;
//
//   if (minutesBeforeNextEvent <= MinsBeforeNews || minutesAfterPrevEvent <= MinsAfterNews)
//      {
//      NewsTime = true;
//      }
//      else
//      {
//      NewsTime = false;
//      }
//    return(NewsTime);
//    }

/*
FFC Advanced call:
-------------
iCustom(
        string       NULL,            // symbol
        int          0,               // timeframe
        string       "FFC",           // path/name of the custom indicator compiled program
        bool         true,            // true/false: Active chart only
        bool         true,            // true/false: Include High impact
        bool         true,            // true/false: Include Medium impact
        bool         true,            // true/false: Include Low impact
        bool         true,            // true/false: Include Speaks
        bool         false,           // true/false: Include Holidays
        string       "",              // Find keyword
        string       "",              // Ignore keyword
        bool         true,            // true/false: Allow Updates
        int          4,               // Update every (in hours)
        int          0,               // Buffers: (0) Minutes, (1) Impact
        int          0                // shift
*/
//   minutesSincePrevEvent = iCustom(NULL, 0, "FFC", true, IncludeHighNews, IncludeMediumNews, IncludeLowNews, IncludeSpeakNews, IncludeHolidays,"","", true, 4, 0, 0);
//
//   minutesUntilNextEvent = iCustom(NULL, 0, "FFC", true, IncludeHighNews, IncludeMediumNews, IncludeLowNews, IncludeSpeakNews, IncludeHolidays,"","", true, 4, 0, 1);
//
//   impactOfPrevEvent = iCustom(NULL, 0, "FFC", true, IncludeHighNews, IncludeMediumNews, IncludeLowNews, IncludeSpeakNews, IncludeHolidays,"","", true, 4, 1, 0);
//
//   impactOfNextEvent = iCustom(NULL, 0, "FFC", true, IncludeHighNews, IncludeMediumNews, IncludeLowNews, IncludeSpeakNews, IncludeHolidays,"","", true, 4, 1, 1);

// FFCAL call

//   minutesSincePrevEvent = iCustom(NULL, 0, "FFCal", true, true, false, true, true, 1, 0);
//
//   minutesUntilNextEvent = iCustom(NULL, 0, "FFCalendar", true, true, false, true, true, 1, 1);
//
//   impactOfPrevEvent = iCustom(NULL, 0, "FFCalendar", true, true, false, true, true, 2, 0);
//
//   impactOfNextEvent = iCustom(NULL, 0, "FFCalendar", true, true, false, true, true, 2, 1);

//+------------------------------------------------------------------+
//| DAYS TO AVOID TRADING                                            |
//+------------------------------------------------------------------+

bool DayToTrade()
{
   bool daytotrade = false;

   // add here the conditions for days to avoid trading, choose FALSE or TRUE
   if (DayOfWeek() == 0)
      daytotrade = Sunday;
   if (DayOfWeek() == 1)
      daytotrade = Monday;
   if (DayOfWeek() == 2)
      daytotrade = Tuesday;
   if (DayOfWeek() == 3)
      daytotrade = Wednesday;
   if (DayOfWeek() == 4)
      daytotrade = Thursday;
   if (DayOfWeek() == 5)
      daytotrade = Friday;

   for (int jan = 1; jan <= 15; jan++)
   {
      if (DayOfYear() == jan)
         daytotrade = false;
   }

   for (int dec = 350; dec <= 365; dec++)
   {
      if (DayOfYear() == dec)
         daytotrade = false;
   }

   return (daytotrade);
}

//+------------------------------------------------------------------+
//| HOURS TO AVOID TRADING                                           |
//+------------------------------------------------------------------+

bool HourToTrade()
{
   bool hourtotrade = false;

   // add here the conditions for hours to avoid trading, choose FALSE or TRUE

   if (Hour() >= StartHourTrade && Hour() <= EndHourTrade)
      hourtotrade = true;

   return (hourtotrade);
}

//+------------------------------------------------------------------+
//| MONTH TO AVOID TRADING                                           |
//+------------------------------------------------------------------+

bool MonthToTrade()
{
   bool monthtotrade = false;

   // add here the conditions for month to avoid trading, choose FALSE or TRUE

   if (Month() == 1)
      monthtotrade = January;
   if (Month() == 2)
      monthtotrade = February;
   if (Month() == 3)
      monthtotrade = March;
   if (Month() == 4)
      monthtotrade = April;
   if (Month() == 5)
      monthtotrade = May;
   if (Month() == 6)
      monthtotrade = June;
   if (Month() == 7)
      monthtotrade = July;
   if (Month() == 8)
      monthtotrade = August;
   if (Month() == 9)
      monthtotrade = September;
   if (Month() == 10)
      monthtotrade = October;
   if (Month() == 11)
      monthtotrade = November;
   if (Month() == 12)
      monthtotrade = December;

   return (monthtotrade);
}

//+------------------------------------------------------------------+
//| TRADE ON FRIDAY EVENING                                          |
//+------------------------------------------------------------------+

bool NoFridayEvening()
{
   bool fridayevening = true;

   if (DayOfWeek() == 5 && Hour() >= 22)
      fridayevening = false;

   return (fridayevening);
}

//+------------------------------------------------------------------+
