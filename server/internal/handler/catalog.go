package handler

import (
	"encoding/json"
	"log/slog"
	"net/http"

	"squared-store/internal/middleware"
	"squared-store/internal/model"
	"squared-store/internal/store"
)

func CatalogHandler(s store.AppStore) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		ctx := r.Context()

		hash, err := s.CatalogHash(ctx)
		if err != nil {
			slog.Error("catalog hash failed", "error", err, "request_id", middleware.GetRequestID(ctx))
			writeError(w, r, http.StatusInternalServerError, "internal error")
			return
		}
		etag := `"` + hash + `"`

		if match := r.Header.Get("If-None-Match"); match == etag {
			w.WriteHeader(http.StatusNotModified)
			return
		}

		apps, err := s.List(ctx)
		if err != nil {
			slog.Error("list apps failed", "error", err, "request_id", middleware.GetRequestID(ctx))
			writeError(w, r, http.StatusInternalServerError, "internal error")
			return
		}

		w.Header().Set("Content-Type", "application/json")
		w.Header().Set("ETag", etag)
		w.Header().Set("Cache-Control", "public, max-age=60")
		json.NewEncoder(w).Encode(model.CatalogResponse{Apps: apps})
	}
}
