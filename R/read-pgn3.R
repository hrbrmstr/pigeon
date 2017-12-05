#' Read chess match files in Portable Game Notation (PGN) format
#'
#' @md
#' @param path path to PGN file
#' @param n if not `Inf` then the number of games to read in. If `n` > total
#'        games in the PGN file, it will only read in that may games. This is
#'        a sequential operation. If you want this to be a random sample,
#'        set `sample` to `TRUE` and `n` to be the number of samples you want.
#' @param sample if `TRUE` **and** `n` is **not** `Inf` then the `n` games
#'        retrieved will be from a random sample. Use `set.seed()` before
#'        calling this if you want the results to be reproducible.
#' @param quiet if `TRUE` no progress bars will be shown. Defaults to `TRUE` (no progress bars)
#' @export
#' @examples
#' games <- read_pgn(system.file("extdata", "r7.pgn", package="pigeon"))
read_pgn <- function(path, n=Inf, sample=FALSE, quiet = TRUE) {

  path <- path.expand(path)

  if (!file.exists(path)) stop("File not found", call.=FALSE)

  tot_games <- pgn_count(path)

  if (!is.infinite(n)) {

    if (n > tot_games) n <- tot_games

    idx <- if (sample) base::sample(n, n) else 1:n

  } else {
    idx <- 1:tot_games
  }

  .pgn_recs(path, idx, quiet = quiet)

}
