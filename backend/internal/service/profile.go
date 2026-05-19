package service

import (
	"context"
	"fmt"

	"github.com/aprimr/myvault/internal/models"
	"github.com/aprimr/myvault/internal/repository"
	"github.com/jackc/pgx/v5/pgxpool"
)

func GetProfile(ctx context.Context, db *pgxpool.Pool, uid string) (*models.User, error) {
	// Call Repository
	user, err := repository.GetProfileByUID(ctx, db, uid)
	if err != nil {
		return nil, err
	}

	// Check if user is verified
	if !user.IsVerified {
		return nil, fmt.Errorf("email is not verified")
	}

	// Check if user is active
	if !user.IsActive {
		return nil, fmt.Errorf("account is inactive")
	}

	// Check if user is not deleted
	if user.IsDeleted {
		return nil, fmt.Errorf("account is deleted")
	}

	return user, nil
}
