#include <Rcpp.h>
using namespace Rcpp;

// This is a simple example of exporting a C++ function to R. You can
// source this function into an R session using the Rcpp::sourceCpp
// function (or via the Source button on the editor toolbar). Learn
// more about Rcpp at:
//
//   http://www.rcpp.org/
//   http://adv-r.had.co.nz/Rcpp.html
//   http://gallery.rcpp.org/
//

extern "C" {
  int do_main(char *ifil, char *ofil, char *lfil);
}

// [[Rcpp::export]]
bool parse_pgn(std::string in_path, std::string out_path, std::string log_path) {

  int ret = do_main(
    (char *)in_path.c_str(),
    (char *)out_path.c_str(),
    (char *)log_path.c_str()
  );

  return(ret == 0);

}
