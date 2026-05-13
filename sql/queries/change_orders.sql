-- name: GetAllChangeOrders :many
SELECT co.id, co.title, co.justification, co.effective_date, co.created_at,
       cos.status,
       u.full_name  AS assigned_to_name,
       cr.title     AS ecr_title
FROM change_orders co
JOIN change_order_statuses cos ON co.status_id  = cos.id
JOIN users                 u   ON co.assigned_to = u.id
JOIN change_requests       cr  ON co.ecr_id      = cr.id
ORDER BY co.created_at DESC;

-- name: GetChangeOrderById :one
SELECT co.id, co.title, co.justification, co.effective_date, co.created_at,
       cos.status,
       u.full_name AS assigned_to_name,
       cr.title    AS ecr_title
FROM change_orders co
JOIN change_order_statuses cos ON co.status_id  = cos.id
JOIN users                 u   ON co.assigned_to = u.id
JOIN change_requests       cr  ON co.ecr_id      = cr.id
WHERE co.id = $1;

-- name: CreateChangeOrder :one
INSERT INTO change_orders (ecr_id, title, justification, assigned_to, status_id, effective_date)
VALUES (
    $1, $2, $3, $4,
    (SELECT id FROM change_order_statuses WHERE status = 'draft'),
    $5
)
RETURNING *;

-- name: UpdateChangeOrderStatus :one
UPDATE change_orders co
SET co.status_id = (SELECT id FROM change_order_statuses WHERE status = $2)
WHERE co.id = $1
RETURNING *;

-- name: CreateEcoRequirementLink :exec
INSERT INTO eco_requirement_links (id, requirement_id, old_version, new_version)
VALUES ($1, $2, $3, $4);
