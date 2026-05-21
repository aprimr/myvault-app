package repository

import (
	"context"
	"fmt"

	"github.com/aprimr/myvault/internal/models"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"
)

func GetProfileByUID(ctx context.Context, db *pgxpool.Pool, uid string) (*models.User, error) {
	query := "SELECT uid, username, email, name, profile_url, is_active, is_verified, is_deleted, created_at, updated_at FROM users WHERE uid=$1"

	var user models.User
	err := db.QueryRow(ctx, query, uid).Scan(
		&user.Uid,
		&user.Username,
		&user.Email,
		&user.Name,
		&user.ProfileUrl,
		&user.IsActive,
		&user.IsVerified,
		&user.IsDeleted,
		&user.CreatedAt,
		&user.UpdatedAt,
	)
	if err != nil {
		if err == pgx.ErrNoRows {
			return nil, fmt.Errorf("user not found")
		}
		return nil, err
	}

	return &user, nil
}

func ChangeProfileUrl(ctx context.Context, db *pgxpool.Pool, uid, profileUrl string) error {
	query := "UPDATE users SET profile_url=$1 WHERE uid=$2 AND is_verified=TRUE AND is_active=TRUE"

	cmdTag, err := db.Exec(ctx, query, profileUrl, uid)
	if err != nil {
		return err
	}
	if cmdTag.RowsAffected() == 0 {
		return fmt.Errorf("failed updating profileurl")
	}

	return nil
}

func DeleteProfileUrl(ctx context.Context, db *pgxpool.Pool, uid string) error {
	query := "UPDATE users SET profile_url='' WHERE uid=$1"

	cmdTag, err := db.Exec(ctx, query, uid)
	if err != nil {
		return err
	}
	if cmdTag.RowsAffected() == 0 {
		return fmt.Errorf("failed deleting profileurl")
	}

	return nil
}

func UpdateUsername(ctx context.Context, db *pgxpool.Pool, uid, username string) error {

	query := "UPDATE users SET username=$1 WHERE uid=$2"

	cmdTag, err := db.Exec(ctx, query, username, uid)
	if err != nil {
		return err
	}
	if cmdTag.RowsAffected() == 0 {
		return fmt.Errorf("failed to update username")
	}

	return nil
}

func UpdateName(ctx context.Context, db *pgxpool.Pool, uid, name string) error {

	query := "UPDATE users SET name=$1 WHERE uid=$2"

	cmdTag, err := db.Exec(ctx, query, name, uid)
	if err != nil {
		return err
	}
	if cmdTag.RowsAffected() == 0 {
		return fmt.Errorf("failed to update name")
	}

	return nil
}
