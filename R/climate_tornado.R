#' Title
#'
#' @return
#' @export
#'
#' @examples
climate_tornado <- function(data = NULL) {
  if (is.null(data)) {
    data <- climate_data()
  }

  gg_dat <- data %>%
    dplyr::select(year = Year, all_of(month.abb)) %>%
    tidyr::pivot_longer(-year, names_to = "month", values_to = "t_diff") %>%
    tidyr::drop_na()

  grid_labels <- tibble::tibble(
    x = c(-5, -4, 0, 1),
    y = 2030,
    labels = c("+1\u00B0 C", "0\u00B0 C", "0\u00B0 C", "+1\u00B0 C")
  )

  year_labels <- tibble::tibble(
    x = -2,
    y = c(seq(1880, 2000, by = 20), 2021)
  )


  gg_dat %>%
    dplyr::filter(month == "Apr" | month == "Oct") %>%
    tidyr::pivot_wider(names_from = "month", values_from = "t_diff") %>%
    dplyr::mutate(ave_t = (Oct + Apr) / 2) %>%
    ggplot2::ggplot(aes(x = -4 - Oct, xend = Apr, y = year, yend = year, color = ave_t)) +
    ggplot2::geom_vline(xintercept = c(-5, -4, 0, 1), color = "gold") +
    ggplot2::geom_label(
      data = grid_labels, ggplot2::aes(x = x, y = y, label = labels),
      inherit.aes = FALSE,
      fill = "black", color = "gold", label.size = 0, size = 3
    ) +
    ggplot2::geom_segment(size = 0.9, lineend = "round") +
    ggplot2::geom_text(
      data = year_labels, aes(x = x, y = y, label = y),
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
