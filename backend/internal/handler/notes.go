package handler

import (
	"encoding/json"
	"net/http"
	"strings"

	"github.com/aprimr/myvault/internal/constants"
	"github.com/aprimr/myvault/internal/database"
	"github.com/aprimr/myvault/internal/dto"
	"github.com/aprimr/myvault/internal/helper/response"
	"github.com/aprimr/myvault/internal/service"
)

type NotesHandler struct{}

func NewNotesHandler() *NotesHandler {
	return &NotesHandler{}
}

func (h *NotesHandler) HandleAddNewNotes(w http.ResponseWriter, r *http.Request) {
	// Get uid from request context
	uid, ok := r.Context().Value(constants.ContextUID).(string)
	if !ok || uid == "" {
		response.Error(w, http.StatusUnauthorized, "Unauthorized")
		return
	}

	// Parse json
	var req dto.AddNoteRequest
	err := json.NewDecoder(r.Body).Decode(&req)
	if err != nil {
		response.Error(w, http.StatusBadRequest, "Invalid request body")
		return
	}

	// Validate data
	if strings.TrimSpace(req.Title) == "" {
		response.Error(w, http.StatusBadRequest, "Title is required")
		return
	}

	// Call service layer
	notes, err := service.AddNewNotes(r.Context(), database.DB, uid, req.Title, req.Content)
	if err != nil {
		response.Error(w, http.StatusInternalServerError, "Something went wrong")
		return
	}

	response.JSON(w, http.StatusOK, "Notes added successfully", notes)
}
