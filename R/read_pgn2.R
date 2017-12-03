# #' Read chess match files in Portable Game Notation (PGN) format
# #'
# #' @md
# #' @param path path to PGN file
# #' @param n if not `Inf` then the number of games to read in. If `n` > total
# #'        games in the PGN file, it will only read in that may games. This is
# #'        a sequential operation. If you want this to be a random sample,
# #'        set `sample` to `TRUE` and `n` to be the number of samples you want.
# #' @param sample if `TRUE` **and** `n` is **not** `Inf` then the `n` games
# #'        retrieved will be from a random sample. Use `set.seed()` before
# #'        calling this if you want the results to be reproducible.
# #' @export
# read_pgn <- function(path, n=Inf, sample=FALSE) {
#
#   path <- path.expand(path)
#
#   if (!file.exists(path)) stop("File not found", call.=FALSE)
#
#   pgn_movetext_regex <- '([NBKRQ]?[a-h]?[1-8]?[\\-x]?[a-h][1-8](?:=?[nbrqkNBRQK])?|[PNBRQK]?@[a-h][1-8]|--|Z0|O-O(?:-O)?|0-0(?:-0)?)|(\\{.*)|(;.*)|(\\$[0-9]+)|(\\()|(\\))|(\\*|1-0|0-1|1/2-1/2)|([\\?!]{1,2})'
#
#   l <- suppressWarnings(stri_read_lines(path))
#
#   starts <- which(stri_detect_regex(l, "^\\[Event "))
#   ends <- c((starts[-1]-1), length(l))
#
#   if (!is.infinite(n)) {
#
#     if (n > length(starts)) n <- length(starts)
#
#     idx <- if (sample) base::sample(length(starts), n) else 1:n
#
#     starts <- starts[idx]
#     ends <- ends[idx]
#
#   }
#
#   pb <- dplyr::progress_estimated(length(starts))
#   purrr::map2_df(starts, ends, ~{
#
#     pb$tick()$print()
#
#     game <- l[.x:.y]
#
#     meta <- game[which(stri_detect_regex(game, "^\\["))]
#     meta <- stri_match_first_regex(meta, "\\[([[:alpha:]]+) (.*)]")[,2:3]
#
#     field <- as.vector(meta[,1])
#     value <- as.vector(meta[,2])
#     value <- stri_replace_all_regex(value, '(^"|"$)', "")
#
#     ret <- as.list(set_names(value, field))
#
#     moves <- game[which(stri_detect_regex(game, "^[^\\[]"))]
#     moves <- stri_match_all_regex(moves, pgn_movetext_regex)[[1]][,-1]
#     moves <- moves[!is.na(moves)]
#
#     ret$Moves <- list(moves)
#
#     ret
#
#   })
#
# }
