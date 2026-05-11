package database

import (
	"context"
	"os"

	"github.com/aprimr/myvault/internal/logger"
	"github.com/jackc/pgx/v5/pgxpool"
)

var DB *pgxpool.Pool

func Connect() {
	dbURL := os.Getenv("DATABASE_URL")

	// Create connection
	pool, err := pgxpool.New(context.Background(), dbURL)
	if err != nil {
		logger.Fatal("Failed to connect to database", err)
	}

	// Ping database
	err = pool.Ping(context.Background())
	if err != nil {
		logger.Fatal("Failed to ping database", err)
	}

	DB = pool
}
