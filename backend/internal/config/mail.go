package config

import (
	"os"
	"strconv"
)

type MailConfig struct {
	Host     string
	Port     int
	User     string
	Password string
	From     string
}

func LoadMailConfig() MailConfig {
	port, _ := strconv.Atoi(os.Getenv("SMTP_PORT"))

	return MailConfig{
		Host:     os.Getenv("SMTP_HOST"),
		Port:     port,
		User:     os.Getenv("SMTP_USER"),
		Password: os.Getenv("SMTP_PASS"),
		From:     os.Getenv("SMTP_FROM"),
	}
}
