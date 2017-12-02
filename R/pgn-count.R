#' Count number of games in a PGN file
#'
#' @md
#' @param path path to PGN file
#' @return numeric (count of gamesz in PGN file)
#' @export
pgn_count <- function(path, n=Inf, sample=FALSE) {

  path <- path.expand(path)

  if (!file.exists(path)) stop("File not found", call.=FALSE)

  l <- suppressWarnings(stri_read_lines(path))

  length(which(stri_detect_regex(l, "^\\[Event ")))

}
