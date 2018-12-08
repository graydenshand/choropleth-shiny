# Choropleth with Shiny
### *Choropleth in Shiny with some advanced features*


![test](https://github.com/graydenshand/choropleth-shiny/blob/master/Screen%20Shot%202018-12-08%20at%203.22.52%20PM.png)

I made this to play around with Shiny shiny and ultimately create something with slightly more complexity than most simple plots.

I compiled the majority of this dataset in 2017 for [this paper](https://link.springer.com/article/10.1007/s11187-017-9984-1). Mostly the data comes from the Census Bureau, the Bureau of Labor Statistics, and the Bureau of Economic Analysis. 

Features
* Spatial functions to map hover coordinates to states.
  + Allows for the output of any data in the dataset when a state is hovered over. 
* Slider control changes year and can be "played" for an animated view.
* Radio buttons to select variable to map in the choropleth. 
  + I have included two different inequality measures, but any variable in the dataset could be added.
