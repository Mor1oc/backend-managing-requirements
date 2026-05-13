package handlers

import (
	"net/http"

	db "github.com/Mor1oc/backend-managing-requirements/internal/database"
	"github.com/jackc/pgx/v5/pgtype"
	"github.com/labstack/echo/v5"
)

func (apiCfg *ApiConfig) HandlerGetAllAprovals(c *echo.Context) error {
	rows, err := apiCfg.DB.GetAllApprovals(c.Request().Context())
	if err != nil {
		return respondError(c, http.StatusInternalServerError, err)
	}
	return c.JSON(http.StatusOK, rows)
}

type createApprovalRequest struct {
	VersionNumber int32   `json:"version_number" validate:"required"`
	Comment       string  `json:"comment"`
	ApproverID    *string `json:"approver_id"`
}

func (apiCfg *ApiConfig) HandlerCreateAproval(c *echo.Context) error {
	var reqUID pgtype.UUID
	if err := reqUID.Scan(c.Param("requirement_id")); err != nil {
		return respondError(c, http.StatusBadRequest, err)
	}

	var req createApprovalRequest
	if err := c.Bind(&req); err != nil {
		return respondError(c, http.StatusBadRequest, err)
	}

	approverID := pgtype.UUID{}
	if req.ApproverID != nil {
		if err := approverID.Scan(*req.ApproverID); err != nil {
			return respondError(c, http.StatusBadRequest, err)
		}
	}

	row, err := apiCfg.DB.CreateApproval(c.Request().Context(), db.CreateApprovalParams{
		RequirementID: reqUID,
		VersionNumber: req.VersionNumber,
		Comment:       pgtype.Text{String: req.Comment, Valid: req.Comment != ""},
		ApproverID:    approverID,
	})
	if err != nil {
		return respondError(c, http.StatusInternalServerError, err)
	}
	return c.JSON(http.StatusCreated, row)
}

type updateApprovalRequest struct {
	VersionNumber int32   `json:"version_number" validate:"required"`
	Status        string  `json:"status"         validate:"required"`
	Comment       *string `json:"comment"`
	ApproverID    *string `json:"approver_id"`
}

func (apiCfg *ApiConfig) HandlerUpdateAproval(c *echo.Context) error {
	var reqUID pgtype.UUID
	if err := reqUID.Scan(c.Param("requirement_id")); err != nil {
		return respondError(c, http.StatusBadRequest, err)
	}

	var req updateApprovalRequest
	if err := c.Bind(&req); err != nil {
		return respondError(c, http.StatusBadRequest, err)
	}

	approverID := pgtype.UUID{}
	if req.ApproverID != nil {
		if err := approverID.Scan(*req.ApproverID); err != nil {
			return respondError(c, http.StatusBadRequest, err)
		}
	}

	comment := pgtype.Text{}
	if req.Comment != nil {
		comment = pgtype.Text{String: *req.Comment, Valid: true}
	}

	row, err := apiCfg.DB.UpdateApproval(c.Request().Context(), db.UpdateApprovalParams{
		RequirementID: reqUID,
		VersionNumber: req.VersionNumber,
		Status:        req.Status,
		Comment:       comment,
		ApproverID:    approverID,
	})
	if err != nil {
		return respondError(c, http.StatusInternalServerError, err)
	}
	return c.JSON(http.StatusOK, row)
}
