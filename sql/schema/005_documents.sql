-- +goose Up
-- Документы (с версионированием)
CREATE TABLE documents (
    document_id UUID NOT NULL,
    external_ref VARCHAR(100),
    title TEXT NOT NULL,
    description TEXT,
    type_id UUID NOT NULL REFERENCES document_types(type_id) ON DELETE RESTRICT,
    is_external BOOLEAN DEFAULT TRUE,
    version_number INTEGER NOT NULL DEFAULT 1,
    file_path TEXT,
    uploaded_by UUID NOT NULL REFERENCES users(user_id) ON DELETE RESTRICT,
    uploaded_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    status_id UUID NOT NULL REFERENCES document_statuses(status_id) ON DELETE RESTRICT,
    PRIMARY KEY (document_id, version_number)
);

-- Связь документов и проектов (многие-ко-многим)
CREATE TABLE document_projects (
    document_id UUID NOT NULL,
    document_version INTEGER NOT NULL,
    project_id UUID NOT NULL REFERENCES projects(project_id) ON DELETE CASCADE,
    PRIMARY KEY (document_id, document_version, project_id),
    FOREIGN KEY (document_id, document_version)
        REFERENCES documents(document_id, version_number)
        ON DELETE CASCADE
);

-- Индексы для ускорения поиска
CREATE INDEX idx_documents_uploaded_by ON documents(uploaded_by);
CREATE INDEX idx_documents_status ON documents(status_id);
CREATE INDEX idx_document_projects_project ON document_projects(project_id);

-- +goose Down
DROP TABLE IF EXISTS document_projects;
DROP TABLE IF EXISTS documents;
