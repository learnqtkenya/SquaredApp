package handler

import (
	"encoding/json"
	"net/http"

	"github.com/jackc/pgx/v5/pgxpool"
)

// LivenessHandler returns 200 if the process is alive. No dependency checks.
func LivenessHandler() http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Content-Type", "application/json")
		w.WriteHeader(http.StatusOK)
		json.NewEncoder(w).Encode(map[string]string{
			"status":  "ok",
			"service": "squared-store",
		})
	}
}

// ReadinessHandler returns 200 if the service can accept traffic (DB is reachable).
// Returns 503 if the database is unavailable.
func ReadinessHandler(pool *pgxpool.Pool) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		status := "ok"
		httpCode := http.StatusOK

		if err := pool.Ping(r.Context()); err != nil {
			status = "unavailable"
			httpCode = http.StatusServiceUnavailable
		}

		w.Header().Set("Content-Type", "application/json")
		w.WriteHeader(httpCode)
		json.NewEncoder(w).Encode(map[string]string{
			"status":  status,
			"service": "squared-store",
		})
	}
}
