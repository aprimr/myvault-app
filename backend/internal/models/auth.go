package models

import (
	"time"
)

type User struct {
	Uid        string    `json:"uid"`
	Username   string    `json:"username"`
	Email      string    `json:"email"`
	Password   string    `json:"-"`
	Name       string    `json:"name"`
	ProfileUrl string    `json:"profile_url"`
	IsActive   bool      `json:"is_active"`
	IsVerified bool      `json:"is_verified"`
	IsDeleted  bool      `json:"is_deleted"`
	CreatedAt  time.Time `json:"created_at"`
	UpdatedAt  time.Time `json:"updated_at"`
}
