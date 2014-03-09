## Setup
source("server.R")

## Specify layout
shinyUI(pageWithSidebar(
	
	headerPanel(HTML("Simple Mortgage Calculator")),
	
	
	sidebarPanel(
		## Construct input options
		
		## Enter mortgage information
		h4("Mortgage parameters"),
		
		## Loan amount
		numericInput("principal", "Amount borrowed", 10000, min=1),
		helpText("This is the amount you will borrow and is called the loan's principal."),
		
		## Interest rate
		numericInput("interest", "Yearly interest rate (in %)", 10, min=0.01, max=100, step=0.01),
		helpText("The yearly interest rate (in %) should be a number between 0.01 and 100. Lower values are better for you!"),
		
		## Loan duration
		numericInput("duration", "Loan duration (in years)", 5, min=1/12, max=100, step=1/12),
		helpText("The total duration of the loan in years. It can be a fraction with 1/12 increments per extra month, for example 3.5 years (3 years and 6 months)."),
		
		## Payment frequency
		sliderInput("payfreq", "Payment frequency (in months)", value=1, min=1, max=12, step=1),
		helpText("How frequently you will make payments? (in months) Minimum every month and maximum every year (12 months)."),
		
		## When will you make your first payment?
		numericInput("firstpay", "Month of the first payment", 1, min=1, max=5 * 12, step=1),
		helpText("In which month will you make your first payment?"),
		
		## Frquency of interest compounding
		numericInput("compoundfreq", "How frequently are interests compounded? (in months)", value=1, min=1, max=12, step=1),
		helpText("That is, how frequently interests are calculated. Banks will normally compound the interest at the same frequency that payments are made. Only consider a more frequent interest compounding than payment frequency if the loaner is willing to give you such a deal (for example, to reduce costs from commissions on currency trades or wire transfers).")
		
		
		
		
	),
		
	mainPanel(
		tabsetPanel(
			## Main results
			tabPanel("Results",
				h4("Punchline"),
				verbatimTextOutput("payment"),
				h4("Loan's principle over time"),
				p("The following interactive plot shows how the loan's principal changes over time as well as how much you've payed. You can use the bottom panel to zoom into a region of interest. You can also hover your mouse on top of a line to see the closest value."),
				showOutput("myChart", "nvd3"),
				h4("Amortization table"),
				p("The following interactive table shows how much you pay (and when), the total amount you have payed and the remaining principal (it is only shown for the months when interest compounding is calculated)."),
				dataTableOutput("amort"),
				h4("Download"),
				HTML("Download the amortization table in <a href='http://en.wikipedia.org/wiki/Comma-separated_values'>CSV</a> format."),
				downloadButton('downloadData', 'Download'),
				tags$hr()
			),
			
			## Credits
			tabPanel("Credits",
				HTML("Main source: <a href='http://en.wikipedia.org/wiki/Mortgage_calculator'>Mortgage calculator</a> by Wikipedia. Also used <a href='http://www.drcalculator.com/mortgage/instructions.html'>these instructions</a> linked from <a href='http://www.r-chart.com/2010/11/mortgage-calculator-and-amortization.html'>'Mortgage Calculator (and Amortization Charts) with R'</a>. You may also want to check out the <a href='http://biostatmatt.com/archives/1908'>'Mortgage Refinance Calculator'</a>. "),
				tags$hr(),
				HTML("Chart made with <a href='http://rcharts.readthedocs.org/en/latest/'>rCharts</a> with the <a href='http://nvd3.org/'>NVD3</a> library."),
				tags$hr(),
				HTML("Powered by <a href='http://www.rstudio.com/shiny/'>Shiny</a> and hosted by <a href='http://www.rstudio.com/'>RStudio</a>."),
				HTML("Developed by <a href='http://bit.ly/LColladoTorres'>L. Collado Torres</a>."),
				HTML("Version 0.0.2. Code hosted by <a href='https://github.com/lcolladotor/mortgage'>GitHub</a>."),
				tags$hr()
				
			)
			
		)
	)
	
))
