package middleware

import (
	"log/slog"
	"net/http"
	"time"
)

type responseWriter struct {
	http.ResponseWriter
	statusCode int
}

func (rw *responseWriter) WriteHeader(code int) {
	rw.statusCode = code
	rw.ResponseWriter.WriteHeader(code)
}

func Logging(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		start := time.Now()
		wrapped := &responseWriter{ResponseWriter: w, statusCode: http.StatusOK}
		next.ServeHTTP(wrapped, r)

		attrs := []slog.Attr{
			slog.String("method", r.Method),
			slog.String("path", r.URL.Path),
			slog.Int("status", wrapped.statusCode),
			slog.Int64("duration_ms", time.Since(start).Milliseconds()),
			slog.String("remote", r.RemoteAddr),
		}
		if reqID := GetRequestID(r.Context()); reqID != "" {
			attrs = append(attrs, slog.String("request_id", reqID))
		}

		level := slog.LevelInfo
		if wrapped.statusCode >= 500 {
			level = slog.LevelError
		} else if wrapped.statusCode >= 400 {
			level = slog.LevelWarn
		}

		slog.LogAttrs(r.Context(), level, "request", attrs...)
	})
}
