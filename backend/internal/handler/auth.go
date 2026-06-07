package handler

import (
	"encoding/json"
	"net/http"
	"strings"
	"time"

	"github.com/aprimr/myvault/internal/constants"
	"github.com/aprimr/myvault/internal/database"
	"github.com/aprimr/myvault/internal/dto"
	"github.com/aprimr/myvault/internal/helper/response"
	"github.com/aprimr/myvault/internal/helper/validation"
	"github.com/aprimr/myvault/internal/logger"
	"github.com/aprimr/myvault/internal/mail"
	"github.com/aprimr/myvault/internal/service"
)

type AuthHandler struct {
	mailService *mail.Service
}

func NewAuthHandler(mailService *mail.Service) *AuthHandler {
	return &AuthHandler{
		mailService: mailService,
	}
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
	err = h.mailService.SendOTP(req.Name, req.Email, otp)
	if err != nil {
		logger.Error("Mail Service Error", err)
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
	otpId, err := service.VerifyOTP(r.Context(), database.DB, req.OTP, req.Purpose, req.Uid)
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

	data := map[string]string{
		"uid":    req.Uid,
		"otp_id": otpId,
	}
	response.JSON(w, http.StatusOK, "OTP verified successfully", data)

}

func (h *AuthHandler) HandleLogin(w http.ResponseWriter, r *http.Request) {
	var req dto.LoginRequest

	// Decode JSON
	err := json.NewDecoder(r.Body).Decode(&req)
	if err != nil {
		response.Error(w, http.StatusBadRequest, "Invalid request body")
		return
	}

	// Validate data
	if err := validation.Email(req.Email); err != nil {
		response.Error(w, http.StatusBadRequest, err.Error())
		return
	}
	if err := validation.Password(req.Password); err != nil {
		response.Error(w, http.StatusBadRequest, err.Error())
		return
	}

	// Call login service
	token, user, err := service.Login(r.Context(), database.DB, req.Email, req.Password)
	if err != nil {
		logger.Error("Login Service Error", err)
		if err.Error() == "account is inactive" {
			response.Error(w, http.StatusForbidden, "Account is inactive. Please contact support.")
			return
		}
		if err.Error() == "account is not verified" {
			response.Error(w, http.StatusForbidden, "Please verify your account.")
			return
		}
		if err.Error() == "account deleted" {
			response.Error(w, http.StatusNotFound, "Account deleted. Please contact support.")
			return
		}
		if err.Error() == "invalid credentials" {
			response.Error(w, http.StatusNotFound, "Invalid credentials")
			return
		}

		response.Error(w, http.StatusInternalServerError, "Something went wrong")
		return
	}

	// Call Mail Service
	curTime := time.Now().Format("2006-01-02 15:04")
	err = h.mailService.SendLoginAlert(user.Name, req.Email, curTime)
	if err != nil {
		logger.Error("Mail Service Error", err)
	}

	data := map[string]string{
		"token": token,
	}

	response.JSON(w, http.StatusOK, "Login successful", data)
}

func (h *AuthHandler) HandleForgotPassword(w http.ResponseWriter, r *http.Request) {
	var req dto.ForgotPasswordRequest
	// Decode JSON
	err := json.NewDecoder(r.Body).Decode(&req)
	if err != nil {
		logger.Debug(err.Error())
		response.Error(w, http.StatusBadRequest, "Ivalid request body")
		return
	}

	// Validate data
	if err := validation.Email(req.Email); err != nil {
		response.Error(w, http.StatusBadRequest, err.Error())
		return
	}

	// Call ForgotPassword service
	otp, user, err := service.ForgotPassword(r.Context(), database.DB, req.Email)
	if err != nil {
		logger.Error("ForgotPassword Service Error", err)
		if err.Error() == "invalid credentials" {
			response.Error(w, http.StatusForbidden, "Incorrect email")
		}
		response.Error(w, http.StatusInternalServerError, "Something went wrong")
	}

	// Call Mail service
	err = h.mailService.SendForgotPasswordOTP(user.Name, req.Email, otp)
	if err != nil {
		logger.Error("Mail Service Error", err)
	}

	data := map[string]string{
		"uid":   user.Uid,
		"email": req.Email,
	}

	response.JSON(w, http.StatusOK, "Verification code sent", data)
}

func (h *AuthHandler) HandleSetNewPassword(w http.ResponseWriter, r *http.Request) {
	var req dto.SetNewPasswordRequest

	// Decode JSON
	err := json.NewDecoder(r.Body).Decode(&req)
	if err != nil {
		response.Error(w, http.StatusBadRequest, "Invalid request body")
		return
	}

	// Call service
	err = service.SetNewPassword(r.Context(), database.DB, req.Uid, req.OtpId, req.Password)
	if err != nil {
		logger.Error("SetNewPassword Service", err)
		if err.Error() == "otp not verified" {
			response.Error(w, http.StatusBadRequest, "OTP is not verified")
			return
		}
		if err.Error() == "password reset request timeout" {
			response.Error(w, http.StatusRequestTimeout, "Password reset request timeout")
			return
		}
		if err.Error() == "user inactive or deleted" {
			response.Error(w, http.StatusBadRequest, "Account is inactive or deleted. Please contact support.")
			return
		}
		response.Error(w, http.StatusInternalServerError, "Something went wrong")
		return
	}

	response.JSON(w, http.StatusOK, "Password reset successful", nil)
}
