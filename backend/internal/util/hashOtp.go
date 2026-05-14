package util

import (
	"crypto/hmac"
	"crypto/sha256"
	"encoding/hex"
)

var otpSecret = []byte("your-secret-key")

func HashOTP(otp string) string {
	h := hmac.New(sha256.New, otpSecret)
	h.Write([]byte(otp))
	return hex.EncodeToString(h.Sum(nil))
}

func CompareOTP(hashedOTP, inputOTP string) bool {
	inputHash := HashOTP(inputOTP)
	return hmac.Equal([]byte(hashedOTP), []byte(inputHash))
}
