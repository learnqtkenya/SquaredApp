package store

import "errors"

// Sentinel errors returned by AppStore implementations.
var (
	ErrNotFound = errors.New("not found")
	ErrConflict = errors.New("conflict")
)
