# Install and load required libraries 

#already I have installed all the libraries so i used comments to avoid re-installation if I run the app.

#install.packages("ggplot2")
#install.packages("dplyr")
#install.packages("readr")
#install.packages("shiny")
#install.packages("shinydashboard")
#install.packages("shinyjs")
#install.packages("shinythemes")
#install.packages("shinyalert")
#install.packages("DT")
#install.packages("plotly")
#install.packages("factoextra")

library(ggplot2)
library(dplyr)
library(readr)
library(shiny)
library(shinydashboard)
library(shinyjs)
library(shinythemes)
library(shinyalert)
library(DT)
library(plotly)
library(factoextra)
# Load the dataset
spotify_songs <- read.csv("spotify_top_hits.csv", header = TRUE, sep = ",")
print(head(spotify_songs))

# Data Preprocessing
spotify_songs <- spotify_songs %>%  #pipeline Operator(%>%)
  mutate(duration_min = (duration_ms / 1000) / 60)

# Creating popular_rating for analysis
spotify_songs$popularity_rating <- as.factor(
  ifelse(spotify_songs$popularity <= 60, "Low - Under 60", 
         ifelse(spotify_songs$popularity <= 80, "Med - 60-79", 
                "High - 80 above"
         )
  )
)

#User Interface
ui <- dashboardPage(
  dashboardHeader(title = "SPOTIFY INSIGHTS"),
  dashboardSidebar(
    sidebarMenu(
      menuItem("Histogram", tabName = "histogram"),
      menuItem("Popularity vs. Explicit Content", tabName = "popularity_explicit"),
      menuItem("Popularity Rating", tabName = "popularity_rating"),
      menuItem("Top Artists", tabName = "top_artists"),
      menuItem("Song Duration Over Years", tabName = "duration_over_years"),
      menuItem("Popularity vs. Valency", tabName = "popularity_valency"),
      menuItem("Data Table", tabName = "data_table"),
      menuItem("Download Data", tabName = "download_data"),
      menuItem("Exit Dashboard", tabName = "exit_dashboard", icon = icon("sign-out-alt"))
    )
  ),
  dashboardBody(
    useShinyjs(),
    useShinyalert(force = TRUE),
    uiOutput("welcome_message"),
    fluidRow(
      column(2,
             actionButton("refresh_data_btn", "Refresh Data", class = "btn-info"),
             actionButton("reset_filters_btn", "Reset Filters", class = "btn-warning")
      ),
      column(2,
             actionButton("toggle_sidebar_btn", "Toggle Sidebar", class = "btn-secondary"),
             actionButton("logout_btn", "Logout", class = "btn-danger")
      )
    ),
    tags$style(HTML("
      .btn-info, .btn-warning, .btn-secondary, .btn-danger {
        margin-bottom: 10px; /* Adjust the spacing between buttons */
      }
    ")),
    tabItems(
      tabItem(tabName = "histogram",
              plotlyOutput("histogram_plot")),
      tabItem(tabName = "popularity_explicit",
              plotlyOutput("popularity_explicit_plot")),
      tabItem(tabName = "popularity_rating",
              plotlyOutput("popularity_rating_plot")),
      tabItem(tabName = "top_artists",
              plotlyOutput("top_artists_plot")),
      tabItem(tabName = "duration_over_years",
              plotlyOutput("duration_over_years_plot")),
      tabItem(tabName = "popularity_valency",
              plotlyOutput("popularity_valency_plot")),
      tabItem(tabName = "data_table",
              DTOutput("data_table")),
      tabItem(tabName = "download_data",
              fluidRow(
                box(
                  title = "Download Filtered Data", status = "primary", solidHeader = TRUE, width = 12,
                  selectInput("artist_filter", "Filter by Artist:", choices = c("All", unique(spotify_songs$artist)), selected = "All"),
                  downloadButton("download_data_btn", "Download Data")
                )
              )
      ),
      tabItem(tabName = "exit_dashboard",
              fluidRow(
                box(
                  title = "Exit Dashboard", status = "danger", solidHeader = TRUE, width = 12,
                  actionButton("exit_button", "Exit Dashboard", class = "btn-danger")
                )
              )
      )
    )
  ),
  skin = "red"
)

server <- function(input, output, session) {
  
  # Reactive values to store login status and username
  credentials <- reactiveValues(authenticated = FALSE, username = NULL)
  
  # Dummy user credentials
  valid_users <- data.frame(
    username = c("subbu", "ram", "Bhavana"),
    password = c("123", "123", "Bhavana"),
    stringsAsFactors = FALSE
  )
  
  # Check credentials and update reactive values
  observeEvent(input$login_button, {
    req(input$username, input$password)
    if (input$username %in% valid_users$username && 
        input$password == valid_users$password[valid_users$username == input$username]) {
      credentials$authenticated <- TRUE
      credentials$username <- input$username
      shinyalert("Welcome", paste("Welcome,", credentials$username, "!"), type = "success")
      delay(1000, {
        hide("welcome_message")  # Delay for 1 second before hiding welcome message
        removeModal() # Remove the modal
      })
    } else {
      shinyalert("Invalid Credentials", "Incorrect username or password. Please try again.", type = "error")
    }
  })
  
  # Show login modal if not authenticated
  observe({
    if (!credentials$authenticated) {
      showModal(modalDialog(
        title = div(style = "color: #347AB7; text-align: center; font-size: 24px; font-weight: bold;", "Login"),
        textInput("username", "Username:", placeholder = "Enter your username"),
        passwordInput("password", "Password:", placeholder = "Enter your password"),
        div(style = "text-align: center;", actionButton("login_button", "Login", class = "btn-primary")),
        easyClose = FALSE,
        footer = NULL,
        tags$style(HTML("
          .modal-dialog {
            width: 400px;
          }
          .modal-content {
            padding: 20px;
            border-radius: 10px;
            border: 1px solid #ccc;
            box-shadow: 0 0 10px rgba(0, 0, 0, 0.1);
          }
          .modal-title {
            color: #347AB7;
            font-size: 24px;
            font-weight: bold;
            text-align: center;
          }
          .btn-primary {
            background-color: #347AB7;
            border-color: #347AB7;
          }
          .btn-primary:hover {
            background-color: #286090;
            border-color: #204d74;
          }
        ")),
        tags$script(HTML("
          $(document).on('keypress', function(e) {
            if(e.which == 13) {
              $('#login_button').click();
            }
          });
        "))
      ))
    }
  })
  
  # Display welcome message
  output$welcome_message <- renderUI({
    req(credentials$authenticated)
    tagList(
      h3(paste("Welcome,", credentials$username, "!"))
    )
  })
  
  # Plots (only render if authenticated)
  output$histogram_plot <- renderPlotly({
    req(credentials$authenticated)
    p <- ggplot(spotify_songs, aes(x = popularity)) +  
      geom_histogram(bins = 15, fill = "orange") + 
      labs(title = "Popularity Distribution by Song", x = "Popularity", y = "Count") + 
      theme_minimal()
    ggplotly(p)
  })
  
  output$popularity_explicit_plot <- renderPlotly({
    req(credentials$authenticated)
    p <- ggplot(spotify_songs, aes(x = popularity, fill = explicit)) + 
      geom_histogram() + 
      scale_fill_manual(values = c("True"="red","False"="blue"))+
      ggtitle("Popularity Change with Explicit Content")
    ggplotly(p)
  })
  
  output$popularity_rating_plot <- renderPlotly({
    req(credentials$authenticated)
    p <- ggplot(spotify_songs, aes(x = popularity_rating)) + 
      geom_bar() + 
      labs(title = "Popularity of Songs Rated High, Med, Low") + 
      theme_minimal()
    ggplotly(p)
  })
  
  output$top_artists_plot <- renderPlotly({
    req(credentials$authenticated)
    Artist_Popular <- spotify_songs %>% count(artist, sort = TRUE, name = "Count") 
    Artist_Fil <- Artist_Popular %>% filter(Count >= 15) 
    p <- ggplot(Artist_Fil, aes(x = reorder(artist, Count), y = Count)) + 
      geom_bar(stat = "identity", fill = "red") + 
      coord_flip() + 
      labs(y = "Number of Songs", x = "Artist", title = "Top Artists by Number of Songs") + 
      theme_minimal()
    ggplotly(p)
  })
  
  output$duration_over_years_plot <- renderPlotly({
    req(credentials$authenticated)
    song_duration <- transmute(spotify_songs, duration_min = (duration_ms / 1000) / 60 , year) 
    p <- ggplot(song_duration, aes(x = year, y = duration_min)) + 
      labs(title = "Duration of Songs Over Years (2000-2020)", x = "Year", y = "Duration (minutes)") + 
      geom_smooth() + 
      geom_point()
    ggplotly(p)
  })
  
  output$popularity_valency_plot <- renderPlotly({
    req(credentials$authenticated)
    p <- ggplot(spotify_songs, aes(x = valence, y = popularity, color = duration_min)) + 
      geom_point(size = 2) + 
      ggtitle("Relationship Between Song Popularity and Valency")
    ggplotly(p)
  })
  
  # Data Table
  output$data_table <- renderDT({
    req(credentials$authenticated)
    datatable(spotify_songs, options = list(pageLength = 10, autoWidth = TRUE))
  })
  
  # Download Data
  output$download_data_btn <- downloadHandler(
    filename = function() {
      paste("spotify_songs_filtered_", Sys.Date(), ".csv", sep = "")
    },
    content = function(file) {
      filtered_data <- if (input$artist_filter == "All") {
        spotify_songs
      } else {
        spotify_songs %>% filter(artist == input$artist_filter)
      }
      write.csv(filtered_data, file, row.names = FALSE)
      shinyalert("Download Complete", "Your filtered data has been downloaded.", type = "success")
    }
  )
  
  # Refresh Data
  observeEvent(input$refresh_data_btn, {
    spotify_songs <<- read.csv("spotify_top_hits.csv", header = TRUE, sep = ",")
    spotify_songs <<- spotify_songs %>%
      mutate(duration_min = (duration_ms / 1000) / 60)
    spotify_songs$popularity_rating <<- as.factor(
      ifelse(spotify_songs$popularity <= 60, "Low - Under 60", 
             ifelse(spotify_songs$popularity <= 80, "Med - 60-79", 
                    "High - 80 above"
             )
      )
    )
    shinyalert("Data Refreshed", "The dataset has been refreshed.", type = "success")
  })
  
  # Reset Filters
  observeEvent(input$reset_filters_btn, {
    updateSelectInput(session, "artist_filter", selected = "All")
    shinyalert("Filters Reset", "All filters have been reset.", type = "success")
  })
  
  # Toggle Sidebar
  observeEvent(input$toggle_sidebar_btn, {
    shinyjs::toggle(id = "sidebarItemExpanded", anim = TRUE)
  })
  
  # Logout
  observeEvent(input$logout_btn, {
    credentials$authenticated <- FALSE
    credentials$username <- NULL
    shinyalert("Logged Out", "You have been logged out.", type = "info")
    showModal(modalDialog(
      title = div(style = "color: #347AB7; text-align: center; font-size: 24px; font-weight: bold;", "Login"),
      textInput("username", "Username:", placeholder = "Enter your username"),
      passwordInput("password", "Password:", placeholder = "Enter your password"),
      actionButton("login_button", "Login", class = "btn-primary"),
      easyClose = FALSE,
      footer = NULL,
      tags$style(HTML("
        .modal-dialog {
          width: 400px;
        }
        .modal-content {
          padding: 20px;
          border-radius: 10px;
          border: 1px solid #ccc;
          box-shadow: 0 0 10px rgba(0, 0, 0, 0.1);
        }
        .modal-title {
          color: #347AB7;
          font-size: 24px;
          font-weight: bold;
          text-align: center;
        }
        .btn-primary {
          background-color: #347AB7;
          border-color: #347AB7;
        }
        .btn-primary:hover {
          background-color: #286090;
          border-color: #204d74;
        }
      ")),
      tags$script(HTML("
        $(document).on('keypress', function(e) {
          if(e.which == 13) {
            $('#login_button').click();
          }
        "))
    ))
  })
  
  # Exit Dashboard
  observeEvent(input$exit_button, {
    stopApp()
  })
}
# Run the application
shinyApp(ui = ui, server = server)
