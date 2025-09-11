package apis

import (
	"net/http"

	"github.com/pocketbase/pocketbase/core"
)

type ErrorResponse struct {
	Error   string `json:"error"`
	Message string `json:"message"`
	Code    int    `json:"code"`
}

type SuccessResponse struct {
	Success bool   `json:"success"`
	Message string `json:"message"`
	Data    any    `json:"data,omitempty"`
}

// Helper function to send error response
func sendErrorResponse(e *core.RequestEvent, errorResp *ErrorResponse) error {
	statusCode := http.StatusBadRequest
	if errorResp.Code != 0 {
		statusCode = errorResp.Code
	}
	return e.JSON(statusCode, errorResp)
}
