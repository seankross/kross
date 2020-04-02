context("get_function_locations")

test_that("correct number of functions are detected", {

  file_path <- system.file("test", "test_functions.R", package = "kross")

  result <- get_function_locations(file_path)
  result_rows <- nrow(result)
  result_unique_function_names <- result %>%
    select(.data$name) %>%
    unique() %>%
    nrow()

  expect_equal(result_rows, 31)

  expect_equal(result_unique_function_names, 9)

})

test_that("an empty tibble is returned when there are no functions", {

  file_path <- system.file("test", "test_no_functions.R", package = "kross")

  result <- get_function_locations(file_path)
  result_rows <- nrow(result)

  expect_equal(result_rows, 0)

})
