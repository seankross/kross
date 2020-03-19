#' Find where functions are in an R file
#'
#' @param path The path to an R file.
#' @importFrom tibble as_tibble
#' @importFrom dplyr filter mutate select slice pull rename bind_rows n
#' @importFrom purrr "%>%" map_dfr
#' @importFrom utils getParseData
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
    parse() %>%
    getParseData() %>%
    as_tibble() %>%
    rename("id_" = "id")

  get_parent <- function(id_) {
    parent_id <- parse_data %>%
      filter(id_ == !!id_) %>%
      pull(parent)

    parse_data %>%
      filter(id_ == parent_id)
  }

  get_children <- function(id_) {
    parse_data %>%
      filter(parent == !!id_)
  }

  find_function_locations <- function(id_) {
    p1 <- get_parent(id_)
    p2 <- get_parent(p1$id_)
    p3 <- get_children(p2$id_) %>%
      slice(1)
    function_name <- get_children(p3$id_) %>%
      filter(token == "SYMBOL")

    if (nrow(function_name) == 0) {
      function_name <- p1 %>%
        mutate(text = NA)
    }

    p4 <- get_children(p1$id_) %>%
      slice(n())
    curly_brackets <- get_children(p4$id_) %>%
      filter(token %in% c("'{'", "'}'"))

    bind_rows(function_name, curly_brackets) %>%
      mutate(name = function_name$text) %>%
      select(name, text, line1) %>%
      rename(token = text, line = line1)
  }

  parse_data %>%
    filter(token == "FUNCTION") %>%
    pull("id_") %>%
    map_dfr(find_function_locations)
}
