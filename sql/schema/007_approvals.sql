-- +goose Up
CREATE TABLE approvals (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    requirement_id UUID NOT NULL,
    version_number INTEGER NOT NULL,
    status_id UUID NOT NULL REFERENCES approval_statuses(status_id) ON DELETE RESTRICT,
    comment TEXT,
    requested_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    responded_at TIMESTAMP,
    FOREIGN KEY (requirement_id, version_number)
        REFERENCES requirements(id, version_number)
        ON DELETE CASCADE
);

CREATE INDEX idx_approvals_requirement ON approvals(requirement_id, version_number);
CREATE INDEX idx_approvals_status ON approvals(status_id);

-- +goose Down
DROP TABLE IF EXISTS approvals;
