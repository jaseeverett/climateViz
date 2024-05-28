#' Create climate spiral plot
#'
#' @param data
#' @param by_year TRUE/FALSE - Colour the output by Year, or by temperature difference (DEFAULT)
#' @param animate
#'
#' @return
#' @export
#'
#' @examples
climate_spiral <- function(data = NULL, by_year = FALSE, animate = FALSE) {
  if (is.null(data)) {
    data <- climate_data()
  }

  temp <- data %>%
    dplyr::select(tidyselect::all_of(c("Year", month.abb))) %>%
    tidyr::pivot_longer(-Year, names_to = "month", values_to = "t_diff") %>%
    tidyr::drop_na()

  next_jan <- temp %>%
    dplyr::filter(month == "Jan") %>%
    dplyr::mutate(
      Year = Year - 1,
      month = "next_Jan"
    )

  gg_dat <- dplyr::bind_rows(temp, next_jan) %>%
    dplyr::mutate(
      month = factor(month, levels = c(month.abb, "next_Jan")),
      month_number = as.numeric(month)
    )

  annotation <- gg_dat %>%
    dplyr::slice_max(Year) %>%
    dplyr::slice_max(month_number)


  month_labels <- tibble::tibble(
    x = 1:12,
    labels = month.abb,
    y = 2.7
  )

  gridlines <- tibble::tibble(
    x = c(1.2, 1.3, 1.6),
    xend = c(12.8, 12.7, 12.4),
    y = c(1, 0, -1),
    yend = y
  )


  if (isTRUE(by_year)) {
    temp_lines <- tibble::tibble(
      x = 12,
      y = c(1.5, 2.0),
      labels = c("1.5\u00B0C", "2.0\u00B0C")
    )

    gg <- gg_dat %>%
      ggplot2::ggplot(ggplot2::aes(x = month_number, y = t_diff, group = Year, color = Year)) +
      ggplot2::geom_col(
        data = month_labels, ggplot2::aes(x = x + 0.5, y = 2.4), fill = "black",
        width = 1,
        inherit.aes = FALSE
      ) +
      ggplot2::geom_col(
        data = month_labels, ggplot2::aes(x = x + 0.5, y = -2), fill = "black",
        width = 1,
        inherit.aes = FALSE
      ) +
      ggplot2::geom_hline(yintercept = c(1.5, 2.0), color = "red") +
      ggplot2::geom_line() +
      ggplot2::geom_point(
        data = annotation, ggplot2::aes(x = month_number, y = t_diff, color = Year),
        size = 2,
        inherit.aes = FALSE
      ) +
      ggplot2::geom_label(
        data = temp_lines, ggplot2::aes(x = x, y = y, label = labels),
        color = "red", fill = "black", label.size = 0,
        inherit.aes = FALSE
      ) +
      ggplot2::geom_text(
        data = month_labels, ggplot2::aes(x = x, y = y, label = labels),
        inherit.aes = FALSE, color = "white",
        angle = seq(360 - 360 / 12, 0, length.out = 12)
      ) +
      ggplot2::geom_text(ggplot2::aes(x = 1, y = -1.3, label = "2022"), size = 6) +
      ggplot2::scale_x_continuous(
        breaks = 1:12,
        labels = month.abb, expand = c(0, 0),
        sec.axis = ggplot2::dup_axis(name = NULL, labels = NULL)
      ) +
      ggplot2::scale_y_continuous(
        breaks = seq(-2, 2, 0.2),
        limits = c(-2, 2.7), expand = c(0, -0.7),
        sec.axis = ggplot2::dup_axis(name = NULL, labels = NULL)
      ) +
      ggplot2::scale_color_viridis_c(
        breaks = seq(1880, 2020, 20),
        guide = "none"
      ) +
      ggplot2::coord_polar(start = 2 * pi / 12) +
      ggplot2::labs(
        x = NULL,
        y = NULL,
        title = "Global temperature change (1880-2022)"
      ) +
      ggplot2::theme(
        panel.background = ggplot2::element_rect(fill = "#444444", size = 1),
        plot.background = ggplot2::element_rect(fill = "#444444", color = "#444444"),
        panel.grid = ggplot2::element_blank(),
        axis.text.x = ggplot2::element_blank(),
        axis.text.y = ggplot2::element_blank(),
        axis.title.y = ggplot2::element_blank(),
        axis.ticks = ggplot2::element_blank(),
        axis.title = ggplot2::element_text(color = "white", size = 13),
        plot.title = ggplot2::element_text(color = "white", hjust = 0.5, size = 15)
      )
  }

  if (isFALSE(by_year)) {
    temp_lines <- tibble::tibble(
      x = 1,
      y = c(1, 0, -1),
      labels = c("+1\u00B0 C", "0\u00B0 C", "-1\u00B0 C")
    )

    gg <- gg_dat %>%
      ggplot2::ggplot(ggplot2::aes(x = month_number, y = t_diff, group = Year, color = t_diff)) +
      ggplot2::geom_label(ggplot2::aes(x = 1, y = -1.7, label = Year),
        fill = "black",
        label.size = 0,
        size = 6
      ) +
      ggplot2::geom_line() +
      ggplot2::geom_segment(
        data = gridlines, ggplot2::aes(x = x, y = y, xend = xend, yend = yend),
        color = c("yellow", "green", "yellow"),
        inherit.aes = FALSE
      ) +
      ggplot2::geom_text(
        data = temp_lines, ggplot2::aes(x = x, y = y, label = labels),
        color = c("yellow", "green", "yellow"), size = 2, fontface = "bold",
        inherit.aes = FALSE
      ) +
      ggplot2::geom_text(
        data = month_labels, ggplot2::aes(x = x, y = y, label = labels),
        inherit.aes = FALSE, color = "yellow"
      ) +
      ggplot2::scale_y_continuous(
        limits = c(-2.0, 1.5), expand = c(0, -0.3)
      ) +
      ggplot2::scale_color_gradient2(
        low = "blue", high = "red", mid = "white", midpoint = 0,
        guide = "none"
      ) +
      ggplot2::coord_polar(start = 0) +
      ggplot2::labs(
        x = NULL,
        y = NULL,
        title = NULL
      ) +
      ggplot2::theme(
        panel.background = ggplot2::element_rect(fill = "black"),
        plot.background = ggplot2::element_rect(fill = "black", color = "black"),
        panel.grid = ggplot2::element_blank(),
        axis.text.x = ggplot2::element_blank(),
        axis.text.y = ggplot2::element_blank(),
        axis.ticks = ggplot2::element_blank(),
        axis.title = ggplot2::element_blank(),
        plot.title = ggplot2::element_blank()
      )
  }

  if (isTRUE(animate)) {
    gg <- gg +
      gganimate::transition_manual(frames = Year, cumulative = TRUE)

    # animate(a, width=4.155, height=4.5, unit="in", res=300)
    # anim_save("climate_spiral.gif")


    gganimate::animate(gg,
      width = 4.155, height = 4.5, unit = "in", res = 300,
      renderer = gganimate::av_renderer("climate_spiral.mp4")
    )
  } else {
    return(gg)
  }
}
