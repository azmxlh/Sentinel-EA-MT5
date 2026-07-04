# Sentinel EA – Basic Gold Scalping EA for MT5

## Overview
Sentinel EA is a **basic automated trading strategy** for **gold (XAU/USD)** on **MetaTrader 5**, designed for **scalping the 1-minute chart**. It uses **fast and slow EMAs** combined with **SuperDOM signals** to identify high-probability entries and exits.

## Key Features
- Adjustable **stop loss (SL) and take profit (TP)** levels  
- **Single trade at a time** with a **5-minute cooldown** between trades  
- **Test mode** available for demo or backtesting  
- **Trade logging**: entries, exits, and P&L saved to CSV for analysis  
- Optimized for short-term scalping with fast execution and low latency  

## Backtest & Performance
- **Timeframe:** 1M  
- **Symbol:** XAU/USD  
- **Total Trades:** 81  
- **Net Profit:** $9,163  
- **Win Rate:** 67.9%  
- **Profit Factor:** 1.38  
- **Maximum Drawdown (Balance):** $3,672 (29.99%)  

## Screenshots
![Settings](https://github.com/azmxlh/Sentinel-EA-MT5/blob/main/screenshots/Backtest.png)  
![Inputs](https://github.com/azmxlh/Sentinel-EA-MT5/blob/main/screenshots/Inputs.png)  
![Backtest](https://github.com/azmxlh/Sentinel-EA-MT5/blob/main/screenshots/Backtest.png)  
![Graph](https://github.com/azmxlh/Sentinel-EA-MT5/blob/main/screenshots/Graph.png)  
![Optimization](https://github.com/azmxlh/Sentinel-EA-MT5/blob/main/screenshots/Optimization.png)

## Setup & Usage
1. Copy `Sentinel.mq5` into your **MetaTrader 5 / Experts** folder  
2. Open MT5, attach Sentinel EA to the **XAU/USD 1M chart**  
3. Adjust inputs for **EMAs, SL, TP, and test mode** as needed (default settings are optimized)  
4. Enable **AutoTrading** to run the EA live or on a demo account  

## Files Included
- `Sentinel.mq5` – EA source code  
- `trades.csv` – Logged trades from backtest  
- `screenshots/` – Settings, inputs, backtest, graph, optimization  

## Notes
- This is a **basic EA**, designed for simple scalping  
- Performance may vary in live markets; demo-testing recommended  
- Designed for MT5 with real-time data and minimal slippage  

