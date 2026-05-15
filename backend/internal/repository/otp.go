package repository

import (
	"context"
	"fmt"

	"github.com/aprimr/myvault/internal/models"
	"github.com/jackc/pgx/v5/pgxpool"
)

func StoreOTP(ctx context.Context, db *pgxpool.Pool, uid, otpHash, purpose string) error {
	query := "INSERT INTO otp_codes (uid, otp_hash, purpose ) VALUES($1, $2, $3)"

	_, err := db.Exec(ctx, query, uid, otpHash, purpose)
	return err
}

func IncrementOTPAttempts(ctx context.Context, db *pgxpool.Pool, uid, purpose string) error {
	query := "UPDATE otp_codes SET attempts=attempts+1 WHERE uid=$1 AND purpose=$2"

	cmdTag, err := db.Exec(ctx, query, uid, purpose)

	if err != nil {
		return err
	}

	if cmdTag.RowsAffected() == 0 {
		return fmt.Errorf("otp not found")
	}

	return nil
}

func GetOTPByUid(ctx context.Context, db *pgxpool.Pool, uid, purpose string) (*models.OTP, error) {
	var otpData models.OTP

	query := "SELECT id, uid, otp_hash, purpose, expires_at, consumed, attempts, created_at FROM otp_codes WHERE uid=$1 AND purpose=$2 ORDER BY created_at DESC LIMIT 1"

	err := db.QueryRow(ctx, query, uid, purpose).Scan(&otpData.Id, &otpData.Uid, &otpData.OTPHash, &otpData.Purpose, &otpData.ExpiresAt, &otpData.Consumed, &otpData.Attempts, &otpData.CreatedAt)

	if err != nil {
		return nil, err
	}

	return &otpData, err
}

func MarkOTPConsumed(ctx context.Context, db *pgxpool.Pool, id string) error {
	query := "UPDATE otp_codes SET consumed=TRUE WHERE id=$1 AND consumed=FALSE"

	cmdTag, err := db.Exec(ctx, query, id)

	if err != nil {
		return err
	}

	if cmdTag.RowsAffected() == 0 {
		return fmt.Errorf("otp not found")
	}

	return nil
}
