package service

import (
	"context"
	"fmt"

	"github.com/aprimr/myvault/internal/constants"
	"github.com/aprimr/myvault/internal/helper/username"
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

func GenerateAndStoreOTP(ctx context.Context, db *pgxpool.Pool, uid string) (string, error) {
	// Generate OTP
	purpose := constants.OTPPurposeRegister
	otp, err := util.GenerateOTP()
	if err != nil {
		return "", err
	}

	// Hash OPT
	hashedOTP := util.HashOTP(otp)

	// Call repository
	err = repository.StoreOTP(ctx, db, uid, hashedOTP, purpose)
	if err != nil {
		return "", err
	}

	return otp, nil
}
