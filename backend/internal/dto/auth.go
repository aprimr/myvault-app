package dto

type LoginRequest struct {
	Email    string `json:"email" binding:"required, email"`
	Password string `json:"password" binding:"required"`
}

type SignupRequest struct {
	Email      string `json:"email" binding:"required, email"`
	Password   string `json:"password" binding:"required"`
	Name       string `json:"name" binding:"required"`
	ProfileUrl string `json:"profile_url" binding:"required"`
}
