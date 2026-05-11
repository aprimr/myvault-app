package main

import (
	"log"
	"net/http"
	"os"

	"github.com/aprimr/myvault/internal/logger"
	"github.com/joho/godotenv"
)

func main() {
	// Load env
	err := godotenv.Load()
	if err != nil {
		log.Fatalln("Failed to load env")
	}

	// Init logger
	logger.Init(os.Getenv("APP_ENV"))

	mux := http.NewServeMux()

	// Spin up server
	port := ":" + os.Getenv("PORT")
	logger.Info("Server started at PORT" + port)
	err = http.ListenAndServe(port, mux)
	if err != nil {
		logger.Fatal("Failed to start server", err)
	}
}
