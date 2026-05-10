-- +goose Up
-- Справочник статусов документов
CREATE TABLE document_statuses (
    status_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    status VARCHAR(20) NOT NULL UNIQUE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Справочник статусов требований
CREATE TABLE requirement_statuses (
    status_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    status VARCHAR(20) NOT NULL UNIQUE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Справочник статусов согласований
CREATE TABLE approval_statuses (
    status_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    status VARCHAR(20) NOT NULL UNIQUE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Справочник статусов запросов на изменение
CREATE TABLE change_request_statuses (
    status_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    status VARCHAR(20) NOT NULL UNIQUE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Справочник статусов распоряжений об изменении
CREATE TABLE change_order_statuses (
    status_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    status VARCHAR(20) NOT NULL UNIQUE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Справочник приоритетов запросов на изменение
CREATE TABLE change_request_priorities (
    priority_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    priority VARCHAR(20) NOT NULL UNIQUE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- +goose Down
DROP TABLE IF EXISTS change_request_priorities;
DROP TABLE IF EXISTS change_order_statuses;
DROP TABLE IF EXISTS change_request_statuses;
DROP TABLE IF EXISTS approval_statuses;
DROP TABLE IF EXISTS requirement_statuses;
DROP TABLE IF EXISTS document_statuses;
