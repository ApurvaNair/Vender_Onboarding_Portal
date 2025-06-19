-- Create the database (only if it doesn't already exist)
CREATE DATABASE IF NOT EXISTS vendor_portal;
USE vendor_portal;

-- USER MANAGEMENT 

-- Table: user_roles
-- Stores types of users (e.g., admin, vendor, approver)
CREATE TABLE user_roles (
    id INT AUTO_INCREMENT PRIMARY KEY,
    role_name VARCHAR(50) NOT NULL UNIQUE
);

-- Table: users
-- Stores user details (email, phone, etc.)
CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    phone VARCHAR(20),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Table: user_permissions
-- Allows each user to have one or more roles (multi-role support)
CREATE TABLE user_permissions (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    role_id INT NOT NULL,
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (role_id) REFERENCES user_roles(id),
    UNIQUE(user_id, role_id)
);

-- VENDOR MANAGEMENT 

-- Table: vendors
-- Stores vendor company info, onboarding status, soft delete, risk level
-- Extra Features:
-- - 'performance_rating': Rating for vendor performance (0–5)
-- - 'risk_level': Classifies vendor risk
-- - 'is_deleted': Enables soft deletion
CREATE TABLE vendors (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    category VARCHAR(50),
    contact_person VARCHAR(100),
    email VARCHAR(100),
    phone VARCHAR(20),
    address TEXT,
    status ENUM('pending', 'approved', 'rejected') DEFAULT 'pending',
    risk_level ENUM('low','medium','high') DEFAULT 'medium',
    performance_rating DECIMAL(2,1) DEFAULT 0.0,  -- Bonus: Vendor Rating System
    is_deleted BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Backup Table: archived_vendors (for soft deletes)
CREATE TABLE archived_vendors AS SELECT * FROM vendors WHERE 1=0;

-- DOCUMENT MANAGEMENT

-- Table: document_templates
-- Stores list of required/optional documents per vendor type
CREATE TABLE document_templates (
    id INT AUTO_INCREMENT PRIMARY KEY,
    template_name VARCHAR(100),
    doc_type VARCHAR(100),
    required BOOLEAN DEFAULT TRUE
);

-- Table: documents
-- Stores documents uploaded by vendors
CREATE TABLE documents (
    id INT AUTO_INCREMENT PRIMARY KEY,
    vendor_id INT NOT NULL,
    doc_type VARCHAR(100),
    filename VARCHAR(255),
    status ENUM('submitted', 'approved', 'rejected') DEFAULT 'submitted',
    upload_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_deleted BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (vendor_id) REFERENCES vendors(id)
);

-- Table: document_versions
-- Tracks versions of uploaded documents
CREATE TABLE document_versions (
    id INT AUTO_INCREMENT PRIMARY KEY,
    document_id INT NOT NULL,
    version_number INT,
    filename VARCHAR(255),
    upload_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (document_id) REFERENCES documents(id)
);

-- APPROVAL WORKFLOW 

-- Table: approval_levels
-- Tracks multi-step approval process per vendor
CREATE TABLE approval_levels (
    id INT AUTO_INCREMENT PRIMARY KEY,
    vendor_id INT NOT NULL,
    approver_id INT NOT NULL,
    level INT NOT NULL,
    status ENUM('pending','approved','rejected') DEFAULT 'pending',
    remarks TEXT,
    due_date DATE,
    action_date TIMESTAMP NULL,
    FOREIGN KEY (vendor_id) REFERENCES vendors(id),
    FOREIGN KEY (approver_id) REFERENCES users(id)
);


-- AUTOMATIC REMINDERS (Bonus Feature)

-- Table: approval_reminders
-- Stores automatic reminders for pending approvals
-- Bonus Feature: Sends reminders before/after due date
CREATE TABLE approval_reminders (
    id INT AUTO_INCREMENT PRIMARY KEY,
    approval_id INT NOT NULL,
    reminder_date DATE,
    message TEXT,
    FOREIGN KEY (approval_id) REFERENCES approval_levels(id)
);

-- AUDIT LOGGING 

-- Table: audit_logs
-- Stores automatic log entries (via triggers)
CREATE TABLE audit_logs (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    vendor_id INT,
    action VARCHAR(100),
    details TEXT,
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (vendor_id) REFERENCES vendors(id)
);

-- NOTIFICATIONS 

-- Table: notifications
-- Stores system-generated alerts and messages to users
CREATE TABLE notifications (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    vendor_id INT,
    message TEXT NOT NULL,
    read_status BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (vendor_id) REFERENCES vendors(id)
);

-- TRIGGERS FOR AUTOMATIC LOGGING 

DELIMITER //
-- Trigger: Auto log after vendor registration
CREATE TRIGGER trg_log_vendor_registration
AFTER INSERT ON vendors
FOR EACH ROW
BEGIN
  INSERT INTO audit_logs(user_id, vendor_id, action, details)
  VALUES (NULL, NEW.id, 'Vendor Registered', CONCAT('Vendor ', NEW.name, ' registered.'));
END;
//

-- Trigger: Auto log after document upload
CREATE TRIGGER trg_log_document_upload
AFTER INSERT ON documents
FOR EACH ROW
BEGIN
  INSERT INTO audit_logs(user_id, vendor_id, action, details)
  VALUES (NULL, NEW.vendor_id, 'Document Uploaded', CONCAT('Document ', NEW.filename, ' uploaded.'));
END;
//
DELIMITER ;

-- INDEXES FOR PERFORMANCE 

CREATE INDEX idx_documents_vendor ON documents(vendor_id);
CREATE INDEX idx_permissions_user ON user_permissions(user_id);
CREATE INDEX idx_approval_approver ON approval_levels(approver_id);
CREATE INDEX idx_vendors_status ON vendors(status);

-- VIEWS FOR REPORTING (Bonus feature)

-- View: vendor_compliance_score
-- Shows each vendor’s document completion %
CREATE VIEW vendor_compliance_score AS
SELECT 
    v.id AS vendor_id,
    v.name AS vendor_name,
    COUNT(DISTINCT d.doc_type) AS submitted_docs,
    (SELECT COUNT(*) FROM document_templates WHERE required = TRUE) AS total_required_docs,
    ROUND(
        (COUNT(DISTINCT d.doc_type) / 
         (SELECT COUNT(*) FROM document_templates WHERE required = TRUE)
        ) * 100, 2
    ) AS compliance_score_percent
FROM vendors v
LEFT JOIN documents d 
    ON v.id = d.vendor_id AND d.status != 'rejected'
GROUP BY v.id;

-- View: pending_approvals
-- Shows which approvals are still pending and by whom
CREATE VIEW pending_approvals AS
SELECT 
    v.id AS vendor_id,
    v.name AS vendor_name,
    a.level,
    u.name AS approver_name,
    a.status,
    a.due_date
FROM approval_levels a
JOIN vendors v ON v.id = a.vendor_id
JOIN users u ON u.id = a.approver_id
WHERE a.status = 'pending';
