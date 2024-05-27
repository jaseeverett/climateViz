
#' Retrieve climate data from GISS.
#' @return A dataframe of climate data
#' @export
#'
#' @examples
#' data <- climate_data()
#'
climate_data <- function(){

  fi <- "https://data.giss.nasa.gov/gistemp/tabledata_v4/GLB.Ts+dSST.csv"

  readr::read_csv(file = fi, skip = 1, na = "***")

}
