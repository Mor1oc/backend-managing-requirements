package handlers

import (
	"github.com/Mor1oc/backend-managing-requirements/internal/database"
	"github.com/jackc/pgx/v5/pgxpool"
	"github.com/labstack/echo/v5"
)

type ApiConfig struct {
	DB   *database.Queries
	Pool *pgxpool.Pool
}

func respondError(c *echo.Context, code int, err error) error {
	return c.JSON(code, map[string]string{"error": err.Error()})
}
