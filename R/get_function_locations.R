#' Find where functions are in an R file
#'
#' @param path The path to an R file.
#' @importFrom tibble as_tibble
#' @importFrom dplyr filter mutate select slice pull rename bind_rows n
#' @importFrom purrr "%>%" map_dfr
#' @importFrom utils getParseData
#' @importFrom rlang .data ":="
#' @export
#' @return A [tibble::tibble()] with the columns:
#' * `name`, the name of the function associated with a token.
#' * `token`, either the name of the function, or an open or closed curly bracket.
#' * `line`, the line of the code file where the token appears.
#'
#' If the `name` and `token` is `NA` then the row represents an anonymous
#' function.
#' @examples
#' \dontrun{
#'
#' # First specify the path to an R file
#' file_path <- system.file("test", "test_functions.R", package = "kross")
#'
#' get_function_locations(file_path)
#'
#' }
#'
get_function_locations <- function(path) {
  parse_data <- path %>%
    parse(keep.source = TRUE) %>%
    getParseData() %>%
    as_tibble()

  parse_data %>%
    filter(.data$token == "FUNCTION") %>%
    pull(.data$id) %>%
    map_dfr(find_function_locations, parse_data = parse_data)

}

get_parent <- function(id, parse_data) {
  parent_id <- parse_data %>%
    filter(.data$id == !!id) %>%
    pull(.data$parent)

  parse_data %>%
    filter(.data$id == parent_id)
}

get_children <- function(id, parse_data) {
  parse_data %>%
    filter(.data$parent == !!id)
}

find_function_locations <- function(id, parse_data) {
  p1 <- get_parent(id, parse_data)
  p2 <- get_parent(p1$id, parse_data)
  p3 <- get_children(p2$id, parse_data) %>%
     slice(1)
  function_name <- get_children(p3$id, parse_data) %>%
    filter(.data$token == "SYMBOL")

  if (nrow(function_name) == 0) {
    function_name <- p1 %>%
      mutate(text := NA)
  }

  p4 <- get_children(p1$id, parse_data) %>%
    slice(n())
  curly_brackets <- get_children(p4$id, parse_data) %>%
    filter(.data$token %in% c("'{'", "'}'"))

  bind_rows(function_name, curly_brackets) %>%
    mutate(name = function_name$text) %>%
    select(name, text, line1) %>%
    rename(token = text, line = line1)
}
