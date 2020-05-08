library(evaluate)

#rm(foobar)
#tc <- textConnection("foobar", open = "w")

createWrapper <- function(parent = emptyenv()) {
  myEnv <- new.env(parent = parent)
  assign("allItems", list(), envir = myEnv)
  rc2evaluate <- function(src) {
    evaluate(src, output_handler = outputHandler, stop_on_error = 1L)
  }
  outputHandler <- new_output_handler(
    source=function(value, visible = TRUE) {
      #      writeLines("source", con = tc)

      all = get("allItems", envir = myEnv)
      newval <- list(data=value)
      class(newval) <- "rc2src"
      all[[length(all) + 1]] = newval
      assign("allItems", all, envir = myEnv)
      invisible(NULL)
    }, 
    text=function(txt) {
      #    writeLines("text", con = tc)
    }, 
    message=function(msg) {
#      writeLines("msg", con = tc)
      all = get("allItems", envir = myEnv)
      newval <- list(data=msg)
      class(newval) <- "rc2msg"
      all[[length(all) + 1]] = newval
      assign("allItems", all, envir = myEnv)
      
      invisible(NULL)
    },
    warning=function(msg) {
#      writeLines("warn", con = tc)
      invisible(NULL)
    },
    error=function(msg) {
#      writeLines("err", con = tc)
      all = get("allItems", envir = myEnv)
      newval <- list(data=msg)
      class(newval) <- "rc2err"
      all[[length(all) + 1]] = newval
      assign("allItems", all, envir = myEnv)
      
      invisible(NULL)
    }, 
    graphics = function(data) {
#      writeLines("gfx", con = tc)
      all = get("allItems", envir = myEnv)
      newval <- list(data)
      class(newval) <- "rc2plot"
      all[[length(all) + 1]] = newval
      assign("allItems", all, envir = myEnv)

      invisible(NULL)
    },
    value=function(value, visible = TRUE) {
 #     writeLines("val", con = tc)
      # was getting calls with NULL, FALSE because funcs return invisible(NULL). now skip that
      if(visible == FALSE) { return(invisible(NULL)) }
      vals <- list(data=value, visible=visible)
      class(vals) <- "valuePair"
      all = get("allItems", envir = myEnv)
      newval <- structure(list(vals), myclass="val")
      class(newval) <- "rc2value"
      all[[length(all) + 1]] = newval
      assign("allItems", all, envir = myEnv)
      
      invisible(NULL)
    })
  saveImage <- function(img, name) {
    png(name)
    replayPlot(img)
    dev.off()
  }
  structure(list(outputHandler=outputHandler, env=myEnv, evaluate=rc2evaluate, saveImage=saveImage))
}

wrapper <- createWrapper()
#if (TRUE) {
#  dd <- evaluate("44-21; rnorm(10)", output_handler = wrapper$outputHandler, debug=TRUE)
#  dd <- wrapper$evaluate("44-21; rnorm(10)")
#} else {
  wrapper$evaluate("2+2\n plot(rnorm(10))\n 1*8; plot(rnorm(4)); message(\"hello\")")
#}
items <- get("allItems", envir = wrapper$env)
#items
