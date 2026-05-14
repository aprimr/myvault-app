package repository

import (
	"context"

	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"
)

func CreateUser(ctx context.Context, db *pgxpool.Pool, username, email, password, name string) (string, error) {
	query := "INSERT INTO users (username, email, password, name) VALUES($1, $2, $3, $4) RETURNING uid"

	var uid string

	// Execute query
	err := db.QueryRow(ctx, query, username, email, password, name).Scan(&uid)
	if err != nil {
		return "", err
	}

	return uid, nil
}

func IsEmailTaken(ctx context.Context, db *pgxpool.Pool, email string) (bool, error) {
	query := "SELECT 1 FROM users WHERE email=$1"

	var exists int
	err := db.QueryRow(ctx, query, email).Scan(&exists)

	if err == nil {
		// Email found, return true
		return true, nil
	}

	if err == pgx.ErrNoRows {
		// No rows, return false
		return false, nil
	}

	return false, err
}

func IsUsernameTaken(ctx context.Context, db *pgxpool.Pool, username string) (bool, error) {
	query := "SELECT 1 FROM users WHERE username=$1"

	var exists int
	err := db.QueryRow(ctx, query, username).Scan(&exists)

	if err == nil {
		// Username found, return true
		return true, nil
	}

	if err == pgx.ErrNoRows {
		// No rows, return false
		return false, nil
	}

	return false, err
}

func StoreOTP(ctx context.Context, db *pgxpool.Pool, uid, otpHash, purpose string) error {
	query := "INSERT INTO otp_codes (uid, otp_hash, purpose ) VALUES($1, $2, $3)"

	_, err := db.Exec(ctx, query, uid, otpHash, purpose)
	return err
}
