# R/sequences.R

#' Calculate GC content of a DNA sequence
#'
#' Computes the percentage of guanine (G) and cytosine (C) bases in a
#' DNA sequence. Ambiguous bases (e.g. `N`) are counted in the denominator
#' but not as GC, so they dilute the result.
#'
#' @param sequence A single character string of DNA bases (`A`, `T`, `G`, `C`).
#'   Case-insensitive. Must have length 1.
#'
#' @returns A single numeric value giving the GC percentage (0–100), rounded
#'   to two decimal places. Returns `NA_real_` for empty strings.
#'
#' @examples
#' gc_content("ATGCATGC")        # 50.00 — balanced
#' gc_content("GCGCGCGC")        # 100.00 — all GC
#' gc_content("ATATATAT")        # 0.00 — all AT
#' gc_content("ATGCNN")          # 33.33 — N bases dilute
#'
#' # Works naturally with the native pipe
#' c(promoter = "ATATAT", exon = "GCGCGC") |> vapply(gc_content, numeric(1))
#'
#' @seealso [reverse_complement()] for the companion function.
#' @export
gc_content <- function(sequence) {
  if (!is.character(sequence) || length(sequence) != 1L) {
    stop("`sequence` must be a single character string.", call. = FALSE)
  }
  bases <- strsplit(toupper(sequence), "")[[1]]
  if (length(bases) == 0L) return(NA_real_)
  gc <- sum(bases %in% c("G", "C"))
  round(gc / length(bases) * 100, 2)
}


#' Reverse complement of a DNA sequence
#'
#' Returns the reverse complement of a DNA sequence using standard
#' Watson–Crick base-pairing rules (A↔T, G↔C). Ambiguous bases are
#' passed through unchanged.
#'
#' @param sequence A single character string of DNA bases. Case-insensitive.
#'   Must have length 1.
#'
#' @returns A character string: the reverse complement, upper-case.
#'
#' @examples
#' reverse_complement("ATGC")    # "GCAT"
#' reverse_complement("AAAA")    # "TTTT"
#' reverse_complement("GCGCGC")  # "GCGCGC"
#' reverse_complement("ATGCN")   # "NGCAT" — N passed through
#'
#' @seealso [gc_content()] for the companion function.
#' @export
reverse_complement <- function(sequence) {
  if (!is.character(sequence) || length(sequence) != 1L) {
    stop("`sequence` must be a single character string.", call. = FALSE)
  }
  map   <- c(A = "T", T = "A", G = "C", C = "G")
  bases <- strsplit(toupper(sequence), "")[[1]]
  rev_comp <- map[bases]
  rev_comp[is.na(rev_comp)] <- bases[is.na(rev_comp)]  # pass-through unknowns
  paste(rev(rev_comp), collapse = "")
}
