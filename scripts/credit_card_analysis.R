library(tidyverse)
library(lubridate)
library(ggplot2)
library(forecast)
library(tseries)
library(reshape2)
library(dplyr)
library(lubridate, warn.conflicts = FALSE)

df <- read.csv("A:/GithuB/Credit Card Spending Analysis/data/Credit card transactions.csv", stringsAsFactors = FALSE)
View(df)

df$Date <- dmy(df$Date)
df <- na.omit(df)


## Exploratory Data Analysis
summary(df)
str(df)  

# Add Date fetaures
df$Year <- year(df$Date)
df$Month <- month(df$Date)
df$Weekday <- weekdays(df$Date)

# Aggregation
total_spend_city <- df %>% group_by(City) %>% 
  summarise(Total_Spend=sum(Amount)) %>%
  arrange(desc(Total_Spend))

View(total_spend_city)


# Transactions by Card
card_counts <- df %>% group_by(Card.Type) %>%
  summarise(Count=n())
card_counts

# Histogram of Amount
ggplot(df, aes(x=Amount))+
  geom_histogram(bins=50, fill="skyblue", color="black")+
  ggtitle('Transaction Amount Distribution')

## Time Series Aggregation
monthly_spend <- df %>% 
  group_by(YearMonth = floor_date(Date, "month")) %>%
  summarise(MonthlyAmount=sum(Amount))

monthly_spend

# Plotting Monthly Spending
ggplot(monthly_spend, aes(x=YearMonth, y=MonthlyAmount))+
  geom_line(color='darkgreen')+
  ggtitle('Monthly Spending Trend')


## Anomaly detection using Z-Score
df$z_score <- scale(df$Amount)
df$Anomaly <- abs(df$z_score > 3)

# Plot Anomalies
ggplot(df, aes(x=Date, y=Amount, color=Anomaly))+
  geom_point(alpha=0.7)+
  ggtitle('Anomalies in Transactions')


## Time Series Forecasting
ts_data <- ts(monthly_spend$MonthlyAmount, start = c(2014,1), frequency = 12)
model <- auto.arima(ts_data)  
forecasted <- forecast(model, h=6)


# Plot Forecast
autoplot(forecasted)+ggtitle('ARIMA Forecast for Montlhy Spending')

