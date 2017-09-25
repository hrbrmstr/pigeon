/*
 *  This file is part of pgn-extract: a Portable Game Notation (PGN) extractor.
 *  Copyright (C) 1994-2017 David J. Barnes
 *
 *  pgn-extract is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 *
 *  pgn-extract is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with pgn-extract. If not, see <http://www.gnu.org/licenses/>.
 *
 *  David J. Barnes may be contacted as d.j.barnes@kent.ac.uk
 *  https://www.cs.kent.ac.uk/people/staff/djb/
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include "bool.h"
#include "mymalloc.h"
#include "defs.h"
#include "typedef.h"
#include "tokens.h"
#include "taglist.h"
#include "lex.h"
#include "moves.h"
#include "map.h"
#include "lists.h"
#include "output.h"
#include "end.h"
#include "grammar.h"
#include "hashing.h"
#include "argsfile.h"

/* The maximum length of an output line.  This is conservatively
 * slightly smaller than the PGN export standard of 80.
 */
#define MAX_LINE_LENGTH 75

/* Define a file name relative to the current directory representing
 * a file of ECO classificiations.
 */
#ifndef DEFAULT_ECO_FILE
#define DEFAULT_ECO_FILE "eco.pgn"
#endif

/* This structure holds details of the program state
 * available to all parts of the program.
 * This goes against the grain of good structured programming
 * principles, but most of these fields are set from the program's
 * arguments and are read-only thereafter. If I had done this in
 * C++ there would have been a cleaner interface!
 */
StateInfo GlobalState = {
    FALSE,              /* skipping_current_game */
    FALSE,              /* check_only (-r) */
    0,                  /* verbosity level (-s and --quiet) */
    TRUE,               /* keep_NAGs (-N) */
    TRUE,               /* keep_comments (-C) */
    TRUE,               /* keep_variations (-V) */
    ALL_TAGS,           /* tag_output_form (-7, --notags) */
    TRUE,               /* match_permutations (-v) */
    FALSE,              /* positional_variations (-x) */
    FALSE,              /* use_soundex (-S) */
    FALSE,              /* suppress_duplicates (-D) */
    FALSE,              /* suppress_originals (-U) */
    FALSE,              /* fuzzy_match_duplicates (--fuzzy) */
    0,                  /* fuzzy_match_depth (--fuzzy) */
    FALSE,              /* check_tags */
    FALSE,              /* add_ECO (-e) */
    FALSE,              /* parsing_ECO_file (-e) */
    DONT_DIVIDE,        /* ECO_level (-E) */
    SAN,                /* output_format (-W) */
    MAX_LINE_LENGTH,    /* max_line_length (-w) */
    FALSE,              /* use_virtual_hash_table (-Z) */
    FALSE,              /* check_move_bounds (-b) */
    FALSE,              /* match_only_checkmate (-M) */
    FALSE,              /* match_only_stalemate (--stalemate) */
    FALSE,              /* keep_move_numbers (--nomovenumbers) */
    TRUE,               /* keep_results (--noresults) */
    TRUE,               /* keep_checks (--nochecks) */
    FALSE,              /* output_evaluation (--evaluation) */
    FALSE,              /* keep_broken_games (--keepbroken) */
    FALSE,              /* suppress_redundant_ep_info (--nofauxep) */
    TRUE,               /* json_format (--json) */
    FALSE,              /* check_for_repetition (--repetition) */
    FALSE,              /* check_for_fifty_move_rule (--fifty) */
    FALSE,              /* tag_match_anywhere (--tagsubstr) */
    0,                  /* depth_of_positional_search */
    0,                  /* num_games_processed */
    0,                  /* num_games_matched */
    0,                  /* games_per_file (-#) */
    1,                  /* next_file_number */
    0,                  /* lower_move_bound */
    10000,              /* upper_move_bound */
    -1,                 /* output_ply_limit (--plylimit) */
    0,                  /* stability_threshold (--stable) */
    0,                  /* maximum_matches */
    FALSE,              /* output_FEN_string */
    FALSE,              /* add_FEN_comments (--fencomments) */
    FALSE,              /* add_hashcode_comments (--hashcomments) */
    FALSE,              /* add_position_match_comments (--markmatches) */
    FALSE,              /* output_plycount (--plycount) */
    FALSE,              /* output_total_plycount (--totalplycount) */
    FALSE,              /* add_hashcode_tag (--addhashcode) */
    FALSE,              /* fix_result_tags (--fixresulttags) */
    FALSE,              /* separate_comment_lines (--commentlines) */
    FALSE,              /* split_variants (--separatevariants) */
    FALSE,              /* reject_inconsistent_results (--nobadresults) */
    FALSE,              /* allow_null_moves (--allownullmoves) */
    0,                  /* split_depth_limit */
    NORMALFILE,         /* current_file_type */
    SETUP_TAG_OK,       /* setup_status */
    "MATCH",            /* position_match_comment (--markpositionmatches) */
    (char *) NULL,      /* FEN_comment_pattern (-Fpattern) */
    (char *) NULL,      /* current_input_file */
    DEFAULT_ECO_FILE,   /* eco_file (-e) */
    (FILE *) NULL,      /* outputfile (-o, -a). Default is stdout */
    (char *) NULL,      /* output_filename (-o, -a) */
    (FILE *) NULL,      /* logfile (-l). Default is stderr */
    (FILE *) NULL,      /* duplicate_file (-d) */
    (FILE *) NULL,      /* non_matching_file (-n) */
    NULL,               /* matching_game_numbers */
    NULL,               /* next_game_number_to_output */
    NULL,               /* skip_game_numbers */
    NULL,               /* next_game_number_to_skip */
};

StateInfo defState = {
    FALSE,              /* skipping_current_game */
    FALSE,              /* check_only (-r) */
    0,                  /* verbosity level (-s and --quiet) */
    TRUE,               /* keep_NAGs (-N) */
    TRUE,               /* keep_comments (-C) */
    TRUE,               /* keep_variations (-V) */
    ALL_TAGS,           /* tag_output_form (-7, --notags) */
    TRUE,               /* match_permutations (-v) */
    FALSE,              /* positional_variations (-x) */
    FALSE,              /* use_soundex (-S) */
    FALSE,              /* suppress_duplicates (-D) */
    FALSE,              /* suppress_originals (-U) */
    FALSE,              /* fuzzy_match_duplicates (--fuzzy) */
    0,                  /* fuzzy_match_depth (--fuzzy) */
    FALSE,              /* check_tags */
    FALSE,              /* add_ECO (-e) */
    FALSE,              /* parsing_ECO_file (-e) */
    DONT_DIVIDE,        /* ECO_level (-E) */
    SAN,                /* output_format (-W) */
    MAX_LINE_LENGTH,    /* max_line_length (-w) */
    FALSE,              /* use_virtual_hash_table (-Z) */
    FALSE,              /* check_move_bounds (-b) */
    FALSE,              /* match_only_checkmate (-M) */
    FALSE,              /* match_only_stalemate (--stalemate) */
    FALSE,              /* keep_move_numbers (--nomovenumbers) */
    TRUE,               /* keep_results (--noresults) */
    TRUE,               /* keep_checks (--nochecks) */
    FALSE,              /* output_evaluation (--evaluation) */
    FALSE,              /* keep_broken_games (--keepbroken) */
    FALSE,              /* suppress_redundant_ep_info (--nofauxep) */
    TRUE,               /* json_format (--json) */
    FALSE,              /* check_for_repetition (--repetition) */
    FALSE,              /* check_for_fifty_move_rule (--fifty) */
    FALSE,              /* tag_match_anywhere (--tagsubstr) */
    0,                  /* depth_of_positional_search */
    0,                  /* num_games_processed */
    0,                  /* num_games_matched */
    0,                  /* games_per_file (-#) */
    1,                  /* next_file_number */
    0,                  /* lower_move_bound */
    10000,              /* upper_move_bound */
    -1,                 /* output_ply_limit (--plylimit) */
    0,                  /* stability_threshold (--stable) */
    0,                  /* maximum_matches */
    FALSE,              /* output_FEN_string */
    FALSE,              /* add_FEN_comments (--fencomments) */
    FALSE,              /* add_hashcode_comments (--hashcomments) */
    FALSE,              /* add_position_match_comments (--markmatches) */
    FALSE,              /* output_plycount (--plycount) */
    FALSE,              /* output_total_plycount (--totalplycount) */
    FALSE,              /* add_hashcode_tag (--addhashcode) */
    FALSE,              /* fix_result_tags (--fixresulttags) */
    FALSE,              /* separate_comment_lines (--commentlines) */
    FALSE,              /* split_variants (--separatevariants) */
    FALSE,              /* reject_inconsistent_results (--nobadresults) */
    FALSE,              /* allow_null_moves (--allownullmoves) */
    0,                  /* split_depth_limit */
    NORMALFILE,         /* current_file_type */
    SETUP_TAG_OK,       /* setup_status */
    "MATCH",            /* position_match_comment (--markpositionmatches) */
    (char *) NULL,      /* FEN_comment_pattern (-Fpattern) */
    (char *) NULL,      /* current_input_file */
    DEFAULT_ECO_FILE,   /* eco_file (-e) */
    (FILE *) NULL,      /* outputfile (-o, -a). Default is stdout */
    (char *) NULL,      /* output_filename (-o, -a) */
    (FILE *) NULL,      /* logfile (-l). Default is stderr */
    (FILE *) NULL,      /* duplicate_file (-d) */
    (FILE *) NULL,      /* non_matching_file (-n) */
    NULL,               /* matching_game_numbers */
    NULL,               /* next_game_number_to_output */
    NULL,               /* skip_game_numbers */
    NULL,               /* next_game_number_to_skip */
};

/* Prepare the output file handles in GlobalState. */
static void
init_default_global_state(void)
{

  memcpy( (void*)&GlobalState, (void*)&defState, sizeof(defState) );

  GlobalState.outputfile = NULL;
  GlobalState.output_filename = NULL;
  GlobalState.logfile = NULL;
  GlobalState.current_input_file = NULL;

//    GlobalState.outputfile = stdout;
//    GlobalState.logfile = stderr;
//    set_output_line_length(MAX_LINE_LENGTH);
}

int do_main(char *ifil, char *ofil, char *lfil) {

//    int argnum;

    /* Prepare global state. */
    init_default_global_state();
    /* Prepare the Game_Header. */
    init_game_header();
    /* Prepare the tag lists for -t/-T matching. */
    init_tag_lists();
    /* Prepare the hash tables for transposition detection. */
    init_hashtab();
    /* Initialise the lexical analyser's tables. */
    init_lex_tables();

    process_argument('o', ofil);
    process_argument('l', lfil);

    add_filename_to_source_list(ifil, NORMALFILE);

    /* Make some adjustments to other settings if JSON output is required. */
    if (GlobalState.json_format) {
        if (GlobalState.output_format != EPD &&
                GlobalState.output_format != CM &&
                GlobalState.ECO_level == DONT_DIVIDE) {
            GlobalState.keep_comments = FALSE;
            GlobalState.keep_variations = FALSE;
            GlobalState.keep_results = FALSE;
        }
        else {
            fprintf(GlobalState.logfile, "JSON output is not currently supported with -E, -Wepd or -Wcm\n");
            GlobalState.json_format = FALSE;
        }
    }

    /* Prepare the hash tables for duplicate detection. */
    init_duplicate_hash_table();

    /* Open up the first file as the source of input. */
    if (!open_first_file()) {
//        exit(1);
    }

    yyparse(GlobalState.current_file_type);

    /* @@@ I would prefer this to be somewhere else. */
    if (GlobalState.json_format &&
            !GlobalState.check_only &&
            GlobalState.num_games_matched > 0) {
        fputs("\n]\n", GlobalState.outputfile);
    }

    /* Remove any temporary files. */
    clear_duplicate_hash_table();

    (void)fclose(GlobalState.outputfile);

    if ((GlobalState.logfile != NULL)) {
        (void) fclose(GlobalState.logfile);
    }

    return 0;
}
