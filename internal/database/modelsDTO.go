package database

import (
	"time"

	"github.com/google/uuid"
)

type ApprovalDTO struct {
	ID            uuid.UUID
	Requirement   RequirementDTO
	VersionNumber int32
	Status        string
	Comment       string
	RequestedAt   time.Time
	RespondedAt   time.Time
}

type ChangeOrderDTO struct {
	ID            uuid.UUID
	Ecr           ChangeRequestDTO
	Title         string
	Justification string
	AssignedTo    string // ФИО пользователя
	Status        string
	EffectiveDate time.Time
	CreatedAt     time.Time
}

type ChangeRequestDTO struct {
	ID          uuid.UUID
	Title       string
	Description string
	Requester   string // ФИО пользователя
	Project     string // название проекта
	Status      string
	Priority    string
	CreatedAt   time.Time
	ResolvedAt  time.Time
}

type DocumentDTO struct {
	ID            uuid.UUID
	ExternalRef   string
	Title         string
	Description   string
	Type          string
	IsExternal    bool
	VersionNumber int32
	FilePath      string
	UploadedBy    string
	UploadedAt    time.Time
	Status        string
}

type ProjectDTO struct {
	ID        uuid.UUID
	Name      string
	StartDate time.Time
	EndDate   time.Time
	CreatedAt time.Time
	UpdatedAt time.Time
}

type RequirementDTO struct {
	ID                    uuid.UUID
	ExternalID            string
	Type                  string
	ParentVersion         int32
	CreatedBy             string // ФИО пользователя
	CreatedAt             time.Time
	VersionNumber         int32
	Title                 string
	Description           string
	SourceDocumentID      string // Название документа
	SourceDocumentVersion int32
	SourceClause          string
	Status                string
	IsBaseline            bool
	ChangeReason          string
	ChangedBy             string // ФИО пользователя
	ChangedAt             time.Time
}

type UserDTO struct {
	ID           uuid.UUID
	PasswordHash string
	FullName     string
	Email        string
	Department   string
	Position     string
	IsSupervisor bool
	CreatedAt    time.Time
	UpdatedAt    time.Time
}
