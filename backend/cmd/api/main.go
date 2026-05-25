package main

import (
	"fmt"
	"log"
	"net/http"
	"os"
	"time"

	"github.com/aprimr/myvault/internal/config"
	"github.com/aprimr/myvault/internal/database"
	"github.com/aprimr/myvault/internal/handler"
	"github.com/aprimr/myvault/internal/logger"
	"github.com/aprimr/myvault/internal/mail"
	"github.com/aprimr/myvault/internal/middleware"
	"github.com/aprimr/myvault/internal/util"
	"github.com/go-chi/chi/v5"
	"github.com/joho/godotenv"
)

func main() {

	start := time.Now()

	// Load env
	err := godotenv.Load()
	if err != nil {
		log.Fatalln("Failed to load env")
	}
	fmt.Printf("Time to load env: %v \n", time.Since(start))

	// Init logger
	logger.Init(os.Getenv("APP_ENV"))
	fmt.Printf("Time to init logger: %v \n", time.Since(start))

	// Init mailer
	mailCfg := config.LoadMailConfig()
	mailService := mail.New(mailCfg)
	fmt.Printf("Time to init mail: %v \n", time.Since(start))

	// Init cloudinary
	err = util.InitCloudinary()
	if err != nil {
		logger.Fatal("Failed to init cloudinary", err)
	}
	fmt.Printf("Time to init cloudinary: %v \n", time.Since(start))

	// Connect DB
	database.Connect()
	fmt.Printf("Time to connect db: %v \n", time.Since(start))

	// Create chi router
	r := chi.NewRouter()

	authHandler := handler.NewAuthHandler(mailService)       // authHandler
	profileHandler := handler.NewProfileHandler(mailService) // profileHandler
	credentialHandler := handler.NewCredentialHandler()      // profileHandler

	// Routes
	r.Route("/api", func(r chi.Router) {

		// auth routes
		r.Route("/auth", func(r chi.Router) {
			r.Post("/signup", authHandler.HandleSignup)
			r.Post("/login", authHandler.HandleLogin)
			r.Post("/verify-otp", authHandler.HandleVerifyOTP)
			r.Post("/forgot-password", authHandler.HandleForgotPassword)
			r.Post("/set-new-password", authHandler.HandleSetNewPassword)
		})

		// Protected routes
		r.Group(func(r chi.Router) {
			// use auth middleware
			r.Use(middleware.Authorization)

			// Profile routes
			r.Get("/me", profileHandler.HandleGetProfile)
			r.Put("/me", profileHandler.HandleUpdateProfile)
			r.Put("/me/photo", profileHandler.HandleUpdateProfilePic)
			r.Delete("/me/photo", profileHandler.HandleDeleteProfilePic)

			// Settings
			r.Put("/me/email", profileHandler.HandleChangeEmail)
			r.Put("/me/password", profileHandler.HandleChangePassword)

			// Credential
			r.Route("/credential", func(r chi.Router) {
				r.Get("/", credentialHandler.HandleGetCredential)
				r.Post("/", credentialHandler.HandleAddCredential)
			})
		})

	})
	fmt.Printf("Time to create new router and register routes: %v \n", time.Since(start))

	// Spin up server
	port := ":" + os.Getenv("PORT")
	logger.Info("Server started at PORT" + port)
	err = http.ListenAndServe(port, r)
	if err != nil {
		logger.Fatal("Failed to start server", err)
	}
	fmt.Printf("Time to spin up server: %v \n", time.Since(start))
}
