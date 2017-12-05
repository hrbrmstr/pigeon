#' Convert a PGN file to a SQLite DB
#'
#' Read one ore more PGN files and store the game(s) into a SQLite database.
#'
#' If `sql_out` exists and `overwrite` is `TRUE` then the `games` table will be
#' dropped and overwritten. If `overwrite` if `FALSE` and `sql_out` exists and
#' there is a `games` table, the `games` table will be appended to.
#'
#' @md
#' @param paths path(s) to PGN file(s)
#' @param sql_out SQLite database file (will be created if it doesn't exist)
#' @param overwrite overwrite the `games` table if it exists?
#' @export
pgn2sql <- function(paths, sql_out, overwrite=TRUE) {

  sql_out <- path.expand(sql_out)

  RSQLite::dbConnect(RSQLite::SQLite(), sql_out)

}