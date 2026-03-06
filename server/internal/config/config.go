package config

import (
	"fmt"
	"os"
	"strconv"

	"github.com/joho/godotenv"
)

type Config struct {
	Port           string
	DatabaseURL    string
	MigrationsPath string
	AllowedOrigins string
	SecretsKey     string
	LogLevel       string
	RateLimit      float64
	RateBurst      int
}

func Load() (Config, error) {
	_ = godotenv.Load()

	cfg := Config{
		Port:           getEnv("PORT", "8080"),
		DatabaseURL:    getEnv("DATABASE_URL", "postgres://squared:squared@db:5432/squared?sslmode=disable"),
		MigrationsPath: getEnv("MIGRATIONS_PATH", "file://migrations"),
		AllowedOrigins: getEnv("ALLOWED_ORIGINS", "*"),
		SecretsKey:     os.Getenv("SECRETS_KEY"),
		LogLevel:       getEnv("LOG_LEVEL", "info"),
	}

	rl, err := strconv.ParseFloat(getEnv("RATE_LIMIT", "10"), 64)
	if err != nil {
		return Config{}, fmt.Errorf("invalid RATE_LIMIT: %w", err)
	}
	cfg.RateLimit = rl

	rb, err := strconv.Atoi(getEnv("RATE_BURST", "20"))
	if err != nil {
		return Config{}, fmt.Errorf("invalid RATE_BURST: %w", err)
	}
	cfg.RateBurst = rb

	if err := cfg.validate(); err != nil {
		return Config{}, err
	}
	return cfg, nil
}

func (c Config) validate() error {
	if c.DatabaseURL == "" {
		return fmt.Errorf("DATABASE_URL is required")
	}
	if c.Port == "" {
		return fmt.Errorf("PORT is required")
	}
	if _, err := strconv.Atoi(c.Port); err != nil {
		return fmt.Errorf("PORT must be a number: %w", err)
	}
	switch c.LogLevel {
	case "debug", "info", "warn", "error":
	default:
		return fmt.Errorf("LOG_LEVEL must be one of: debug, info, warn, error")
	}
	if c.RateLimit <= 0 {
		return fmt.Errorf("RATE_LIMIT must be positive")
	}
	if c.RateBurst <= 0 {
		return fmt.Errorf("RATE_BURST must be positive")
	}
	return nil
}

func getEnv(key, fallback string) string {
	if v := os.Getenv(key); v != "" {
		return v
	}
	return fallback
}
