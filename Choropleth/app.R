#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(sp)
library(tidyverse)
library(rgeos)

# Define UI for application that draws a histogram
ui <- fluidPage(
    div(class='container',
        h2('Inequality 1988-2013'),
        div(class="container-fluid",
            sliderInput("year_slide", label = "Year:",
                        min = 1989, max = 2013, value = 1989, step = 1, width='100%', animate=TRUE, sep="", ticks=FALSE, animationOptions(interval = 10 ,loop=TRUE, playButton, pauseButton))
        ),
        div(class="Choropleth",
            plotOutput('Choropleth', hover=hoverOpts(id="Choropleth_hover"))
        ),
        
        
        fluidRow(
            column(6,
                radioButtons("inequality_measure", label = h3("Inequality Measure"),
                             choices = list("Gini Coefficient" = 'Gini', "Top 1% Share of Income" = 'Top0.1'), 
                             selected = 'Gini', width="100%")
            ),
            column(6,
                h3('Hover Data'),
                tableOutput('dataTable')
            )
        )
    )
)

# Define server logic required to draw a chloropleth
server <- function(input, output) {
    state.from.hover <- function(point) {
        i = 1
        for (p in polygons){
            if (gContains(p, point)){
                tmp <- data %>% filter(group==i, Year==input$year_slide) %>% group_by(Area, Year) %>% summarise(Gini=mean(Gini), Top0.1 = mean(Top0.1))
                #return(paste("State: ", toupper(tmp$Area), "  ", input$inequality_measure, ": ", tmp[[input$inequality_measure]], sep=""))
                df = data.frame(matrix(c(toupper(tmp$Area), tmp[[input$inequality_measure]]), nrow=1, ncol=2))
                colnames(df) <- c('State', input$inequality_measure)
                return(df)
            }
            i = i + 1
        }
        
    }
    
    f = "DATA.Master.csv"
    data = read_csv(f)
    
    states <- map_data('state')
    names(states)[5]= "Area"
    data$Area <- sapply(data$Area, tolower)
    
    data <- states %>% inner_join(data) %>% arrange(Area, Year)
    
    polygons <- list()
    for (i in levels(factor(states$group))) {
         tmp = states %>% filter(group==i)
         buf = "POLYGON(("
         for (row in rownames(tmp)){
             if(row==1){
                 buf = paste(buf, tmp[row,1]," ", tmp[row,2], sep="")
             } else{
                 buf = paste(buf, ",", tmp[row,1]," ", tmp[row,2], sep="")
             }
         }
         buf = paste(buf,"))", sep="")
         #print(buf)
         polygon = readWKT(as.character(buf))
         polygons[[i]] <- polygon
    }
   
    
    
    data %>% filter(Year==2000) %>% ggplot() + 
        geom_polygon(aes(x=long, y=lat, group=group), colour="black", fill=NA)
   
    output$Choropleth <- renderPlot({
        inequality_col <- data %>% select(input$inequality_measure)
        legend_max <- max(inequality_col)
        legend_min <- min(inequality_col)
        p <- data %>% 
            filter(Year == input$year_slide) %>% 
            ggplot(aes_string(fill=input$inequality_measure)) + 
            geom_polygon(aes(x=long, y=lat, group=group)) + 
            theme_minimal() + 
            theme(axis.title=element_blank(), panel.grid=element_blank(), 
                  axis.text=element_blank(), legend.position=c(.95,.40), legend.direction="vertical", 
                  legend.key.height=unit(1,"cm")) + scale_fill_continuous(type="viridis", limits=c(legend_min,legend_max))
        p
    })
    
    
    output$dataTable <- renderTable({
        hover.long <- input$Choropleth_hover$x
        hover.lat <- input$Choropleth_hover$y
        if (length(hover.long) > 0)  {
            point <- readWKT(paste('POINT(',hover.long," ",hover.lat,")",sep=''))
            return(state.from.hover(point))
        }
        #return(point)
    })
    
}

# Run the application 
shinyApp(ui = ui, server = server)
