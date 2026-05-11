-- +goose Up
CREATE TABLE change_requests (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title TEXT NOT NULL,
    description TEXT,
    requester_id UUID NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
    project_id UUID NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
    status_id UUID NOT NULL REFERENCES change_request_statuses(id) ON DELETE RESTRICT,
    priority_id UUID NOT NULL REFERENCES change_request_priorities(id) ON DELETE RESTRICT,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    resolved_at TIMESTAMP
);

CREATE TABLE change_request_requirements (
    id UUID NOT NULL,
    requirement_id UUID NOT NULL,
    version_number INTEGER NOT NULL,
    PRIMARY KEY (id, requirement_id, version_number),
    FOREIGN KEY (ecr_id)
        REFERENCES change_requests(id)
        ON DELETE CASCADE,
    FOREIGN KEY (requirement_id, version_number)
        REFERENCES requirements(id, version_number)
        ON DELETE RESTRICT
);

CREATE INDEX idx_change_requests_project ON change_requests(project_id);
CREATE INDEX idx_change_requests_status ON change_requests(status_id);
CREATE INDEX idx_change_requests_priority ON change_requests(priority_id);
CREATE INDEX idx_crr_requirement ON change_request_requirements(requirement_id, version_number);

-- +goose Down
DROP TABLE IF EXISTS change_request_requirements;
DROP TABLE IF EXISTS change_requests;
