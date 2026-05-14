package util

import (
	"crypto/rand"
	"math/big"
)

func GenerateOTP() (string, error) {
	const length = 6
	const digits = "0123456789"

	otp := make([]byte, length)

	for i := range otp {
		num, err := rand.Int(rand.Reader, big.NewInt(int64(len(digits))))

		if err != nil {
			return "", err
		}

		otp[i] = digits[num.Int64()]
	}

	return string(otp), nil
}
