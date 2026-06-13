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

func GetAllNotes(ctx context.Context, db *pgxpool.Pool, uid string) (*[]models.Notes, error) {
	key := []byte(os.Getenv("AES_ENCRYPTION_KEY"))

	// Call Repository
	notes, err := repository.GetAllNotes(ctx, db, uid)
	if err != nil {
		return nil, fmt.Errorf("failed to fetch notes")
	}

	// Decrypt notes
	var decrypted []models.Notes
	for _, n := range *notes {
		title, err := util.Decrypt(n.Title, key)
		if err != nil {
			return nil, err
		}

		content, err := util.Decrypt(n.Content, key)
		if err != nil {
			return nil, err
		}

		decrypted = append(decrypted, models.Notes{
			Id:        n.Id,
			Uid:       n.Uid,
			Title:     title,
			Content:   content,
			CreatedAt: n.CreatedAt,
			UpdatedAt: n.UpdatedAt,
		})
	}

	return &decrypted, nil
}

func GetNotesByID(ctx context.Context, db *pgxpool.Pool, uid, id string) (*models.Notes, error) {
	key := []byte(os.Getenv("AES_ENCRYPTION_KEY"))

	notes, err := repository.GetNotesByID(ctx, db, id, uid)
	if err != nil {
		return nil, err
	}

	// Decrypt data
	title, err := util.Decrypt(notes.Title, key)
	if err != nil {
		return nil, err
	}

	content, err := util.Decrypt(notes.Content, key)
	if err != nil {
		return nil, err
	}

	return &models.Notes{
		Id:        notes.Id,
		Uid:       notes.Uid,
		Title:     title,
		Content:   content,
		CreatedAt: notes.CreatedAt,
		UpdatedAt: notes.UpdatedAt,
	}, nil
}

func DeleteNotesByID(ctx context.Context, db *pgxpool.Pool, id, uid string) error {
	// Call repository
	err := repository.DeleteNotesByID(ctx, db, id, uid)

	return err
}

func UpdateNotes(ctx context.Context, db *pgxpool.Pool, title, content, id, uid string) (*models.Notes, error) {
	key := []byte(os.Getenv("AES_ENCRYPTION_KEY"))

	// Encrypt title and content
	encryptedTitle, err := util.Encrypt(title, key)
	if err != nil {
		return nil, err
	}
	encryptedContent, err := util.Encrypt(content, key)
	if err != nil {
		return nil, err
	}

	// Call repository
	notes, err := repository.UpdateNotes(ctx, db, id, uid, encryptedTitle, encryptedContent)
	if err != nil {
		return nil, err
	}

	return notes, nil
}
