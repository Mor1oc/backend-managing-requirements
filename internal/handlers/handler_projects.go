package handlers

import (
	"net/http"
	"time"

	db "github.com/Mor1oc/backend-managing-requirements/internal/database"
	"github.com/jackc/pgx/v5/pgtype"
	"github.com/labstack/echo/v5"
)

func (apiCfg *ApiConfig) HandlerGetAllProjects(c *echo.Context) error {
	rows, err := apiCfg.DB.GetAllProjects(c.Request().Context())
	if err != nil {
		return respondError(c, http.StatusInternalServerError, err)
	}
	return c.JSON(http.StatusOK, rows)
}

type createProjectRequest struct {
	Name      string  `json:"name"       validate:"required"`
	StartDate *string `json:"start_date"` // "2006-01-02"
	EndDate   *string `json:"end_date"`
}

func parseDate(s *string) pgtype.Date {
	if s == nil {
		return pgtype.Date{}
	}
	t, err := time.Parse("2006-01-02", *s)
	if err != nil {
		return pgtype.Date{}
	}
	return pgtype.Date{Time: t, Valid: true}
}

func (apiCfg *ApiConfig) HandlerCreateProject(c *echo.Context) error {
	var req createProjectRequest
	if err := c.Bind(&req); err != nil {
		return respondError(c, http.StatusBadRequest, err)
	}

	row, err := apiCfg.DB.CreateProject(c.Request().Context(), db.CreateProjectParams{
		Name:      req.Name,
		StartDate: parseDate(req.StartDate),
		EndDate:   parseDate(req.EndDate),
	})
	if err != nil {
		return respondError(c, http.StatusInternalServerError, err)
	}
	return c.JSON(http.StatusCreated, row)
}

type updateProjectRequest struct {
	ID        string  `json:"id"         validate:"required,uuid"`
	Name      *string `json:"name"`
	StartDate *string `json:"start_date"`
	EndDate   *string `json:"end_date"`
}

func (apiCfg *ApiConfig) HandlerUpdateProject(c *echo.Context) error {
	var req updateProjectRequest
	if err := c.Bind(&req); err != nil {
		return respondError(c, http.StatusBadRequest, err)
	}

	var uid pgtype.UUID
	if err := uid.Scan(req.ID); err != nil {
		return respondError(c, http.StatusBadRequest, err)
	}

	toNullText := func(s *string) pgtype.Text {
		if s == nil {
			return pgtype.Text{}
		}
		return pgtype.Text{String: *s, Valid: true}
	}

	row, err := apiCfg.DB.UpdateProject(c.Request().Context(), db.UpdateProjectParams{
		ID:        uid,
		Name:      toNullText(req.Name),
		StartDate: parseDate(req.StartDate),
		EndDate:   parseDate(req.EndDate),
	})
	if err != nil {
		return respondError(c, http.StatusInternalServerError, err)
	}
	return c.JSON(http.StatusOK, row)
}

func (apiCfg *ApiConfig) HandlerGetRequirementsByProjectId(c *echo.Context) error {
	var uid pgtype.UUID
	if err := uid.Scan(c.Param("project_id")); err != nil {
		return respondError(c, http.StatusBadRequest, err)
	}

	rows, err := apiCfg.DB.GetRequirementsByProjectId(c.Request().Context(), uid)
	if err != nil {
		return respondError(c, http.StatusInternalServerError, err)
	}
	return c.JSON(http.StatusOK, rows)
}

func (apiCfg *ApiConfig) HandlerGetAllAprovalsByProjectId(c *echo.Context) error {
	var uid pgtype.UUID
	if err := uid.Scan(c.Param("project_id")); err != nil {
		return respondError(c, http.StatusBadRequest, err)
	}

	rows, err := apiCfg.DB.GetApprovalsByProjectId(c.Request().Context(), uid)
	if err != nil {
		return respondError(c, http.StatusInternalServerError, err)
	}
	return c.JSON(http.StatusOK, rows)
}
