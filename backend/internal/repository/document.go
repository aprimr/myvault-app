package repository

import (
	"context"

	"github.com/aprimr/myvault/internal/models"
	"github.com/jackc/pgx/v5/pgxpool"
)

func AddDocument(ctx context.Context, db *pgxpool.Pool, uid, title, description, documentURL string) (*models.Document, error) {
	query := "INSERT INTO documents (uid, title, description, document_url) VALUES($1, $2, $3, $4) RETURNING id, uid, title, description, document_url, created_at, updated_at"

	var document models.Document
	err := db.QueryRow(ctx, query, uid, title, description, documentURL).Scan(
		&document.Id,
		&document.Uid,
		&document.Title,
		&document.Description,
		&document.DocumentURL,
		&document.CreatedAt,
		&document.UpdatedAt,
	)

	return &document, err
}
