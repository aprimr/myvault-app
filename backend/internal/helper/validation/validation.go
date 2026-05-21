package validation

import (
	"errors"
	"fmt"
	"regexp"
	"strings"
	"unicode"
)

// validation.Email checks:
// - at least 3 characters before @
// - at least 2 characters in domain name before .
// - at least 2 characters after .
func Email(email string) error {
	// Regex for email
	re := regexp.MustCompile(`^[A-Za-z0-9._%+\-]{3,}@[A-Za-z0-9\-]{2,}\.[A-Za-z]{2,}$`)

	if strings.TrimSpace(email) == "" {
		return errors.New("Email is required")
	}

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

	if strings.TrimSpace(password) == "" {
		return errors.New("Password is required")
	}

	if len(password) < 8 {
		return errors.New("Password must be at least 8 characters long")
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
		return errors.New("Password must contain at least one number")
	}
	if !hasLetter {
		return errors.New("Password must contain at least one letter")
	}
	if !hasSpecial {
		return errors.New("Password must contain at least one special character")
	}

	return nil
}

// validation.Username checks:
// - at least 7 characters
// - only lowercase letters
// - can contain numbers
// - can contain . or _
func Username(username string) error {

	username = strings.TrimSpace(username)

	if username == "" {
		return errors.New("Username is required")
	}

	if len(username) < 7 {
		return errors.New("Username must be at least 7 characters long")
	}

	for _, ch := range username {

		// allow lowercase letters
		if ch >= 'a' && ch <= 'z' {
			continue
		}

		// allow numbers
		if unicode.IsDigit(ch) {
			continue
		}

		// allow dot and underscore
		if ch == '.' || ch == '_' {
			continue
		}

		return errors.New("Username can only contain lowercase letters, numbers, '.' and '_'")
	}

	return nil
}

// validation.EmptyString checks:
// - if given string is empty
func EmptyString(str string) error {
	if strings.TrimSpace(str) == "" {
		return fmt.Errorf("String is required")
	}

	return nil
}
