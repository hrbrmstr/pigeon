context("read_pgn")
test_that("read_pgn() works", {

  games <- read_pgn(system.file("extdata", "r7.pgn", package="pigeon"))
  expect_equal(nrow(games), 2)

  games <- read_pgn(system.file("extdata", "r7.pgn", package="pigeon"), n = 1)
  expect_equal(nrow(games), 1)

  games <- read_pgn(system.file("extdata", "r7.pgn", package="pigeon"), n = 2)
  expect_equal(nrow(games), 2)

  games <- read_pgn(system.file("extdata", "r7.pgn", package="pigeon"), n = 3)
  expect_equal(nrow(games), 2)

  set.seed(1492)
  games <- read_pgn(system.file("extdata", "r7.pgn", package="pigeon"), n = 1, sample = TRUE)
  expect_equal(games$Round, "44.1")

})

context("pgn_count")
test_that("pgn_count() works", {

  expect_equal(
    pgn_count(system.file("extdata", "r7.pgn", package="pigeon")),
    2
  )

})

context("pgn_parse_moves")
test_that("pgn_parse_moves() works", {

  moves <- c("1. c4 Nf6 2. d4 e6 3. Nf3 b6 4. g3 Ba6 5. Nbd2 Bb4",
             "6. a3 Bxd2+ 7. Nxd2 Bb7 8.Nf3 d5 9. cxd5 Bxd5 10. Bg2 O-O 11. O-O Nbd7",
             "12. Bf4 c5 13. dxc5 1/2-1/2")

  expect_equal(
    pgn_parse_moves(moves[1]),
    c("c4", "Nf6", "d4", "e6", "Nf3", "b6", "g3", "Ba6", "Nbd2","Bb4")
  )

  expect_equal(
    pgn_parse_moves(moves[1:2]),
    c("c4", "Nf6", "d4", "e6", "Nf3", "b6", "g3", "Ba6", "Nbd2",
      "Bb4", "a3", "Bxd2", "Nxd2", "Bb7", "Nf3", "d5", "cxd5", "Bxd5",
      "Bg2", "O-O", "O-O", "Nbd7")
  )

  expect_equal(
    pgn_parse_moves(moves),
    c("c4", "Nf6", "d4", "e6", "Nf3", "b6", "g3", "Ba6", "Nbd2",
      "Bb4", "a3", "Bxd2", "Nxd2", "Bb7", "Nf3", "d5", "cxd5", "Bxd5",
      "Bg2", "O-O", "O-O", "Nbd7", "Bf4", "c5", "dxc5", "1/2-1/2")
  )

})

context("pgn sql conversion")
test_that("SQL works", {

  tf <- tempfile(fileext = ".db")

  pgn2sql(system.file("extdata", "r7.pgn", package="pigeon"), tf)

  con <- RSQLite::dbConnect(RSQLite::SQLite(), tf)

  testthat::expect_equal(RSQLite::dbListTables(con), "games")

  testthat::expect_equal(
    unlist(RSQLite::dbGetQuery(con, "SELECT COUNT(*) FROM games"), use.names=FALSE),
    2
  )

  unlink(tf)

})
