.s_int_pgn_count <- purrr::safely(int_pgn_count)

#' Count number of games in a PGN file
#'
#' @md
#' @param path path to PGN file
#' @return numeric (count of gamesz in PGN file)
#' @export
pgn_count <- function(path) {

  path <- path.expand(path)

  if (!file.exists(path)) stop("File not found", call.=FALSE)

  res <- .s_int_pgn_count(path)

  if (is.null(res)) message("Error reading file: [%s]", res$error)

  return(res$result)

}
