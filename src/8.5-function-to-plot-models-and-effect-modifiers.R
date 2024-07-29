# Function to plot the AORs ----
 
func_plot_full_model <- function(df_plot, title = "Here goes the title") {
    plot <- ggplot(df_plot, aes(x = estimate, y = duration_label)) +
        geom_pointrange(aes(xmin = conf.low.se, xmax = conf.high.se), 
                        color = "#fa9fb5", linewidth = 1.5, alpha = 0.5) +
        geom_point(color = "#dd1c77", size = 1.8, alpha = 0.8) +
        geom_vline(xintercept = 1, colour = "black", linetype = "dashed", linewidth = 1.2) +
        geom_text(aes(label = sprintf("%.2f", estimate)), vjust = -1.5, hjust = 0.5, size = 3.5) +
        labs(
            x = "Adjusted Odds Ratio [95% CI]",
            y = "Heatwave Duration",
            title = title
        ) +
        scale_x_continuous(limits = c(0.9, 1.2)) +
        theme_classic(base_size = 12, base_family = "Times New Roman") +
        theme(
            panel.grid.major = element_line(linewidth=0.25), 
            panel.grid.minor.x = element_line(linewidth=0.15),
            strip.background = element_blank(),  
            strip.placement = "outside",  
            strip.text.y.left = element_text(angle = 0),
            strip.text = element_text(face = "bold", size = 12),
            axis.ticks = element_blank(), 
            axis.title.x = element_text(margin = margin(t = 15)),
            axis.title.y = element_text(margin = margin(r = 15)),
            panel.border = element_blank(),
            legend.position="none",
            panel.spacing=unit(0, "cm"),
            plot.title = element_text(hjust = 0.5, face = "bold", size = 12)
        )
    return(plot)
}
