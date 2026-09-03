# Generate `data/nz_data.rda` and `inst/extdata/nz_data.csv`
#
# nz_data is the example master list of NZX trading instruments for
# filters.trade. `SYMBOL` and `NAME` come from the real list below; the
# attribute columns (EXCHANGE, SECTOR, MARKET_CAP, DIV_YIELD, ADV_20D) are
# synthetic placeholders, generated with a fixed seed so the file is
# reproducible.
#
# Re-run with:  Rscript data-raw/nz_data.R

source_csv <- "/home/joezhu-hp/homepage-stock/data/nz_list.csv"

raw <- read.csv(source_csv, stringsAsFactors = FALSE, check.names = FALSE)

# Normalise non-breaking spaces (U+00A0) and surrounding whitespace in names.
name <- gsub("\u00a0", " ", raw$name)
name <- trimws(name)

set.seed(2024)

sectors <- c(
  "Technology", "Financials", "Health Care", "Energy", "Industrials",
  "Consumer Staples", "Consumer Discretionary", "Utilities", "Real Estate",
  "Materials", "Communication Services"
)

n <- nrow(raw)

nz_data <- data.frame(
  SYMBOL = raw$Symbol,
  NAME = name,
  EXCHANGE = "NZX",
  SECTOR = sample(sectors, n, replace = TRUE),
  MARKET_CAP = round(10^runif(n, 8, 11)),
  DIV_YIELD = ifelse(runif(n) < 0.25, 0, round(runif(n, 0.5, 8), 2)),
  ADV_20D = round(10^runif(n, 3, 7)),
  stringsAsFactors = FALSE
)

usethis::use_data(nz_data, overwrite = TRUE)
write.csv(nz_data, "inst/extdata/nz_data.csv", row.names = FALSE)
