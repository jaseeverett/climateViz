#' Plot climate stripes
#'
#' @param data Optional data input. If not provided, climate_stripe will use the NASA GISS data.
#'
#' @return A ggplot
#' @export
#'
#' @importFrom rlang .data
#'
#' @examples
#' gg <- climate_stripe()
climate_stripe <- function(data = NULL) {

  if (is.null(data)) {
    data <- climate_data()
  }

  gg_dat <- data %>%
    dplyr::select("Year", t_diff = .data$`J-D`) %>%
    tidyr::drop_na()

  gg_dat %>%
    ggplot2::ggplot(ggplot2::aes(x = .data$Year, y = 1, fill = .data$t_diff)) +
    ggplot2::geom_tile(show.legend = FALSE) +
    ggplot2::scale_fill_stepsn(
      colors = c("#08306B", "white", "#67000D"),
      values = scales::rescale(c(min(gg_dat$t_diff), 0, max(gg_dat$t_diff))),
      n.breaks = 12
    ) +
    ggplot2::coord_cartesian(expand = FALSE) +
    ggplot2::scale_x_continuous(breaks = seq(1890, 2020, 30)) +
    ggplot2::labs(title = glue::glue("Global temperature change ({min(gg_dat$Year)}-{max(gg_dat$Year)})")) +
    ggplot2::theme_void() +
    ggplot2::theme(
      axis.text.x = ggplot2::element_text(
        color = "white",
        margin = ggplot2::margin(t = 5, b = 10, unit = "pt")
      ),
      plot.title = ggplot2::element_text(
        color = "white",
        margin = ggplot2::margin(b = 5, t = 10, unit = "pt"),
        hjust = 0.05
      ),
      plot.background = ggplot2::element_rect(fill = "black")
    )
}
