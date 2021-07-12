#' @importFrom httpuv startServer
#' @export
serve_viewer <- function() {
  # TODO: Convert this environment object into an actual R6 class

  app_html_file <- system.file("index.html", package = "viewerserver")
  app_html <- paste(collapse = "\n", readLines(app_html_file))

  path <- file.path(dirname(tempdir()), "R_viewerserver")
  if (!dir.exists(path)) dir.create(path)

  env <- new.env(parent = emptyenv())
  env$path <- path
  env$socket <- list()
  env$server <- httpuv::startServer(host = "0.0.0.0", port = 8001, app = list(
    call = function(req) {
      list(
        status = 200L,
        headers = list("Content-Type" = "text/html"),
        body = app_html
      )
    },
    staticPaths = list(
      "/" = system.file(package = "viewerserver"),
      "/file" = env$path
    ),
    onWSOpen = function(ws) {
      ws$onMessage(function(binary, message) {
        # TODO: handle device width/height adjusting to fill browser
        # print(jsonlite::fromJSON(message))
      })

      # preserve socket so that we can send content to it
      ws$send("Awaiting Content...")
      env$socket <- ws
    }
  ))

  env$show <- function(x, ...) {
    if (is.null(env$socket)) return()

    new_dir <- tempfile(tools::file_path_sans_ext(basename(x)), tmpdir = env$path)
    new_path <- paste0(new_dir, ".", tools::file_ext(x))
    
    if (basename(x) == "index.html") {
      dir.create(new_dir)
      file.copy(dirname(x), new_dir, recursive = TRUE)
      content <- render(file.path(basename(new_dir), basename(dirname(x)), basename(x)))
    } else if (dir.exists(x)) {
      dir.create(new_path)
      file.copy(x, new_path, recursive = TRUE)
      content <- render(basename(new_path))
    } else if (file.exists(x)) {
      file.copy(x, new_path)
      content <- render(basename(new_path))
    } else {
      content <- render(x)
    }

    env$socket$send(content)
  }
  
  env
}
