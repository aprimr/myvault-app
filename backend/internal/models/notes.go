package models

import "time"

type Notes struct {
	Id        string    `json:"id"`
	Uid       string    `json:"uid"`
	Title     string    `json:"title"`
	Content   string    `json:"content"`
	CreatedAt time.Time `json:"created_at"`
	UpdatedAt time.Time `json:"updated_at"`
}
