shinyUI(pageWithSidebar(
  
  headerPanel("Live examples for the course M1102"),
  
  sidebarPanel(p(HTML("Navigate through the different panels to study various
important properties of univariate descriptive statistics. These examples have
been designed for the course 'M1102' (<a href='www.stid-france.com'>DUT STID
</a>). They are kindly provided by <a href='http://www.nathalievilla.org'>
Nathalie Villa-Vialaneix</a>. The scripts are available for download on <a 
href='http://www.github.com'>GitHub</a>. Use <div style='font-size:12px;
font-family:courrier;background-color:#FADDF2;border:1px solid black;'>
<font color='#870500'><b>git clone https://github.com/tuxette/m1102.git</b>
</font></div>")),
               p(HTML("The scripts are provided without any guarantee under the
licence <a href='http://www.wtfpl.net/'>WTFPL</a>. They use the free language
<a href='http://cran.univ-paris1.fr'>R</a> and the package <a 
href='http://www.rstudio.com/shiny/'>shiny</a>. It is kindly hosted by <a
href='http://www.rstudio.com'>rstudio</a>."))
  ),
  
  mainPanel(
    tabsetPanel(
      tabPanel("Mean/Median",
               p(HTML("<form class='well' style='background-color:#FADDF2'>This
example illustrates how a single outlier can affect the mean whereas the median
remains unchanged. Use the slider control to move one value in the dataset:
observations are shown with black points on the horizontal axis. Look at the way
the mean varies whereas the median remains unchanged.</form>")),
               sliderInput("outlier", "Value of the outlier:", value = 0,
                           min = -25, max = 25),
               plotOutput("meanmedian")),
      
      tabPanel("Standard deviation",
               p(HTML("<form class='well' style='background-color:#FADDF2'>This
example illustrates the impact of the standard deviation on the variable
distribution. Use the slider control to select the standard deviation and see
how this changes the histogram. The scale of the standard deviation is
represented by a straight blue line at <i>y</i>-coordinate 0.35.</form>")),
               sliderInput("sd", "Standard deviation:", value=1, min=1, max=5,
                           step=0.5),
               plotOutput("sdchart")),
      
      tabPanel("Linear transformation",
               p(HTML("<form class='well' style='background-color:#FADDF2'>This
example illustrates the effect of a linear transformation of the data on the
main statistics. The original data, <i>X</i>, displayed on the first histogram
are transformed as <i>aX</i>+<i>b</i>, where <i>a</i> is called the slope and
<i>b</i> is called the intercept. Use the two slider controls to see how
changing the slope and intercept impacts the distribution and the main
statistics (below the graphic).</form>")),
               sliderInput("intercept", "Intercept:", value=0, min=-5, max=5),
               sliderInput("slope", "Slope:", value=1, min=0.5, max=2,
                           ticks=FALSE),
               plotOutput("transfchart"),
               tableOutput("transfnum")),
      
      tabPanel("Skewness",
               p(HTML("<form class='well' style='background-color:#FADDF2'>This
example illustrates the effect of the fact that the observation distribution
'leans' to one side of the mean on the skewness coefficient. Multiply positive
or negative values by a given factor and see how this affects the distribution,
the mean and the median as well as the skewness.</form>")),
               sliderInput("coefpos", "Multiply positive values by:", value=1,
                           min=1, max=5,step=0.5),
               sliderInput("coefneg", "Multiply negative values by:", value=1,
                           min=1, max=5,step=0.5),
               plotOutput("skewness")),
      
      tabPanel("Kurtosis",
               p(HTML("<form class='well' style='background-color:#FADDF2'>This
example illustrates the behaviour of the Kurtosis, which measures the peakedness
of a distribution, depending on the distribution type. Select one of the
distribution below and have a look at the histogram and corresponding Kurtosis.
</form>")),
               selectInput("dist", "Distribution type:", 
                           c("bimodal","uniform","gaussian","laplace"),
                           "gaussian"),
               plotOutput("kurtosis")),
      
      tabPanel("Gini/Lorenz",
               p(HTML("<form class='well' style='background-color:#FADDF2'>This
example illustrates the evolution of the Gini coefficient and Lorenz curve in a
very simple case: a firm with one director, 10 executives and 100 employees. Use
the two slider controls to set the salary of the director and of the executives
(the other employees' salary are supposed to be all equal to 1000 €) and see how
this affects the Gini coefficient and the Lorenz curve.</form>")),
               sliderInput("headsal","Director's monthly salary (k€):",
                           value=500, min=1, max=500),
               sliderInput("execsal","Executives' monthly salary (k€):",
                           value=50, min=1, max=50),
               p(HTML("Other employees' monthly salary: 1000€.")),
               plotOutput("gini")
      )
    )
  )
))