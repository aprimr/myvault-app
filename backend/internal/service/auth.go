package service

import (
	"context"
	"fmt"

	"github.com/aprimr/myvault/internal/helper/username"
	"github.com/aprimr/myvault/internal/repository"
	"github.com/aprimr/myvault/internal/util"
	"github.com/jackc/pgx/v5/pgxpool"
)

func Signup(ctx context.Context, db *pgxpool.Pool, email, password, name string) error {

	var genUsername string

	// Generate username
	// Check if username already exists
	// if already exists, generate new username
	for {
		genUsername = username.New()

		exists, err := repository.IsUsernameTaken(ctx, db, genUsername)
		if err != nil {
			return err
		}

		if !exists {
			break
		}
	}

	// Hash password
	hash, err := util.HashPassword(password)
	if err != nil {
		return err
	}

	// Call repository
	err = repository.CreateUser(ctx, db, genUsername, email, hash, name)
	if err != nil {
		return fmt.Errorf("Failed to create user profile %v", err)
	}

	return nil
}
