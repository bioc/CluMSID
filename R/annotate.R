#' Generate a \code{data.frame} with feature information from list of
#' \code{MS2spectrum} objects
#'
#' \code{Featurelist} generates a \code{data.frame} that contains feature ID,
#' precurosur \emph{m/z} and retention time for all features contained in a list
#' of \code{MS2spectrum} objects as produced by \code{extractMS2spectra} and
#' \code{mergeSpecList}. \code{Featurelist} is used internally by
#' \code{\link{writeFeaturelist}}.
#'
#' @param featlist A list of \code{MS2spectrum} objects as produced by
#'   \code{extractMS2spectra} and \code{mergeSpecList}
#'
#' @return A \code{data.frame} that contains feature ID, precurosur \emph{m/z}
#'   and retention time
#'
#' @export
Featurelist <- function(featlist){
  id <- c(); mz <- c(); rt <- c()
  for(i in 1:length(featlist)){
    id[i] <- featlist[[i]]@id
    mz[i] <- featlist[[i]]@precursor
    rt[i] <- featlist[[i]]@rt
  }
  df <- data.frame(id, mz, rt, stringsAsFactors = FALSE)
  return(df)
}

#' Write feature information from list of \code{MS2spectrum} objects
#'
#' \code{writeFeaturelist} uses \code{\link{Featurelist}} to generate a
#' \code{data.frame} that contains feature ID, precurosur \emph{m/z} and
#' retention time for all features contained in a list of \code{MS2spectrum}
#' objects as produced by \code{extractMS2spectra} and \code{mergeSpecList} and
#' writes it to a csv file.
#'
#' @inheritParams Featurelist
#'
#' @param filename The desired file name of the csv file, default is
#'   \code{"pre_anno.csv"}
#'
#' @return A csv file that contains feature ID, precurosur \emph{m/z} and
#'   retention time. The file has a header but no row names and is separated by
#'   \code{','}.
#'
#' @export
writeFeaturelist <- function(featlist, filename = "pre_anno.csv"){
  df <- Featurelist(featlist)
  df$annotation <- rep("", length(featlist))
  utils::write.table(
    df,
    file = filename,
    sep = ",",
    row.names = F
  )
}

#' Adding external annotations to list of \code{MS2spectrum} objects
#'
#' \code{addAnnotations} is used to add annotations that have been assigned
#' externally, e.g. by library search, to a list of \code{MS2spectrum} objects
#' as produced by \code{extractMS2spectra} and \code{mergeSpecList}.
#'
#' @inheritParams Featurelist
#'
#' @param annolist A list of annotations, either as a \code{data.frame} or csv
#'   file. The order of features must be the same as in \code{featlist}. Please
#'   see the package vignette for a detailed example!
#'
#' @param annotationColumn The column of \code{annolist} were the annotation is
#'   found. Default is \code{4}, which is the case if
#'   \code{\link{writeFeaturelist}} followed by manual addition of annotations,
#'   e.g. in Excel, is used to generate \code{annolist}.
#'
#' @return A list of \code{MS2spectrum} objects as produced by
#'   \code{extractMS2spectra} and \code{mergeSpecList} with external annotations
#'   added to the \code{annotation} slot of each \code{MS2spectrum} object.
#'
#' @export
addAnnotations <- function(featlist, annolist, annotationColumn = 4){
  if(is.data.frame(annolist)){
    ident <- annolist
  } else {
    ident <-
      utils::read.csv(file = annolist, stringsAsFactors = F)
  }
  stopifnot(length(featlist) == nrow(annolist))
  for(i in 1:length(featlist)){
    if(ident[i, annotationColumn] != ""){
      featlist[[i]]@annotation <- ident[i, annotationColumn]
    }
  }
  return(featlist)
}