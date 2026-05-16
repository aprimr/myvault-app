package mail

import (
	"context"
	"fmt"

	"github.com/aprimr/myvault/internal/config"
	"github.com/wneessen/go-mail"
)

type Service struct {
	cfg  config.MailConfig
	from string
}

func New(cfg config.MailConfig) *Service {
	return &Service{
		cfg:  cfg,
		from: cfg.From,
	}
}

func (s *Service) newClient() (*mail.Client, error) {
	return mail.NewClient(
		s.cfg.Host,
		mail.WithPort(s.cfg.Port),
		mail.WithSMTPAuth(mail.SMTPAuthPlain),
		mail.WithUsername(s.cfg.User),
		mail.WithPassword(s.cfg.Password),
		mail.WithTLSPolicy(mail.TLSOpportunistic),
	)
}

func (s *Service) SendOTP(name, to, otp string) error {
	msg := mail.NewMsg()

	if err := msg.From(s.from); err != nil {
		return err
	}
	if err := msg.To(to); err != nil {
		return err
	}

	msg.Subject("MyVault account verification")
	msg.SetBodyString(mail.TypeTextHTML, buildOTPMailBody(name, otp))

	c, err := s.newClient()
	if err != nil {
		return err
	}

	if err := c.DialWithContext(context.Background()); err != nil {
		return fmt.Errorf("smtp dial failed: %w", err)
	}
	defer c.Close()

	return c.Send(msg)
}

func (s *Service) SendLoginAlert(name, to, loginTime string) error {
	msg := mail.NewMsg()

	if err := msg.From(s.from); err != nil {
		return err
	}

	if err := msg.To(to); err != nil {
		return err
	}

	msg.Subject("New login to your MyVault account")
	msg.SetBodyString(mail.TypeTextHTML, buildLoginAlertMailBody(name, loginTime))

	c, err := s.newClient()
	if err != nil {
		return err
	}

	if err := c.DialWithContext(context.Background()); err != nil {
		return fmt.Errorf("smtp dial failed: %w", err)
	}
	defer c.Close()

	return c.Send(msg)
}
