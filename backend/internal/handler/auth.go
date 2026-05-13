package handler

import (
	"encoding/json"
	"net/http"

	"github.com/aprimr/myvault/internal/database"
	"github.com/aprimr/myvault/internal/dto"
	"github.com/aprimr/myvault/internal/helper/response"
	"github.com/aprimr/myvault/internal/helper/validation"
	"github.com/aprimr/myvault/internal/logger"
	"github.com/aprimr/myvault/internal/service"
)

type AuthHandler struct{}

func NewAuthHandler() *AuthHandler {
	return &AuthHandler{}
}

func (h *AuthHandler) HandleSignup(w http.ResponseWriter, r *http.Request) {
	var req dto.SignupRequest

	// Decode JSON
	err := json.NewDecoder(r.Body).Decode(&req)
	if err != nil {
		response.Error(w, http.StatusBadRequest, "Invalid request body")
		return
	}

	// Validate data
	if req.Name == "" {
		response.Error(w, http.StatusBadRequest, "Name is required")
		return
	}
	if err := validation.Email(req.Email); err != nil {
		response.Error(w, http.StatusBadRequest, err.Error())
		return
	}
	if err := validation.Password(req.Password); err != nil {
		response.Error(w, http.StatusBadRequest, err.Error())
		return
	}

	// Call service
	err = service.Signup(r.Context(), database.DB, req.Email, req.Password, req.Name)
	if err != nil {
		logger.Error("Signup Service Error", err)
		response.Error(w, http.StatusInternalServerError, "Something went wrong")
		return
	}

	response.JSON(w, http.StatusCreated, "User registered successfully", nil)
}
