-- +goose Up
INSERT INTO document_statuses (status) VALUES
    ('draft'),
    ('active'),
    ('deprecated')
ON CONFLICT (status) DO NOTHING;

INSERT INTO requirement_statuses (status) VALUES
    ('draft'),
    ('approved'),
    ('rejected'),
    ('obsolete')
ON CONFLICT (status) DO NOTHING;

INSERT INTO approval_statuses (status) VALUES
    ('pending'),
    ('approved'),
    ('rejected')
ON CONFLICT (status) DO NOTHING;

INSERT INTO change_request_statuses (status) VALUES
    ('open'),
    ('review'),
    ('approved'),
    ('rejected'),
    ('implemented')
ON CONFLICT (status) DO NOTHING;

INSERT INTO change_order_statuses (status) VALUES
    ('draft'),
    ('approved'),
    ('executed'),
    ('cancelled')
ON CONFLICT (status) DO NOTHING;

INSERT INTO change_request_priorities (priority) VALUES
    ('low'),
    ('medium'),
    ('high'),
    ('critical')
ON CONFLICT (priority) DO NOTHING;

-- +goose Down
TRUNCATE TABLE change_request_priorities RESTART IDENTITY CASCADE;
TRUNCATE TABLE change_order_statuses RESTART IDENTITY CASCADE;
TRUNCATE TABLE change_request_statuses RESTART IDENTITY CASCADE;
TRUNCATE TABLE approval_statuses RESTART IDENTITY CASCADE;
TRUNCATE TABLE requirement_statuses RESTART IDENTITY CASCADE;
TRUNCATE TABLE document_statuses RESTART IDENTITY CASCADE;
