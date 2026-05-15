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
	purpose := constants.OTPPurposeVerifyEmail
	otp, err := service.GenerateAndStoreOTP(r.Context(), database.DB, uid, purpose)
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

	data := map[string]string{
		"uid":   uid,
		"email": req.Email,
	}

	response.JSON(w, http.StatusCreated, "User registered successfully", data)
}

func (h *AuthHandler) HandleVerifyOTP(w http.ResponseWriter, r *http.Request) {
	var req dto.ValidateOTPRequest

	// Decode JSON
	err := json.NewDecoder(r.Body).Decode(&req)
	if err != nil {
		response.Error(w, http.StatusBadRequest, "Invalid request body")
		return
	}

	// Validate data
	if err := validation.EmptyString(req.OTP); err != nil {
		response.Error(w, http.StatusBadRequest, "OTP is required")
		return
	}
	if err := validation.EmptyString(req.Purpose); err != nil {
		response.Error(w, http.StatusBadRequest, "Purpose is required")
		return
	}
	if err := validation.EmptyString(req.Uid); err != nil {
		response.Error(w, http.StatusBadRequest, "Uid is required")
		return
	}

	// Call VerifyOTP service
	err = service.VerifyOTP(r.Context(), database.DB, req.OTP, req.Purpose, req.Uid)
	if err != nil {
		logger.Error("VerifyOTP Service Error", err)
		if err.Error() == "otp verification attempt limit exceed" {
			response.Error(w, http.StatusTooManyRequests, "Too many attempts, please try again after 10 minutes")
			return
		}
		if err.Error() == "invalid otp" {
			response.Error(w, http.StatusBadRequest, "Invalid OTP")
			return
		}
		if err.Error() == "otp expired" {
			response.Error(w, http.StatusBadRequest, "OTP expired")
			return
		}
		response.Error(w, http.StatusInternalServerError, "Something went wrong")
		return
	}

	response.JSON(w, http.StatusOK, "OTP verified successfully", nil)

}
