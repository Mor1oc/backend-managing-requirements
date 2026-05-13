-- name: GetAllProjects :many
SELECT * FROM projects ORDER BY created_at DESC;

-- name: CreateProject :one
INSERT INTO projects (name, start_date, end_date)
VALUES ($1, $2, $3)
RETURNING *;

-- name: UpdateProject :one
UPDATE projects
SET
    name       = COALESCE(sqlc.narg('name'),       name),
    start_date = COALESCE(sqlc.narg('start_date'), start_date),
    end_date   = COALESCE(sqlc.narg('end_date'),   end_date),
    updated_at = CURRENT_TIMESTAMP
WHERE id = sqlc.arg('id')
RETURNING *;
