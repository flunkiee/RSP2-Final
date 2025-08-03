library(tidyverse)
library(patchwork)
library(tcltk)    
library(tools)    

file_paths <- tk_choose.files(caption = "Select gene data files", multi = TRUE)


read_gene_file <- function(file_path) {
  gene_name <- file_path_sans_ext(basename(file_path))  # extract gene name from filename
  df <- read_csv(file_path)
  df <- df %>%
    mutate(
      Gene = gene_name,
      Pair = paste(`Species 1`, `Species 2`, sep = " vs ")
    )
  return(df)
}


all_data <- map_dfr(file_paths, read_gene_file)

plot_gene <- function(data, gene_name) {
  ggplot(data, aes(x = Pair, y = Dist)) +
    geom_point(shape = 21, color = "black", fill = "white") +
    geom_errorbar(aes(ymin = Dist - `Std. Err`, ymax = Dist + `Std. Err`), width = 0.2) +
    theme_minimal() +
    theme(
      panel.grid = element_blank(),
      axis.text.x = element_blank(),
      axis.title.x = element_blank()
    ) +
    labs(
      title = gene_name,
      y = "n-s"
    )
}

plots <- all_data %>%
  split(.$Gene) %>%
  map2(names(.), ~ plot_gene(.x, .y))


wrap_plots(plots) +
  plot_annotation(title = "Candidozyma Auris pN-pS")

