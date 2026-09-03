test_that("add_filter registers a filter definition", {
  add_filter(
    id = "TLARGE",
    title = "Large Cap",
    target = "tickers",
    condition = MARKET_CAP >= 1e10,
    overwrite = TRUE
  )

  f <- get_filter("TLARGE")
  expect_type(f, "list")
  expect_named(f, c("title", "target", "condition"))
  expect_equal(f$title, "Large Cap")
  expect_equal(f$target, "TICKERS")
  expect_true(is.call(f$condition))
})

test_that("character conditions are stored in the same shape as substituted ones", {
  add_filter(
    id = "TTECH",
    title = "Technology Sector",
    target = "TICKERS",
    condition = "SECTOR == 'Technology'",
    character_only = TRUE,
    overwrite = TRUE
  )

  expect_equal(get_filter("TTECH")$condition, quote(SECTOR == "Technology"))
})

test_that("filter ids may only contain upper case letters and numbers", {
  expect_error(add_filter("lower", "Lower Case", "TICKERS", TRUE), "uppercase")
})

test_that("existing filters are protected unless overwrite is TRUE", {
  add_filter("TDUP", "First", "TICKERS", TRUE, overwrite = TRUE)
  expect_error(add_filter("TDUP", "Second", "TICKERS", TRUE), "already exists")

  add_filter("TDUP", "Second", "TICKERS", FALSE, overwrite = TRUE)
  expect_equal(get_filter("TDUP")$title, "Second")
})

test_that("get_filters splits a combined id on underscores", {
  add_filter("TUS", "US Listed", "TICKERS", TRUE, overwrite = TRUE)
  add_filter("TMID", "Mid Cap", "TICKERS", TRUE, overwrite = TRUE)

  out <- get_filters("TUS_TMID")
  expect_named(out, c("TUS", "TMID"))
  expect_error(get_filters("TNOSUCHFILTER"), "does not exist")
})

test_that("apply_filter subsets a data frame", {
  add_filter(
    id = "TLAR",
    title = "Large Cap",
    target = "TICKERS",
    condition = MARKET_CAP >= 1e10,
    overwrite = TRUE
  )

  tickers <- data.frame(
    SYMBOL = c("AAA", "BBB", "CCC"),
    MARKET_CAP = c(1e11, 5e9, 2e10),
    stringsAsFactors = FALSE
  )

  out <- apply_filter(tickers, "TLAR", target = "TICKERS", verbose = FALSE)
  expect_equal(out$SYMBOL, c("AAA", "CCC"))
  expect_equal(attr(out, "filters"), "TLAR")
})

test_that("apply_filter combines the conditions of a combined id", {
  add_filter("TSECT", "Technology", "TICKERS", SECTOR == "Technology", overwrite = TRUE)
  add_filter("TLIQ", "Liquid", "TICKERS", ADV_20D > 1e6, overwrite = TRUE)

  tickers <- data.frame(
    SYMBOL = c("AAA", "BBB", "CCC"),
    SECTOR = c("Technology", "Technology", "Energy"),
    ADV_20D = c(2e6, 5e5, 9e6),
    stringsAsFactors = FALSE
  )

  out <- apply_filter(tickers, "TSECT_TLIQ", target = "TICKERS", verbose = FALSE)
  expect_equal(out$SYMBOL, "AAA")
})

test_that("apply_filter returns data unchanged when no filter matches the target", {
  add_filter("TPRICE", "Price Filter", "PRICES", CLOSE > 10, overwrite = TRUE)
  tickers <- data.frame(SYMBOL = "AAA", stringsAsFactors = FALSE)

  expect_equal(
    apply_filter(tickers, "TPRICE", target = "TICKERS", verbose = FALSE),
    tickers
  )
  expect_equal(
    apply_filter(tickers, "", target = "TICKERS", verbose = FALSE),
    tickers
  )
})

test_that("apply_filter propagates the selected trading codes to other datasets", {
  add_filter(
    id = "TTEC",
    title = "Technology",
    target = "TICKERS",
    condition = SECTOR == "Technology",
    overwrite = TRUE
  )

  datasets <- list(
    tickers = data.frame(
      SYMBOL = c("AAA", "BBB"),
      SECTOR = c("Technology", "Energy"),
      stringsAsFactors = FALSE
    ),
    prices = data.frame(
      SYMBOL = c("AAA", "BBB"),
      CLOSE = c(10, 20),
      stringsAsFactors = FALSE
    )
  )

  out <- apply_filter(datasets, "TTEC", verbose = FALSE)
  expect_equal(out$tickers$SYMBOL, "AAA")
  expect_equal(out$prices$SYMBOL, "AAA")
})

test_that("apply_filter errors when a filter target is missing from the list", {
  add_filter("TMISS", "Missing Target", "SIGNALS", VALUE > 0, overwrite = TRUE)

  expect_error(
    apply_filter(list(tickers = data.frame(SYMBOL = "AAA")), "TMISS", verbose = FALSE),
    "missing in `data`"
  )
})

test_that("apply_filter has no method for unsupported classes", {
  expect_error(apply_filter(1:3, "TTEC"), "No `apply_filter\\(\\)` method")
})

test_that("list_all_filters returns definitions sorted by target and id", {
  out <- list_all_filters()
  expect_true(is.data.frame(out))
  expect_true(all(c("id", "title", "target", "condition") %in% names(out)))
  expect_true("TTEC" %in% out$id)
  expect_equal(out, out[order(out$target, out$id), , drop = FALSE])
})
