library(ineq)
library(ggplot2)
library(bitops)
library(e1071)
data1 <- rnorm(20)
data2 <- rnorm(1000)

# for emulating ggplot2 default colors
ggColors <- function(n) {
  hues = seq(15, 375, length=n+1)
  hcl(h=hues, l=65, c=100)[1:n]
}

shinyServer(function(input, output) {
  
  # mean/median comparison
  newData1 <- reactive({
    c(data1, input$outlier)
  })
  
  test <- renderPrint({
    paste("mean",mean(newData1()),"median",median(newData1()))
  })
  
  output$meanmedian <- renderPlot({
    new.d <- newData1()
    new.d <- data.frame(value=new.d)
    new.d$y <- rep(0,length(new.d$value))
    p <- ggplot(new.d, aes(value)) +
      geom_histogram(binwidth=1, aes(fill=..density.., y=..density..))+
      geom_point(x=new.d$value, y=new.d$y, size=3)+xlim(-25,25)+xlab("data")+
      scale_fill_gradient("Density", low = "pink", high = "darkred")+
      geom_vline(xintercept=mean(new.d$value), size=1, colour=ggColors(3)[3])+
      geom_vline(xintercept=median(new.d$value), size=1, colour=ggColors(3)[2])+
      ggtitle(paste("Mean (blue line):", round(mean(new.d$value),2),
                    "\n Median (green line):", round(median(new.d$value),2)))
    print(p)
  })
  
  # standard deviation
  newData2 <- reactive({
    data2*input$sd
  })
  
  output$sdchart <- renderPlot({
    new.d <- newData2()
    new.d <- data.frame("value"=new.d)
    p <- ggplot(new.d, aes(value)) +
      geom_histogram(binwidth=1, aes(fill=..density.., y=..density..))+
      xlim(-20,20)+ylim(0,0.4)+
      scale_fill_gradient("Density", low = "pink", high = "darkred")+
      geom_density()+xlab("data")+
      geom_segment(x = 0, y = 0.35, xend = sd(new.d$value), yend = 0.35,
                   colour=ggColors(3)[3], size=1.4)
    print(p)
  })
  
  # linear transformation
  newData3 <- reactive({
    data2*input$slope+input$intercept
  })
  
  output$transfchart <- renderPlot({
    new.d <- newData3()
    new.d <- data.frame("value"=new.d)
    p <- ggplot(new.d, aes(value)) +
      geom_histogram(binwidth=0.5, aes(fill=..density.., y=..density..))+
      xlim(-10,10)+
      scale_fill_gradient("Density", low = "pink", high = "darkred")+
      geom_density()+xlab("data")
    print(p)
  })
  
  output$transfnum <- renderTable({
    new.d <- newData3()
    trnum <- data.frame("mean"=mean(new.d), "sd"=sd(new.d), "var"=var(new.d), 
                        "Q1"=quantile(new.d,0.25), "median"=median(new.d),
                        "Q3"=quantile(new.d,0.75))
    rownames(trnum) <- "Main statistics:"
    trnum
  })
  
  # Skewness
  newData4 <- reactive({
    new.d <- data2
    new.d[new.d>0] <- new.d[new.d>0]*input$coefpos
    new.d[new.d<0] <- new.d[new.d<0]*input$coefneg
    
    new.d <- data.frame("value"=new.d)
    new.d
  })
  
  output$skewness <- renderPlot({
    new.d <- newData4()
    p <- ggplot(new.d, aes(x=value)) +
      geom_histogram(binwidth=0.5, aes(fill=..density.., y=..density..))+
      xlim(-10,10)+xlab("data")+geom_density()+ylim(0,0.5)+
      scale_fill_gradient("Density", low = "pink", high = "darkred")+
      ggtitle(paste("Skewness:", round(skewness(new.d$value, type=1),2),
                    "\n Mean (blue line):", round(mean(new.d$value), 2),
                    " - Median (green line):", round(median(new.d$value), 2)))+
      geom_vline(xintercept=mean(new.d$value), size=1, colour=ggColors(3)[3])+
      geom_vline(xintercept=median(new.d$value), size=1, colour=ggColors(3)[2])
    print(p)
  })
  
  # Kurtosis coefficient
  rlaplace <- function(n) {
    base.obs <- runif(n,-1/2,1/2)
    -sign(base.obs)*log(1-2*abs(base.obs))
  }
  
  newData5 <- reactive({
    new.d <- switch(input$dist,
                    "bimodal"=c(rnorm(500,-5,0.5),rnorm(500,5,0.5)),
                    "uniform"=runif(1000,-10,10),
                    "gaussian"=rnorm(1000),
                    "laplace"=rlaplace(1000)
    )
                    
    new.d <- data.frame("value"=new.d)
    new.d
  })
  
  output$kurtosis <- renderPlot({
    new.d <- newData5()
    p <- ggplot(new.d, aes(x=value)) +
      geom_histogram(binwidth=0.5, aes(fill=..density.., y=..density..))+
      xlim(-10,10)+xlab("data")+geom_density()+ylim(0,0.5)+
      scale_fill_gradient("Density", low = "pink", high = "darkred")+
      ggtitle(paste("Kurtosis:", round(kurtosis(new.d$value, type=1),2)+3))
    print(p)
  })
  
  # Lorentz's curve and Gini coefficient
  newData6 <- reactive({
    new.d <- c(input$headsal, rep(input$execsal,10), rep(1,100))
    new.d <- data.frame("value"=new.d)
    new.d
  })
  
  output$gini <- renderPlot({
    new.d <- newData6()
    gini.index <- ineq(new.d$value, type="Gini")
    lorenz.curve <- Lc(new.d$value)
    lorenz.curve <- data.frame(x=lorenz.curve$p, y=lorenz.curve$L)
    p <- ggplot(lorenz.curve, aes(x,y)) +
      geom_line(size=1.2, colour=ggColors(3)[1]) +
      ggtitle(paste("Gini index:",round(gini.index,3))) +
      geom_abline(intercept=0, slope=1)+
      geom_polygon(fill=ggColors(3)[1])+xlab("Cumulative salary")+
      ylab("Cumulative frequency")
    print(p)
  })
})