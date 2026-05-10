-- +goose Up
-- Заполнение справочников статусов начальными значениями

-- document_statuses
INSERT INTO document_statuses (status_id, status) VALUES
    (gen_random_uuid(), 'draft'),
    (gen_random_uuid(), 'active'),
    (gen_random_uuid(), 'deprecated')
ON CONFLICT (status) DO NOTHING;

-- requirement_statuses
INSERT INTO requirement_statuses (status_id, status) VALUES
    (gen_random_uuid(), 'draft'),
    (gen_random_uuid(), 'approved'),
    (gen_random_uuid(), 'rejected'),
    (gen_random_uuid(), 'obsolete')
ON CONFLICT (status) DO NOTHING;

-- approval_statuses
INSERT INTO approval_statuses (status_id, status) VALUES
    (gen_random_uuid(), 'pending'),
    (gen_random_uuid(), 'approved'),
    (gen_random_uuid(), 'rejected')
ON CONFLICT (status) DO NOTHING;

-- change_request_statuses
INSERT INTO change_request_statuses (status_id, status) VALUES
    (gen_random_uuid(), 'open'),
    (gen_random_uuid(), 'review'),
    (gen_random_uuid(), 'approved'),
    (gen_random_uuid(), 'rejected'),
    (gen_random_uuid(), 'implemented')
ON CONFLICT (status) DO NOTHING;

-- change_order_statuses
INSERT INTO change_order_statuses (status_id, status) VALUES
    (gen_random_uuid(), 'draft'),
    (gen_random_uuid(), 'approved'),
    (gen_random_uuid(), 'executed'),
    (gen_random_uuid(), 'cancelled')
ON CONFLICT (status) DO NOTHING;

-- change_request_priorities
INSERT INTO change_request_priorities (priority_id, priority) VALUES
    (gen_random_uuid(), 'low'),
    (gen_random_uuid(), 'medium'),
    (gen_random_uuid(), 'high'),
    (gen_random_uuid(), 'critical')
ON CONFLICT (priority) DO NOTHING;

-- +goose Down
-- Очистка справочников (осторожно: может нарушить целостность, если есть данные)
TRUNCATE TABLE change_request_priorities RESTART IDENTITY CASCADE;
TRUNCATE TABLE change_order_statuses RESTART IDENTITY CASCADE;
TRUNCATE TABLE change_request_statuses RESTART IDENTITY CASCADE;
TRUNCATE TABLE approval_statuses RESTART IDENTITY CASCADE;
TRUNCATE TABLE requirement_statuses RESTART IDENTITY CASCADE;
TRUNCATE TABLE document_statuses RESTART IDENTITY CASCADE;
