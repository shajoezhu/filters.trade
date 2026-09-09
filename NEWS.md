# filters.trade 0.0.1

* Initial scaffold of the package.

* Added the filter registry with `add_filter()`, `get_filter()`,
  `get_filters()`, `list_all_filters()` and `load_filters()`.

* Added `apply_filter()` with methods for `data.frame` and named `list`s of
  data frames, propagating the selected trading codes from `TICKERS` to every
  other dataset.

* Added the starter filter definitions in `inst/filters.yaml`.
