#' Parse a character vector of chess moves in algebraic notations
#'
#' @param moves character vector of chess moves
#' @return character vector of the invidivual components of `moves`
#' @export
pgn_parse_moves <- function(moves) {

  moves <- paste0(moves, collapse=" ")

  moves <- stri_replace_all_regex(moves, "[\\(\\)\\{\\}]", "")
  moves <- stri_match_all_regex(moves, pgn_movetext_regex)[[1]][,-1]
  moves <- moves[!is.na(moves)]

  moves

}
