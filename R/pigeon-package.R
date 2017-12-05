#' Parse Portable Game Notation ('PGN') Files
#'
#' 'Portable Game Notation' ('PGN') is a plain text computer-processible format
#' for recording chess games (both the moves and related data), supported by many chess
#' programs. It was was devised around 1993, by Steven J. Edwards, and was first
#' popularized via the 'Usenet' newsgroup 'rec.games.chess'. 'PGN' is structured
#' "for easy reading and writing by human users and for easy parsing and generation by
#' computer programs." The chess moves themselves are given in algebraic chess notation.
#' Tools are provided to parse 'PGN' files into a data frame.
#'
#' @md
#' @name pigeon
#' @docType package
#' @author Bob Rudis (bob@@rud.is)
#' @importFrom stringi stri_detect_regex stri_read_lines stri_match_all_regex
#' @importFrom stringi stri_match_first_regex stri_replace_all_regex
#' @importFrom purrr map2_df set_names map_df safely walk
#' @importFrom dplyr progress_estimated
#' @importFrom Rcpp sourceCpp
#' @import RSQLite
#' @useDynLib pigeon
NULL
