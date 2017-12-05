paths <- c("~/Desktop/r7.pgn", "~/Desktop/r7.pgn")
sql_out <- "~/Desktop/a.db"

paths <- unique(path.expand(paths))
sql_out <- path.expand(sql_out)

chess_db <- RSQLite::dbConnect(RSQLite::SQLite(), sql_out)

game_insert <- function(x, db) {

  x <- pigeon:::.parse_pgn_rec(x)

  dbSendQuery(
    conn = db,
    statement = "INSERT INTO games VALUES(?, ?)"
  ) -> res

  RSQLite::dbBind(res)

}

testfn <- function(x) {
  message(x)
}

if (!("games" %in% dbListTables(chess_db))) {

  found <- paths[file.exists(paths)]
  not_found <- paths[!file.exists(paths)]

  for (f in found) {

    message(found)

    pigeon:::int_pgn_iter(f, testfn)

  }


}

RSQLite::dbDisconnect(db)