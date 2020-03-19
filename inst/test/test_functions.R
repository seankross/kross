basic_function <- function(x = 2, y = 3) {
  x + y
}

outer_function <- function() {

  inner_function <- function(x) {
    x + 4
  }

}

newline_function <-
  function() {
    ""
  }

c_style_function <- function()
{
  ""
}

anonymous_function <- function() {
  function() 1
}

anonymous_function_2 <- function() {
  function() {2}
}


anonymous_function_3 <- function() {
  function() {
    3
  }
}
