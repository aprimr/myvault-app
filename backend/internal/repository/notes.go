package repository

import (
	"context"

	"github.com/aprimr/myvault/internal/models"
	"github.com/jackc/pgx/v5/pgxpool"
)

func AddNewNotes(ctx context.Context, db *pgxpool.Pool, uid, title, content string) (*models.Notes, error) {
	query := "INSERT INTO notes (uid, title, content) VALUES($1, $2, $3) RETURNING id, uid, title, content, created_at, updated_at"

	var notes models.Notes
	err := db.QueryRow(ctx, query, uid, title, content).Scan(
		&notes.Id,
		&notes.Uid,
		&notes.Title,
		&notes.Content,
		&notes.CreatedAt,
		&notes.UpdatedAt,
	)

	if err != nil {
		return nil, err
	}
	return &notes, nil
}
