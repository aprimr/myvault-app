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

type ProfileHandler struct {
}

func NewProfileHandler() *ProfileHandler {
	return &ProfileHandler{}
}

func (h *ProfileHandler) GetProfileHandler(w http.ResponseWriter, r *http.Request) {
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

func (h *ProfileHandler) UpdateProfilePicHandler(w http.ResponseWriter, r *http.Request) {
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
