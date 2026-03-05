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

func ListAppsHandler(s store.AppStore) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		apps, err := s.List(r.Context())
		if err != nil {
			slog.Error("list apps failed", "error", err, "request_id", middleware.GetRequestID(r.Context()))
			writeError(w, r, http.StatusInternalServerError, "internal error")
			return
		}
		writeJSON(w, http.StatusOK, apps)
	}
}

func GetAppHandler(s store.AppStore) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		id := r.PathValue("id")
		app, err := s.GetByID(r.Context(), id)
		if err != nil {
			if errors.Is(err, store.ErrNotFound) {
				writeError(w, r, http.StatusNotFound, err.Error())
				return
			}
			slog.Error("get app failed", "error", err, "id", id, "request_id", middleware.GetRequestID(r.Context()))
			writeError(w, r, http.StatusInternalServerError, "internal error")
			return
		}
		writeJSON(w, http.StatusOK, app)
	}
}

func CreateAppHandler(s store.AppStore) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		var app model.App
		if err := json.NewDecoder(r.Body).Decode(&app); err != nil {
			var maxBytesErr *http.MaxBytesError
			if errors.As(err, &maxBytesErr) {
				writeError(w, r, http.StatusRequestEntityTooLarge, "request body too large")
				return
			}
			writeError(w, r, http.StatusBadRequest, "invalid JSON body")
			return
		}
		if err := app.Validate(); err != nil {
			writeError(w, r, http.StatusBadRequest, err.Error())
			return
		}

		created, err := s.Create(r.Context(), app)
		if err != nil {
			if errors.Is(err, store.ErrConflict) {
				writeError(w, r, http.StatusConflict, "app with this id already exists")
				return
			}
			slog.Error("create app failed", "error", err, "request_id", middleware.GetRequestID(r.Context()))
			writeError(w, r, http.StatusInternalServerError, "internal error")
			return
		}
		writeJSON(w, http.StatusCreated, created)
	}
}

func UpdateAppHandler(s store.AppStore) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		id := r.PathValue("id")

		var app model.App
		if err := json.NewDecoder(r.Body).Decode(&app); err != nil {
			var maxBytesErr *http.MaxBytesError
			if errors.As(err, &maxBytesErr) {
				writeError(w, r, http.StatusRequestEntityTooLarge, "request body too large")
				return
			}
			writeError(w, r, http.StatusBadRequest, "invalid JSON body")
			return
		}
		app.ID = id
		if err := app.Validate(); err != nil {
			writeError(w, r, http.StatusBadRequest, err.Error())
			return
		}

		updated, err := s.Update(r.Context(), id, app)
		if err != nil {
			if errors.Is(err, store.ErrNotFound) {
				writeError(w, r, http.StatusNotFound, err.Error())
				return
			}
			slog.Error("update app failed", "error", err, "id", id, "request_id", middleware.GetRequestID(r.Context()))
			writeError(w, r, http.StatusInternalServerError, "internal error")
			return
		}
		writeJSON(w, http.StatusOK, updated)
	}
}

func DeleteAppHandler(s store.AppStore) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		id := r.PathValue("id")
		if err := s.Delete(r.Context(), id); err != nil {
			if errors.Is(err, store.ErrNotFound) {
				writeError(w, r, http.StatusNotFound, err.Error())
				return
			}
			slog.Error("delete app failed", "error", err, "id", id, "request_id", middleware.GetRequestID(r.Context()))
			writeError(w, r, http.StatusInternalServerError, "internal error")
			return
		}
		w.WriteHeader(http.StatusNoContent)
	}
}

func writeJSON(w http.ResponseWriter, status int, v any) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(status)
	json.NewEncoder(w).Encode(v)
}

func writeError(w http.ResponseWriter, r *http.Request, status int, msg string) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(status)
	json.NewEncoder(w).Encode(model.ErrorResponse{
		Error:     msg,
		RequestID: middleware.GetRequestID(r.Context()),
	})
}
