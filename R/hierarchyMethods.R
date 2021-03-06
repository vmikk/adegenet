########################################################################
# hierarchy methods definitions. 
#
# Zhian Kamvar, March 2015
# kamvarz@science.oregonstate.edu
########################################################################
.getHier <- function(x, formula = NULL, combine = TRUE, call = match.call()){
  if (is.null(x@strata)){
	  warning("Strata must be specified before defining a hierarchy. See ?strata for details.", call. = FALSE)
	  return(NULL)
	}
  if (is.null(x@hierarchy)){
    warning("A hierarchy must be defined before retrieving it.", call. = FALSE)
    return(NULL)
  }
  if (is.null(formula)){
    if (!is.null(x@hierarchy)){
      # Returning the base hierarchy
      return(.getHier(x, formula = x@hierarchy, combine = combine, call = call))      
    } else {
      return(NULL)
    }
  }
  vars <- all.vars(formula)
  if (any(!vars %in% names(x@strata))){
    stop(.strata_incompatible_warning(vars, x@strata), call. = FALSE)
  }
  if (!.test_existing_hier(vars, all.vars(x@hierarchy))){
  	callform <- as.character(call["formula"])
    lines <- paste(rep("-", 78), collapse = "")
  	stop(paste0("\n", lines, "\n", callform, "\nis not a subset of\n", 
         paste(x@hierarchy, collapse = "")), call. = FALSE)
  }
  if (combine){
    strata <- .make_strata(formula, x@strata)
  } else {
    strata <- x@strata[all.vars(formula)]
  }
  invisible(return(strata))
}

.setHier <- function(x, value, call = match.call()){
  if (is.null(value)){
    x@hierarchy <- value
    return(x)
  }
  if (is.null(x@strata)){
  	warning("Strata must be specified before defining a hierarchy. See ?strata for details.", call. = FALSE)
  	return(NULL)
  }
  if (!is.language(value)){
    callval <- as.character(call["value"])
    stop(paste(callval, "is not a formula"), call. = FALSE)
  }
  vars <- all.vars(value)
  if (any(!vars %in% names(x@strata))){
    stop(.strata_incompatible_warning(vars, x@strata), call. = FALSE)
  }

  ## TODO: Insert Jerome's method of checking whether or not the hierarchy is 
  ##       truly hierarchical.
  
  x@hierarchy <- value
  return(x)
}

.test_existing_hier <- function(query, hier){
	matches <- match(hier, query)
	matches <- matches[!is.na(matches)]
	if (all(matches == sort(matches))){
		return(TRUE)
	} else {
		return(FALSE)
	}
}

#==============================================================================#
#' Access and manipulate the population hierarchy for genind or genlight objects.
#' 
#' The following methods allow the user to quickly change the hierarchy or
#' population of a genind or genlight object. 
#' 
#' @export
#' @rdname hierarchy-methods
#' @aliases hier,genind-method hier,genlight-method
#' @param x a genind or genlight object
#' @param formula a nested formula indicating the order of the population 
#'   hierarchy to be returned.
#' @param combine if \code{TRUE} (default), the levels will be combined
#'   according to the formula argument. If it is \code{FALSE}, the levels will
#'   not be combined.
#' @param value a formula specifying the full hierarchy of columns in the strata
#'   slot. \strong{(See Details below)}
#' @docType methods
#'   
#' @details You must first specify your strata before you can specify your 
#'   hierarchies. Hierarchies are special cases of strata in that the levels 
#'   must be nested within each other. An error will occur if you specify a 
#'   hierarchy that is not truly hierarchical.
#'   
#'   \subsection{Details on Formulas}{
#'   
#'   The preferred use of these functions is with a \code{\link{formula}} 
#'   object. Specifically, a hierarchical formula argument is used to name which
#'   strata are hierarchical. An example of a hierarchical formula would
#'   be:\tabular{r}{ \code{~Country/City/Neighborhood}} This convention was
#'   chosen as it becomes easier to type and makes intuitive sense when defining
#'   a hierarchy. Note: it is important to use hierarchical formulas when
#'   specifying hierarchies as other types of formulas (eg. 
#'   \code{~Country*City*Neighborhood}) will give incorrect results.}
#'   
#' @seealso \code{\link{strata}} \code{\link{genind}}
#'   \code{\link{as.genind}}
#'   
#' @author Zhian N. Kamvar
#' @examples
#' # let's look at the microbov data set:
#' data(microbov)
#' microbov
#' 
#' # We see that we have three vectors of different names in the 'other' slot. 
#' ?microbov
#' # These are Country, Breed, and Species
#' names(other(microbov))
#' 
#' # Let's set the hierarchy
#' strata(microbov) <- data.frame(other(microbov))
#' microbov
#' 
#' # And change the names so we know what they are
#' nameStrata(microbov) <- ~Country/Breed/Species
#' 
#' # let's see what the hierarchy looks like by Species and Breed:
#' hier(microbov) <- ~Species/Breed
#' head(hier(microbov, ~Species/Breed))
#' 
#==============================================================================#
hier <- function(x, formula = NULL, combine = TRUE, value){
  standardGeneric("hier")
} 

#' @export
setGeneric("hier")

setMethod(
  f = "hier",
  signature(x = "genind"),
  definition = function(x, formula = NULL, combine = TRUE, value){
    theCall <- match.call()
    if (missing(value)){
      .getHier(x, formula = formula, combine = combine, theCall)  
    } else {
      .setHier(x, value, theCall)
    }
  })

setMethod(
  f = "hier",
  signature(x = "genlight"),
  definition = function(x, formula = NULL, combine = TRUE, value){
    theCall <- match.call()
    if (missing(value)){
      .getHier(x, formula = formula, combine = combine, theCall)  
    } else {
      .setHier(x, value, theCall)
    }
    
  })


#==============================================================================#
#' @export 
#' @rdname hierarchy-methods
#' @aliases hier<-,genind-method hier<-,genlight-method
#' @docType methods
#==============================================================================#
"hier<-" <- function(x, value){
  standardGeneric("hier<-")
}  

#' @export
setGeneric("hier<-")

setMethod(
  f = "hier<-",
  signature(x = "genind"),
  definition = function(x, value){
    theCall <- match.call()
    return(.setHier(x, value, theCall))
  })

setMethod(
  f = "hier<-",
  signature(x = "genlight"),
  definition = function(x, value){
    theCall <- match.call()
    return(.setHier(x, value, theCall))
  })
