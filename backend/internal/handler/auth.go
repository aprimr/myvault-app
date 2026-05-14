package handler

import (
	"encoding/json"
	"net/http"
	"strings"

	"github.com/aprimr/myvault/internal/database"
	"github.com/aprimr/myvault/internal/dto"
	"github.com/aprimr/myvault/internal/helper/response"
	"github.com/aprimr/myvault/internal/helper/validation"
	"github.com/aprimr/myvault/internal/logger"
	"github.com/aprimr/myvault/internal/mail"
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
	if strings.TrimSpace(req.Name) == "" {
		response.Error(w, http.StatusBadRequest, "Name is required")
		return
	}
	if len(req.Name) < 5 {
		response.Error(w, http.StatusBadRequest, "Name must be atleast 5 characters long")
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

	// Call signup service
	uid, err := service.Signup(r.Context(), database.DB, req.Email, req.Password, req.Name)
	if err != nil {
		logger.Error("Signup Service Error", err)
		if err.Error() == "email already exists" {
			response.Error(w, http.StatusConflict, "An account already exists with this email")
			return
		}
		response.Error(w, http.StatusInternalServerError, "Something went wrong")
		return
	}

	// Call generate and store Otp service
	otp, err := service.GenerateAndStoreOTP(r.Context(), database.DB, uid)
	if err != nil {
		logger.Error("GenerateAndStoreOTP Service Error", err)
		response.Error(w, http.StatusInternalServerError, "Failed to generate OTP")
		return
	}

	// Call mail service
	err = mail.SendOTP(req.Name, req.Email, otp)
	if err != nil {
		logger.Error("Mail Service Error", err)
		response.Error(w, http.StatusInternalServerError, "Failed to send OTP")
		return
	}

	response.JSON(w, http.StatusCreated, "User registered successfully", nil)
}
