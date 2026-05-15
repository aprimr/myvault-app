package service

import (
	"context"
	"fmt"
	"time"

	"github.com/aprimr/myvault/internal/repository"
	"github.com/aprimr/myvault/internal/util"
	"github.com/jackc/pgx/v5/pgxpool"
)

func GenerateAndStoreOTP(ctx context.Context, db *pgxpool.Pool, uid, purpose string) (string, error) {
	// Generate OTP
	otp, err := util.GenerateOTP()
	if err != nil {
		return "", err
	}

	// Hash OPT
	hashedOTP := util.HashOTP(otp)

	// Call repository
	err = repository.StoreOTP(ctx, db, uid, hashedOTP, purpose)
	if err != nil {
		return "", err
	}

	return otp, nil
}

func VerifyOTP(ctx context.Context, db *pgxpool.Pool, otp, purpose, uid string) error {
	// Get OTP from db
	otpData, err := repository.GetOTPByUid(ctx, db, uid, purpose)
	if err != nil {
		return err
	}

	// Check if code is expired
	if time.Now().After(otpData.ExpiresAt) {
		return fmt.Errorf("otp expired")
	}

	// Check if attempt is greater than 10
	// If so, return error
	if otpData.Attempts >= 10 {
		return fmt.Errorf("otp verification attempt limit exceed")
	}

	// Increment otp verification attempts
	newAttempts, err := repository.IncrementAndGetOTPAttempts(ctx, db, uid, purpose)
	if err != nil {
		return err
	}

	// Re-check after increment
	if newAttempts > 10 {
		return fmt.Errorf("otp verification attempt limit exceed")
	}

	// Compare OTP and OTP hash
	match := util.CompareHashOTP(otp, otpData.OTPHash)
	if match == false {
		return fmt.Errorf("invalid otp")
	}

	// if matched , verify user and mark otp as consumed
	err = repository.VerifyUserAndConsumeOTP(ctx, db, uid, otpData.Id)
	if err != nil {
		return err
	}

	return nil
}
