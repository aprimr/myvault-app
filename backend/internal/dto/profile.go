package dto

type UpdateProfileRequest struct {
	Username *string `json:"username"`
	Name     *string `json:"name"`
}

type ChangeEmailRequest struct {
	Email string `json:"email"`
}

type ChangePasswordRequest struct {
	Password        string `json:"password"`
	NewPassword     string `json:"new_password"`
	ConfirmPassword string `json:"confirm_password"`
}
