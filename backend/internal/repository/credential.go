package repository

import (
	"context"
	"fmt"

	"github.com/jackc/pgx/v5/pgxpool"
)

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
