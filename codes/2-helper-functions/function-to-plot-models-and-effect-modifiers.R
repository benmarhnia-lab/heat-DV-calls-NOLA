# Function to plot the AORs ----
 
func_plot_full_model <- function(df_plot, title = "Here goes the title") {

    # Pre-processing
    ## Define the desired order
    all_levels <- c("Heatwave: 5 days", "Heatwave: 3 days", "Extreme heat day")
    # desired_order <- c("Heatwave: 5 days", "Heatwave: 3 days", "Extreme heat day")
    
    ## Create a new factor with the desired order
    df_plot$duration_label <- factor(df_plot$duration_label, levels = all_levels)
    
    ## Calculate the range of OR values including CI bounds
    x_range <- range(c(df_plot$ci.low.se, df_plot$conf.high.se), na.rm = TRUE)
    ## Add some padding to the range
    x_range <- c(min(x_range) * 0.9, max(x_range) * 1.1)

    plot <- ggplot(df_plot, aes(x = estimate, y = duration_label)) +
        geom_pointrange(aes(xmin = conf.low.se, xmax = conf.high.se), 
                        color = "#dd1c77", linewidth = 0.5, alpha = 0.5) +
        geom_point(color = "#dd1c77", size = 2) +
        geom_vline(xintercept = 1, colour = "black", linetype = "dashed", linewidth = 0.5) +
        geom_text(aes(label = sprintf("%.2f", estimate)), vjust = -1.5, hjust = 0.5, size = 3.5) +
        labs(
            x = "Odds Ratio and 95% CI",
            y = "Heatwave Duration",
            title = title
        ) +
        scale_x_log10(
            breaks = scales::breaks_log(n = 8),
            labels = scales::label_number(accuracy = 0.01),
            limits = x_range
        ) +
        scale_y_discrete(limits = rev(all_levels)) +  # Use all_levels here
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
