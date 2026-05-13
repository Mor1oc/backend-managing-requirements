-- name: GetAllDocuments :many
SELECT d.id, d.version_number, d.external_ref, d.title, d.description,
       d.is_external, d.file_path, d.uploaded_at,
       dt.type_code,
       ds.status,
       u.full_name AS uploaded_by_name
FROM documents d
JOIN document_types   dt ON d.type_id     = dt.id
JOIN document_statuses ds ON d.status_id  = ds.id
JOIN users             u  ON d.uploaded_by = u.id
ORDER BY d.uploaded_at DESC;

-- name: GetDocumentById :many
SELECT d.id, d.version_number, d.external_ref, d.title, d.description,
       d.is_external, d.file_path, d.uploaded_at,
       dt.type_code,
       ds.status,
       u.full_name AS uploaded_by_name
FROM documents d
JOIN document_types    dt ON d.type_id     = dt.id
JOIN document_statuses ds ON d.status_id  = ds.id
JOIN users              u  ON d.uploaded_by = u.id
WHERE d.id = $1
ORDER BY d.version_number;
