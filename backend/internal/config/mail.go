package config

import "os"

type MailConfig struct {
	BrevoAPIKey string
	From        string
}

func LoadMailConfig() MailConfig {
	return MailConfig{
		BrevoAPIKey: os.Getenv("BREVO_API_KEY"),
		From:        os.Getenv("SMTP_FROM"),
	}
}
