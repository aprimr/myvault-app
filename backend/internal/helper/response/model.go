package response

type successResponse struct {
	Success bool   `json:"success"`
	Message string `json:"message"`
	Data    any    `json:"data,omitempty"`
}

type errorResponse struct {
	Success bool   `json:"success"`
	Message string `json:"message"`
}
