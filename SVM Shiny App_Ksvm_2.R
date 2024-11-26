library(shiny)
library(kernlab)
library(ggplot2)
library(plotly)

ui <- fluidPage(
  titlePanel("SVM Model Fitting and Visualization"),
  sidebarLayout(
    sidebarPanel(
      fileInput("datafile", "Upload CSV File", accept = ".csv"),
      uiOutput("feature_selector"),
      selectInput("kernel", "Kernel Type", 
                  choices = c("vanilladot", "rbfdot", "polydot", "tanhdot", "laplacedot", "besseldot", "anovadot", "splinedot")),
      numericInput("C", "Cost (C)", value = 1, min = 0.1, step = 0.1),
      numericInput("degree", "Polynomial Degree (for polydot)", value = 3, min = 1),
      numericInput("sigma", "Sigma (for rbfdot/laplacedot/anovadot)", value = 0.1, step = 0.01),
      actionButton("fit_model", "Fit Model")
    ),
    mainPanel(
     # plotOutput("svm_plot"),
      plotlyOutput("pairwise_plot"),
      verbatimTextOutput("model_summary")
    )
  )
)

server <- function(input, output, session) {
  rv <- reactiveValues(data = NULL, model = NULL, binary = TRUE)
  
  observeEvent(input$datafile, {
    rv$data <- read.csv(input$datafile$datapath)
    
    # Dynamically update the feature selection UI
    updateSelectInput(session, "x_feature", "Select X Features", choices = names(rv$data))
    updateSelectInput(session, "y_feature", "Select Y Feature (Class/Target)", choices = names(rv$data))
  })
  
  output$feature_selector <- renderUI({
    req(rv$data)
    tagList(
      # Enable multiple selection for x_feature
      selectInput("x_feature", "Select X Features", choices = names(rv$data), multiple = TRUE),
      selectInput("y_feature", "Select Y Feature (Class/Target)", choices = names(rv$data))
    )
  })
  
  observeEvent(input$fit_model, {
    req(rv$data, input$x_feature, input$y_feature)
    
    # Create the matrix of X features (multiple selected features)
    x <- as.matrix(rv$data[input$x_feature])  # Select multiple columns for X
    y <- as.factor(rv$data[[input$y_feature]])  # Y is the target variable
    
    rv$binary <- length(levels(y)) == 2
    
    # Construct kernel function
    kernel_function <- switch(input$kernel,
                              "vanilladot" = vanilladot(),
                              "rbfdot" = rbfdot(sigma = input$sigma),
                              "polydot" = polydot(degree = input$degree),
                              "tanhdot" = tanhdot(),
                              "laplacedot" = laplacedot(sigma = input$sigma),
                              "besseldot" = besseldot(),
                              "anovadot" = anovadot(sigma = input$sigma),
                              "splinedot" = splinedot())
    
    rv$model <- ksvm(x, y, type = "C-svc", kernel = kernel_function, C = input$C)
  })
  
  output$svm_plot <- renderPlot({
    req(rv$model, rv$binary, rv$data, input$x_feature, input$y_feature)
    
    if (rv$binary) {
      x <- as.matrix(rv$data[input$x_feature])  # Handle multiple features
      plot(rv$model, data = x)  # Plot SVM decision boundary
    } else {
      plot.new()
      text(0.5, 0.5, "Binary classification only for this plot.", cex = 1.2)
    }
  })
  
  output$pairwise_plot <- renderPlotly({
    req(rv$model, !rv$binary, rv$data, input$x_feature, input$y_feature)
    
    # Use first two features for pairwise plot (projection to 2D)
    x_data <- rv$data[[input$x_feature[1]]]  # Use the first feature for plotting
    y_data <- rv$data[[input$y_feature]]
    pred <- predict(rv$model, as.matrix(rv$data[input$x_feature]))
    
    p <- ggplot(rv$data, aes_string(x = input$x_feature[1], y = input$x_feature[2], color = "factor(pred)")) +
      geom_point(size = 3) +
      labs(title = "Pairwise Decision Boundaries", color = "Prediction") +
      theme_minimal()
    
    ggplotly(p)
  })
  
  output$model_summary <- renderPrint({
    req(rv$model)
    rv$model
  })
}

shinyApp(ui = ui, server = server)
