package models

import "time"

type Credential struct {
	Id              string    `json:"id"`
	Uid             string    `json:"uid"`
	Title           string    `json:"title"`
	EmailOrUsername string    `json:"email_or_username"`
	Password        string    `json:"password"`
	LoginURL        *string   `json:"login_url"`
	Description     *string   `json:"description"`
	CreatedAt       time.Time `json:"created_at"`
	UpdatedAt       time.Time `json:"updated_at"`
}
