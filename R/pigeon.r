#' Read in a PGN file
#'
#' @param path path to PGN file
#' @return data frame of results or an empty data frame if parsing errors occurred
#' @export
#' @examples
#' read_pgn(system.file("extdata", "r7.pgn", package="pigeon"))
read_pgn <- function(path) {

  path <- path.expand(path)
  if (!file.exists(path)) stop("Path not found", call.=FALSE)

  json <- tempfile()
  log <- tempfile()

  on.exit(unlink(log), add = TRUE)
  on.exit(unlink(json), add = TRUE)

  val <- parse_pgn(path, json, log)

  if (val) {
    json_lines <- trimws(paste0(readLines(json, warn=FALSE), collapse="\n"))
    # if (!grepl("]$", json_lines)) json_lines <- sub("$", "]\n", json_lines)
    ret <- jsonlite::fromJSON(json_lines, flatten=TRUE)
  } else {
    warning("Error parsing PGN file")
    ret <- data.frame()
  }

  class(ret) <- c("tbl_df", "tbl", "data.frame")
  ret

}
