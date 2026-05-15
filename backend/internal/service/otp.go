package service

import (
	"context"
	"fmt"

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
	// Increment otp verification attempts
	err := repository.IncrementOTPAttempts(ctx, db, uid, purpose)
	if err != nil {
		return err
	}

	// Get OTP from db
	otpData, err := repository.GetOTPByUid(ctx, db, uid, purpose)
	if err != nil {
		return err
	}

	// Check if attempt is greater than 10
	// If so, return error
	if otpData.Attempts > 10 {
		return fmt.Errorf("otp verification attempt limit exceed")
	}

	// Compare OTP and OTP hash
	match := util.CompareHashOTP(otp, otpData.OTPHash)
	if match == false {
		return fmt.Errorf("invalid otp")
	}

	// if matched , mark user as verified And mark otp as consumed
	err = repository.VerifyUser(ctx, db, uid)
	if err != nil {
		return err
	}

	err = repository.MarkOTPConsumed(ctx, db, otpData.Id)
	if err != nil {
		return err
	}

	return nil
}
