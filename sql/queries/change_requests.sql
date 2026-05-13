-- name: GetAllChangeRequests :many
SELECT cr.id, cr.title, cr.description, cr.created_at, cr.resolved_at,
       crs.status,
       crp.priority,
       u.full_name AS requester_name,
       p.name      AS project_name
FROM change_requests cr
JOIN change_request_statuses   crs ON cr.status_id   = crs.id
JOIN change_request_priorities crp ON cr.priority_id = crp.id
JOIN users    u ON cr.requester_id = u.id
JOIN projects p ON cr.project_id   = p.id
ORDER BY cr.created_at DESC;

-- name: CreateChangeRequest :one
INSERT INTO change_requests (title, description, requester_id, project_id, status_id, priority_id)
VALUES (
    $1, $2, $3, $4,
    (SELECT id FROM change_request_statuses   WHERE status   = 'open'),
    (SELECT id FROM change_request_priorities WHERE priority = $5)
)
RETURNING *;

-- name: UpdateChangeRequestStatus :one
UPDATE change_requests cr
SET
    cr.status_id   = (SELECT id FROM change_request_statuses WHERE status = $2),
    cr.resolved_at = CASE
                    WHEN $2 IN ('approved','rejected','implemented')
                    THEN CURRENT_TIMESTAMP
                    ELSE resolved_at
                  END
WHERE cr.id = $1
RETURNING *;

-- name: LinkRequirementToChangeRequest :exec
INSERT INTO change_request_requirements (id, requirement_id, version_number)
VALUES ($1, $2, $3)
ON CONFLICT DO NOTHING;
