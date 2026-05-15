package repository

import (
	"context"

	"github.com/jackc/pgx/v5/pgxpool"
)

func StoreOTP(ctx context.Context, db *pgxpool.Pool, uid, otpHash, purpose string) error {
	query := "INSERT INTO otp_codes (uid, otp_hash, purpose ) VALUES($1, $2, $3)"

	_, err := db.Exec(ctx, query, uid, otpHash, purpose)
	return err
}
