package middleware

import (
	"net"
	"net/http"
	"sync"

	"golang.org/x/time/rate"
)

// RateLimit returns middleware that enforces per-IP rate limiting.
// rps is requests per second, burst is the token bucket burst size.
func RateLimit(rps float64, burst int) func(http.Handler) http.Handler {
	var (
		mu      sync.Mutex
		clients = make(map[string]*rate.Limiter)
	)

	return func(next http.Handler) http.Handler {
		return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			ip, _, err := net.SplitHostPort(r.RemoteAddr)
			if err != nil {
				ip = r.RemoteAddr
			}

			mu.Lock()
			limiter, exists := clients[ip]
			if !exists {
				limiter = rate.NewLimiter(rate.Limit(rps), burst)
				clients[ip] = limiter
			}
			mu.Unlock()

			if !limiter.Allow() {
				w.Header().Set("Content-Type", "application/json")
				w.Header().Set("Retry-After", "1")
				w.WriteHeader(http.StatusTooManyRequests)
				w.Write([]byte(`{"error":"rate limit exceeded"}`))
				return
			}

			next.ServeHTTP(w, r)
		})
	}
}
