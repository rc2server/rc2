# Client API

Messages are primarily sent as JSON, however a few must be sent via messagepack. Theoretically it should all work as messagepack, but this writing the Mac client only supports messagepack for saveResponse and showOutput. The java appserver fully supports messagepack (but has not been tested).

TODO: document required vs optional properties

## Nested Objects

Aside from native JSON types, dates are sent as milliseconds since the 1970 epoch. The following object types are embedded.

* Error
	* errorCode: int
	* message: string
* File
	* id: integer
	* wspaceId: int
	* name: string
	* version: int
	* dateCreated: date
	* lastModified: date
	* fileSize: int
* SessionImage
	* id: int
	* sessionId: int
	* batchId: int
	* wspaceId: int
	* name: string
	* title: string
	* dateCreated: date
	* imageData: string (base64 encoded bytes)
* Variable

## Client Requests

All messages to the server must contain a "msg" property. It must match one of the following:

* execute 
	* code: string
	* fileId: int
	* type: string { run|source|"" }
	* noEcho: bool
* fileop 
	* operation: string { rm|rename|duplicate }
	* transId: string
	* fileVersion: int
	* fileId: int
	* newName: string
* getVariable 
	* variable: string
* help
	* topic: string
* keepAlive
* save (messagepack only)
	* apiVersion: int { 1 }
	* transId: int
	* fileId: int
	* fileVersion: int
	* content: string
* watchVariables (watch)

## Server Responses

All contain a "msg" property. The can might also contain a "queryId" property to link multiple responses to the same query.

* echo
	* queryId: int
	* fileId: int
	* query: string
* error
	* error: error
* execComplete 
	* imageBatchId: int
	* images: [SessionImage]
	* queryId: int
	* expectShowOutput: bool
* results
	* queryId: int
	* string: string
* filechanged 
	* fileId: int
	* file: File
	* type: string { Update|Insert|Delete }
* fileOpResponse
	* transId: int
	* operation: string { rm|rename|duplicate }
	* success: bool
	* file: File
	* error: Error
* help
	* topic: string
	* items: [string: string]
* saveResponse
	* transId: int
	* success: bool
	* file: File
	* error: Error
* showOutput
	* file: File
	* fileData: bytes (only sent via messagepack, only sent if file is < XX bytes where XX is defined in the server config yml file defaulting to 25 KB)
* variables 
	* variables: Variable | [string: Variable] | ["assigned": [string: Variable], "removed": [string]]
	* singleValue: bool
	* delta: bool

## Error Codes

The app server can send error messages with the following codes to allow for recovery.

* 0: unknown

* 1001: no such file

* 1002: file version mismatch

* 1003: database update failed

* 1005: failed to connect to compute engine

* 1006: invalid request

* 1007: passing along error from compute engine
