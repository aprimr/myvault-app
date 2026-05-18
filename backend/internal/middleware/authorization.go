package middleware

import (
	"context"
	"net/http"
	"strings"

	"github.com/aprimr/myvault/internal/constants"
	"github.com/aprimr/myvault/internal/helper/jwt"
	"github.com/aprimr/myvault/internal/helper/response"
)

func Authorization(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {

		// Get auth header
		authHeader := r.Header.Get("Authorization")
		if strings.TrimSpace(authHeader) == "" {
			response.Error(w, http.StatusUnauthorized, "Auth header missing")
			return
		}

		// Trim prefix to get jwt token
		jwtToken := strings.TrimPrefix(authHeader, "Bearer ")
		if strings.TrimSpace(jwtToken) == "" {
			response.Error(w, http.StatusUnauthorized, "JWT token missing")
			return
		}

		// Verify token
		jwtClaims, err := jwt.Validate(jwtToken)
		if err != nil {
			response.Error(w, http.StatusUnauthorized, "JWT token tampered")
		}

		// Send jwt with request
		ctx := context.WithValue(r.Context(), constants.ContextUID, jwtClaims.Uid)
		ctx = context.WithValue(ctx, constants.ContextEmail, jwtClaims.Email)

		// Call next handler
		next.ServeHTTP(w, r.WithContext(ctx))
	})
}
