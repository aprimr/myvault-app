package dto

type LoginRequest struct {
	Email    string `json:"email" binding:"required, email"`
	Password string `json:"password" binding:"required"`
}

type SignupRequest struct {
	Email    string `json:"email" binding:"required, email"`
	Password string `json:"password" binding:"required"`
	Name     string `json:"name" binding:"required"`
}

type ValidateOTPRequest struct {
	Uid     string `json:"uid" binding:"required"`
	OTP     string `json:"otp" binding:"required"`
	Purpose string `json:"purpose" binding:"required"`
}
