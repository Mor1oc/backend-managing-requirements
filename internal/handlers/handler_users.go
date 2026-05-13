package handlers

import (
	"net/http"

	db "github.com/Mor1oc/backend-managing-requirements/internal/database"
	"github.com/jackc/pgx/v5/pgtype"
	"github.com/labstack/echo/v5"
)

type createUserRequest struct {
	PasswordHash string `json:"password_hash" validate:"required"`
	FullName     string `json:"full_name"      validate:"required"`
	Email        string `json:"email"          validate:"required,email"`
	Department   string `json:"department"`
	Position     string `json:"position"`
	IsSupervisor bool   `json:"is_supervisor"`
}

func (apiCfg *ApiConfig) HandlerCreateUser(c *echo.Context) error {
	var req createUserRequest
	if err := c.Bind(&req); err != nil {
		return respondError(c, http.StatusBadRequest, err)
	}

	user, err := apiCfg.DB.CreateUser(c.Request().Context(), db.CreateUserParams{
		PasswordHash: req.PasswordHash,
		FullName:     req.FullName,
		Email:        req.Email,
		Department:   pgtype.Text{String: req.Department, Valid: req.Department != ""},
		Position:     pgtype.Text{String: req.Position, Valid: req.Position != ""},
		IsSupervisor: req.IsSupervisor,
	})
	if err != nil {
		return respondError(c, http.StatusInternalServerError, err)
	}

	return c.JSON(http.StatusCreated, user)
}

type updateUserRequest struct {
	ID           string  `json:"id"            validate:"required,uuid"`
	PasswordHash *string `json:"password_hash"`
	FullName     *string `json:"full_name"`
	Email        *string `json:"email"`
	Department   *string `json:"department"`
	Position     *string `json:"position"`
	IsSupervisor *bool   `json:"is_supervisor"`
}

func (apiCfg *ApiConfig) HandlerUpdateUser(c *echo.Context) error {
	var req updateUserRequest
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
	toNullBool := func(b *bool) pgtype.Bool {
		if b == nil {
			return pgtype.Bool{}
		}
		return pgtype.Bool{Bool: *b, Valid: true}
	}

	user, err := apiCfg.DB.UpdateUser(c.Request().Context(), db.UpdateUserParams{
		ID:           uid,
		PasswordHash: toNullText(req.PasswordHash),
		FullName:     toNullText(req.FullName),
		Email:        toNullText(req.Email),
		Department:   toNullText(req.Department),
		Position:     toNullText(req.Position),
		IsSupervisor: toNullBool(req.IsSupervisor),
	})
	if err != nil {
		return respondError(c, http.StatusInternalServerError, err)
	}

	return c.JSON(http.StatusOK, user)
}
