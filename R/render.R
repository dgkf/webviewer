#' @import htmltools
#' @importFrom mime guess_type
#' @export
render <- function(x, type = mime::guess_type(x)) {
  if (grepl("^https?://", x)) return(render.http(x))
  UseMethod("render", structure(1L, class = rev(strsplit(type, "/")[[1L]])))
}

#' @export
render.image <- function(x, ...) {
  img(src = sprintf("file/%s", x))
}

#' @export
render.html <- function(x, ...) {
  tags$iframe(src = sprintf("file/%s", x))
}

#' @export
render.http <- function(x, ...) {
  tags$iframe(src = x, class = "fill")
}
