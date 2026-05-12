package validation

import (
	"errors"
	"regexp"
	"unicode"
)

// validation.Email checks:
// - at least 3 characters before @
// - at least 2 characters in domain name before .
// - at least 2 characters after .
func Email(email string) error {
	// Regex for email
	re := regexp.MustCompile(`^[A-Za-z0-9._%+\-]{3,}@[A-Za-z0-9\-]{2,}\.[A-Za-z]{2,}$`)

	if !re.MatchString(email) {
		return errors.New("Invalid email format")
	}

	return nil
}

// validation.Password checks:
// - at least 8 characters
// - at least 1 digit
// - at least 1 special character
// - at least 1 letter
func Password(password string) error {
	if len(password) < 8 {
		return errors.New("password must be at least 8 characters long")
	}

	var hasDigit, hasLetter, hasSpecial bool

	for _, ch := range password {
		switch {
		case unicode.IsDigit(ch):
			hasDigit = true
		case unicode.IsLetter(ch):
			hasLetter = true
		case unicode.IsPunct(ch) || unicode.IsSymbol(ch):
			hasSpecial = true
		}
	}

	if !hasDigit {
		return errors.New("password must contain at least one number")
	}
	if !hasLetter {
		return errors.New("password must contain at least one letter")
	}
	if !hasSpecial {
		return errors.New("password must contain at least one special character")
	}

	return nil
}
