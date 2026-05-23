package models

import "time"

type Credential struct {
	Id                   string    `json:"id"`
	Uid                  string    `json:"uid"`
	Title                string    `json:"title"`
	EmailOrUsername      string    `json:"email_or_username_encrypted"`
	PasswordEncrypted    string    `json:"-"`
	LoginURL             *string   `json:"login_url"`
	DescriptionEncrypted *string   `json:"-"`
	CreatedAt            time.Time `json:"created_at"`
	UpdatedAt            time.Time `json:"updated_at"`
}
