-- name: CreateProject :one 
INSERT INTO projects (name, start_date)
VALUES ($1, $2)
RETURNING *;

-- name: UpdateProjectById :one 
UPDATE projects
SET name = $1, start_date = $2, end_date = $3, updated_at = CURRENT_TIMESTAMP
WHERE id = $4
RETURNING *;
