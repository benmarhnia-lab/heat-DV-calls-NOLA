#' Calculate Attributable Fractions and Numbers with Confidence Intervals
#' 
#' @description
#' This function calculates point estimates and confidence intervals for attributable
#' fractions (AF) and attributable numbers (AN) using Monte Carlo simulation from
#' a list of fitted models and total case counts.
#'
#' @param models_list A named list of fitted regression models
#' @param df_total_cases A data frame containing total case counts with columns:
#'   \itemize{
#'     \item variable - Names matching the models in models_list
#'     \item total_cases - Total number of cases for each exposure
#'   }
#' @param n_iterations Number of Monte Carlo iterations (default: 1000)
#' @param conf_level Confidence level for intervals (default: 0.95)
#'
#' @return A data frame with rows for each exposure and columns:
#'   \itemize{
#'     \item exposure - Name of the exposure variable
#'     \item total_cases - Total cases for that exposure
#'     \item af_point - Point estimate of attributable fraction (%)
#'     \item af_lower - Lower confidence bound for AF (%)
#'     \item af_upper - Upper confidence bound for AF (%)
#'     \item an_point - Point estimate of attributable number
#'     \item an_lower - Lower confidence bound for AN
#'     \item an_upper - Upper confidence bound for AN
#'   }
#'
#' @details
#' The function uses Monte Carlo simulation to generate confidence intervals by:
#' 1. Sampling from the distribution of log odds ratios
#' 2. Converting to attributable fractions
#' 3. Calculating attributable numbers using total case counts
#' 4. Computing quantiles for confidence intervals
#'
#' @importFrom stats quantile rnorm
#' @importFrom utils setTxtProgressBar txtProgressBar

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