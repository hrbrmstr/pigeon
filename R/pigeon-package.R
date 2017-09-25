#' Parse Portable Game Notation ('PGN') Files
#'
#' 'Portable Game Notation' ('PGN') is a plain text computer-processible format
#' for recording chess games (both the moves and related data), supported by many chess
#' programs. It was was devised around 1993, by Steven J. Edwards, and was first
#' popularized via the 'Usenet' newsgroup 'rec.games.chess'. 'PGN' is structured
#' "for easy reading and writing by human users and for easy parsing and generation by
#' computer programs." The chess moves themselves are given in algebraic chess notation.
#' Tools are provided -- based on 'pgn-extract' <https://www.cs.kent.ac.uk/people/staff/djb/pgn-extract/>
#' by David J. Barnes -- to parse 'PGN' files into a data frame.
#'
#' @md
#' @name pigeon
#' @docType package
#' @author Bob Rudis (bob@@rud.is)
#' @importFrom jsonlite fromJSON
#' @useDynLib pigeon
#' @importFrom Rcpp sourceCpp
NULL
