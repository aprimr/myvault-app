package models

import "time"

type Document struct {
	Id          string    `json:"id"`
	Uid         string    `json:"uid"`
	Title       string    `json:"title"`
	Description string    `json:"description"`
	DocumentURL string    `json:"document_url"`
	CreatedAt   time.Time `josn:"created_at"`
	UpdatedAt   time.Time `josn:"updated_at"`
}
