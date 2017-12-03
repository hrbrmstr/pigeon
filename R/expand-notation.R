expand_notation <- function(x) {

  ELSE <- TRUE

  cp <- c("N"="Knight", "K"="King", "Q"="Queen", "B"="Bishop", "R"="Rook")

  case_when(
    x == "O-O" ~ "Castled, King side",
    x == "O-O-O" ~ "Castled, Queen side",
    nchar(x) == 3 ~ sprintf("%s to %s", cp[substr(x, 1, 1)], substr(x, 2, 3)),
    nchar(x) == 2 ~ sprintf("Pawn to %s", substr(x, 1, 2)),
    ELSE ~ x
  )

}