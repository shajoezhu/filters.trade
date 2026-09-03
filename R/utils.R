squote <- function(x) {
  paste0("'", x, "'")
}

deparse <- function(expr, ...) {
  gsub('"', "'", base::deparse(expr, ...))
}

map_chr <- function(x, fun, ...) {
  vapply(x, fun, character(1L), ...)
}

map_bool <- function(x, fun, ...) {
  vapply(x, fun, logical(1L), ...)
}

get_labels <- function(data) {
  lapply(data, attr, "label")
}

set_labels <- function(data, labels) {
  for (i in seq_along(data)) {
    attr(data[[i]], "label") <- labels[[i]]
  }
  data
}

#' Combine the conditions of several filters into a single expression
#'
#' Filters requested through a single `id` such as `US_LARGECAP` are combined
#' with `&`, in the order they appear in the `id`.
#'
#' @param filters `list` of filter definitions
#' @return A `call`
#' @noRd
combine_filter_conditions <- function(filters) {
  Reduce(
    function(lhs, rhs) bquote(.(lhs) & .(rhs)),
    lapply(filters, `[[`, "condition")
  )
}

#' Name of the column holding the trading code
#'
#' Trading codes are the join key of the package: a selection made on the
#' universe dataset is propagated to every other dataset through this column.
#' Override it globally with
#' `options(filters.trade.code_col = "ticker")`.
#'
#' @return A `character` scalar
#' @noRd
code_col <- function() {
  getOption("filters.trade.code_col", "SYMBOL")
}

#' Name of the dataset holding the master list of trading codes
#'
#' The trading counterpart of the subject level dataset in a clinical study.
#' Override it globally with
#' `options(filters.trade.code_dataset = "UNIVERSE")`.
#'
#' @return A `character` scalar
#' @noRd
code_dataset <- function() {
  toupper(getOption("filters.trade.code_dataset", "TICKERS"))
}

#' Keep only the trading codes that survive filtering of the master dataset
#'
#' @param x `data.frame` to restrict
#' @param universe `data.frame` of already filtered trading codes
#' @return A `data.frame`
#' @noRd
keep_codes_in_universe <- function(x, universe) {
  by <- code_col()
  rows_to_keep <- x[[by]] %in% universe[[by]]
  set_labels(x[rows_to_keep, , drop = FALSE], get_labels(x))
}
