package main

import (
	"log"
	"net/http"
	"os"

	"github.com/aprimr/myvault/internal/config"
	"github.com/aprimr/myvault/internal/database"
	"github.com/aprimr/myvault/internal/handler"
	"github.com/aprimr/myvault/internal/helper/response"
	"github.com/aprimr/myvault/internal/logger"
	"github.com/aprimr/myvault/internal/mail"
	"github.com/aprimr/myvault/internal/middleware"
	"github.com/aprimr/myvault/internal/util"
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
	mailService := mail.New(mailCfg)

	// Init cloudinary
	err = util.InitCloudinary()
	if err != nil {
		logger.Fatal("Failed to init cloudinary", err)
	}

	// Connect DB
	database.Connect()

	// Create chi router
	r := chi.NewRouter()

	authHandler := handler.NewAuthHandler(mailService)       // authHandler
	profileHandler := handler.NewProfileHandler(mailService) // profileHandler
	credentialHandler := handler.NewCredentialHandler()      // profileHandler
	notesHandler := handler.NewNotesHandler()                // notesHandler
	documentsHandler := handler.NewDocumentsHandler()        // notesHandler

	// Routes
	r.Route("/api", func(r chi.Router) {

		r.Get("/ping", func(w http.ResponseWriter, r *http.Request) {
			response.JSON(w, http.StatusOK, "Pong", nil)
		})

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
				r.Get("/{id}", credentialHandler.HandleGetCredentialById)
				r.Delete("/{id}", credentialHandler.HandleDeleteCredential)
			})

			// Notes
			r.Route("/notes", func(r chi.Router) {
				r.Get("/", notesHandler.HandleGetAllNotes)
				r.Get("/{id}", notesHandler.HandleGetNotesByID)
				r.Post("/", notesHandler.HandleAddNewNotes)
				r.Delete("/{id}", notesHandler.HandleDeleteNotesByID)
				r.Patch("/{id}", notesHandler.HandleUpdateNotes)
			})

			// Document
			r.Route("/document", func(r chi.Router) {
				r.Post("/", documentsHandler.HandleAddDocument)
				r.Get("/", documentsHandler.HandleGetAllDocuments)
				r.Get("/{id}", documentsHandler.HandleGetDocumentByID)
				r.Delete("/{id}", documentsHandler.HandleDeleteDocument)
			})
		})

	})

	// Spin up server
	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}
	addr := ":" + port
	logger.Info("Server started at PORT" + port)
	err = http.ListenAndServe(addr, r)
	if err != nil {
		logger.Fatal("Failed to start server", err)
	}
}
