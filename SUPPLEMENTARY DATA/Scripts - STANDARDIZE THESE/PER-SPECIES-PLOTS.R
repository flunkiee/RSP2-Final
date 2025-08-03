library(tidyverse)
library(patchwork)


file_path <- file.choose()#only works with one file oops

df <- read_csv(file_path)

df <- df %>%
  mutate(
    Gene = str_extract(`Species 1`, "(?<=:)\\w+$"),
    Pair = paste(`Species 1`, `Species 2`, sep = " vs ")
  )

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


plots <- df %>%
  split(.$Gene) %>%
  map2(names(.), ~ plot_gene(.x, .y))

wrap_plots(plots) +
  plot_annotation(title = "Bacillus subtilis group dN-dS")
