package handlers

import (
	"net/http"

	"github.com/jackc/pgx/v5/pgtype"
	"github.com/labstack/echo/v5"
)

func (apiCfg *ApiConfig) HandlerGetAllDocuments(c *echo.Context) error {
	rows, err := apiCfg.DB.GetAllDocuments(c.Request().Context())
	if err != nil {
		return respondError(c, http.StatusInternalServerError, err)
	}
	return c.JSON(http.StatusOK, rows)
}

func (apiCfg *ApiConfig) HandlerGetDocumentById(c *echo.Context) error {
	var uid pgtype.UUID
	if err := uid.Scan(c.Param("id")); err != nil {
		return respondError(c, http.StatusBadRequest, err)
	}

	rows, err := apiCfg.DB.GetDocumentById(c.Request().Context(), uid)
	if err != nil {
		return respondError(c, http.StatusInternalServerError, err)
	}
	return c.JSON(http.StatusOK, rows)
}
