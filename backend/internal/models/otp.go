package models

import "time"

type OTP struct {
	Id        string    `json:"id"`
	Uid       string    `json:"uid"`
	OTPHash   string    `json:"otp_hash"`
	Purpose   string    `json:"purpose"`
	ExpiresAt time.Time `json:"expires_at"`
	Consumed  bool      `json:"consumed"`
	Attempts  int       `json:"attempts"`
	CreatedAt time.Time `json:"created_at"`
}
