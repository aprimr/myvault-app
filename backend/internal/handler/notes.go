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
	"github.com/go-chi/chi/v5"
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

func (h *NotesHandler) HandleGetAllNotes(w http.ResponseWriter, r *http.Request) {
	// Get uid from request context
	uid, ok := r.Context().Value(constants.ContextUID).(string)
	if !ok || uid == "" {
		response.Error(w, http.StatusUnauthorized, "Unauthorized")
		return
	}

	// Call sercice layer
	models, err := service.GetAllNotes(r.Context(), database.DB, uid)
	if err != nil {
		if err.Error() == "failed to fetch notes" {
			response.Error(w, http.StatusInternalServerError, "Failed to fetch notes")
			return
		}
		response.Error(w, http.StatusInternalServerError, "Something went wrong")
		return
	}

	response.JSON(w, http.StatusOK, "Notes fetched", models)
}

func (h *NotesHandler) HandleGetNotesByID(w http.ResponseWriter, r *http.Request) {
	// Get uid from request context
	uid, ok := r.Context().Value(constants.ContextUID).(string)
	if !ok || uid == "" {
		response.Error(w, http.StatusUnauthorized, "Unauthorized")
		return
	}

	// Get note id from request params
	id := chi.URLParam(r, "id")
	if strings.TrimSpace(id) == "" {
		response.Error(w, http.StatusBadRequest, "Invalid notes id")
		return
	}

	// Call service layer
	notes, err := service.GetNotesByID(r.Context(), database.DB, uid, id)
	if err != nil {
		response.Error(w, http.StatusInternalServerError, "Something went wrong")
		return
	}

	response.JSON(w, http.StatusOK, "Notes fetched", notes)
}

func (h *NotesHandler) HandleDeleteNotesByID(w http.ResponseWriter, r *http.Request) {
	// Get uid from request context
	uid, ok := r.Context().Value(constants.ContextUID).(string)
	if !ok || uid == "" {
		response.Error(w, http.StatusUnauthorized, "Unauthorized")
		return
	}

	// Get note id from request params
	id := chi.URLParam(r, "id")
	if strings.TrimSpace(id) == "" {
		response.Error(w, http.StatusBadRequest, "Invalid notes id")
		return
	}

	// Call service layer
	err := service.DeleteNotesByID(r.Context(), database.DB, id, uid)
	if err != nil {
		if err.Error() == "failed to delete notes" {
			response.Error(w, http.StatusInternalServerError, "Failed to delete notes")
			return
		}
		response.Error(w, http.StatusInternalServerError, "Something went wrong")
		return
	}

	response.JSON(w, http.StatusOK, "Notes deleted", nil)
}

func (h *NotesHandler) HandleUpdateNotes(w http.ResponseWriter, r *http.Request) {
	// Get uid from request context
	uid, ok := r.Context().Value(constants.ContextUID).(string)
	if !ok || uid == "" {
		response.Error(w, http.StatusUnauthorized, "Unauthorized")
		return
	}

	// Get note id from request params
	id := chi.URLParam(r, "id")
	if strings.TrimSpace(id) == "" {
		response.Error(w, http.StatusBadRequest, "Invalid notes id")
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
	notes, err := service.UpdateNotes(r.Context(), database.DB, req.Title, req.Content, id, uid)
	if err != nil {
		response.Error(w, http.StatusInternalServerError, "Something went wrong")
		return
	}

	response.JSON(w, http.StatusOK, "Notes updated", notes)
}
