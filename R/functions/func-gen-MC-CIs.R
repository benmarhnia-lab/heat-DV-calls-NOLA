generate_af_an_ci <- function(models_list, df_total_cases, n_iterations = 1000, conf_level = 0.95) {
    results_list <- list()
    
    for (model_name in names(models_list)) {
        model <- models_list[[model_name]]
        model_summary <- summary(model)
        coef <- model_summary$coefficients[1, "coef"]
        odds_ratio <- exp(coef)
        se_log_or <- model_summary$coefficients[1, "se(coef)"]
        
        # Get total cases for this exposure from df_total_cases
        total_cases <- df_total_cases$total_cases[df_total_cases$variable == model_name]
        
        af_samples <- numeric(n_iterations)
        an_samples <- numeric(n_iterations)
        pb <- txtProgressBar(min = 0, max = n_iterations, style = 3)
        
        for(i in 1:n_iterations) {
            iter_seed <- sample.int(.Machine$integer.max, 1)
            set.seed(iter_seed)
            
            tryCatch({
                sampled_or <- exp(rnorm(1, mean = coef, sd = se_log_or))
                af_samples[i] <- (sampled_or - 1) / sampled_or
                an_samples[i] <- af_samples[i] * total_cases
            }, error = function(e) {
                warning(sprintf("Model %s, Iteration %d failed: %s", model_name, i, e$message))
                af_samples[i] <- NA
                an_samples[i] <- NA
            })
            
            setTxtProgressBar(pb, i)
        }
        
        close(pb)
        
        af_samples <- af_samples[!is.na(af_samples)]
        an_samples <- an_samples[!is.na(an_samples)]
        alpha <- 1 - conf_level
        
        results_list[[model_name]] <- data.frame(
            exposure = model_name,
            total_cases = total_cases,
            af_point = 100 * (odds_ratio - 1) / odds_ratio,
            af_lower = 100 * quantile(af_samples, probs = alpha/2, na.rm = TRUE),
            af_upper = 100 * quantile(af_samples, probs = 1 - alpha/2, na.rm = TRUE),
            an_point = ((odds_ratio - 1) / odds_ratio) * total_cases,
            an_lower = quantile(an_samples, probs = alpha/2, na.rm = TRUE),
            an_upper = quantile(an_samples, probs = 1 - alpha/2, na.rm = TRUE)
        )
    }
    
    final_results <- do.call(rbind, results_list)
    return(final_results)
}