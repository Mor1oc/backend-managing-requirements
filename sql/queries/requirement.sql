-- name: GetRequirementsByProjectId :many 
SELECT 
    r.id,
    r.external_id,
    rt.name AS type,
    parent.version_number AS parent_version,
    creator.full_name AS created_by,
    r.created_at,
    r.version_number,
    r.title,
    r.description,
    d.title AS source_document_name,
    COALESCE(r.source_document_version, d.version_number) AS source_document_version,
    r.source_clause,
    rs.status AS status,
    r.is_baseline,
    r.change_reason,
    changer.full_name AS changed_by,
    r.changed_at
FROM requirements r
LEFT JOIN users creator ON r.created_by = creator.id
LEFT JOIN users changer ON r.changed_by = changer.id
LEFT JOIN requirement_types rt ON r.type_id = rt.id
LEFT JOIN requirement_statuses rs ON r.status_id = rs.id
LEFT JOIN documents d ON r.source_document_id = d.id
LEFT JOIN requirements parent ON r.parent_id = parent.id
WHERE r.project_id = $1
ORDER BY r.created_at, r.version_number DESC;

-- name: GetAllRequirements :many 
SELECT 
    r.id,
    r.external_id,
    rt.name AS type,
    parent.version_number AS parent_version,
    creator.full_name AS created_by,
    r.created_at,
    r.version_number,
    r.title,
    r.description,
    d.title AS source_document_name,
    COALESCE(r.source_document_version, d.version_number) AS source_document_version,
    r.source_clause,
    rs.status AS status,
    r.is_baseline,
    r.change_reason,
    changer.full_name AS changed_by,
    r.changed_at
FROM requirements r
LEFT JOIN users creator ON r.created_by = creator.id
LEFT JOIN users changer ON r.changed_by = changer.id
LEFT JOIN requirement_types rt ON r.type_id = rt.id
LEFT JOIN requirement_statuses rs ON r.status_id = rs.id
LEFT JOIN documents d ON r.source_document_id = d.id
LEFT JOIN requirements parent ON r.parent_id = parent.id;

-- name: GetAllRequirementVersions :many
SELECT 
    r.id,
    r.external_id,
    rt.name AS type,
    parent.version_number AS parent_version,
    creator.full_name AS created_by,
    r.created_at,
    r.version_number,
    r.title,
    r.description,
    d.title AS source_document_name,
    COALESCE(r.source_document_version, d.version_number) AS source_document_version,
    r.source_clause,
    rs.status AS status,
    r.is_baseline,
    r.change_reason,
    changer.full_name AS changed_by,
    r.changed_at
FROM requirements r
LEFT JOIN users creator ON r.created_by = creator.id
LEFT JOIN users changer ON r.changed_by = changer.id
LEFT JOIN requirement_types rt ON r.type_id = rt.id
LEFT JOIN requirement_statuses rs ON r.status_id = rs.id
LEFT JOIN documents d ON r.source_document_id = d.id
LEFT JOIN requirements parent ON r.parent_id = parent.id
WHERE r.id = $1
ORDER BY r.version_number;
