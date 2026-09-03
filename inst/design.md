# filters.trade — design

## Purpose and scope

`filters.trade` selects trading instruments out of a dataset by applying named,
saved filter expressions. It is a port of the CRAN
[`filters`](https://cran.r-project.org/package=filters) package from the
clinical trial domain to the trading domain: where `filters` selects subjects
out of CDISC datasets such as `ADSL` and `ADAE`, `filters.trade` selects trading
codes out of datasets such as `TICKERS` and `PRICES`.

The unit of the package is the **filter**: an `id`, a human readable `title`, a
`target` dataset and a `condition`. A condition is an expression, stored
unevaluated and evaluated later against the target dataset. Filters are
registered once and referred to afterwards by id, so a screening rule is
written in one place and reused across screens, reports and notebooks.

In scope: defining filters, loading them from yaml, inspecting them, and
applying them to a single dataset or to a named list of datasets.

Out of scope: fetching market data, computing indicators, backtesting, and
rendering output. `filters.trade` decides *which* instruments are in scope; the
planned sibling package `autoslider.trade` (a downstream package of
`autoslider.core`) renders the tables and figures for them.

## Requirements

### Registration and storage

- The package **shall** provide a function to register a filter definition
  consisting of an id, a title, a target dataset and a condition.
- Filter definitions **shall** be held in a package level registry keyed by id,
  alive for the length of the R session and never written to disk.
- Filter ids **shall** contain only upper case letters and numbers.
- A condition supplied as code **shall** be captured unevaluated, and a
  condition supplied as a character string **shall** be parsed; both **shall**
  be stored in the same representation.
- Registering an id that already exists **shall** fail unless overwriting is
  explicitly requested.

### Inspection

- The package **shall** provide a function to retrieve a single filter by id.
- The package **shall** provide a function to retrieve several filters at once,
  interpreting an id containing underscores as a request for each part.
- The package **shall** provide a function listing every registered filter with
  its id, title, target and condition.

### Loading from yaml

- The package **shall** provide a function that registers filters from a yaml
  file, in which each top level key is an id and carries `title`, `target` and
  `condition`.
- The function **shall** accept `.yml` and `.yaml` files only.
- The package **should** ship a starter set of filters covering common
  instrument universe and price based screens.

### Applying filters

- The package **shall** provide a function that applies filters to a data frame
  and to a named list of data frames.
- Only the definitions whose target matches the dataset **shall** be applied;
  when no definition matches, the data **shall** be returned unchanged.
- The conditions of all matching filters **shall** be combined with `&`.
- Conditions **shall** be evaluated against the target dataset so that columns
  are referenced unquoted.
- Applying a filter to a list **shall** fail when a dataset targeted by a
  filter is missing from the list.
- After the master trading code dataset has been filtered, every other dataset
  in the list **shall** be restricted to the trading codes that survived, so
  that a selection made on the universe carries through to prices and signals.
- Unsupported input classes **shall** raise an error rather than pass through
  silently.
- The function **should** report which filters were applied and how many
  records were kept, controlled by a `verbose` argument.

### Trading conventions

- The column holding the trading code **shall** default to `SYMBOL` and the
  dataset holding the master list of trading codes **shall** default to
  `TICKERS`.
- Both defaults **should** be overridable through package options, so that a
  project using `ticker` or `UNIVERSE` does not have to rename columns.

### Optional

- Support for further dataset classes **will** be possible by adding
  `apply_filter()` methods.
- Persisting the registry across sessions **will** be possible.
