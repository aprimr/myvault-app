package handler

import (
	"encoding/json"
	"net/http"
	"strings"

	"github.com/aprimr/myvault/internal/constants"
	"github.com/aprimr/myvault/internal/database"
	"github.com/aprimr/myvault/internal/dto"
	"github.com/aprimr/myvault/internal/helper/response"
	"github.com/aprimr/myvault/internal/helper/validation"
	"github.com/aprimr/myvault/internal/logger"
	"github.com/aprimr/myvault/internal/service"
	"github.com/go-chi/chi/v5"
)

type CredentialHandler struct {
}

func NewCredentialHandler() *CredentialHandler {
	return &CredentialHandler{}
}

func (h *CredentialHandler) HandleGetCredential(w http.ResponseWriter, r *http.Request) {
	// Get uid from request context
	uid, ok := r.Context().Value(constants.ContextUID).(string)
	if !ok || uid == "" {
		response.Error(w, http.StatusUnauthorized, "Unauthorized")
		return
	}

	// Call GetCredential service
	credentials, err := service.GetCredential(r.Context(), database.DB, uid)
	if err != nil {
		logger.Error("GetCredential service", err)
		response.Error(w, http.StatusInternalServerError, "Something went wrong")
		return
	}

	response.JSON(w, http.StatusOK, "Credentials fetched", credentials)
}

func (h *CredentialHandler) HandleAddCredential(w http.ResponseWriter, r *http.Request) {
	var req dto.AddCredentialRequest

	// Get uid from request context
	uid, ok := r.Context().Value(constants.ContextUID).(string)
	if !ok || uid == "" {
		response.Error(w, http.StatusUnauthorized, "Unauthorized")
		return
	}

	// Parse request body
	err := json.NewDecoder(r.Body).Decode(&req)
	if err != nil {
		response.Error(w, http.StatusBadRequest, "Invalid request body")
		return
	}

	// validate data
	if err := validation.EmptyString(req.Title); err != nil {
		response.Error(w, http.StatusBadRequest, "Title is required")
		return
	}
	if err := validation.EmptyString(req.EmailOrUsername); err != nil {
		response.Error(w, http.StatusBadRequest, "Email or Username is required")
		return
	}
	if err := validation.EmptyString(req.Password); err != nil {
		response.Error(w, http.StatusBadRequest, "Password is required")
		return
	}

	// Call AddCredential service
	err = service.AddCredential(r.Context(), database.DB, uid, req.Title, req.EmailOrUsername, req.Password, req.LoginURL, req.Description)
	if err != nil {
		logger.Error("AddCredential service", err)
		response.Error(w, http.StatusInternalServerError, "Something went wrong")
	}

	response.JSON(w, http.StatusCreated, "Credential added", nil)
}

func (h *CredentialHandler) HandleDeleteCredential(w http.ResponseWriter, r *http.Request) {

	// Get uid from request context
	uid, ok := r.Context().Value(constants.ContextUID).(string)
	if !ok || uid == "" {
		response.Error(w, http.StatusUnauthorized, "Unauthorized")
		return
	}

	// Get credential id from url params
	id := chi.URLParam(r, "id")
	if strings.TrimSpace(id) == "" {
		response.Error(w, http.StatusBadRequest, "Credential id is required")
		return
	}

	// Call DeleteCredential Service
	err := service.DeleteCredential(r.Context(), database.DB, uid, id)
	if err != nil {
		if err.Error() == "failed to delete credential" {
			response.Error(w, http.StatusInternalServerError, "Failed to delete credential")
			return
		}
		response.Error(w, http.StatusInternalServerError, "Something went wrong")
		return
	}

	response.JSON(w, http.StatusOK, "Credential removed", nil)
}
