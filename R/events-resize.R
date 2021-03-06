#' @include events.R
NULL

#' Event broker for resize events.
#'
#' The resize event broker is useful if you want your shiny app to respond
#' to resize events.
#'
#' @export
#' @importFrom methods setRefClass
Resize <- setRefClass("Resize", contains = "EventBroker",
  methods = list(
    resize = function() {
      "A reactive value changed when the plot is resized."

      listen_for("resize")
    }
  )
)

#' An interactive input bound to resize events.
#'
#' @param f A function which is called each time the plot area is resized.
#'
#' @export
#' @examples
#' \dontrun{
#' # This example just prints out the current dimensions to the console
#' print_info <- function(x) {
#'   cat(str(x))
#' }
#'
#' ggvis(mtcars, props(x = ~mpg, y = ~wt)) +
#'   mark_symbol() +
#'   resize(print_info)
#' }
resize <- function(f) {
  stopifnot(is.function(f))
  handler("resize", "resize", list(f = f))
}

#' @export
as.reactive.resize <- function(x, session = NULL, ...) {
  h <- Resize(session, id = x$id)

  obs <- observe({
    r <- h$resize()
    if (is.null(r)) return()

    x$control_args$f(r)
  })

  session$onSessionEnded(function() {
    obs$suspend()
  })

  reactive({ NULL })
}
