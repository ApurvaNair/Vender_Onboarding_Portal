# Vendor_Onboarding_Portal

Author: Apurva Nair

## Overview

This project provides a complete backend database solution for a Vendor Onboarding Portal using MySQL (version 5.7 or higher)

It includes:
- User-role management
- Vendor registration
- Document upload tracking
- Multi-level approval workflows
- Automatic reminders and notifications
- Audit logging
- Views and indexing for reporting and performance

All functionality is implemented using SQL only — through DDL, DML, triggers, procedures, and views.

## Files Included:

| File Name           | Purpose                                                         |
|---------------------|-----------------------------------------------------------------|
| `schema.sql`        | Creates all tables, views, triggers, and indexes                |
| `sample_data.sql`   | Inserts realistic sample data including edge cases              |
| `workflow.sql`      | Defines stored procedures for registration, upload, and approval |
| `test.sql`          | Query script to verify outputs from all core workflows          |

## Schema Summary:

Database: vendor_portal

Users & Roles:
- users : General user information.
- user_roles : Defines roles (Admin, Approver, Vendor).
- user_permissions : Connects users with one or more roles.

Vendor Information:
- vendors : Stores vendor details, onboarding status, risk level.
- archived_vendors : Backup for soft-deleted vendors.

Documents:
- document_templates : Defines required document types.
- documents : Tracks each vendor's document submissions.
- document_versions : Stores re-uploaded versions.

Approval Workflow:
- approval_levels : Supports multi-level approvals for vendors.
- approval_reminders : Tracks reminders for pending actions.

Logging & Notifications:
- audit_logs : Trigger-based log of key actions.
- notifications : Messages for users (e.g., upload/update alerts).

Views:
- vendor_compliance_score : Shows % compliance based on document uploads.
- pending_approvals : Lists all vendors still awaiting approval.

Indexes:
- idx_documents_vendor : Improves performance when retrieving documents for a specific vendor (used in JOINs and filters).
- idx_permissions_user : Speeds up lookups of user-role mappings when filtering by user ID.
- idx_approval_approver : Optimizes queries to fetch approval tasks assigned to a specific approver.
- idx_vendors_status : Enhances efficiency when filtering or grouping vendors by their onboarding status.

Stored Procedures:

1. register_vendor(...)  
   Registers a new vendor and inserts into the `vendors` table.

2. upload_document(...)  
   Records an uploaded document and auto-logs via a trigger.

3. update_approval_status(...)  
   Updates the approval status. If all levels are approved, the vendor is marked approved. If any level is rejected, vendor is rejected.

Workflow (Business Logic)
1. User Management
Users (users) are assigned roles (user_roles) such as admin, approver, or vendor.
Each user may have multiple roles via the user_permissions table.

2. Vendor Registration
Vendors are added to the system using the register_vendor procedure.
Stored in the vendors table with onboarding status, risk_level, and performance_rating.
Soft deletes are enabled using the is_deleted flag; backups are kept in archived_vendors.

3. Document Management
document_templates defines required document types like PAN, GST, etc.
Vendors upload documents via upload_document.
Uploads are saved in the documents table.
Re-uploaded versions are tracked in document_versions.

4. Approval Workflow
Each vendor goes through one or more approval levels (approval_levels).

Approvers are assigned by level (e.g., level 1, level 2).
update_approval_status procedure allows approvers to approve or reject.
If all levels approve → vendor is marked as approved
If any level rejects → vendor is marked as rejected

5. Automatic Reminders (Bonus Feature)
approval_reminders stores messages and dates for follow-up on pending approvals.

Helps simulate auto-email or notification reminders before/after due dates.

6. Notifications
Stored in the notifications table.

Used to notify vendors about missing documents, rejection, or onboarding updates.

7. Audit Logging (Triggers)
Two triggers log all significant events automatically:

trg_log_vendor_registration: Logs when a vendor is registered

trg_log_document_upload: Logs when a document is uploaded

Entries are saved in the audit_logs table with timestamps and action details.

8. Reports and Views
vendor_compliance_score: Shows % of required documents submitted per vendor.

pending_approvals: Lists which vendors still need approval and by whom.

9. Performance Optimization
Indexed key columns to improve speed of common queries:

idx_documents_vendor: Speeds up document lookups by vendor

idx_permissions_user: Fast role lookup for users

idx_approval_approver: Optimizes pending approval queries

idx_vendors_status: Improves vendor status filtering in dashboards


## How to Run:

**1. Open MySQL Workbench and connect to your server.**
**2. Run schema.sql**
**3. Run sample_data.sql**
**4. Run workflow.sql**
**5. Run test.sql to verify output**

