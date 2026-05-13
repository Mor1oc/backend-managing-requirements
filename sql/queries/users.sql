-- name: CreateUser :one
INSERT INTO users (password_hash, full_name, email, department, position, is_supervisor)
VALUES ($1, $2, $3, $4, $5, $6)
RETURNING *;

-- name: UpdateUser :one
UPDATE users
SET
    password_hash = COALESCE(sqlc.narg('password_hash'), password_hash),
    full_name     = COALESCE(sqlc.narg('full_name'),     full_name),
    email         = COALESCE(sqlc.narg('email'),         email),
    department    = COALESCE(sqlc.narg('department'),    department),
    position      = COALESCE(sqlc.narg('position'),      position),
    is_supervisor = COALESCE(sqlc.narg('is_supervisor'), is_supervisor),
    updated_at    = CURRENT_TIMESTAMP
WHERE id = sqlc.arg('id')
RETURNING *;
