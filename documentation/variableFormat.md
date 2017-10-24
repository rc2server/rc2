What format do vector, matrix, array come as?

is object?
	- setObjectData
	- addSummary
switch sexp
	- vecsxp: setListData
	- envsxp: setEnvironmentData
	- closxp, specialsxp, builtinsxp: setFunctionData
	- default: setPrimitiveData

## Object
	- class first name, or  "ordered factor" if (class[1] == "ordered", class[2] == "factor")
	- if s4 { S4 = true }
	- if factor: type = "f", levels = ["",""], values = [1,2,1]
	- if date: type = "date", value = "YYY-MM-DD"
	- if POSIXct: type = "date", value = 2324234234.22
	- if POSIXlt: type = "date", value = fractional timestamp
	- if data.frame
	- default: generic="true", names=["",""], length=2, value=[json, json] (names/values are attributes)
	

## Data Frame

	- class = "data.frame"
	- summary = "data.frame: 32 objs of 11 variables"
	- cols = ["mpg", "cyl"]
	- ncol = 2
	- nrow = 4
	- row.names = ["row1","row2"]
	- types = ["d","i"]
	- rows = [[21.0, 2], [44.0, 45]]

### Test case

	all cols and rows named, col types: logic, int, real, str, complex

## Function
	- class = "function"
	- notAVector = true
	- primitive = false
	- body = ""

## Environment
	
	- class = "environment"
	- value = [ json, json]

## Primitives

	- nil: class = "NULL", type = "n"; notAVector = true
	- logical: class = "logical", type = "b", value = [t,f,t]
	- int: class = "integer vector", type = "i", value = [1,2,3]
	- real: class = "numeric vector", type = "d", value = [1.2, NaN, Inf, -Inf]
	- string: class = "string", type="s", value = ["foo","bar"]
	- complex: class = "complex", type="c", value = ["", ""]
	- raw: class = "raw", type="r", NOVALUE
	- default: class = "unsupported type", notAVector = true, primitive = false
	
	if !notAVector, length = 2
	if RF_isArray { primitive = false; nrows=dim[0], ncols=dim[1], dims=[all dims], dimnames = [], class = "matrix|array"
	
## List

	class = "list"
	names = 
	length = x
	if includeChildren { value = [] }
	summary = ""
