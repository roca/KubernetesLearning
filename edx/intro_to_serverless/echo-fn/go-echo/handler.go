package function

import (
	"log"
	"net/http"

	"github.com/openfaas/templates-sdk/go-http"
)

// Handle a function invocation
func Handle(req handler.Request) (handler.Response, error) {

	log.Printf("%s", req.Body)

	return handler.Response{
		Body:       req.Body,
		StatusCode: http.StatusOK,
	}, nil
}
