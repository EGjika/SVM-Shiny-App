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
      #plotOutput("svm_plot"),
      plotlyOutput("pairwise_plot"),
      verbatimTextOutput("model_summary")
    )
  )
)

server <- function(input, output, session) {
  # Reactive values to store dataset and model
  rv <- reactiveValues(data = NULL, model = NULL, binary = TRUE)
  
  # Load dataset and update UI for feature selection
  observeEvent(input$datafile, {
    rv$data <- read.csv(input$datafile$datapath)
    updateSelectInput(session, "x_feature", "Select X Feature", choices = names(rv$data))
    updateSelectInput(session, "y_feature", "Select Y Feature (Class/Target)", choices = names(rv$data))
  })
  
  # Dynamically render feature selectors
  output$feature_selector <- renderUI({
    req(rv$data)
    tagList(
      selectInput("x_feature", "Select X Feature", choices = names(rv$data)),
      selectInput("y_feature", "Select Y Feature (Class/Target)", choices = names(rv$data))
    )
  })
  
  # Fit the model when button is clicked
  observeEvent(input$fit_model, {
    req(rv$data, input$x_feature, input$y_feature)
    x <- as.matrix(rv$data[[input$x_feature]])
    y <- as.factor(rv$data[[input$y_feature]])
    
    # Check if binary classification
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
    
    # Fit the model
    rv$model <- ksvm(x, y, type = "C-svc", kernel = kernel_function, C = input$C)
  })
  
  # Plot the model (binary classification only)
  output$svm_plot <- renderPlot({
    req(rv$model, rv$binary, rv$data, input$x_feature, input$y_feature)
    if (rv$binary) {
      x <- as.matrix(rv$data[[input$x_feature]])
      plot(rv$model, data = x)
    } else {
      plot.new()
      text(0.5, 0.5, "Binary classification only for this plot.", cex = 1.2)
    }
  })
  
  # Pairwise decision boundaries for multiclass
  output$pairwise_plot <- renderPlotly({
    req(rv$model, !rv$binary, rv$data, input$x_feature, input$y_feature)
    x_data <- rv$data[[input$x_feature]]
    y_data <- rv$data[[input$y_feature]]
    pred <- predict(rv$model, as.matrix(x_data))
    
    # Generate a ggplot visualization
    p <- ggplot(rv$data, aes_string(x = input$x_feature, y = input$y_feature, color = "factor(pred)")) +
      geom_point(size = 3) +
      labs(title = "Pairwise Decision Boundaries", color = "Prediction") +
      theme_minimal()
    ggplotly(p)
  })
  
  # Display model summary
  output$model_summary <- renderPrint({
    req(rv$model)
    rv$model
  })
}

shinyApp(ui = ui, server = server)
