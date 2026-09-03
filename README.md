# filters.trade

A filter system for selecting trading instruments, in the spirit of the
[`filters`](https://cran.r-project.org/package=filters) package.

A **filter** is a named expression bound to a target dataset. Filters are
defined once, kept in a package level registry for the length of the R
session, and applied later to select trading codes (tickers, symbols) out of a
universe, price or signal dataset.

## Installation

```r
# install.packages("devtools")
devtools::install()
```

## Usage

```r
library(filters.trade)

# Load the starter definitions shipped in inst/filters.yaml
load_filters(system.file("filters.yaml", package = "filters.trade"))

tickers <- data.frame(
  SYMBOL = c("AAA", "BBB", "CCC"),
  SECTOR = c("Technology", "Energy", "Technology"),
  MARKET_CAP = c(1e11, 5e10, 4e9),
  stringsAsFactors = FALSE
)

prices <- data.frame(
  SYMBOL = c("AAA", "BBB", "CCC"),
  CLOSE = c(10, 20, 30),
  stringsAsFactors = FALSE
)

# Select a single dataset
apply_filter(tickers, "TECH", target = "TICKERS")

# Combine filters with underscores, and propagate the selected codes to
# every other dataset in the list
apply_filter(list(tickers = tickers, prices = prices), "TECH_LARGECAP")
```

Filters can also be defined in code:

```r
add_filter(
  id = "MEGACAP",
  title = "Mega Cap",
  target = "TICKERS",
  condition = MARKET_CAP >= 2e11
)
```

Or in a yaml file:

```yaml
MEGACAP:
  title: Mega Cap
  target: TICKERS
  condition: MARKET_CAP >= 2e11
```

## Trading conventions

Two conventions replace the clinical study conventions of `filters`:

- `SYMBOL` is the column holding the trading code. Override with
  `options(filters.trade.code_col = "ticker")`.
- `TICKERS` is the dataset holding the master list of trading codes. Override
  with `options(filters.trade.code_dataset = "UNIVERSE")`.

After `TICKERS` has been filtered, every other dataset is restricted to the
trading codes that survived, so a selection made on the universe carries
through to prices and signals.
