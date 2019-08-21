library(evaluate)

createWrapper <- function() {
  index <- 0
  curList <- list()
  myEnv <- new.env()
  assign("items", list(), envir = myEnv)
#  items <- list()
  assign("nextIndex", 1, envir = myEnv)
  addGeneric <- function(obj) {
    index <- get("nextIndex", envir = myEnv)
    assign("nextIndex", index + 1, envir = myEnv)
    curList = get("items", envir = myEnv)
    curList[[index]] = obj
    assign("items", curList, envir = myEnv)
    invisible(NULL)
  }
  outputHandler <- new_output_handler(
    source=function(value, visible = TRUE) {
      index <- get("nextIndex", envir = myEnv)
      assign("nextIndex", index + 1, envir = myEnv)
      curList = get("items", envir = myEnv)
      curList[[index]] = structure(list(data=value), myclass="src")
      assign("items", curList, envir = myEnv)
      invisible(NULL)
  }, 
  text=function(txt) {
    # index <- get("nextIndex", envir = myEnv)
    # assign("nextIndex", index + 1, envir = myEnv)
    # curList = get("items", envir = myEnv)
    # curList[[index]] = structure(list(data=txt), myclass="mytext")
    # assign("items", curList, envir = myEnv)
    # invisible(NULL)
  }, 
  message=function(msg) {
    index <- get("nextIndex", envir = myEnv)
    assign("nextIndex", index + 1, envir = myEnv)
    curList = get("items", envir = myEnv)
    curList[[index]] = structure(list(data=msg), myclass="message")
    assign("items", curList, envir = myEnv)
  },
  warning=function(msg) {
#    addGeneric(structure(list(data=msg), class="warning"))
  },
  error=function(msg) {
    index <- get("nextIndex", envir = myEnv)
    assign("nextIndex", index + 1, envir = myEnv)
    curList = get("items", envir = myEnv)
    curList[[index]] = structure(list(data=msg), myclass="myerror")
    assign("items", curList, envir = myEnv)
  }, 
  graphics = function(data) {
#    invisible()
  },
  value=function(value, visible = TRUE) {
    index <- get("nextIndex", envir = myEnv)
    assign("nextIndex", index + 1, envir = myEnv)
    curList = get("items", envir = myEnv)
    curList[index] = structure(list(data=value, visible=visible), class="myvalue")
    assign("items", curList, envir = myEnv)
#    addGeneric(structure(list(value=value, visible=visible), class="value"))
    invisible(NULL)
  })
  structure(list(outputHandler=outputHandler, env=myEnv)) #items=get("items", envir = myEnv)), class="wrapper")
}

wrapper <- createWrapper()
evaluate("2+2; doofus(); rnorm(10); message(\"hello\")", output_handler = wrapper$outputHandler, debug=FALSE)
items <- get("items", envir = wrapper$env)
items

