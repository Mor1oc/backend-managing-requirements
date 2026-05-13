-- name: GetAllApprovals :many
SELECT a.id, a.requirement_id, a.version_number, a.comment, a.created_at,
       aps.status,
       r.title       AS requirement_title,
       u.full_name   AS approver_name
FROM approvals a
JOIN approval_statuses aps ON a.status_id      = aps.id
JOIN requirements      r   ON a.requirement_id = r.id
                           AND a.version_number = r.version_number
LEFT JOIN users        u   ON a.approver_id    = u.id
ORDER BY a.created_at DESC;

-- name: GetApprovalsByProjectId :many
SELECT a.id, a.requirement_id, a.version_number, a.comment, a.created_at,
       aps.status,
       r.title     AS requirement_title,
       u.full_name AS approver_name
FROM approvals a
JOIN approval_statuses aps ON a.status_id      = aps.id
JOIN requirements      r   ON a.requirement_id = r.id
                           AND a.version_number = r.version_number
LEFT JOIN users        u   ON a.approver_id    = u.id
WHERE r.project_id = $1
ORDER BY a.created_at DESC;

-- name: CreateApproval :one
INSERT INTO approvals (requirement_id, version_number, status_id, comment, approver_id)
VALUES (
    $1, $2,
    (SELECT id FROM approval_statuses WHERE status = 'pending'),
    $3, $4
)
RETURNING *;

-- name: UpdateApproval :one
UPDATE approvals
SET
    status_id   = (SELECT id FROM approval_statuses WHERE status = sqlc.arg('status')),
    comment     = COALESCE(sqlc.narg('comment'),     comment),
    approver_id = COALESCE(sqlc.narg('approver_id'), approver_id)
WHERE requirement_id = sqlc.arg('requirement_id')
  AND version_number = sqlc.arg('version_number')
RETURNING *;
