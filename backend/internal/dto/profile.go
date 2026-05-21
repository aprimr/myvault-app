package dto

type UpdateProfileRequest struct {
	Username *string `json:"username"`
	Name     *string `json:"name"`
}
