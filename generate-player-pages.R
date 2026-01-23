library(tidyverse)

# Paths
data_file <- "data/scores.csv"
players_dir <- "players"
quarto_yaml <- "_quarto.yml"

# Ensure players folder exists
if(!dir.exists(players_dir)) dir.create(players_dir)

# Read player list from dataset
players <- read_csv(data_file) %>% 
  pull(player) %>% 
  unique() %>% 
  sort()

# Function to sanitize filenames (lowercase, replace spaces with _)
sanitize_filename <- function(name) {
  name %>% tolower() %>% gsub(" ", "_", .)
}

# Generate a .qmd file for each player
for(player_name in players) {
  file_name <- paste0(players_dir, "/", sanitize_filename(player_name), ".qmd")
  
  template <- readLines("_players-template.qmd")
  filled <- gsub("\\{\\{PLAYER_NAME\\}\\}", player_name, template)
  filled <- gsub("\\{\\{TITLE_PLAYER_NAME\\}\\}", tools::toTitleCase(player_name), filled)
  writeLines(filled, file_name)
}

# Build the fixed YAML navbar section
navbar_yaml <- c(
  "project:",
  "  type: website",
  "  output-dir: docs",
  "  pre-render: \"Rscript generate-player-pages.R\"",
  "",
  "format:", 
  "  html:",
  "    theme: cosmo",
  "",
  "website:",
  "  title: \"Bowling Stats\"",
  "  navbar:",
  "    left:",
  "      - text: \"Leaderboard\"",
  "        href: index.qmd"
)

# Add each player to the menu
player_lines <- unlist(lapply(players, function(p) {
  fname <- sanitize_filename(p)
  c(
    paste0("      - text: \"", tools::toTitleCase(p), "\""),
    paste0("        href: players/", fname, ".qmd")
  )
}))

# Combine navbar YAML with player entries
yaml_lines <- c(navbar_yaml, player_lines)

# Write the YAML to _quarto.yml
writeLines(yaml_lines, quarto_yaml)

cat("Generated", length(players), "player pages and updated _quarto.yml with fixed navbar structure\n")