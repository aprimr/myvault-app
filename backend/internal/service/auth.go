package service

import (
	"context"
	"fmt"

	"github.com/aprimr/myvault/internal/helper/jwt"
	"github.com/aprimr/myvault/internal/helper/username"
	"github.com/aprimr/myvault/internal/models"
	"github.com/aprimr/myvault/internal/repository"
	"github.com/aprimr/myvault/internal/util"
	"github.com/jackc/pgx/v5/pgxpool"
)

func Signup(ctx context.Context, db *pgxpool.Pool, email, password, name string) (string, error) {
	// Check if email already exists
	exists, err := repository.IsEmailTaken(ctx, db, email)
	if err != nil {
		return "", err
	}
	if exists == true {
		return "", fmt.Errorf("email already exists")
	}

	var genUsername string

	// Generate username
	// Check if username already exists
	// if already exists, generate new username
	for {
		genUsername = username.New()

		exists, err := repository.IsUsernameTaken(ctx, db, genUsername)
		if err != nil {
			return "", err
		}

		if !exists {
			break
		}
	}

	// Hash password
	hash, err := util.HashPassword(password)
	if err != nil {
		return "", err
	}

	// Call repository
	uid, err := repository.CreateUser(ctx, db, genUsername, email, hash, name)
	if err != nil {
		return "", fmt.Errorf("Failed to create user profile %v", err)
	}

	return uid, nil
}

func Login(ctx context.Context, db *pgxpool.Pool, email, password string) (string, *models.User, error) {
	// Get user by email
	user, err := repository.GetUserByEmail(ctx, db, email)
	if err != nil {
		return "", user, err
	}

	//  Check if user is active, verified and deleted
	if !user.IsActive {
		return "", nil, fmt.Errorf("account is inactive")
	}
	if !user.IsVerfied {
		return "", nil, fmt.Errorf("account is not verified")
	}
	if user.IsDeleted {
		return "", nil, fmt.Errorf("account deleted")
	}

	// Compare password
	match := util.CompareHash(password, user.Password)
	if !match {
		return "", nil, fmt.Errorf("invalid credentials")
	}

	// Generate JWT token
	token, err := jwt.Generate(user.Uid, user.Email)
	if err != nil {
		return "", nil, err
	}

	return token, user, nil
}
