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
