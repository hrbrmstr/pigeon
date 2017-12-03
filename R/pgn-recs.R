pgn_movetext_regex <- '([NBKRQ]?[a-h]?[1-8]?[\\-x]?[a-h][1-8](?:=?[nbrqkNBRQK])?|[PNBRQK]?@[a-h][1-8]|--|Z0|O-O(?:-O)?|0-0(?:-0)?)|(\\{.*)|(;.*)|(\\$[0-9]+)|(\\()|(\\))|(\\*|1-0|0-1|1/2-1/2)|([\\?!]{1,2})'

.parse_pgn_rec <- function(game) {

  meta <- game[which(stri_detect_regex(game, "^\\["))]
  meta <- stri_match_first_regex(meta, "\\[([[:alpha:]]+) (.*)]")[,2:3]

  field <- as.vector(meta[,1])
  value <- as.vector(meta[,2])
  value <- stri_replace_all_regex(value, '(^"|"$)', "")

  ret <- as.list(set_names(value, field))

  moves <- game[which(stri_detect_regex(game, "^[^\\[]"))]
  moves <- stri_match_all_regex(moves, pgn_movetext_regex)[[1]][,-1]
  moves <- moves[!is.na(moves)]

  ret$Moves <- list(moves)

  ret

}

.s_parse_pgn_rec <- purrr::safely(.parse_pgn_rec)

.pgn_recs <- function(path, recs) {

  path <- path.expand(path)

  if (!file.exists(path)) stop("File not found", call.=FALSE)

  map_df(int_pgn_recs(path, unique(sort(recs))), ~{
    res <- .s_parse_pgn_rec(.x)
    if (is.null(res$result)) message("Malformed record...")
    res$result
  })

}
