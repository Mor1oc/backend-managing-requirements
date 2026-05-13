package handlers

import (
	"net/http"

	db "github.com/Mor1oc/backend-managing-requirements/internal/database"
	"github.com/Mor1oc/backend-managing-requirements/internal/services"
	"github.com/jackc/pgx/v5/pgtype"
	"github.com/labstack/echo/v5"
)

func (apiCfg *ApiConfig) HandlerGetAllEcr(c *echo.Context) error {
	rows, err := apiCfg.DB.GetAllChangeRequests(c.Request().Context())
	if err != nil {
		return respondError(c, http.StatusInternalServerError, err)
	}
	return c.JSON(http.StatusOK, rows)
}

type createECRRequest struct {
	Title            string `json:"title"        validate:"required"`
	Description      string `json:"description"`
	RequesterID      string `json:"requester_id" validate:"required,uuid"`
	ProjectID        string `json:"project_id"   validate:"required,uuid"`
	Priority         string `json:"priority"     validate:"required"`
	RequirementLinks []struct {
		RequirementID string `json:"requirement_id"`
		VersionNumber int32  `json:"version_number"`
	} `json:"requirement_links"`
}

func (apiCfg *ApiConfig) HandleCreateECRequest(c *echo.Context) error {
	var req createECRRequest
	if err := c.Bind(&req); err != nil {
		return respondError(c, http.StatusBadRequest, err)
	}

	var requesterUID, projectUID pgtype.UUID
	if err := requesterUID.Scan(req.RequesterID); err != nil {
		return respondError(c, http.StatusBadRequest, err)
	}
	if err := projectUID.Scan(req.ProjectID); err != nil {
		return respondError(c, http.StatusBadRequest, err)
	}

	ctx := c.Request().Context()
	ecr, err := apiCfg.DB.CreateChangeRequest(ctx, db.CreateChangeRequestParams{
		Title:       req.Title,
		Description: pgtype.Text{String: req.Description, Valid: req.Description != ""},
		RequesterID: requesterUID,
		ProjectID:   projectUID,
		Priority:    req.Priority,
	})
	if err != nil {
		return respondError(c, http.StatusInternalServerError, err)
	}

	for _, link := range req.RequirementLinks {
		var rUID pgtype.UUID
		if err := rUID.Scan(link.RequirementID); err != nil {
			continue
		}
		_ = apiCfg.DB.LinkRequirementToChangeRequest(ctx, db.LinkRequirementToChangeRequestParams{
			ID:            ecr.ID,
			RequirementID: rUID,
			VersionNumber: link.VersionNumber,
		})
	}

	return c.JSON(http.StatusCreated, ecr)
}

// HandleCreateECOrder — создаёт change_order + eco_requirement_links в транзакции
func (apiCfg *ApiConfig) HandleCreateECOrder(c *echo.Context) error {
	var req services.CreateECORequest
	if err := c.Bind(&req); err != nil {
		return respondError(c, http.StatusBadRequest, err)
	}

	eco, err := services.CreateECOrder(c.Request().Context(), apiCfg.Pool, req)
	if err != nil {
		return respondError(c, http.StatusInternalServerError, err)
	}
	return c.JSON(http.StatusCreated, eco)
}

type updateECRStatusRequest struct {
	Status string `json:"status" validate:"required"`
}

func (apiCfg *ApiConfig) HandlerUpdateStatusEcr(c *echo.Context) error {
	var uid pgtype.UUID
	if err := uid.Scan(c.Param("id")); err != nil {
		return respondError(c, http.StatusBadRequest, err)
	}

	var req updateECRStatusRequest
	if err := c.Bind(&req); err != nil {
		return respondError(c, http.StatusBadRequest, err)
	}

	row, err := apiCfg.DB.UpdateChangeRequestStatus(c.Request().Context(), db.UpdateChangeRequestStatusParams{
		ID:     uid,
		Status: req.Status,
	})
	if err != nil {
		return respondError(c, http.StatusInternalServerError, err)
	}
	return c.JSON(http.StatusOK, row)
}
