package service

import (
	"context"
	"fmt"
	"mime/multipart"
	"os"

	"github.com/aprimr/myvault/internal/logger"
	"github.com/aprimr/myvault/internal/models"
	"github.com/aprimr/myvault/internal/repository"
	"github.com/aprimr/myvault/internal/util"
	"github.com/jackc/pgx/v5/pgxpool"
)

func GetAllDocuments(ctx context.Context, db *pgxpool.Pool, uid string) (*[]models.Document, error) {
	// Get encryption key
	key := []byte(os.Getenv("AES_ENCRYPTION_KEY"))

	// Call repository
	documents, err := repository.GetAllDocuments(ctx, db, uid)
	if err != nil {
		return nil, err
	}

	// Decrypt data
	for i := range *documents {
		doc := &(*documents)[i]

		title, err := util.Decrypt(doc.Title, key)
		if err != nil {
			return nil, fmt.Errorf("error decrypting data")
		}

		description, err := util.Decrypt(doc.Description, key)
		if err != nil {
			return nil, fmt.Errorf("error decrypting data")
		}

		documentURL, err := util.Decrypt(doc.DocumentURL, key)
		if err != nil {
			logger.Debug(err.Error())
			return nil, fmt.Errorf("error decrypting data")
		}

		doc.Title = title
		doc.Description = description
		doc.DocumentURL = documentURL
	}

	return documents, nil
}

func GetDocumentByID(ctx context.Context, db *pgxpool.Pool, id, uid string) (*models.Document, error) {
	key := []byte(os.Getenv("AES_ENCRYPTION_KEY"))

	document, err := repository.GetDocumentByID(ctx, db, uid, id)
	if err != nil {
		return nil, err
	}

	// Decrypt data
	title, err := util.Decrypt(document.Title, key)
	if err != nil {
		return nil, fmt.Errorf("failed to decrypt data")
	}
	description, err := util.Decrypt(document.Description, key)
	if err != nil {
		return nil, fmt.Errorf("failed to decrypt data")
	}
	documentURL, err := util.Decrypt(document.DocumentURL, key)
	if err != nil {
		return nil, fmt.Errorf("failed to decrypt data")
	}

	document.Title = title
	document.Description = description
	document.DocumentURL = documentURL

	return document, nil
}

func AddDocument(ctx context.Context, db *pgxpool.Pool, uid, title, description string, file *multipart.File) (*models.Document, error) {
	// Get encryption key
	key := []byte(os.Getenv("AES_ENCRYPTION_KEY"))

	// Store file in cloudinary
	documenURL, err := util.UploadImage(ctx, *file, "docs")
	if err != nil {
		return nil, err
	}

	// encrypt title description and documentURL
	encryptedTitle, err := util.Encrypt(title, key)
	if err != nil {
		return nil, fmt.Errorf("error encrypting data")
	}
	encryptedDescription, err := util.Encrypt(description, key)
	if err != nil {
		return nil, fmt.Errorf("error encrypting data")
	}
	encryptedDocumentURL, err := util.Encrypt(documenURL, key)
	if err != nil {
		return nil, fmt.Errorf("error encrypting data")
	}

	// Store document in database
	document, err := repository.AddDocument(ctx, db, uid, encryptedTitle, encryptedDescription, encryptedDocumentURL)
	if err != nil {
		return nil, err
	}

	return document, nil
}
