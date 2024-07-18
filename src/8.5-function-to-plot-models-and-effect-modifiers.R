# Function to full model ----

func_plot_full_model <- function(df_plot, title = "Here goes the title") {
    plot <- ggplot(df_plot, aes(x = estimate, y = duration_label)) +
        geom_point() +
        facet_wrap(~threshold_label, ncol = 1) +
        geom_vline(xintercept = 1, colour = "black", linetype = "dashed") +
        geom_text(aes(label = sprintf("%.2f", estimate)), vjust = -1.5, hjust = 0.5, size = 3.5) +
        geom_pointrange(aes(xmin = conf.low, xmax = conf.high)) +
        labs(
            x = "Adjusted Odds Ratio [95% CI]",
            y = "Heatwave Duration",
            title = title  # Add the title here
        ) +
        xlim(0.9, 1.5) +  # Updated this line to set x-axis limits from 0.5 to 1.5
        theme_classic(base_size = 14, base_family = "Times New Roman") +
        theme(
            panel.grid.major = element_line(linewidth=0.25), 
            panel.grid.minor.x = element_line(linewidth=0.15),
            strip.background = element_blank(),  
            strip.placement = "outside",  
            strip.text.y.left = element_text(angle = 0),
            strip.text = element_text(face = "bold", size = 14),
            axis.ticks = element_blank(), 
            axis.title.x = element_text(margin = margin(t = 15)),
            axis.title.y = element_text(margin = margin(r = 15)),
            panel.border = element_blank(),
            legend.position="none",
            panel.spacing=unit(0, "cm"),
            plot.title = element_text(hjust = 0.5, face = "bold", size = 16)  # Center the title and make it bold
        )
    return(plot)
}