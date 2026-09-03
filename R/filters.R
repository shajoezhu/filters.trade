#' Add a New Filter Definition
#'
#' Add a new filter definition or overwrite an existing one. A filter binds an
#' unevaluated `condition` to a `target` dataset so that it can be applied
#' later by [apply_filter()]. Unless `character_only = TRUE`, `condition` is
#' captured with [substitute()] and therefore written without quotes.
#'
#' @param id `character` The id of this filter. Only upper case letters and
#'   numbers are allowed, e.g. `"LARGECAP"`.
#' @param title `character` The title of the filter
#' @param target `character` The target dataset of the filter, e.g.
#'   `"TICKERS"` or `"PRICES"`
#' @param condition The filter condition
#' @param character_only `logical`. Is `condition` a string? Defaults to
#'   `FALSE`.
#' @param overwrite `logical` Should existing filters be overwritten? Defaults
#'   to `FALSE`.
#'
#' @return A `list` of `title`, `target` and `condition`, invisibly
#' @export
#'
#' @examples
#' add_filter(
#'   id = "LARGECAP",
#'   title = "Large Cap",
#'   target = "TICKERS",
#'   condition = MARKET_CAP >= 1e10
#' )
#'
#' add_filter(
#'   id = "TECH",
#'   title = "Technology Sector",
#'   target = "TICKERS",
#'   condition = "SECTOR == 'Technology'",
#'   character_only = TRUE
#' )
#'
add_filter <- function(id,
                       title,
                       target,
                       condition,
                       character_only = FALSE,
                       overwrite = FALSE) {
  assert_valid_id(id)
  tryCatch(
    {
      assert_character_scalar(title)
      assert_character_vector(target)
      assert_logical_scalar(character_only)
    },
    error = function(e) {
      stop("Failed at filter ", squote(id), "\n", print(e))
    }
  )
  assert_logical_scalar(overwrite)
  if (!overwrite) assert_filter_exists(id)

  condition <- if (character_only) {
    # `parse()` returns an expression (vector); `[[` extracts the language
    # object so that a character condition and a substituted condition end up
    # stored in exactly the same shape.
    parse(text = condition, keep.source = FALSE)[[1L]]
  } else {
    substitute(condition)
  }

  .filters[[id]] <- list(
    title = title,
    target = toupper(target),
    condition = condition
  )
}

#' Get a Filter Definition
#'
#' @param id `character`. The filter ID
#'
#' @return A `list` with elements `title`, `target` and `condition`
#' @export
#'
#' @examples
#' add_filter(
#'   id = "LARGECAP",
#'   title = "Large Cap",
#'   target = "TICKERS",
#'   condition = MARKET_CAP >= 1e10,
#'   overwrite = TRUE
#' )
#' get_filter("LARGECAP")
#'
#' ## Filter `FOO` does not exist
#' try(get_filter("FOO"))
#'
get_filter <- function(id) {
  assert_valid_id(id)
  if (!id %in% ls(envir = .filters)) {
    stop("Filter ", squote(id), " does not exist.", call. = FALSE)
  }
  .filters[[id]]
}

#' Get Multiple Filter Definitions
#'
#' Filter IDs are combined into a single string separated by underscores, so
#' `"US_LARGECAP"` requests the two filters `US` and `LARGECAP`.
#'
#' @param ids `character`. The filter IDs as a single string separated by
#'   underscores
#'
#' @return A named `list` of filter definitions
#' @export
#'
#' @examples
#' add_filter(
#'   id = "US",
#'   title = "US Listed",
#'   target = "TICKERS",
#'   condition = EXCHANGE %in% c("NYSE", "NASDAQ"),
#'   overwrite = TRUE
#' )
#' get_filters("US_LARGECAP")
#'
get_filters <- function(ids) {
  assert_character_scalar(ids)
  ids <- strsplit(ids, "_")[[1L]]
  filters <- lapply(ids, get_filter)
  names(filters) <- ids
  filters
}

#' List All Filters
#'
#' List all filter definitions currently held in the registry.
#'
#' @return A `data.frame` with columns `id`, `title`, `target` and `condition`
#' @export
#'
#' @examples
#' list_all_filters()
#'
list_all_filters <- function() {
  filters_list <- as.list(.filters)
  filters <- data.frame(
    id = names(filters_list),
    title = map_chr(filters_list, `[[`, "title"),
    target = map_chr(filters_list, `[[`, "target"),
    condition = map_chr(filters_list, function(x) deparse(x[["condition"]])),
    stringsAsFactors = FALSE
  )
  filters[order(filters$target, filters$id), , drop = FALSE]
}

#' Apply a Filter to a Dataset or List of Datasets
#'
#' @param data `data.frame` or named `list` of `data.frame`s
#' @param id `character`. The ID of one or more filters defined with
#'   [add_filter()], combined with underscores. An empty string applies no
#'   filter.
#' @param target `character`. The name of the dataset, e.g. `"TICKERS"` or
#'   `"PRICES"`
#' @param verbose `logical`. Should informative messages be printed? Defaults
#'   to `TRUE`.
#' @param ... Not used.
#'
#' @return A new `data.frame` or `list` of `data.frame`s filtered based upon
#'   the condition defined for `id`. When the master trading code dataset is
#'   among the filter targets, every other dataset is restricted to the
#'   surviving trading codes.
#' @export
#'
#' @examples
#' tickers <- data.frame(
#'   SYMBOL = c("AAA", "BBB", "CCC"),
#'   SECTOR = c("Technology", "Energy", "Technology"),
#'   stringsAsFactors = FALSE
#' )
#' prices <- data.frame(
#'   SYMBOL = c("AAA", "BBB", "CCC"),
#'   CLOSE = c(10, 20, 30),
#'   stringsAsFactors = FALSE
#' )
#'
#' add_filter(
#'   id = "TECH",
#'   title = "Technology Sector",
#'   target = "TICKERS",
#'   condition = SECTOR == "Technology",
#'   overwrite = TRUE
#' )
#'
#' apply_filter(tickers, "TECH", target = "TICKERS")
#' apply_filter(list(tickers = tickers, prices = prices), "TECH")
#'
apply_filter <- function(data, ...) {
  UseMethod("apply_filter")
}

#' @rdname apply_filter
#' @export
apply_filter.default <- function(data, ...) {
  stop("No `apply_filter()` method defined for class `", class(data)[1L], "`.")
}

#' @rdname apply_filter
#' @export
apply_filter.data.frame <- function(data,
                                    id,
                                    target = deparse(substitute(data)),
                                    verbose = TRUE,
                                    ...) {
  assert_data_frame(data)
  if (!is.null(id)) assert_character_scalar(id)
  assert_character_scalar(target)
  assert_logical_scalar(verbose)

  if (is.null(id) || id == "") {
    return(data)
  }

  target <- toupper(target)
  filters <- get_filters(id)
  filter_targets <- lapply(filters, `[[`, "target")
  matches_target <- map_bool(filter_targets, function(t) target %in% t)
  matching_filters <- filters[matches_target]

  if (!length(matching_filters)) {
    if (verbose) {
      message("No filter matched target ", target, ".")
    }
    return(data)
  }

  if (verbose) {
    log_matching_filters(names(matching_filters), target)
  }

  filter_condition <- combine_filter_conditions(matching_filters)
  call <- call("subset", x = quote(data), subset = filter_condition)
  filtered_data <- eval(call)
  attr(filtered_data, "filters") <- names(matching_filters)

  if (verbose) {
    log_number_of_matched_records(data, filtered_data, filter_condition)
  }

  set_labels(filtered_data, get_labels(data))
}

#' @rdname apply_filter
#' @export
apply_filter.list <- function(data, id, verbose = TRUE, ...) {
  assert_named_list_of_data_frames(data)

  dataset_names <- toupper(names(data))
  filters <- get_filters(id)
  datasets_to_filter <- unique(unlist(lapply(filters, `[[`, "target")))
  missing_datasets <- setdiff(datasets_to_filter, dataset_names)

  if (length(missing_datasets)) {
    stop(
      "The following filter targets are missing in `data`: ",
      paste(missing_datasets, collapse = ", "), ".",
      call. = FALSE
    )
  }

  filtered_datasets <- Map(
    function(dataset, name) {
      if (!name %in% datasets_to_filter) {
        dataset
      } else {
        apply_filter(
          data = dataset,
          id = id,
          verbose = verbose,
          target = name
        )
      }
    },
    data,
    dataset_names
  )

  if (code_dataset() %in% datasets_to_filter) {
    restrict_to_selected_codes(filtered_datasets)
  } else {
    filtered_datasets
  }
}

#' Propagate the selected trading codes to every other dataset
#'
#' Once the master trading code dataset has been filtered, datasets such as
#' prices or signals are restricted to the codes that survived. This is the
#' trading counterpart of dropping subjects that are no longer in the subject
#' level dataset.
#'
#' @param filtered_datasets named `list` of `data.frame`s
#' @return A named `list` of `data.frame`s
#' @noRd
restrict_to_selected_codes <- function(filtered_datasets) {
  master <- code_dataset()
  is_master <- toupper(names(filtered_datasets)) == master
  other_datasets <- names(filtered_datasets)[!is_master]
  for (ds in other_datasets) {
    filtered_datasets[[ds]] <- keep_codes_in_universe(
      filtered_datasets[[ds]],
      filtered_datasets[[which(is_master)]]
    )
  }
  filtered_datasets
}
