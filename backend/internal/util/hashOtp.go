package util

import (
	"crypto/sha256"
	"encoding/hex"
)

func HashOTP(otp string) string {
	hash := sha256.Sum256([]byte(otp))

	return hex.EncodeToString(hash[:])
}

func CompareHashOTP(inputOTP, hashedOTP string) bool {
	inputHash := HashOTP(inputOTP)

	return inputHash == hashedOTP
}
