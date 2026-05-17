package repository

import (
	"context"
	"fmt"

	"github.com/aprimr/myvault/internal/models"
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

func GetUserByEmail(ctx context.Context, db *pgxpool.Pool, email string) (*models.User, error) {
	var user models.User

	query := "SELECT uid, username, email, password, name, profile_url, is_active, is_verified, is_deleted, created_at, updated_at FROM users WHERE email=$1"

	err := db.QueryRow(ctx, query, email).Scan(
		&user.Uid,
		&user.Username,
		&user.Email,
		&user.Password,
		&user.Name,
		&user.ProfileUrl,
		&user.IsActive,
		&user.IsVerfied,
		&user.IsDeleted,
		&user.CreatedAt,
		&user.UpdatedAt,
	)

	if err != nil {
		if err == pgx.ErrNoRows {
			return nil, fmt.Errorf("invalid credentials")
		}
		return nil, err
	}

	return &user, nil
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

func VerifyUserAndConsumeOTP(ctx context.Context, db *pgxpool.Pool, uid, otpID string) error {
	tx, err := db.Begin(ctx)
	if err != nil {
		return err
	}
	defer tx.Rollback(ctx)

	_, err = tx.Exec(ctx,
		"UPDATE users SET is_verified=TRUE, updated_at=now() WHERE uid=$1", uid)
	if err != nil {
		return err
	}

	cmdTag, err := tx.Exec(ctx,
		"UPDATE otp_codes SET consumed=TRUE WHERE id=$1 AND consumed=FALSE", otpID)
	if err != nil {
		return err
	}
	if cmdTag.RowsAffected() == 0 {
		return fmt.Errorf("otp already consumed")
	}

	return tx.Commit(ctx)
}

func UpdatePassword(ctx context.Context, db *pgxpool.Pool, uid, password string) error {
	query := "UPDATE users SET password=$1, is_verified=TRUE, updated_at=now() WHERE uid=$2 AND is_active=TRUE AND is_deleted=FALSE "

	cmdTag, err := db.Exec(ctx, query, password, uid)
	if err != nil {
		return err
	}

	if cmdTag.RowsAffected() == 0 {
		return fmt.Errorf("user inactive or deleted")
	}

	return nil
}
