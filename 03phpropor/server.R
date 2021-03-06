library(shiny)
shinyServer(function(input,output,session){
  
  dt <- reactive({
    inFile <- input$file1
    if(is.null(inFile)) 
      dt <- read.table('datos.txt', header=T, sep='\t')
    else dt <- read.csv(inFile$datapath, header=input$header,
                        sep=input$sep)
  })
  
  observe({
    updateSelectInput(session, "variable", choices=names(dt())) 
  })
  
  observeEvent(input$variable, {
    column_levels <- as.character(sort(unique(dt()[[input$variable]])))
    updateSelectInput(session, "niveles", choices = column_levels)
  })
  
  output$inputData <- renderTable({
    inFile <- input$file1
    if(is.null(inFile)) 
      dt <- read.table('datos.txt', header=T, sep='\t')
    else dt <- read.csv(inFile$datapath, header=input$header, 
                        sep=input$sep)
    dt
  })
  
  
  output$appPlot <- renderPlot({
    inFile <- input$file1
    if(is.null(inFile)) 
      dt <- read.table('datos.txt', header=T, sep='\t')
    else dt <- read.csv(inFile$datapath, header=input$header, 
                        sep=input$sep)
    Niveles <- na.omit(dt[, input$variable])  # Para sacar los NA de la variable
    
    tabla <- table(Niveles)
    ptabla <- prop.table(tabla)
    xx <- barplot(ptabla, las=1, col='deepskyblue3',
                  ylab='Frecuencia relativa', 
                  xlab='Niveles', ylim=c(0, max(ptabla)+0.1))
    
    text(x=xx, y=ptabla, pos=3, cex=0.8, col="black",
         label=round(ptabla, 4))

  })
  
  output$consolidado <- renderTable({
    inFile <- input$file1
    if(is.null(inFile)) 
      dt <- read.table('datos.txt', header=T, sep='\t')
    else dt <- read.csv(inFile$datapath, header=input$header, 
                        sep=input$sep)
    y <- na.omit(dt[, input$variable])  # Para sacar los NA de la variable
    tabla <- table(y)
    x <- tabla[input$niveles]
    n <- sum(tabla)
    res <- cbind(x, n, x/n)
    colnames(res) <- c('Número de éxitos', 
                       'Número de casos', 
                       'Proporción observada')
    res
  }, align='c', bordered = TRUE, digits=4)
  
  output$resul1 <- renderText({
    inFile <- input$file1
    if(is.null(inFile)) 
      dt <- read.table('datos.txt', header=T, sep='\t')
    else dt <- read.csv(inFile$datapath, header=input$header, sep=input$sep)
    dt <- na.omit(dt)  # Para eliminar obs con NA
    
    y <- na.omit(dt[, input$variable])  # Para sacar los NA de la variable
    tabla <- table(y)
    x <- tabla[input$niveles]
    n <- sum(tabla)
    ph <- prop.test(x=x, n=n, alternative=input$h0, 
                    conf.level=input$alfa, p=input$p0,
                    correct=input$correct)
    
    ph$statistic <- sign(ph$estimate - ph$null.value) * sqrt(ph$statistic)
    paste0('El estadístico de prueba es z0=', round(ph$statistic, 4),
           ' con un valor-P de ', round(ph$p.value, 2), '.')
})
  
  output$resul2 <- renderText({
    inFile <- input$file1
    if(is.null(inFile)) 
      dt <- read.table('datos.txt', header=T, sep='\t')
    else dt <- read.csv(inFile$datapath, header=input$header, sep=input$sep)
    dt <- na.omit(dt)  # Para eliminar obs con NA
    
    y <- na.omit(dt[, input$variable])  # Para sacar los NA de la variable
    tabla <- table(y)
    x <- tabla[input$niveles]
    n <- sum(tabla)
    ph <- prop.test(x=x, n=n, alternative=input$h0, 
                    conf.level=input$alfa, p=input$p0,
                    correct=input$correct)
    
    intervalo <- paste("(", round(ph$conf.int[1], digits=4),
                       ", ",
                       round(ph$conf.int[2], digits=4),
                       ").", sep='')
    paste0('El intervalo de confianza del ', 100*input$alfa,
           '% para proporción poblacional es ',
           intervalo)
  })

})
