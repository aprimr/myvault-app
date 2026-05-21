package dto

type UpdateProfileRequest struct {
	Username *string `json:"username"`
	Name     *string `json:"name"`
}

type ChangeEmailRequest struct {
	Email string `json:"email"`
}
