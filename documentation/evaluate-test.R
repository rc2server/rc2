library(evaluate)

#rm(foobar)
#tc <- textConnection("foobar", open = "w")

createWrapper <- function() {
  curList <- list()
  myEnv <- new.env(parent = emptyenv())
  assign("curValues", list(), envir = myEnv)
  assign("items", list(), envir = myEnv)
  assign("plots", list(), envir = myEnv)
  assign("nextValId", 1, envir = myEnv)
  assign("nextPlotId", 1, envir = myEnv)
  rc2evaluate <- function(src) {
    rval <- evaluate(src, output_handler = outputHandler)
    curList <- get("items", envir = myEnv)
    curVals = get("curValues", envir = myEnv)
    curPlots = get("plots", envir = myEnv)
    if(length(curPlots) > 0) {
      curList[['images']] = curPlots
    }
    curList[["value"]] = structure((curVals))
    assign("items", curList, envir = myEnv)
    rval
  }
  outputHandler <- new_output_handler(
    source=function(value, visible = TRUE) {
#      writeLines("source", con = tc)
      curList = get("items", envir = myEnv)
      curList[['source']] = structure(list(data=value), myclass="src")
      plots = get("plots", envir = myEnv)
      if (length(plots) > 0) {
        curList[['images']] = plots
      }
      assign("items", curList, envir = myEnv)
      invisible(NULL)
  }, 
  text=function(txt) {
#    writeLines("text", con = tc)
  }, 
  message=function(msg) {
#    writeLines("message", con = tc)
    curList = get("items", envir = myEnv)
    curList[['message']] = structure(list(data=msg), myclass="message")
    assign("items", curList, envir = myEnv)
  },
  warning=function(msg) {
  },
  error=function(msg) {
#    writeLines("error", con = tc)
    curList = get("items", envir = myEnv)
    curList[['error']] = structure(list(data=msg), myclass="myerror")
    assign("items", curList, envir = myEnv)
  }, 
  graphics = function(data) {
#    writeLines("graphics", con = tc)
    plots = get("plots", envir = myEnv)
    nextPlotId <- get("nextPlotId", envir = myEnv)
    plots[[nextPlotId]] = data
    assign("nextPlotId", nextPlotId + 1, envir = myEnv)
    assign("plots", plots, envir = myEnv)
  },
value=function(value, visible = TRUE) {
#  writeLines("value", con = tc)
  vals <- structure(list(data=value, visible=visible), class="myvalue")
  curVals <- get("curValues", envir = myEnv)
  nextValId <- get("nextValId", envir = myEnv)
  curVals[[nextValId]] = vals
  assign("nextValId", nextValId + 1, envir = myEnv)
  assign("curValues", curVals, envir = myEnv)
  invisible(NULL)
})
  structure(list(outputHandler=outputHandler, env=myEnv, evaluate=rc2evaluate))
}

#wrapper <- createWrapper()
#if (TRUE) {
#  dd <- evaluate("44-21; rnorm(10)", output_handler = wrapper$outputHandler, debug=TRUE)
#  dd <- wrapper$evaluate("44-21; rnorm(10)")
#} else {
#  wrapper$evaluate("2+2; doofus(); plot(rnorm(10)); plot(rnorm(4)); message(\"hello\")")
#}
#items <- get("items", envir = wrapper$env)
#items

