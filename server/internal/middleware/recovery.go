package middleware

import (
	"encoding/json"
	"log/slog"
	"net/http"
	"runtime/debug"
)

func Recovery(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		defer func() {
			if err := recover(); err != nil {
				reqID := GetRequestID(r.Context())
				slog.Error("panic recovered",
					"error", err,
					"stack", string(debug.Stack()),
					"request_id", reqID,
				)
				w.Header().Set("Content-Type", "application/json")
				w.WriteHeader(http.StatusInternalServerError)
				json.NewEncoder(w).Encode(map[string]any{
					"error":     "internal server error",
					"requestId": reqID,
				})
			}
		}()
		next.ServeHTTP(w, r)
	})
}
