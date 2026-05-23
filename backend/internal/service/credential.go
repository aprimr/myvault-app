package service

import (
	"context"
	"fmt"
	"os"

	"github.com/aprimr/myvault/internal/repository"
	"github.com/aprimr/myvault/internal/util"
	"github.com/jackc/pgx/v5/pgxpool"
)

func AddCredential(ctx context.Context, db *pgxpool.Pool, uid, title, emailOrUsername, password, loginURL, description string) error {
	key := []byte(os.Getenv("AES_ENCRYPTION_KEY"))

	// Encrypt data
	encryptedTitle, err := util.Encrypt(title, key)
	if err != nil {
		return fmt.Errorf("encrypt title failed: %w", err)
	}

	encryptedEmailOrUsername, err := util.Encrypt(emailOrUsername, key)
	if err != nil {
		return fmt.Errorf("encrypt email/username failed: %w", err)
	}

	encryptedPassword, err := util.Encrypt(password, key)
	if err != nil {
		return fmt.Errorf("encrypt password failed: %w", err)
	}

	encryptedLoginURL, err := util.Encrypt(loginURL, key)
	if err != nil {
		return fmt.Errorf("encrypt loginURL failed: %w", err)
	}

	encryptedDescription, err := util.Encrypt(description, key)
	if err != nil {
		return fmt.Errorf("encrypt description failed: %w", err)
	}

	// Store encrypted credential
	err = repository.StoreCredential(ctx, db, uid, encryptedTitle, encryptedEmailOrUsername, encryptedPassword, encryptedLoginURL, encryptedDescription)
	if err != nil {
		return err
	}

	return nil
}
