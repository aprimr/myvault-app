package handler

import (
	"net/http"
	"strings"

	"github.com/aprimr/myvault/internal/constants"
	"github.com/aprimr/myvault/internal/database"
	"github.com/aprimr/myvault/internal/helper/response"
	"github.com/aprimr/myvault/internal/logger"
	"github.com/aprimr/myvault/internal/service"
)

type DocumentsHandler struct {
}

func NewDocumentsHandler() *DocumentsHandler {
	return &DocumentsHandler{}
}

func (h *DocumentsHandler) HandleAddDocument(w http.ResponseWriter, r *http.Request) {
	// Get uid from request context
	uid, ok := r.Context().Value(constants.ContextUID).(string)
	if !ok || uid == "" {
		response.Error(w, http.StatusUnauthorized, "Unauthorized")
		return
	}

	// Parse multipart form
	err := r.ParseMultipartForm(10 << 20)
	if err != nil {
		response.Error(w, http.StatusBadRequest, "File too large or invalid form")
		return
	}

	// Get file
	file, _, err := r.FormFile("file")
	if err != nil {
		response.Error(w, http.StatusBadRequest, "File is required")
		return
	}
	defer file.Close()

	// Get title and description
	title := r.FormValue("title")
	description := r.FormValue("description")

	// Valdate title
	if strings.TrimSpace(title) == "" {
		response.Error(w, http.StatusBadRequest, "Document title is required")
		return
	}

	// Call service
	document, err := service.AddDocument(r.Context(), database.DB, uid, title, description, &file)
	if err != nil {
		if err.Error() == "error encrypting data" {
			response.Error(w, http.StatusInternalServerError, "Failed to encrypt data")
			return
		}
		response.Error(w, http.StatusInternalServerError, "Something went wrong")
		logger.Error("error", err)
		return
	}

	response.JSON(w, http.StatusOK, "Document added successfully", document)
}
