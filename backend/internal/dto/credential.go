package dto

type AddCredentialRequest struct {
	Title           string `json:"title"`
	EmailOrUsername string `json:"email_or_username"`
	Password        string `json:"password"`
	LoginURL        string `json:"login_url"`
	Description     string `json:"description"`
}
