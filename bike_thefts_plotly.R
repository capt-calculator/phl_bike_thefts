library(plotly)
library(data.table)

thefts_link_1 = 'https://raw.githubusercontent.com/CityOfPhiladelphia/phl-open-geodata/master/bicycle_thefts/bicycle_thefts_Part1.csv'
thefts_link_2 = 'https://raw.githubusercontent.com/CityOfPhiladelphia/phl-open-geodata/master/bicycle_thefts/Bike_Thefts_Part2.csv'
weather = read.csv('weather.csv')

thefts_1 = read.csv(url(thefts_link_1))
thefts_2 = read.csv(url(thefts_link_2))

#combine theft data sets using columns in common
inter = intersect(colnames(thefts_1), colnames(thefts_2))
thefts_1 = thefts_1[inter]
thefts_2 = thefts_2[inter]

thefts = rbind(thefts_1, thefts_2)

#rename THEFT_DATE column in thefts in preparation for a join with the weather data
colnames(thefts)[4] = 'DATE'

#Create a single DATE column
weather$DATE = paste(weather$MO, weather$DAY, weather$YEAR, sep="/")

#merge thefts with the weather data
data = merge(thefts, weather, by='DATE')

data$counts = 1
data$TEMP = (data$HIGH + data$LOW) / 2

data = data.table(data)

by_temp = data[, sum(counts), by=TEMP]

plot(by_temp, col='blue', main='Bike Thefts by Temperature', xlab='Daily Mean Temperature', ylab='Thefts')

py = plotly()

trace1 = list(
  x = by_temp$TEMP,
  y = by_temp$V1,
  
  type = 'scatter',
  mode='markers',
  
  marker = list(
    color = 'rgb(0, 204, 102)',
    size=10
    )
  )

plot_data = list(trace1)

layout = list(
  title = 'Philadelphia Bike Thefts by Temperature (2010-2014)',
  
  xaxis = list(
    title = 'Daily Temperature'
    ),
  
  yaxis = list(
    title='Thefts'
    ),
  
  annotations = list(
    list(
      x = 0.9, 
      y = -0.17, 
      xref = "paper", 
      yref = "paper", 
      text = "Source: OpenDataPhilly", 
      showarrow = FALSE
      )
    )
  )

response = py$plotly(plot_data, kwargs=list(filename='ph_bike_thefts', layout=layout, fileopt='overwrite'))

