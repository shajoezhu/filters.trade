#' filters.trade Package
#'
#' A filter system for selecting trading instruments. `add_filter()` and
#' `apply_filter()` are the two entry points of the package.
#'
"_PACKAGE"

#' @importFrom tools file_ext
#' @importFrom yaml read_yaml
NULL

#' Package level filter registry
#'
#' Every filter definition lives in this environment, keyed by its upper case
#' `id`. Nothing is written to disk; the registry is populated by `add_filter()`
#' or `load_filters()` and lives for the length of the R session.
#'
#' @noRd
.filters <- new.env(parent = emptyenv())
