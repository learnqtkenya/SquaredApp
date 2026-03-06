package middleware

import (
	"encoding/json"
	"net/http"
	"strings"
)

// AdminAuth returns middleware that requires a valid Bearer token for requests.
// If token is empty, all requests are allowed (auth disabled).
func AdminAuth(token string) func(http.Handler) http.Handler {
	return func(next http.Handler) http.Handler {
		return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			if token == "" {
				next.ServeHTTP(w, r)
				return
			}

			auth := r.Header.Get("Authorization")
			if !strings.HasPrefix(auth, "Bearer ") || strings.TrimPrefix(auth, "Bearer ") != token {
				w.Header().Set("Content-Type", "application/json")
				w.WriteHeader(http.StatusUnauthorized)
				json.NewEncoder(w).Encode(map[string]string{
					"error": "unauthorized: invalid or missing token",
				})
				return
			}

			next.ServeHTTP(w, r)
		})
	}
}
