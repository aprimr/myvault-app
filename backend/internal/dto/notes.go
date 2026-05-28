package dto

type AddNoteRequest struct {
	Title   string `json:"title"`
	Content string `json:"content"`
}
