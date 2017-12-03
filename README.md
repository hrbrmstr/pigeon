
# pigeon

Parse Portable Game Notation (‘PGN’) Files

## Description

‘Portable Game Notation’ (‘PGN’) is a plain text computer-processible
format for recording chess games (both the moves and related data),
supported by many chess programs. It was was devised around 1993, by
Steven J. Edwards, and was first popularized via the ‘Usenet’ newsgroup
‘rec.games.chess’. ‘PGN’ is structured “for easy reading and writing
by human users and for easy parsing and generation by computer
programs.” The chess moves themselves are given in algebraic chess
notation. Tools are provided to parse ‘PGN’ files into a data frame.

## What’s in the tin?

The following functions are implemented:

  - `pgn_count`:	Count number of games in a PGN file
  - `read_pgn`: Read in a PGN file

The following built-in data sets are included:

  - `system.file("extdata", "r7.pgn", package="pigeon")`: 2017 FIDE
    World Cup extract

## Installation

``` r
devtools::install_github("hrbrmstr/pigeon")
```

## Usage

``` r
library(pigeon)
library(tidyverse)

# current verison
packageVersion("pigeon")
```

    ## [1] '0.2.0'

Built-in example

``` r
fide <- read_pgn(system.file("extdata", "r7.pgn", package="pigeon"))

fide
```

    ## # A tibble: 2 x 12
    ##            Event    Site       Date Round               White               Black  Result BlackElo WhiteElo
    ##            <chr>   <chr>      <chr> <chr>               <chr>               <chr>   <chr>    <chr>    <chr>
    ## 1 World Cup 2017 Tbilisi 2017.09.23  44.1 Aronian Levon (ARM)    Ding Liren (CHN) 1/2-1/2     2777     2799
    ## 2 World Cup 2017 Tbilisi 2017.09.24  45.1    Ding Liren (CHN) Aronian Levon (ARM) 1/2-1/2     2799     2777
    ## # ... with 3 more variables: LiveChessVersion <chr>, ECO <chr>, Moves <list>

``` r
glimpse(fide)
```

    ## Observations: 2
    ## Variables: 12
    ## $ Event            <chr> "World Cup 2017", "World Cup 2017"
    ## $ Site             <chr> "Tbilisi", "Tbilisi"
    ## $ Date             <chr> "2017.09.23", "2017.09.24"
    ## $ Round            <chr> "44.1", "45.1"
    ## $ White            <chr> "Aronian Levon (ARM)", "Ding Liren (CHN)"
    ## $ Black            <chr> "Ding Liren (CHN)", "Aronian Levon (ARM)"
    ## $ Result           <chr> "1/2-1/2", "1/2-1/2"
    ## $ BlackElo         <chr> "2777", "2799"
    ## $ WhiteElo         <chr> "2799", "2777"
    ## $ LiveChessVersion <chr> "1.4.8", "1.4.8"
    ## $ ECO              <chr> "A18", "E06"
    ## $ Moves            <list> [<"c4", "{[%clk 1:30:45]} Nf6 {[%clk 1:30:26]} 2. Nc3 {[%clk 1:31:06]} e6">, <"d4", "{[%c...

Bigger example

``` r
tf <- tempfile(fileext = ".zip")
td <- tempdir()
download.file("https://www.pgnmentor.com/players/Adams.zip",  tf)
fil <- unzip(tf, exdir = td)

adams <- read_pgn(fil)

adams
```

    ## # A tibble: 2,968 x 11
    ##             Event      Site       Date Round              White              Black  Result WhiteElo BlackElo   ECO
    ##             <chr>     <chr>      <chr> <chr>              <chr>              <chr>   <chr>    <chr>    <chr> <chr>
    ##  1 Lloyds Bank op    London 1984.??.??     1     Adams, Michael    Sedgwick, David     1-0                     C05
    ##  2 Lloyds Bank op    London 1984.??.??     3     Adams, Michael  Dickenson, Neil F     1-0              2230   C07
    ##  3 Lloyds Bank op    London 1984.??.??     4       Hebden, Mark     Adams, Michael     1-0     2480            B10
    ##  4 Lloyds Bank op    London 1984.??.??     5    Pasman, Michael     Adams, Michael     0-1     2310            D42
    ##  5 Lloyds Bank op    London 1984.??.??     6     Adams, Michael   Levitt, Jonathan 1/2-1/2              2370   B99
    ##  6 Lloyds Bank op    London 1984.??.??     9     Adams, Michael Saeed, Saeed Ahmed     1-0              2430   B56
    ##  7         BCF-ch Edinburgh 1985.??.??     1     Adams, Michael   Singh, Sukh Dave 1/2-1/2     2360     2080   B70
    ##  8         BCF-ch Edinburgh 1985.??.??     2 Abayasekera, Roger     Adams, Michael     1-0     2200     2360   B13
    ##  9         BCF-ch Edinburgh 1985.??.??     3     Adams, Michael    Jackson, Sheila 1/2-1/2     2360     2225   C85
    ## 10         BCF-ch Edinburgh 1985.??.??     4     Muir, Andrew J     Adams, Michael 1/2-1/2     2285     2360   E45
    ## # ... with 2,958 more rows, and 1 more variables: Moves <list>

``` r
glimpse(adams)
```

    ## Observations: 2,968
    ## Variables: 11
    ## $ Event    <chr> "Lloyds Bank op", "Lloyds Bank op", "Lloyds Bank op", "Lloyds Bank op", "Lloyds Bank op", "Lloyds ...
    ## $ Site     <chr> "London", "London", "London", "London", "London", "London", "Edinburgh", "Edinburgh", "Edinburgh",...
    ## $ Date     <chr> "1984.??.??", "1984.??.??", "1984.??.??", "1984.??.??", "1984.??.??", "1984.??.??", "1985.??.??", ...
    ## $ Round    <chr> "1", "3", "4", "5", "6", "9", "1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "?", "1", "...
    ## $ White    <chr> "Adams, Michael", "Adams, Michael", "Hebden, Mark", "Pasman, Michael", "Adams, Michael", "Adams, M...
    ## $ Black    <chr> "Sedgwick, David", "Dickenson, Neil F", "Adams, Michael", "Adams, Michael", "Levitt, Jonathan", "S...
    ## $ Result   <chr> "1-0", "1-0", "1-0", "0-1", "1/2-1/2", "1-0", "1/2-1/2", "1-0", "1/2-1/2", "1/2-1/2", "1-0", "1/2-...
    ## $ WhiteElo <chr> "", "", "2480", "2310", "", "", "2360", "2200", "2360", "2285", "2360", "2250", "2360", "2225", "2...
    ## $ BlackElo <chr> "", "2230", "", "", "2370", "2430", "2080", "2360", "2225", "2360", "2245", "2360", "2260", "2360"...
    ## $ ECO      <chr> "C05", "C07", "B10", "D42", "B99", "B56", "B70", "B13", "C85", "E45", "C84", "B10", "C85", "A22", ...
    ## $ Moves    <list> [<"e4", "e6", "d4", "d5", "Nd2", "Nf6", "e5", "Nfd7", "f4", "c5", "c3", "Nc6", "Ndf3", "cxd4", "c...

``` r
unlink(tf)
unlink(fil)
```
