#' Title
#'
#' @param data Optional data input. If not provided, climate_tornado will use the NASA GISS data.
#'
#' @return A ggplot object
#' @export
#'
#' @importFrom rlang .data
#'
#' @examples
#' gg <- climate_tornado()
climate_tornado <- function(data = NULL) {

  if (is.null(data)) {
    data <- climate_data()
  }

  gg_dat <- data %>%
    dplyr::select(tidyselect::all_of(c("Year", month.abb))) %>%
    tidyr::pivot_longer(-.data$Year, names_to = "month", values_to = "t_diff") %>%
    tidyr::drop_na()

  grid_labels <- tibble::tibble(
    x = c(-5, -4, 0, 1),
    y = 2030,
    labels = c("+1\u00B0 C", "0\u00B0 C", "0\u00B0 C", "+1\u00B0 C")
  )

  year_labels <- tibble::tibble(
    x = -2,
    y = c(seq(1880, 2000, by = 20), max(gg_dat$Year))
  )


  gg_dat %>%
    dplyr::filter(.data$month == "Apr" | .data$month == "Oct") %>%
    tidyr::pivot_wider(names_from = "month", values_from = "t_diff") %>%
    dplyr::mutate(ave_t = (.data$Oct + .data$Apr) / 2) %>%
    ggplot2::ggplot(ggplot2::aes(x = -4 - .data$Oct,
                                 xend = .data$Apr,
                                 y = .data$Year,
                                 yend = .data$Year,
                                 color = .data$ave_t)) +
    ggplot2::geom_vline(xintercept = c(-5, -4, 0, 1), color = "gold") +
    ggplot2::geom_label(
      data = grid_labels, ggplot2::aes(x = .data$x, y = .data$y, label = .data$labels),
      inherit.aes = FALSE,
      fill = "black", color = "gold", label.size = 0, size = 3
    ) +
    ggplot2::geom_segment(size = 0.9, lineend = "round") +
    ggplot2::geom_text(
      data = year_labels, ggplot2::aes(x = .data$x, y = .data$y, label = .data$y),
      inherit.aes = FALSE, color = "gold", size = 3, fontface = "bold"
    ) +
    ggplot2::scale_color_gradient2(
      low = "darkblue", high = "darkred", mid = "white",
      midpoint = 0, guide = "none"
    ) +
    ggplot2::scale_y_continuous(limits = c(NA, 2030), expand = c(0, 0)) +
    ggplot2::coord_cartesian(clip = "off") +
    ggplot2::labs(
      x = NULL,
      y = NULL,
      title = NULL
    ) +
    ggplot2::theme(
      plot.background = ggplot2::element_rect(fill = "black", color = "black"),
      panel.background = ggplot2::element_rect(fill = "black"),
      axis.text = ggplot2::element_blank(),
      axis.ticks = ggplot2::element_blank(),
      panel.grid = ggplot2::element_blank()
    )
}
