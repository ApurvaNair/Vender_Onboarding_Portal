USE vendor_portal;

-- 1. View Data from Core Tables

SELECT * FROM users;
SELECT * FROM user_roles;
SELECT * FROM user_permissions;
SELECT * FROM vendors;
SELECT * FROM document_templates;
SELECT * FROM documents;
SELECT * FROM document_versions;
SELECT * FROM approval_levels;
SELECT * FROM approval_reminders;
SELECT * FROM notifications;
SELECT * FROM audit_logs ORDER BY timestamp DESC;

-- 2. Views and Reports

-- Vendor compliance (document coverage %)
SELECT * FROM vendor_compliance_score;

-- Approvals still pending
SELECT * FROM pending_approvals;

-- 3. Stored Procedure Testing

-- -- 🆕 Register a new vendor
-- CALL register_vendor('TechNova Inc.', 'Software', 'Neha Agarwal', 'neha@technova.com', '9123456789', 'Indore');

-- -- 📤 Upload a PAN document for that vendor (assume ID = 5)
-- CALL upload_document(5, 'PAN Card', 'technova_pan.pdf');

-- -- ✅ Approve a pending approval (update approval_id based on data)
-- CALL update_approval_status(5, 'approved', 'Documents verified successfully.');

-- -- ❌ Reject a different approval
-- CALL update_approval_status(6, 'rejected', 'Document was incomplete or outdated.');

-- 🔄 View updated vendor statuses
SELECT id, name, status FROM vendors;
