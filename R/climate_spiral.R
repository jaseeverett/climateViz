#' Create climate spiral plot
#'
#' @param data Optional data input. If not provided, climate_spiral will use the NASA GISS data.
#' @param by_year TRUE/FALSE - Colour the output by Year, or by temperature difference (DEFAULT)
#' @param animate TRUE/FALSE - Should the output be animated to an mp4
#'
#' @return A ggplot object
#' @export
#'
#' @importFrom rlang .data
#'
#' @examples
#' gg <- climate_spiral()
climate_spiral <- function(data = NULL, by_year = FALSE, animate = FALSE) {

  if (is.null(data)) {
    data <- climate_data()
  }

  temp <- data %>%
    dplyr::select(tidyselect::all_of(c("Year", month.abb))) %>%
    tidyr::pivot_longer(-"Year", names_to = "month", values_to = "t_diff") %>%
    tidyr::drop_na()

  next_jan <- temp %>%
    dplyr::filter(.data$month == "Jan") %>%
    dplyr::mutate(
      Year = .data$Year - 1,
      month = "next_Jan"
    )

  gg_dat <- dplyr::bind_rows(temp, next_jan) %>%
    dplyr::mutate(
      month = factor(.data$month, levels = c(month.abb, "next_Jan")),
      month_number = as.numeric(.data$month)
    )

  annotation <- gg_dat %>%
    dplyr::slice_max(.data$Year) %>%
    dplyr::slice_max(.data$month_number)


  if (isTRUE(by_year)) {

    clm <- "Year" # Column name
    lims <- c(-1.2, 2.5)
    grids <- c(1.5, 2)
    clr <- "red"
    flr <- "black"
    temp_lines <- tibble::tibble(
      x = 1,
      y = grids,
      labels = stringr::str_c(as.character(grids), "\u00B0 C")
    )

  }



  if (isFALSE(by_year)) {

    clm <- "t_diff" # Column name
    grids <- c(1, 0, -1)
    lims <- c(-1.2, 1.5)
    clr <- c("yellow", "green", "yellow")
    flr = NA

    temp_lines <- tibble::tibble(
      x = 1,
      y = grids,
      labels = stringr::str_c(as.character(grids), "\u00B0 C")
    )

  }

  month_labels <- tibble::tibble(
    x = 1:12,
    labels = month.abb,
    y = max(lims) * 1.1
  )

  # if (isTRUE(legend)){
  #   plotguide <- "colourbar"
  # } else if (isFALSE(legend)){
  #   plotguide <- "none"
  # }


  gg <- gg_dat %>%
    ggplot2::ggplot(ggplot2::aes(x = .data$month_number,
                                 y = .data$t_diff,
                                 group = .data$Year,
                                 color = .data[[clm]])) +
    ggplot2::geom_col(
      data = month_labels,
      ggplot2::aes(x = .data$x + 0.5, y = min(lims)), fill = "black",
      width = 1,
      inherit.aes = FALSE) +
    ggplot2::geom_col(
      data = month_labels,
      ggplot2::aes(x = .data$x + 0.5, y = max(lims)), fill = "black",
      width = 1,
      inherit.aes = FALSE) +
    ggplot2::geom_line() +
    {if (by_year == FALSE) ggplot2::scale_color_gradient2(low = "blue", high = "red", mid = "white", midpoint = 0, guide = "none")} +
    {if (by_year == TRUE) ggplot2::scale_color_viridis_c(breaks = seq(min(gg_dat$Year), max(gg_dat$Year), 20), guide = "none")} +
    ggplot2::geom_hline(
      yintercept = grids,
      color = clr) +
    ggplot2::geom_label(
      data = temp_lines,
      ggplot2::aes(x = .data$x,
                   y = .data$y,
                   label = .data$labels),
      color = clr,
      size = 6,
      fontface = "bold",
      fill = flr,
      label.size = 0,
      inherit.aes = FALSE) +
    ggplot2::geom_text(
      data = month_labels,
      ggplot2::aes(x = .data$x,
                   y = .data$y,
                   label = .data$labels),
      inherit.aes = FALSE,
      color = "white",
      angle = seq(0, 360 - 360 / 12, length.out = 12) * -1) +
    ggplot2::scale_y_continuous(
      limits = c(min(lims), max(lims) * 1.2),
      expand = c(0, 0)) +
    ggplot2::coord_radial(expand = FALSE, inner.radius = 0, start = 0) +
    ggplot2::labs(title = glue::glue("Global temperature change ({min(gg_dat$Year)}-{max(gg_dat$Year)})"),
                  x = NULL,
                  y = NULL) +
    ggplot2::theme(
      panel.background = ggplot2::element_rect(fill = "#444444", size = 1),
      # panel.background = ggplot2::element_rect(fill = "black", size = 1),
      plot.background = ggplot2::element_rect(fill = "#444444", color = "#444444"),
      panel.grid = ggplot2::element_blank(),
      axis.text.x = ggplot2::element_blank(),
      axis.text.y = ggplot2::element_blank(),
      axis.ticks = ggplot2::element_blank(),
      axis.title = ggplot2::element_blank(),
      plot.title = ggplot2::element_text(
        color = "white",
        margin = ggplot2::margin(b = 5, t = 10, unit = "pt"),
        hjust = 0.05
      ),
    )



  if (isTRUE(animate)) {

    if (isFALSE(by_year)){
      gg <- gg +
        ggplot2::geom_label(ggplot2::aes(x = 1, y = -1.7, label = .data$Year),
                            fill = "black",
                            label.size = 0,
                            size = 6
        )
    }

    # geom_label(aes(x = 1, y = -1.3, label = year),
    #            color = "white", fill = "black",
    #            label.padding = unit(50, "pt"), label.size = 0,
    #            size = 6
    # ) +
    gg <- gg +
      gganimate::transition_manual(frames = .data$Year, cumulative = TRUE)

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
