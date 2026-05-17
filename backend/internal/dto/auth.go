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

type ForgotPasswordRequest struct {
	Email string `json:"email"`
}

type SetNewPasswordRequest struct {
	Uid      string `json:"uid"`
	OtpId    string `json:"otp_id"`
	Password string `json:"password"`
}
