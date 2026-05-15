package repository

import (
	"context"

	"github.com/aprimr/myvault/internal/models"
	"github.com/jackc/pgx/v5/pgxpool"
)

func StoreOTP(ctx context.Context, db *pgxpool.Pool, uid, otpHash, purpose string) error {
	query := "INSERT INTO otp_codes (uid, otp_hash, purpose ) VALUES($1, $2, $3)"

	_, err := db.Exec(ctx, query, uid, otpHash, purpose)
	return err
}

func IncrementAndGetOTPAttempts(ctx context.Context, db *pgxpool.Pool, uid, purpose string) (int, error) {
	var newAttempts int

	query := "UPDATE otp_codes SET attempts=attempts+1 WHERE uid=$1 AND purpose=$2 RETURNING attempts"

	err := db.QueryRow(ctx, query, uid, purpose).Scan(&newAttempts)

	if err != nil {
		return 0, err
	}

	return newAttempts, nil
}

func GetOTPByUid(ctx context.Context, db *pgxpool.Pool, uid, purpose string) (*models.OTP, error) {
	var otpData models.OTP

	query := "SELECT id, uid, otp_hash, purpose, expires_at, consumed, attempts, created_at FROM otp_codes WHERE uid=$1 AND purpose=$2 AND consumed=FALSE ORDER BY created_at DESC LIMIT 1"

	err := db.QueryRow(ctx, query, uid, purpose).Scan(&otpData.Id, &otpData.Uid, &otpData.OTPHash, &otpData.Purpose, &otpData.ExpiresAt, &otpData.Consumed, &otpData.Attempts, &otpData.CreatedAt)

	if err != nil {
		return nil, err
	}

	return &otpData, err
}
