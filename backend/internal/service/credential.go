package service

import (
	"context"
	"fmt"
	"os"

	"github.com/aprimr/myvault/internal/models"
	"github.com/aprimr/myvault/internal/repository"
	"github.com/aprimr/myvault/internal/util"
	"github.com/jackc/pgx/v5/pgxpool"
)

func GetCredential(ctx context.Context, db *pgxpool.Pool, uid string) ([]models.Credential, error) {
	// GetCredentials from uid
	credentials, err := repository.GetCredentialsByUid(ctx, db, uid)
	if err != nil {
		return nil, err
	}

	// Decrypt the data
	var decrypted []models.Credential
	key := os.Getenv("AES_ENCRYPTION_KEY")
	for _, c := range credentials {
		title, err := util.Decrypt(c.Title, []byte(key))
		if err != nil {
			return nil, err
		}

		emailOrUsername, err := util.Decrypt(c.EmailOrUsername, []byte(key))
		if err != nil {
			return nil, err
		}

		password, err := util.Decrypt(c.Password, []byte(key))
		if err != nil {
			return nil, err
		}

		loginURL, err := util.Decrypt(*c.LoginURL, []byte(key))
		if err != nil {
			return nil, err
		}

		description, err := util.Decrypt(*c.Description, []byte(key))
		if err != nil {
			return nil, err
		}

		decrypted = append(decrypted, models.Credential{
			Id:              c.Id,
			Uid:             c.Uid,
			Title:           title,
			EmailOrUsername: emailOrUsername,
			Password:        password,
			LoginURL:        &loginURL,
			Description:     &description,
			CreatedAt:       c.CreatedAt,
			UpdatedAt:       c.UpdatedAt,
		})
	}

	return decrypted, nil
}

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

func DeleteCredential(ctx context.Context, db *pgxpool.Pool, uid, id string) error {
	err := repository.DeleteCredential(ctx, db, uid, id)

	return err
}
