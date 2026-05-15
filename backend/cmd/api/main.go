package main

import (
	"log"
	"net/http"
	"os"

	"github.com/aprimr/myvault/internal/config"
	"github.com/aprimr/myvault/internal/database"
	"github.com/aprimr/myvault/internal/handler"
	"github.com/aprimr/myvault/internal/logger"
	"github.com/aprimr/myvault/internal/mail"
	"github.com/go-chi/chi/v5"
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

	// Init mailer
	mailCfg := config.LoadMailConfig()
	err = mail.Init(mailCfg)
	if err != nil {
		logger.Fatal("Failed to initialize mailer", err)
	}

	// Connect DB
	database.Connect()

	// Create chi router
	r := chi.NewRouter()

	authHandler := handler.NewAuthHandler() // authHandler

	// Routes
	r.Route("/api", func(r chi.Router) {

		// auth
		r.Route("/auth", func(r chi.Router) {
			r.Post("/signup", authHandler.HandleSignup)
			r.Post("/verify-otp", authHandler.HandleVerifyOTP)
		})

	})

	// Spin up server
	port := ":" + os.Getenv("PORT")
	logger.Info("Server started at PORT" + port)
	err = http.ListenAndServe(port, r)
	if err != nil {
		logger.Fatal("Failed to start server", err)
	}
}
