-- SAMPLE DATA WITH EDGE CASES FOR VENDOR ONBOARDING PORTAL

USE vendor_portal;

-- 1. User Roles
-- Define core system roles for access control.

INSERT INTO user_roles (role_name) VALUES 
  ('admin'), 
  ('approver'), 
  ('vendor');

-- 2. Users (Admins, Approvers, Vendors)
-- Simulate actual users of the system across all roles.

INSERT INTO users (name, email, phone) VALUES
  ('Nisha Iyer', 'nisha.iyer@corp.com', '9876000001'),    -- Admin
  ('Amit Joshi', 'amit.joshi@corp.com', '9876000002'),    -- Approver Level 1
  ('Geeta Rao', 'geeta.rao@corp.com', '9876000003'),      -- Approver Level 2
  ('Ravi Varma', 'ravi@ravient.com', '9888000001'),       -- Vendor
  ('Fatima Shaikh', 'fatima@fsbuilders.com', '9888000002'), -- Vendor
  ('Tushar Singh', 'tushar@tsexports.in', '9888000003'),  -- Vendor
  ('Kiran Jain', 'kiran@kirantextiles.com', '9888000004'),-- Vendor
  ('Manoj Desai', 'manoj.desai@corp.com', '9876000005');  -- Admin 2

-- 3. User Permissions
-- Maps users to roles (multi-role possible).

INSERT INTO user_permissions (user_id, role_id) VALUES
  (1, 1), -- Nisha: Admin
  (2, 2), -- Amit: Approver
  (3, 2), -- Geeta: Approver
  (4, 3), -- Ravi: Vendor
  (5, 3), -- Fatima: Vendor
  (6, 3), -- Tushar: Vendor
  (7, 3), -- Kiran: Vendor
  (8, 1); -- Manoj: Admin

-- 4. Vendors 

INSERT INTO vendors (name, category, contact_person, email, phone, address, performance_rating, is_deleted) VALUES
  ('Ravi Enterprises', 'Electrical', 'Ravi Varma', 'ravi@ravient.com', '9888000001', 'Bangalore', 4.8, FALSE),
  ('FS Builders', 'Construction', 'Fatima Shaikh', 'fatima@fsbuilders.com', '9888000002', 'Mumbai', 3.2, FALSE),
  ('TS Exports', 'Logistics', 'Tushar Singh', 'tushar@tsexports.in', '9888000003', 'Chennai', 2.5, FALSE),
  ('Kiran Textiles', 'Fashion', 'Kiran Jain', 'kiran@kirantextiles.com', '9888000004', 'Ahmedabad', 4.0, TRUE);

-- 5. Document Templates
-- Required documentation as per compliance.

INSERT INTO document_templates (template_name, doc_type, required) VALUES
  ('Standard', 'PAN Card', TRUE),
  ('Standard', 'GST Certificate', TRUE),
  ('Standard', 'Company Profile', FALSE);

-- 6. Uploaded Documents
-- Vendor-specific document uploads and status

-- Edge Case: Fully onboarded with all required documents
INSERT INTO documents (vendor_id, doc_type, filename, status) VALUES
  (1, 'PAN Card', 'ravi_pan.pdf', 'approved'),
  (1, 'GST Certificate', 'ravi_gst.pdf', 'approved'),
  (1, 'Company Profile', 'ravi_profile.pdf', 'submitted');

-- Edge case: Incomplete submission
INSERT INTO documents (vendor_id, doc_type, filename, status) VALUES
  (2, 'PAN Card', 'fatima_pan.pdf', 'approved');

-- Edge case: Document Rejection
INSERT INTO documents (vendor_id, doc_type, filename, status) VALUES
  (3, 'PAN Card', 'tushar_pan.pdf', 'rejected');

-- Edge case: soft-deletion after success
INSERT INTO documents (vendor_id, doc_type, filename, status) VALUES
  (4, 'PAN Card', 'kiran_pan.pdf', 'approved'),
  (4, 'GST Certificate', 'kiran_gst.pdf', 'approved');

-- 7. Document Versions
-- Edge case: Version Tracking

INSERT INTO document_versions (document_id, version_number, filename) VALUES
  (1, 1, 'ravi_pan_v1.pdf'),
  (1, 2, 'ravi_pan_v2.pdf');

-- 8. Approval Workflow
-- Each vendor's approval status at different levels.

-- Edge Case: Completed all approvals (Level 1 and 2)
INSERT INTO approval_levels (vendor_id, approver_id, level, status, due_date) VALUES
  (1, 2, 1, 'approved', CURDATE() - INTERVAL 5 DAY),
  (1, 3, 2, 'approved', CURDATE() - INTERVAL 3 DAY);

-- Edge Case: Pending Approval
INSERT INTO approval_levels (vendor_id, approver_id, level, status, due_date) VALUES
  (2, 2, 1, 'pending', CURDATE() + INTERVAL 1 DAY);

-- Edge case: Approval Rejection
INSERT INTO approval_levels (vendor_id, approver_id, level, status, due_date) VALUES
  (3, 2, 1, 'rejected', CURDATE() - INTERVAL 2 DAY);

-- 🗃️ Edge Case: Fully approved earlier before soft deletion
INSERT INTO approval_levels (vendor_id, approver_id, level, status, due_date) VALUES
  (4, 2, 1, 'approved', CURDATE() - INTERVAL 10 DAY),
  (4, 3, 2, 'approved', CURDATE() - INTERVAL 8 DAY);

-- 9. Approval Reminders
-- Automatic follow-up for pending or rejected approvals

INSERT INTO approval_reminders (approval_id, reminder_date, message) VALUES
  (5, CURDATE(), 'Reminder: Approval pending for FS Builders'),
  (6, CURDATE() - INTERVAL 1 DAY, 'Reminder: TS Exports was rejected');

-- 10. Notifications
-- System alerts and messages to vendors

INSERT INTO notifications (user_id, vendor_id, message) VALUES
  (4, 1, 'Your vendor registration is complete.'),
  (5, 2, 'Please upload your missing GST Certificate.'),
  (6, 3, 'Your PAN document was rejected. Please contact support.');
