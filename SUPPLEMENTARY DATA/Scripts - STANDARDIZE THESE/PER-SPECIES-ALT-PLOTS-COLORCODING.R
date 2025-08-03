library(tidyverse)
library(patchwork)
library(tcltk)
library(tools)


file_paths <- tk_choose.files(caption = "Select gene data files", multi = TRUE)


read_gene_file <- function(file_path) {
  gene_name <- file_path_sans_ext(basename(file_path))
  df <- read_csv(file_path)
  
  df %>%
    mutate(
      Gene = gene_name,
      Pair = paste(`Species 1`, `Species 2`, sep = " & "),
      Clade_combo = map2_chr(.[[5]], .[[6]], ~ paste(sort(c(.x, .y)), collapse = " vs "))
    )
}

all_data <- map_dfr(file_paths, read_gene_file)


plot_gene <- function(data, gene_name) {
  ggplot(data, aes(x = Pair, y = Dist, fill = Clade_combo)) +
    geom_point(shape = 21, color = "black", size = 2.5, show.legend = FALSE) +
    geom_errorbar(aes(ymin = Dist - `Std. Err`, ymax = Dist + `Std. Err`), 
                  width = 0.2, linewidth = 0.5, show.legend = FALSE) +
    theme_minimal() +
    theme(
      panel.grid = element_blank(),
      axis.text.x = element_blank(),
      axis.title.x = element_blank()
    ) +
    labs(title = gene_name, y = "n-s") +
    scale_fill_brewer(palette = "Set3")
}


plots <- all_data %>%
  split(.$Gene) %>%
  map2(names(.), ~ plot_gene(.x, .y))


legend_plot <- ggplot(all_data, aes(x = Pair, y = Dist, fill = Clade_combo)) +
  geom_point(shape = 21, color = NA, size = 4) + 
  scale_fill_brewer(palette = "Set3", name = "Clade Comparisons") +
  theme(
    legend.direction = "horizontal",
    legend.position = "bottom",
    legend.justification = "center",
    legend.key.size = unit(0.5, "cm"),  
    legend.spacing.x = unit(0.3, "cm"),  
    legend.text = element_text(size = 8),
    legend.title = element_text(size = 9)
  ) +
  guides(fill = guide_legend(override.aes = list(size = 4, shape = 21, color = NA)))

legend <- cowplot::get_legend(legend_plot)


final_plot <- wrap_plots(plots, ncol = 2) / 
  legend +
  plot_layout(heights = c(20, 1)) +
  plot_annotation(title = "Candidozyma Auris pN-pS")

final_plot