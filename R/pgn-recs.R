.parse_pgn_rec <- function(game) {

  meta <- game[which(stri_detect_regex(game, "^\\["))]
  meta <- stri_match_first_regex(meta, "\\[([[:alpha:]]+) (.*)]")[,2:3]

  field <- as.vector(meta[,1])
  value <- as.vector(meta[,2])
  value <- stri_replace_all_regex(value, '(^"|"$)', "")

  ret <- as.list(set_names(value, field))

  moves <- game[which(stri_detect_regex(game, "^[^\\[]"))]
  moves <- paste0(moves, collapse=" ")

  moves_raw <- moves

  moves <- stri_replace_all_regex(moves, "[\\(\\)\\{\\}]", "")
  moves <- stri_match_all_regex(moves, pgn_movetext_regex)[[1]][,-1]
  moves <- moves[!is.na(moves)]

  ret$moves_raw <- list(moves_raw)

  ret$Moves <- list(moves)

  ret

}

.s_parse_pgn_rec <- purrr::safely(.parse_pgn_rec)

.pgn_recs <- function(path, recs, quiet = FALSE) {

  path <- path.expand(path)

  if (!file.exists(path)) stop("File not found", call.=FALSE)

  recs <- int_pgn_recs(path, unique(sort(recs)), !quiet)

  if (!quiet) pb <- dplyr::progress_estimated(length(recs))
  map_df(recs, ~{
    if (!quiet) pb$tick()$print()
    res <- .s_parse_pgn_rec(.x)
    if (is.null(res$result)) message("Malformed record...")
    res$result
  })

}
