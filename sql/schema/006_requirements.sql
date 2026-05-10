-- +goose Up
-- Требования 
CREATE TABLE requirements (
    requirement_id UUID NOT NULL,
    external_id VARCHAR(50),
    project_id UUID NOT NULL REFERENCES projects(project_id) ON DELETE CASCADE,
    type_id UUID NOT NULL REFERENCES requirement_types(type_id) ON DELETE RESTRICT,
    parent_version INTEGER,
    created_by UUID NOT NULL REFERENCES users(user_id) ON DELETE RESTRICT,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    version_number INTEGER NOT NULL DEFAULT 1,
    title TEXT NOT NULL,
    description TEXT,
    source_document_id UUID,
    source_document_version INTEGER,
    source_clause TEXT,
    status_id UUID NOT NULL REFERENCES requirement_statuses(status_id) ON DELETE RESTRICT,
    is_baseline BOOLEAN DEFAULT FALSE,
    change_reason TEXT,
    changed_by UUID NOT NULL REFERENCES users(user_id) ON DELETE RESTRICT,
    changed_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (requirement_id, version_number),
    FOREIGN KEY (source_document_id, source_document_version)
        REFERENCES documents(document_id, version_number)
        ON DELETE SET NULL
);

-- Индексы для ускорения поиска
CREATE INDEX idx_requirements_project ON requirements(project_id);
CREATE INDEX idx_requirements_status ON requirements(status_id);
CREATE INDEX idx_requirements_parent ON requirements(parent_version);
CREATE INDEX idx_requirements_source_doc ON requirements(source_document_id, source_document_version);

-- +goose Down
DROP TABLE IF EXISTS requirements;
