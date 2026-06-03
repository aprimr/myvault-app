package service

import (
	"context"
	"fmt"
	"mime/multipart"
	"os"

	"github.com/aprimr/myvault/internal/models"
	"github.com/aprimr/myvault/internal/repository"
	"github.com/aprimr/myvault/internal/util"
	"github.com/jackc/pgx/v5/pgxpool"
)

func AddDocument(ctx context.Context, db *pgxpool.Pool, uid, title, description string, file *multipart.File) (*models.Document, error) {
	// Get encryption key
	key := []byte(os.Getenv("AES_ENCRYPTION_KEY"))

	// Store file in cloudinary
	documenURL, err := util.UploadImage(ctx, *file, "docs")
	if err != nil {
		return nil, err
	}

	// encrypt title and description
	encryptedTitle, err := util.Encrypt(title, key)
	if err != nil {
		return nil, fmt.Errorf("error encrypting data")
	}
	encryptedDescription, err := util.Encrypt(description, key)
	if err != nil {
		return nil, fmt.Errorf("error encrypting data")
	}

	// Store document in database
	document, err := repository.AddDocument(ctx, db, uid, encryptedTitle, encryptedDescription, documenURL)
	if err != nil {
		return nil, err
	}

	return document, nil
}
