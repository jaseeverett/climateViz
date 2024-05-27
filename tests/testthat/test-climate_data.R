test_that("Correct function output", {
  expect_s3_class(
    climate_data(), "tbl_df"
  )
})
