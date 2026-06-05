package handler

import (
	"net/http"
	"strings"

	"github.com/aprimr/myvault/internal/constants"
	"github.com/aprimr/myvault/internal/database"
	"github.com/aprimr/myvault/internal/helper/response"
	"github.com/aprimr/myvault/internal/logger"
	"github.com/aprimr/myvault/internal/service"
	"github.com/go-chi/chi/v5"
)

type DocumentsHandler struct {
}

func NewDocumentsHandler() *DocumentsHandler {
	return &DocumentsHandler{}
}

func (h *DocumentsHandler) HandleGetAllDocuments(w http.ResponseWriter, r *http.Request) {
	// Get uid from request context
	uid, ok := r.Context().Value(constants.ContextUID).(string)
	if !ok || uid == "" {
		response.Error(w, http.StatusUnauthorized, "Unauthorized")
		return
	}

	// Call service layer
	documents, err := service.GetAllDocuments(r.Context(), database.DB, uid)
	if err != nil {
		logger.Debug(err.Error())
		if err.Error() == "error decrypting data" {
			response.Error(w, http.StatusInternalServerError, "Failed to decrypt data")
			return
		}
		response.Error(w, http.StatusInternalServerError, "Something went wrong")
		return
	}

	response.JSON(w, http.StatusOK, "Documents fetched", documents)
}

func (h *DocumentsHandler) HandleGetDocumentByID(w http.ResponseWriter, r *http.Request) {
	// Get uid from request context
	uid, ok := r.Context().Value(constants.ContextUID).(string)
	if !ok || uid == "" {
		response.Error(w, http.StatusUnauthorized, "Unauthorized")
		return
	}

	// Get id from URL params
	id := chi.URLParam(r, "id")
	if strings.TrimSpace(id) == "" {
		response.Error(w, http.StatusBadRequest, "Document id is required")
		return
	}

	// Call service layer
	document, err := service.GetDocumentByID(r.Context(), database.DB, id, uid)
	if err != nil {
		if err.Error() == "failed to decrypt data" {
			response.Error(w, http.StatusInternalServerError, "Failed to decrypt data")
			return
		}
		response.Error(w, http.StatusInternalServerError, "Something went wrong")
		return
	}

	response.JSON(w, http.StatusOK, "Document fetched", document)
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

func (h *DocumentsHandler) HandleDeleteDocument(w http.ResponseWriter, r *http.Request) {
	// Get uid from request context
	uid, ok := r.Context().Value(constants.ContextUID).(string)
	if !ok || uid == "" {
		response.Error(w, http.StatusUnauthorized, "Unauthorized")
		return
	}

	// Get id from URL params
	id := chi.URLParam(r, "id")
	if strings.TrimSpace(id) == "" {
		response.Error(w, http.StatusBadRequest, "Document id is required")
		return
	}

	// Call service
	err := service.DeleteDocument(r.Context(), database.DB, id, uid)
	if err != nil {
		if err.Error() == "document not found" {
			response.Error(w, http.StatusNotFound, "Document not found")
			return
		}
		if err.Error() == "failed to delete document" {
			response.Error(w, http.StatusInternalServerError, "Failed to delete document")
			return
		}
		response.Error(w, http.StatusInternalServerError, "Something went wrong")
		return
	}

	response.JSON(w, http.StatusOK, "Document deleted successfully", nil)
}
