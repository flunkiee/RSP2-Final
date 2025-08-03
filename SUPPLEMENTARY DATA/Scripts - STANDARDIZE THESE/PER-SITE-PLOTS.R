library(tcltk)
library(readr)
library(ggplot2)
library(patchwork)
library(cowplot)

# Select files
file_paths <- tk_choose.files(caption = "Select one or more CSV files")
if (length(file_paths) == 0) stop("No files selected.")


fill_levels <- c(
  "Significant Positive (α > β)",
  "Insignificant Positive",
  "Insignificant Negative",
  "Significant Negative (β > α)"
)

fill_colors <- c(
  "Significant Positive (α > β)" = "steelblue",
  "Insignificant Positive" = "lightblue",
  "Insignificant Negative" = "lightcoral",
  "Significant Negative (β > α)" = "firebrick"
)

plots <- lapply(file_paths, function(file_path) {
  df <- read_csv(file_path, col_types = cols())
  
  site <- factor(df[[1]], levels = unique(df[[1]]))
  alpha <- as.numeric(df[[3]])
  beta <- as.numeric(df[[4]])
  prob <- as.numeric(df[[6]])
  diff <- alpha - beta
  
  prob2 <- as.numeric(df[[7]])
  
  fill_category <- ifelse(prob2 >= 0.9 & diff < 0, "Significant Positive (α > β)",
                          ifelse(prob >= 0.9 & diff > 0, "Significant Negative (β > α)",
                                 ifelse(diff > 0, "Insignificant Negative",
                                        "Insignificant Positive")))
  
  
  fill_factor <- factor(fill_category, levels = fill_levels)
  
  sites_to_label <- c(as.character(site[1]), as.character(site[length(site)]))
  
  title_text <- sub("\\.csv$", "", basename(file_path), ignore.case = TRUE)
  if (nchar(title_text) > 30) title_text <- paste0(substr(title_text, 1, 27), "...")
  
  ggplot(data.frame(Site = site, Diff = diff, Fill = fill_factor),
         aes(x = Site, y = Diff, fill = Fill)) +
    geom_col(width = 0.7) +
    scale_fill_manual(values = fill_colors) +
    scale_x_discrete(breaks = sites_to_label) +
    labs(title = title_text, x = NULL, y = expression(alpha - beta)) +
    theme_minimal(base_size = 12) +
    theme(
      panel.grid = element_blank(),
      panel.background = element_blank(),
      axis.line = element_line(color = "black"),
      axis.text.x = element_text(angle = 45, hjust = 1, size = 8),
      plot.title = element_text(hjust = 0.5, size = 10),
      legend.position = "none",
      plot.margin = margin(5, 5, 5, 5)
    )
})


legend_plot <- ggplot(data.frame(x = 1:4, y = 1, 
                                 Fill = factor(fill_levels, levels = fill_levels)),
                      aes(x, y, fill = Fill)) +
  geom_col() +
  scale_fill_manual(values = fill_colors, name = "Selection Pattern") +
  theme_void() +
  theme(
    legend.position = "bottom",
    legend.direction = "horizontal",
    legend.title = element_text(size = 10),
    legend.text = element_text(size = 8),
    legend.key.size = unit(0.5, "cm")
  )

shared_legend <- get_legend(legend_plot)
legend_wrapped <- wrap_elements(full = shared_legend)

n_files <- length(file_paths)
combined_plots <- wrap_plots(plots, ncol = 1, nrow = n_files+1)

final_plot <- combined_plots / legend_wrapped + 
  plot_layout(heights = c(rep(1, n_files), 0.15))

print(final_plot)
