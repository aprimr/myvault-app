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
)

type ProfileHandler struct {
}

func NewProfileHandler() *ProfileHandler {
	return &ProfileHandler{}
}

func (h *ProfileHandler) HandleGetProfile(w http.ResponseWriter, r *http.Request) {
	// get uid from request context
	uid, ok := r.Context().Value(constants.ContextUID).(string)
	if !ok || uid == "" {
		response.Error(w, http.StatusUnauthorized, "Unauthorized")
		return
	}

	// Call GetProfile service
	user, err := service.GetProfile(r.Context(), database.DB, uid)
	if err != nil {
		logger.Error("Service Error", err)
		if err.Error() == "email is not verified" {
			response.Error(w, http.StatusUnauthorized, "Email is not verified")
		}
		if err.Error() == "account is inactive" {
			response.Error(w, http.StatusUnauthorized, "Account is inactive")
		}
		if err.Error() == "account is deleted" {
			response.Error(w, http.StatusUnauthorized, "Account is deleted")
		}
		if err.Error() == "user not found" {
			response.Error(w, http.StatusInternalServerError, "Error fetching user profile")
		}
		response.Error(w, http.StatusInternalServerError, "Something went wrong")
	}

	response.JSON(w, http.StatusOK, "Profile fetched successfully", user)
}

func (h *ProfileHandler) HandleUpdateProfilePic(w http.ResponseWriter, r *http.Request) {
	// Get uid from request context
	uid, ok := r.Context().Value(constants.ContextUID).(string)
	if !ok || uid == "" {
		response.Error(w, http.StatusUnauthorized, "Unauthorized")
		return
	}

	// Parse multipart form
	err := r.ParseMultipartForm(10 << 20)
	if err != nil {
		response.Error(w, http.StatusBadRequest, "invalid multipart form")
		return
	}

	// Get current profileUrl
	currProfileUrl := r.FormValue("currprofileurl")

	// Get file
	file, header, err := r.FormFile("profilepic")
	if err != nil {
		response.Error(w, http.StatusBadRequest, "Profile pic is required")
		return
	}
	defer file.Close()

	// Validate file
	contentType := header.Header.Get("Content-Type")
	if !strings.HasPrefix(contentType, "image/") {
		response.Error(w, http.StatusBadRequest, "Only images allowed")
		return
	}

	// Check image file size
	if header.Size > 5<<20 {
		response.Error(w, http.StatusBadRequest, "File too large (max 5MB)")
		return
	}

	// Call UpdateProfilePic Service
	profileUrl, err := service.UpdateProfilePicHandler(r.Context(), database.DB, currProfileUrl, file, uid)
	if err != nil {
		logger.Error("UpdateProfilePic Service", err)
		response.Error(w, http.StatusInternalServerError, "Failed to update profile pic")
		return
	}

	response.JSON(w, http.StatusOK, "Profile pic updated", profileUrl)
}

func (h *ProfileHandler) HandleDeleteProfilePic(w http.ResponseWriter, r *http.Request) {
	// Get uid from request context
	uid, ok := r.Context().Value(constants.ContextUID).(string)
	if !ok || uid == "" {
		response.Error(w, http.StatusUnauthorized, "Unauthorized")
		return
	}

	// Call DeleteProfilePic Service
	err := service.DeleteProfilePic(r.Context(), database.DB, uid)
	if err != nil {
		logger.Error("DeleteProfilePic Service", err)
		if err.Error() == "profilepic not set" {
			response.Error(w, http.StatusNotFound, "Profile pic not set")
			return
		}
		response.Error(w, http.StatusInternalServerError, "Something went wrong")
		return
	}

	response.JSON(w, http.StatusOK, "Profile pic deleted", nil)
}

func (h *ProfileHandler) HandleUpdateProfile(w http.ResponseWriter, r *http.Request) {
	var req dto.UpdateProfileRequest

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

	if req.Username == nil && req.Name == nil {
		response.Error(w, http.StatusBadRequest, "Username or name is required")
		return
	}

	// Validate username format if username is not null
	if req.Username != nil {
		if err := validation.Username(*req.Username); err != nil {
			response.Error(w, http.StatusBadRequest, err.Error())
			return
		}
	}

	// Call UpdateProfile service
	err = service.UpdateProfile(r.Context(), database.DB, uid, req.Username, req.Name)
	if err != nil {
		logger.Error("UpdateProfile service", err)

		if err.Error() == "username is already taken" {
			response.Error(w, http.StatusConflict, "Username is unavailable. Please try another")
			return
		}

		response.Error(w, http.StatusInternalServerError, "Something went wrong")
		return
	}

	data := map[string]string{}
	if req.Username != nil {
		data["username"] = *req.Username
	}
	if req.Name != nil {
		data["name"] = *req.Name
	}

	response.JSON(w, http.StatusOK, "Profile updated", data)
}
