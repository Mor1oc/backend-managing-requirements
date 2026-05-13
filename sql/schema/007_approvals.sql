-- +goose Up
CREATE TABLE approvals (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    requirement_id UUID NOT NULL,
    version_number INTEGER NOT NULL,
    status_id UUID NOT NULL REFERENCES approval_statuses(id) ON DELETE RESTRICT,
    comment TEXT,
    approver_id UUID REFERENCES users(id),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (requirement_id, version_number)
        REFERENCES requirements(id, version_number)
        ON DELETE CASCADE
);

CREATE INDEX idx_approvals_requirement ON approvals(requirement_id, version_number);
CREATE INDEX idx_approvals_status ON approvals(status_id);
CREATE INDEX idx_approvals_approver ON approvals(approver_id);

-- +goose Down
DROP TABLE IF EXISTS approvals;
