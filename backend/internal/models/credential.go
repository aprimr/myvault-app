package models

type Credential struct {
	Id                   string `json:"id"`
	Uid                  string `json:"uid"`
	Title                string `json:"title"`
	EmailOrUsername      string `json:"email_or_username"`
	LoginURL             string `json:"login_url"`
	PasswordEncrypted    string `json:"password_encrypted"`
	DescriptionEncrypted string `json:"description_encrypted"`
	LastUsedAt           string `json:"lastused_at"`
	CreatedAt            string `json:"created_at"`
	UpdatedAt            string `json:"updated_at"`
}
