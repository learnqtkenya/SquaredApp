package handler

import (
	"encoding/json"
	"errors"
	"log/slog"
	"net/http"

	"squared-store/internal/middleware"
	"squared-store/internal/model"
	"squared-store/internal/store"
)

func GetSecretsHandler(s store.AppStore) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		appId := r.PathValue("id")
		secrets, err := s.ListSecrets(r.Context(), appId)
		if err != nil {
			if errors.Is(err, store.ErrNotFound) {
				writeError(w, r, http.StatusNotFound, err.Error())
				return
			}
			slog.Error("list secrets failed", "error", err, "app_id", appId, "request_id", middleware.GetRequestID(r.Context()))
			writeError(w, r, http.StatusInternalServerError, "internal error")
			return
		}
		writeJSON(w, http.StatusOK, model.SecretsRequest{Secrets: secrets})
	}
}

func SetSecretsHandler(s store.AppStore) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		appId := r.PathValue("id")

		var req model.SecretsRequest
		if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
			var maxBytesErr *http.MaxBytesError
			if errors.As(err, &maxBytesErr) {
				writeError(w, r, http.StatusRequestEntityTooLarge, "request body too large")
				return
			}
			writeError(w, r, http.StatusBadRequest, "invalid JSON body")
			return
		}

		for _, secret := range req.Secrets {
			if secret.Key == "" {
				writeError(w, r, http.StatusBadRequest, "secret key must not be empty")
				return
			}
		}

		if err := s.SetSecrets(r.Context(), appId, req.Secrets); err != nil {
			slog.Error("set secrets failed", "error", err, "app_id", appId, "request_id", middleware.GetRequestID(r.Context()))
			writeError(w, r, http.StatusInternalServerError, "internal error")
			return
		}
		w.WriteHeader(http.StatusNoContent)
	}
}
