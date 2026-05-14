package mail

import (
	"fmt"

	"github.com/aprimr/myvault/internal/config"
	"github.com/wneessen/go-mail"
)

var client *mail.Client
var from string

func Init(cfg config.MailConfig) error {
	c, err := mail.NewClient(
		cfg.Host,
		mail.WithPort(cfg.Port),
		mail.WithSMTPAuth(mail.SMTPAuthPlain),
		mail.WithUsername(cfg.User),
		mail.WithPassword(cfg.Password),
	)

	if err != nil {
		return err
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

	mailBody := fmt.Sprintf(`
<!DOCTYPE html>
<html>
<body style="margin:0;padding:0;background:#f5f5f5;font-family:'DM Sans',Arial,sans-serif;">
  <table width="100%%" cellpadding="0" cellspacing="0">
    <tr>
      <td align="center">
        <table width="520" cellpadding="0" cellspacing="0" style="background:#ffffff;border:1px solid #e0e0e0;">
 
          <!-- Header -->
          <tr>
            <td style="padding:26px 36px;">
              <img src="https://res.cloudinary.com/dbkl5kiqg/image/upload/v1778762346/1_wydvwk.png"
                         alt="myvault" height="30"
                         style="display:block;height:30px;width:auto;" />
            </td>
          </tr>
 
          <!-- Body -->
          <tr>
            <td style="padding:16px 36px 40px;">
 
              <p style="font-size:18px;color:#555555;line-height:1.7;margin:0 0 8px;">Hi %s,</p>
              <p style="font-size:18px;color:#555555;line-height:1.7;margin:0 0 32px;">
                We received a request to verify your account. Use the code below to verify your account.
              </p>
 
              <div style="margin-bottom:6px;">
                <span style="font-family:'Poppins',Arial,sans-serif;font-size:40px;font-weight:700;letter-spacing:14px;color:#111111;padding-left:14px;">
                  %s
                </span>
              </div>
              <p style="font-size:14px;color:#999999;margin:10px 0 32px;">This code will expire in 10 minutes.</p>
 
			<p style="font-size:14px;color:#999999;line-height:1.7;margin:0;">
                For security reasons, do not share this code with anyone. If you did not request this code, you can safely ignore this email.
              </p>
 
            </td>
          </tr>
 
          <!-- Footer -->
          <tr>
            <td style="padding:22px 45px 28px;border-top:1px solid #ebebeb;">
              <table cellpadding="0" cellspacing="0" style="margin-bottom:10px;">
                <tr>
                  <td style="vertical-align:middle;padding-right:8px;">
                    <img src="https://res.cloudinary.com/dbkl5kiqg/image/upload/v1778757908/1_wqcisl.png"
                         alt="BamboTech" height="22"
                         style="display:block;height:22px;width:auto;opacity:0.5;filter:grayscale(100%%);" />
                  </td>
                  <td style="vertical-align:middle;">
                    <span style="font-size:17px;font-weight:500;color:#888888;">BamboTech</span>
                  </td>
                </tr>
              </table>
              <p style="font-size:11.5px;color:#bbbbbb;line-height:1.8;margin:0;">
                &copy; 2025 BamboTech. All rights reserved.<br />
                <a href="#" style="color:#bbbbbb;">Privacy Policy</a> &nbsp;&middot;&nbsp;
                <a href="#" style="color:#bbbbbb;">Terms of Service</a>
              </p>
            </td>
          </tr>
 
        </table>
      </td>
    </tr>
  </table>
</body>
</html>
`, name, otp)
	msg.Subject("MyVault account verification")

	msg.SetBodyString(mail.TypeTextHTML, mailBody)

	return client.DialAndSend(msg)
}
