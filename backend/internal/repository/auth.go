package repository

import (
	"context"

	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"
)

func CreateUser(ctx context.Context, db *pgxpool.Pool, username, email, password, name string) error {
	query := "INSERT INTO users (username, email, password, name) VALUES($1, $2, $3, $4)"

	// Execute query
	_, err := db.Exec(ctx, query, username, email, password, name)
	if err != nil {
		return err
	}

	return nil
}

func IsUsernameTaken(ctx context.Context, db *pgxpool.Pool, username string) (bool, error) {
	query := "SELECT 1 FROM users WHERE username=$1"

	var exists int
	err := db.QueryRow(ctx, query, username).Scan(&exists)

	if err == nil {
		// Username found, return true
		return true, nil
	}

	if err == pgx.ErrNoRows {
		// No rows, return false
		return false, nil
	}

	return false, err
}
