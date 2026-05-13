package services

import (
	"context"
	"fmt"
	"time"

	db "github.com/Mor1oc/backend-managing-requirements/internal/database"
	"github.com/jackc/pgx/v5/pgtype"
	"github.com/jackc/pgx/v5/pgxpool"
)

type RequirementLink struct {
	RequirementID string `json:"requirement_id"`
	OldVersion    int32  `json:"old_version"`
	NewVersion    int32  `json:"new_version"`
}

type CreateECORequest struct {
	EcrID            string            `json:"ecr_id"       validate:"required,uuid"`
	Title            string            `json:"title"        validate:"required"`
	Justification    string            `json:"justification"`
	AssignedTo       string            `json:"assigned_to"  validate:"required,uuid"`
	EffectiveDate    *string           `json:"effective_date"` // "2006-01-02"
	RequirementLinks []RequirementLink `json:"requirement_links"`
}

func CreateECOrder(ctx context.Context, pool *pgxpool.Pool, req CreateECORequest) (db.ChangeOrder, error) {
	tx, err := pool.Begin(ctx)
	if err != nil {
		return db.ChangeOrder{}, fmt.Errorf("begin tx: %w", err)
	}
	defer tx.Rollback(ctx)

	q := db.New(tx)

	var ecrUID, assignedUID pgtype.UUID
	if err := ecrUID.Scan(req.EcrID); err != nil {
		return db.ChangeOrder{}, err
	}
	if err := assignedUID.Scan(req.AssignedTo); err != nil {
		return db.ChangeOrder{}, err
	}

	effectiveDate := pgtype.Date{}
	if req.EffectiveDate != nil {
		t, err := time.Parse("2006-01-02", *req.EffectiveDate)
		if err == nil {
			effectiveDate = pgtype.Date{Time: t, Valid: true}
		}
	}

	eco, err := q.CreateChangeOrder(ctx, db.CreateChangeOrderParams{
		EcrID:         ecrUID,
		Title:         req.Title,
		Justification: pgtype.Text{String: req.Justification, Valid: req.Justification != ""},
		AssignedTo:    assignedUID,
		EffectiveDate: effectiveDate,
	})
	if err != nil {
		return db.ChangeOrder{}, fmt.Errorf("create change order: %w", err)
	}

	for _, link := range req.RequirementLinks {
		var rUID pgtype.UUID
		if err := rUID.Scan(link.RequirementID); err != nil {
			return db.ChangeOrder{}, fmt.Errorf("invalid requirement_id %s: %w", link.RequirementID, err)
		}
		if err := q.CreateEcoRequirementLink(ctx, db.CreateEcoRequirementLinkParams{
			ID:            eco.ID,
			RequirementID: rUID,
			OldVersion:    link.OldVersion,
			NewVersion:    link.NewVersion,
		}); err != nil {
			return db.ChangeOrder{}, fmt.Errorf("link requirement: %w", err)
		}
	}

	if err := tx.Commit(ctx); err != nil {
		return db.ChangeOrder{}, fmt.Errorf("commit tx: %w", err)
	}

	return eco, nil
}
