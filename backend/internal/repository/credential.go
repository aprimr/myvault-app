package repository

import (
	"context"
	"fmt"

	"github.com/aprimr/myvault/internal/models"
	"github.com/jackc/pgx/v5/pgxpool"
)

func GetCredentialsByUid(ctx context.Context, db *pgxpool.Pool, uid string) ([]models.Credential, error) {
	query := "SELECT id, uid, title_encrypted, email_or_username_encrypted, password_encrypted, login_url_encrypted, description_encrypted, created_at, updated_at  FROM credentials WHERE uid=$1"

	rows, err := db.Query(ctx, query, uid)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var credentials []models.Credential
	for rows.Next() {
		var c models.Credential

		err := rows.Scan(
			&c.Id,
			&c.Uid,
			&c.Title,
			&c.EmailOrUsername,
			&c.Password,
			&c.LoginURL,
			&c.Description,
			&c.CreatedAt,
			&c.UpdatedAt,
		)
		if err != nil {
			return nil, err
		}

		credentials = append(credentials, c)
	}

	return credentials, nil
}

func StoreCredential(ctx context.Context, db *pgxpool.Pool, uid, title, EmailOrUsername, password, loginURL, description string) error {
	query := "INSERT INTO credentials (uid, title_encrypted, email_or_username_encrypted, password_encrypted, login_url_encrypted, description_encrypted) VALUES($1, $2, $3, $4, $5, $6)"

	cmdTag, err := db.Exec(ctx, query, uid, title, EmailOrUsername, password, loginURL, description)
	if err != nil {
		return err
	}

	if cmdTag.RowsAffected() == 0 {
		return fmt.Errorf("failed to store credential")
	}

	return nil
}
