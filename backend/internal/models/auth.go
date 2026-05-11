package models

type User struct {
	Uid        string `json:"uid"`
	Username   string `json:"username"`
	Email      string `json:"email"`
	Password   string `json:"-"`
	Name       string `json:"name"`
	ProfileUrl string `json:"profile_url"`
	IsActive   string `json:"is_active"`
	IsVerfifed string `json:"is_verified"`
	IsDeleted  string `json:"is_deleted"`
	DeletedAt  string `json:"deleted_at"`
	CreatedAt  string `json:"created_at"`
	UpdatedAt  string `json:"updated_at"`
}
