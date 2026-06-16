package mail

import (
	"bytes"
	"encoding/json"
	"fmt"
	"net/http"

	"github.com/aprimr/myvault/internal/config"
)

type Service struct {
	apiKey string
	from   string
}

func New(cfg config.MailConfig) *Service {
	return &Service{
		apiKey: cfg.BrevoAPIKey,
		from:   cfg.From,
	}
}

func (s *Service) send(to, subject, html string) error {
	url := "https://api.brevo.com/v3/smtp/email"

	payload := map[string]any{
		"sender": map[string]string{
			"name":  "MyVault",
			"email": extractEmail(s.from),
		},
		"to": []map[string]string{
			{"email": to},
		},
		"subject":     subject,
		"htmlContent": html,
	}

	body, err := json.Marshal(payload)
	if err != nil {
		return err
	}

	req, err := http.NewRequest("POST", url, bytes.NewBuffer(body))
	if err != nil {
		return err
	}

	req.Header.Set("api-key", s.apiKey)
	req.Header.Set("Content-Type", "application/json")

	client := &http.Client{}
	resp, err := client.Do(req)
	if err != nil {
		return err
	}
	defer resp.Body.Close()

	if resp.StatusCode >= 400 {
		return fmt.Errorf("brevo error: status %s", resp.Status)
	}

	return nil
}

func extractEmail(from string) string {
	start := -1
	for i, c := range from {
		if c == '<' {
			start = i + 1
		}
		if c == '>' {
			return from[start:i]
		}
	}
	return from
}

func (s *Service) SendOTP(name, to, otp string) error {
	return s.send(
		to,
		"MyVault account verification",
		buildOTPMailBody(name, otp),
	)
}

func (s *Service) SendLoginAlert(name, to, loginTime string) error {
	return s.send(
		to,
		"New login to your MyVault account",
		buildLoginAlertMailBody(name, loginTime),
	)
}

func (s *Service) SendForgotPasswordOTP(name, to, otp string) error {
	return s.send(
		to,
		"Reset your MyVault password",
		buildForgotPasswordOTPMailBody(name, otp),
	)
}

func (s *Service) SendChangeEmailOTP(name, to, otp string) error {
	return s.send(
		to,
		"Verify your email address",
		buildChangeEmailOTPMailBody(name, otp),
	)
}

func (s *Service) SendChangeEmailAlert(name, to, newEmail, time string) error {
	return s.send(
		to,
		"Your email address was changed",
		buildChangeEmailAlertMailBody(name, newEmail, time),
	)
}

func (s *Service) SendChangedPasswordAlert(name, to, time string) error {
	return s.send(
		to,
		"Your password was changed",
		buildChangedPasswordAlertMailBody(name, time),
	)
}
