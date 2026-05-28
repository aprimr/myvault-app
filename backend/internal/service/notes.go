package service

import (
	"context"
	"os"

	"github.com/aprimr/myvault/internal/models"
	"github.com/aprimr/myvault/internal/repository"
	"github.com/aprimr/myvault/internal/util"
	"github.com/jackc/pgx/v5/pgxpool"
)

func AddNewNotes(ctx context.Context, db *pgxpool.Pool, uid, title, content string) (*models.Notes, error) {
	key := []byte(os.Getenv("AES_ENCRYPTION_KEY"))

	// Encrypt data
	encryptedTitle, err := util.Encrypt(title, key)
	if err != nil {
		return nil, err
	}

	encryptedContent, err := util.Encrypt(content, key)
	if err != nil {
		return nil, err
	}

	// Call repository
	notes, err := repository.AddNewNotes(ctx, db, uid, encryptedTitle, encryptedContent)
	if err != nil {
		return nil, err
	}

	return notes, nil
}
