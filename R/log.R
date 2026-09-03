log_matching_filters <- function(ids, target) {
  message(
    "Applying filter(s) ", paste(squote(ids), collapse = ", "),
    " to ", target, "."
  )
}

log_number_of_matched_records <- function(data, filtered_data, condition) {
  message(
    "Filter condition: ", deparse(condition), "\n",
    "Kept ", nrow(filtered_data), " of ", nrow(data), " records."
  )
}
