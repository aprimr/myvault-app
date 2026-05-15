package dto

type ValidateOTPRequest struct {
	Uid     string `json:"uid" binding:"required"`
	OTP     string `json:"otp" binding:"required"`
	Purpose string `json:"purpose" binding:"required"`
}
