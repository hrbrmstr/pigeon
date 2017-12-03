#' Count number of games in a PGN file
#'
#' @md
#' @param path path to PGN file
#' @return numeric (count of gamesz in PGN file)
#' @export
pgn_count <- function(path) {

  path <- path.expand(path)

  if (!file.exists(path)) stop("File not found", call.=FALSE)

  int_pgn_count(path)

}
