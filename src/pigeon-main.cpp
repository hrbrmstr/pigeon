// [[Rcpp::depends(RcppProgress)]]

#include <Rcpp.h>

#include "progress.hpp"

#include <iostream>
#include <fstream>
#include <regex>

#include "csv.h"

using namespace Rcpp;

std::regex pgn_regex("^\\[Event (.*)]");

// [[Rcpp::export]]
double int_pgn_count(std::string path) {

  io::LineReader fin(path);

  double ret_val = 0;
  std::cmatch m;

  while (char* line = fin.next_line()) {
    if (std::regex_match(line, m, pgn_regex)) ret_val++;
  }

  return(ret_val);

}

// [[Rcpp::export]]
List int_pgn_recs(std::string path, NumericVector v) {

  bool display_progress = TRUE;

  std::filebuf fb;
  fb.open(path, std::ios::in | std::ios::binary);
  std::istream fis(&fb);

  io::LineReader fin(path, fis);

  List ret(v.size());
  int idx = 0;
  int rec = 0;
  std::cmatch m;

  Progress p(v.size(), display_progress);

  while (char* line = fin.next_line()) {

    if (std::regex_match(line, m, pgn_regex)) { // Found ^[Event ...

      rec++; // increment Event record count

      if (rec == v[idx]) { // if it matches one of the ones we said we want

        if (Progress::check_abort()) return(List());

        p.increment();

        CharacterVector cv; // bag of holding

        cv.push_back(line); // store the Event field

        while(char *line = fin.next_line()) { // going to store other fields and break on first ""
          std::string ll = std::string(line);
          cv.push_back(ll);
          if (ll == "") break;
        }

        bool seen_moves = false;

        while(char *line = fin.next_line()) { // going to store the moves and break on the next ""
          std::string ll = std::string(line);
          if ((!seen_moves) && (ll == "")) continue; // account for malformed whitespace
          seen_moves = true;
          cv.push_back(ll);
          if (ll == "") break;
        }

        ret[idx++] = cv; // store our full record and add it to the return list

      }

    }

    if (idx > v.size()) break; // no need to read in the rest of the file

  }

  fb.close();

  return(ret);

}
