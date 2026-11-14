#' Plot a player's age against the age difference with each opponent
#'
#' Scatter plot like the NYT graphic of Serena Williams' matches:
#' the x-axis is the player's age, the y-axis is the age difference
#' (player's age minus opponent's age), and color shows win or loss.
#'
#' @param data A data frame returned by get_career_data().
#' @return A ggplot object.
#' @export
#' @examples
#' \dontrun{
#' serena <- get_career_data("serena williams")
#' plot_career_ages(serena)
#' }
plot_career_ages <- function(data) {
  if (!is.data.frame(data) || !all(c("player_age", "age_diff", "result") %in% names(data))) {
    stop("`data` must be a data frame returned by get_career_data().", call. = FALSE)
  }
  ggplot2::ggplot(data, ggplot2::aes(x = player_age, y = age_diff, color = result)) +
    ggplot2::geom_hline(yintercept = 0, color = "gray") +
    ggplot2::geom_point(alpha = 0.6) +
    ggplot2::scale_color_manual(values = c("Win" = "#3b6fb6", "Loss" = "#8e44ad")) +
    ggplot2::labs(
      title = paste0(data$player[1], "'s Matches by Age"),
      x = paste0(data$player[1], "'s age"),
      y = "Age difference (player - opponent)",
      color = "Match result",
      caption = "Source: Tennis Abstract"
    ) +
    ggplot2::theme_minimal() +
    ggplot2::theme(plot.background = ggplot2::element_rect(fill = "white", color = NA))
}