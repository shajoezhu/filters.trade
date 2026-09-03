test_that("load_filters reads filter definitions from yaml", {
  yaml_file <- system.file("filters_eg.yaml", package = "filters.trade")
  expect_true(file.exists(yaml_file))

  load_filters(yaml_file, overwrite = TRUE)

  f <- get_filter("YUS")
  expect_equal(f$title, "US Listed Instruments")
  expect_equal(f$target, "TICKERS")
  expect_equal(f$condition, quote(EXCHANGE %in% c("NYSE", "NASDAQ")))
})

test_that("every shipped starter filter parses", {
  load_filters(
    system.file("filters.yaml", package = "filters.trade"),
    overwrite = TRUE
  )

  ids <- list_all_filters()$id
  expect_true(all(c("US", "LARGECAP", "TECH", "DIV", "ABV50") %in% ids))
  expect_equal(get_filter("MIDCAP")$target, "TICKERS")
  expect_equal(get_filter("GAPUP")$target, "PRICES")
})

test_that("load_filters only accepts yaml files", {
  expect_error(load_filters("definitions.txt"))
})
