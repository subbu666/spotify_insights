# 🎵 Spotify Insights - Data Analysis & Visualization with Shiny

Welcome to **Spotify Insights**, an interactive Shiny dashboard that provides **data-driven insights** into popular songs from Spotify! This project leverages \*\*R, Shiny, \*\*to analyze **popularity trends, song characteristics, and artist performances** over time. 🚀

---

## 📌 Features

✅ **Interactive Visualizations** - Explore histograms, scatter plots, and bar charts with Plotly & ggplot2.\
✅ **Popularity Trends** - Discover how explicit content, valence, and song duration impact popularity.\
✅ **Top Artists & Songs** - Identify top-performing artists and their contribution to Spotify's hit songs.\
✅ **User Authentication** - Secure access with login credentials.\
✅ **Data Filtering & Export** - Download filtered datasets for further analysis.\
✅ **Dynamic Dashboard** - Built with Shiny Dashboard for a seamless user   experience.

---

## 📊 Data Overview

The dataset `spotify_top_hits.csv` contains:

- **song\_title**: Name of the song
- **artist**: Performing artist(s)
- **popularity**: Popularity score (0-100)
- **duration\_ms**: Song duration in milliseconds
- **explicit**: Whether the song has explicit content (TRUE/FALSE)
- **year**: Release year of the song
- **valence**: Musical positivity of the track
- **danceability, energy, tempo**: Audio features defining song characteristics

A new feature **`popularity_rating`** has been created:

- **Low** (popularity ≤ 60)
- **Medium** (60 < popularity ≤ 80)
- **High** (popularity > 80)

---

## 🛠️ Installation & Setup

1️⃣ **Clone this repository**

```bash
git clone https://github.com/your-repo/Spotify-Insights.git
cd Spotify-Insights
```

2️⃣ **Install Required R Packages** *(Skip if already installed)*

```r
install.packages(c("shiny", "shinydashboard", "ggplot2", "plotly", "dplyr", "DT", "shinythemes", "shinyjs", "shinyalert", "factoextra"))
```

3️⃣ **Run the Shiny App**

```r
library(shiny)
runApp("app.R")
```

---

## 📺 Dashboard Overview

| Feature                    | Description                                          |
| -------------------------- | ---------------------------------------------------- |
| 📊 Histogram               | Distribution of song popularity                      |
| 🔥 Popularity vs. Explicit | Relationship between popularity and explicit content |
| 🎭 Popularity Rating       | Categorization of songs based on popularity          |
| 🎤 Top Artists             | Most popular artists based on song count             |
| ⏳ Song Duration Trends     | How song durations have changed over the years       |
| 🎶 Popularity vs. Valence  | Influence of song valence on popularity              |
| 📋 Data Table              | Interactive table with filtering options             |
| ⬇️ Download Data           | Export filtered datasets                             |

---

## 🏆 Why This Project Stands Out

💡 **Innovative**: Combines data visualization with ML-powered insights.\
📊 **User-Friendly**: Interactive dashboard with clear insights.\
🔍 **Actionable Insights**: Helps artists and listeners understand trends.\
📈 **Scalable**: Easily extendable with more data and advanced ML models.

---

## 🚀 Future Enhancements

🔹 **More Audio Feature Analysis** - Deep dive into danceability, speechiness, and instrumentalness.\
🔹 **Recommendation System** - Suggest songs based on listening patterns.\
🔹 **Sentiment Analysis** - Analyze lyrics to predict popularity.\
🔹 **Deployment** - Host the app on **ShinyApps.io** or a cloud platform.

---

##
