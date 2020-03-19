# kross

<!-- badges: start -->
<!-- badges: end -->

## Installation

``` r
install.packages("remotes")

remotes::install_github("seankross/kross")
```

## Example

``` r
library(kross)

# First specify the path to an R file
file_path <- system.file("test", "test_functions.R", package = "kross")

get_function_locations(file_path)

# # A tibble: 31 x 3
#    name             token             line
#    <chr>            <chr>            <int>
#  1 basic_function   basic_function       1
#  2 basic_function   {                    1
#  3 basic_function   }                    3
#  4 outer_function   outer_function       5
#  5 outer_function   {                    5
#  6 outer_function   }                   11
#  7 inner_function   inner_function       7
#  8 inner_function   {                    7
#  9 inner_function   }                    9
# 10 newline_function newline_function    13
# # … with 21 more rows
```

