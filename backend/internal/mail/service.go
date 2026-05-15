package mail

import (
	"context"
	"fmt"
	"sync"

	"github.com/aprimr/myvault/internal/config"
	"github.com/wneessen/go-mail"
)

var (
	client *mail.Client
	from   string
	mu     sync.Mutex
)

func Init(cfg config.MailConfig) error {
	c, err := mail.NewClient(
		cfg.Host,
		mail.WithPort(cfg.Port),
		mail.WithSMTPAuth(mail.SMTPAuthPlain),
		mail.WithUsername(cfg.User),
		mail.WithPassword(cfg.Password),
		mail.WithTLSPolicy(mail.TLSOpportunistic),
	)
	if err != nil {
		return err
	}

	// Open the connection once at startup and keep it alive
	if err := c.DialWithContext(context.Background()); err != nil {
		return fmt.Errorf("failed to connect to mail server: %w", err)
	}

	client = c
	from = cfg.From
	return nil
}

func SendOTP(name, to, otp string) error {
	msg := mail.NewMsg()

	if err := msg.From(from); err != nil {
		return err
	}
	if err := msg.To(to); err != nil {
		return err
	}

	msg.Subject("MyVault account verification")
	msg.SetBodyString(mail.TypeTextHTML, buildOTPMailBody(name, otp))

	mu.Lock()
	defer mu.Unlock()

	return client.Send(msg)
}
