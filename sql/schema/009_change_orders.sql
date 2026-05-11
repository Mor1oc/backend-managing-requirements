-- +goose Up
CREATE TABLE change_orders (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    ecr_id UUID NOT NULL REFERENCES change_requests(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    justification TEXT,
    assigned_to UUID NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
    status_id UUID NOT NULL REFERENCES change_order_statuses(id) ON DELETE RESTRICT,
    effective_date DATE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE eco_requirement_links (
    id UUID NOT NULL REFERENCES change_orders(id) ON DELETE CASCADE,
    requirement_id UUID NOT NULL,
    old_version INTEGER NOT NULL,
    new_version INTEGER NOT NULL,
    PRIMARY KEY (id, requirement_id, old_version),
    FOREIGN KEY (requirement_id, old_version)
        REFERENCES requirements(id, version_number)
        ON DELETE RESTRICT,
    FOREIGN KEY (requirement_id, new_version)
        REFERENCES requirements(id, version_number)
        ON DELETE RESTRICT
);

CREATE INDEX idx_change_orders_ecr ON change_orders(ecr_id);
CREATE INDEX idx_change_orders_status ON change_orders(status_id);
CREATE INDEX idx_change_orders_assigned ON change_orders(assigned_to);
CREATE INDEX idx_erl_requirement ON eco_requirement_links(requirement_id, old_version);

-- +goose Down
DROP TABLE IF EXISTS eco_requirement_links;
DROP TABLE IF EXISTS change_orders;
