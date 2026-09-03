test_that("scalar assertions reject wrong length, wrong type or NA", {
  expect_error(assert_character_scalar(c("a", "b")), "character scalar")
  expect_error(assert_character_scalar(1L), "character scalar")
  expect_error(assert_character_scalar(NA_character_), "character scalar")
  expect_error(assert_logical_scalar("TRUE"), "logical scalar")
  expect_error(assert_logical_scalar(NA), "logical scalar")
  expect_silent(assert_character_scalar("a"))
  expect_silent(assert_logical_scalar(TRUE))
})

test_that("assert_valid_id only accepts upper case letters and numbers", {
  expect_error(assert_valid_id("lower"), "uppercase")
  expect_error(assert_valid_id("HAS SPACE"), "uppercase")
  expect_error(assert_valid_id("HAS-DASH"), "uppercase")
  expect_silent(assert_valid_id("LARGECAP2"))
})

test_that("data frame assertions reject non conforming input", {
  expect_error(assert_data_frame(list()), "data.frame")
  expect_error(assert_named_list_of_data_frames(list(1)), "named list of data frames")
  expect_error(assert_named_list_of_data_frames(list(a = 1)), "named list of data frames")
  expect_error(
    assert_named_list_of_data_frames(setNames(list(data.frame()), "")),
    "named list of data frames"
  )
  expect_silent(assert_named_list_of_data_frames(list(tickers = data.frame())))
})
