-- +goose Up
CREATE TABLE documents (
    id UUID NOT NULL,
    external_ref VARCHAR(100),
    title TEXT NOT NULL,
    description TEXT,
    type_id UUID NOT NULL REFERENCES document_types(id) ON DELETE RESTRICT,
    is_external BOOLEAN DEFAULT TRUE,
    version_number INTEGER NOT NULL DEFAULT 1,
    file_path TEXT,
    uploaded_by UUID NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
    uploaded_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    status_id UUID NOT NULL REFERENCES document_statuses(id) ON DELETE RESTRICT,
    PRIMARY KEY (id, version_number)
);

CREATE TABLE document_projects (
    id UUID NOT NULL,
    document_version INTEGER NOT NULL,
    project_id UUID NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
    PRIMARY KEY (id, document_version, project_id),
    FOREIGN KEY (id, document_version)
        REFERENCES documents(id, version_number)
        ON DELETE CASCADE
);

CREATE INDEX idx_documents_uploaded_by ON documents(uploaded_by);
CREATE INDEX idx_documents_status ON documents(id);
CREATE INDEX idx_document_projects_project ON document_projects(id);

-- +goose Down
DROP TABLE IF EXISTS document_projects;
DROP TABLE IF EXISTS documents;
