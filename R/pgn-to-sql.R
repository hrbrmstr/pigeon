.parse_pgn_sql_rec <- function(game) {

  meta <- game[which(stri_detect_regex(game, "^\\["))]
  meta <- stri_match_first_regex(meta, "\\[([[:alpha:]]+) (.*)]")[,2:3]

  field <- as.vector(meta[,1])
  value <- as.vector(meta[,2])
  value <- stri_replace_all_regex(value, '(^"|"$)', "")

  ret <- as.list(set_names(value, field))

  movetext <- game[which(stri_detect_regex(game, "^[^\\[]"))]
  movetext <- paste0(movetext, collapse=" ")

  ret$Movetext <- movetext

  ret

}

.s_parse_pgn_sql_rec <- purrr::safely(.parse_pgn_sql_rec)

#' Convert a PGN file to a SQLite DB
#'
#' Read one ore more PGN files and store the game(s) into a SQLite database under
#' a `games` table (which will be created if it does not exist).
#'
#' A `.` will be printed to stdout for ever 1,000 records inserted.
#'
#' @md
#' @param paths path(s) to PGN file(s)
#' @param sql_out SQLite database file (will be created if it doesn't exist)
#' @export
#' @examples
#' tf <- tempfile(fileext = ".db")
#' pgn2sql(system.file("extdata", "r7.pgn", package="pigeon"), tf)
#'
#' tmp <- dplyr::src_sqlite(tf)
#' dplyr::glimpse(dplyr::tbl(tmp, "games"))
#'
#' unlink(tf)
pgn2sql <- function(paths, sql_out) {

  paths <- unique(path.expand(paths))
  sql_out <- path.expand(sql_out)

  chess_db <- RSQLite::dbConnect(RSQLite::SQLite(), sql_out)

  i <- 0
  parse_errors <- 0

  game_insert <- function(x) {

    i <<- i + 1
    if ((i %% 1000)==0) cat(".", sep="")

    rec <- .s_parse_pgn_sql_rec(x)

    if (!is.null(rec$result)) {

      RSQLite::dbExecute(
        conn = chess_db,
        statement = "INSERT INTO games VALUES(:Event, :Site, :Date, :Round, :White, :Black, :Movetext)",
        params = rec$result
      ) -> rs

    } else {
      parse_errors <<- parse_errors + 1
    }

  }

  # if no `games` table exists

  if (!("games" %in% RSQLite::dbListTables(chess_db))) {

    RSQLite::dbSendQuery(chess_db, "
CREATE TABLE games (
  event TEXT, site TEXT, date TEXT, round TEXT, white TEXT, black TEXT, movetext TEXT
);
") -> rs

    dbGetRowsAffected(rs)
    dbClearResult(rs)

  }

  found <- paths[file.exists(paths)]
  not_found <- paths[!file.exists(paths)]

  for (f in found) {

    i <- parse_errors <- 0

    RSQLite::dbBegin(chess_db) # transactions are safer and provide a speed boost

    pigeon:::int_pgn_iter(f, game_insert)

    if (i >= 1000) cat("\n", sep="")
    if (parse_errors > 0) message(sprintf("%s parsing errors/records skipped",
                                          scales::comma(parse_errors)))

    RSQLite::dbCommit(chess_db)

  }



  RSQLite::dbDisconnect(chess_db)

}