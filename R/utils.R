doc_data_frame <- function(object, name = NULL, envir = .GlobalEnv) {
  x <- if (!missing(object))
    object
  else {
    x <- get(name, envir = envir)
  }
  x <- as.data.frame(x)
  make_item_tag <- function(s) {
    if (grepl("^([[:alpha:]]|[.][[:alpha:]._])[[:alnum:]._]*$",
              s)) {
      paste0("\\code{", s, "}")
    }
    else {
      paste0("\\samp{", gsub("([%{}])", "\\\\\\1",
                             s), "}")
    }
  }
  fmt <- c(paste("  A data frame with", nrow(x),
                              "observations on the following", ifelse(ncol(x) ==
                                                                        1, "variable.", paste(ncol(x), "variables."))),
           "  \\describe{")
  for (i in names(x)) {
    xi <- x[[i]]
    fmt <- c(fmt, paste0("    \\item{", make_item_tag(i),
                         "}{", if (inherits(xi, "ordered")) {
                           paste("an", data.class(xi), "factor with levels",
                                 paste0("\\code{", levels(xi), "}", collapse = " < "),
                                 collapse = " ")
                         } else if (inherits(xi, "factor")) {
                           paste("a factor with levels", paste0("\\code{",
                                                                levels(xi), "}", collapse = " "), collapse = " ")
                         } else if (is.vector(xi)) {
                           paste("a", data.class(xi), "vector")
                         } else if (is.matrix(xi)) {
                           paste("a matrix with", ncol(xi), "columns")
                         } else {
                           paste("a", data.class(xi))
                         }, "}"))
  }
  paste(c(fmt, "  }"))
}

doc_bps6_data <- function(name) {
  env <- new.env()
  data(list = name, package = "bps6data", envir = env)
  doc_data_frame(name = name, envir = env)
}
