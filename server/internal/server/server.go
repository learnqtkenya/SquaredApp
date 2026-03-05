package server

import (
	"context"
	"log/slog"
	"net/http"
	"time"

	"github.com/jackc/pgx/v5/pgxpool"
	"squared-store/internal/config"
	"squared-store/internal/handler"
	"squared-store/internal/middleware"
	"squared-store/internal/store"
)

type Server struct {
	httpServer *http.Server
}

func New(cfg config.Config, appStore store.AppStore, pool *pgxpool.Pool) *Server {
	mux := http.NewServeMux()

	// Health probes
	mux.HandleFunc("GET /healthz", handler.LivenessHandler())
	mux.HandleFunc("GET /readyz", handler.ReadinessHandler(pool))
	mux.HandleFunc("GET /health", handler.ReadinessHandler(pool)) // backwards compat

	// API routes
	mux.HandleFunc("GET /api/catalog", handler.CatalogHandler(appStore))
	mux.HandleFunc("GET /api/apps", handler.ListAppsHandler(appStore))
	mux.HandleFunc("GET /api/apps/{id}/secrets", handler.GetSecretsHandler(appStore))
	mux.HandleFunc("PUT /api/apps/{id}/secrets", handler.SetSecretsHandler(appStore))
	mux.HandleFunc("GET /api/apps/{id...}", handler.GetAppHandler(appStore))
	mux.HandleFunc("POST /api/apps", handler.CreateAppHandler(appStore))
	mux.HandleFunc("PUT /api/apps/{id...}", handler.UpdateAppHandler(appStore))
	mux.HandleFunc("DELETE /api/apps/{id...}", handler.DeleteAppHandler(appStore))

	// Middleware chain (outermost executes first)
	var h http.Handler = mux
	h = middleware.BodyLimit(1 << 20)(h)                     // 1 MB body limit
	h = middleware.CORS(cfg.AllowedOrigins)(h)
	h = middleware.SecurityHeaders(h)
	h = middleware.RateLimit(cfg.RateLimit, cfg.RateBurst)(h)
	h = middleware.Logging(h)
	h = middleware.RequestID(h)
	h = middleware.Recovery(h)

	return &Server{
		httpServer: &http.Server{
			Addr:              ":" + cfg.Port,
			Handler:           h,
			ReadTimeout:       15 * time.Second,
			ReadHeaderTimeout: 5 * time.Second,
			WriteTimeout:      15 * time.Second,
			IdleTimeout:       60 * time.Second,
		},
	}
}

func (s *Server) ListenAndServe() error {
	slog.Info("server starting", "addr", s.httpServer.Addr)
	return s.httpServer.ListenAndServe()
}

func (s *Server) Shutdown(ctx context.Context) error {
	slog.Info("server shutting down")
	return s.httpServer.Shutdown(ctx)
}
