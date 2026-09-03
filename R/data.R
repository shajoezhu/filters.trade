#' New Zealand Exchange (NZX) trading instruments
#'
#' A master list of trading instruments listed on New Zealand's Exchange
#' (NZX), in the shape `filters.trade` expects of the master trading-code
#' dataset. The join key is the `SYMBOL` column; every other column is an
#' attribute that a filter condition can reference unquoted.
#'
#' @format A [data.frame] with 168 rows and 7 columns:
#' \describe{
#'   \item{SYMBOL}{Trading code, e.g. `"ACE.NZ"`. The code column.}
#'   \item{NAME}{Company or instrument name.}
#'   \item{EXCHANGE}{Exchange code; always `"NZX"`.}
#'   \item{SECTOR}{Sector classification.}
#'   \item{MARKET_CAP}{Market capitalisation in NZD.}
#'   \item{DIV_YIELD}{Dividend yield in percent.}
#'   \item{ADV_20D}{Average daily volume over 20 days, in shares.}
#' }
#' @source `SYMBOL` and `NAME` are from
#'   `~/homepage-stock/data/nz_list.csv`. `EXCHANGE`, `SECTOR`, `MARKET_CAP`,
#'   `DIV_YIELD` and `ADV_20D` are synthetic placeholders generated in
#'   `data-raw/nz_data.R` for example use.
"nz_data"
