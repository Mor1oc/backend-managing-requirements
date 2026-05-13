package handlers

import (
	"net/http"

	db "github.com/Mor1oc/backend-managing-requirements/internal/database"
	"github.com/jackc/pgx/v5/pgtype"
	"github.com/labstack/echo/v5"
)

func (apiCfg *ApiConfig) HandlerGetAllEco(c *echo.Context) error {
	rows, err := apiCfg.DB.GetAllChangeOrders(c.Request().Context())
	if err != nil {
		return respondError(c, http.StatusInternalServerError, err)
	}
	return c.JSON(http.StatusOK, rows)
}

func (apiCfg *ApiConfig) HandlerGetEcoById(c *echo.Context) error {
	var uid pgtype.UUID
	if err := uid.Scan(c.Param("id")); err != nil {
		return respondError(c, http.StatusBadRequest, err)
	}

	row, err := apiCfg.DB.GetChangeOrderById(c.Request().Context(), uid)
	if err != nil {
		return respondError(c, http.StatusInternalServerError, err)
	}
	return c.JSON(http.StatusOK, row)
}

type updateECOStatusRequest struct {
	Status string `json:"status" validate:"required"`
}

func (apiCfg *ApiConfig) HandlerUpdateStatusEco(c *echo.Context) error {
	var uid pgtype.UUID
	if err := uid.Scan(c.Param("id")); err != nil {
		return respondError(c, http.StatusBadRequest, err)
	}

	var req updateECOStatusRequest
	if err := c.Bind(&req); err != nil {
		return respondError(c, http.StatusBadRequest, err)
	}

	row, err := apiCfg.DB.UpdateChangeOrderStatus(c.Request().Context(), db.UpdateChangeOrderStatusParams{
		ID:     uid,
		Status: req.Status,
	})
	if err != nil {
		return respondError(c, http.StatusInternalServerError, err)
	}
	return c.JSON(http.StatusOK, row)
}
