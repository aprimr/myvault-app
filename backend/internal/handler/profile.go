package handler

import (
	"net/http"

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
