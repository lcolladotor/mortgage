## Setup
library("shiny")
library("rCharts")
library("reshape2")


## Calculate payment
pay <- function(principal, interest, duration, payfreq, firstpay, compoundfreq) {
	
	r <- interest / (100 * 12 / compoundfreq ) 
	
	if(firstpay > 1) {
		principal <- principal * (1 + r)^((firstpay - 1) / compoundfreq)
		duration <- duration - (firstpay - 1) / 12
	}	
	
	payment <- principal * r / ( 1 - ( 1 + r)^(-duration * 12 / compoundfreq) ) * payfreq / compoundfreq
	res <- list(r=r, payment=payment, principal=principal)
	return(res)
}

## Amortization table
amort <- function(principal, interest, duration, payfreq, firstpay, compoundfreq) {
	pay <- pay(principal, interest, duration, payfreq, firstpay, compoundfreq)
	data <- data.frame(month = seq(0, duration * 12))
	data$payment <- 0
	data$payment[ (data$month - firstpay) >= 0 & (data$month - 1) %% payfreq == 0 ] <- pay$payment
	data$totalPayed <- cumsum(data$payment)
	
	data$principal <- NA
	data$principal[1] <- principal
	idx <- data$month - firstpay >=0 & (data$month - firstpay) %% compoundfreq == 0
	idx.pr <- which(idx)[-length(idx)] + compoundfreq - 1
	idx.pr <- idx.pr[-which(idx.pr > max(data$month))]
	if(firstpay > 1) {
		data$principal[firstpay] <- pay$principal
	}
	data$principal[ idx.pr ] <- (1 + pay$r)^seq_len(length(idx.pr)) * pay$principal - ( (1 + pay$r)^seq_len(length(idx.pr)) - 1 ) / pay$r * pay$payment * compoundfreq / payfreq
	data$principal[ nrow(data)] <- 0
	
	return(data)
}

## Main shiny function
shinyServer(function(input, output, session) {
	## Update max payment frequency
	observe({
		updateNumericInput(session, "firstpay", "Month of the first payment", 1, min=0, max=input$duration * 12, step=1)
	})
	
	## Display payment
	output$payment  <- renderPrint({
		payment <- pay(input$principal, input$interest, input$duration, input$payfreq, input$firstpay, as.integer(input$compoundfreq))$payment
		cat("Your recurrent payment (every ")
		if(input$payfreq > 1) {
			cat(input$payfreq)
			cat(" months")
		} else {
			cat("month")
		}
		
		cat(") will be ")
		cat(round(payment, 2))
		cat(".\nAt the end of the loan you will have payed a total of ")
		total <- payment * (input$duration - (input$firstpay - 1) / 12) * 12 / input$payfreq
		cat(round(total, 2))
		cat(".\nThat is, a total of ")
		cat(round(total - input$principal, 2))
		cat(" in interests.")
	})
	
	## Make a chart with the data
	output$myChart <- renderChart({
		data <- amort(input$principal, input$interest, input$duration, input$payfreq, input$firstpay, as.integer(input$compoundfreq))
		dat.chart <- melt(data, id = 'month')
		dat.chart$value <- round(dat.chart$value, 0)
		chart <- nPlot(value ~ month, group = 'variable',
			data = dat.chart[complete.cases(dat.chart), ],
			type = 'lineWithFocusChart'
		)
		chart$xAxis(axisLabel = 'Month')
		chart$addParams(dom = 'myChart')
		return(chart)
	})

	
	## Display amortization table
	output$amort <- renderDataTable({
		data <- amort(input$principal, input$interest, input$duration, input$payfreq, input$firstpay, as.integer(input$compoundfreq))
		data[-1, ]
	}, options = list(iDisplayLength = 12))
	
	## Download table
	output$downloadData <- downloadHandler(
		filename = function() { paste("amortization-table-", round(runif(1, 1e12, 1e13-1), 0), '.csv', sep='') },
			content = function(file) {
			write.csv(amort(input$principal, input$interest, input$duration, input$payfreq, input$firstpay, as.integer(input$compoundfreq)), file)
		}
	)
})
