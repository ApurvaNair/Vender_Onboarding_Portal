-- WORKFLOW SQL FOR VENDOR ONBOARDING PORTAL
USE vendor_portal;

-- PROCEDURE: Register New Vendor
-- Adds a new vendor entry into the system

DELIMITER //
CREATE PROCEDURE register_vendor (
    IN v_name VARCHAR(100),
    IN v_category VARCHAR(50),
    IN v_contact_person VARCHAR(100),
    IN v_email VARCHAR(100),
    IN v_phone VARCHAR(20),
    IN v_address TEXT
)
BEGIN
    INSERT INTO vendors (name, category, contact_person, email, phone, address)
    VALUES (v_name, v_category, v_contact_person, v_email, v_phone, v_address);
END;
//

-- PROCEDURE: Upload Document
-- Links an uploaded document to a vendor

CREATE PROCEDURE upload_document (
    IN v_id INT,
    IN doc_type VARCHAR(100),
    IN file_name VARCHAR(255)
)
BEGIN
    INSERT INTO documents (vendor_id, doc_type, filename)
    VALUES (v_id, doc_type, file_name);
END;
//

-- PROCEDURE: Update Approval Status
-- Updates approval status at any level
-- If all approvals are marked "approved", vendor is marked approved
-- If any are rejected, vendor is rejected immediately

DELIMITER //
CREATE PROCEDURE update_approval_status (
    IN approval_id INT,
    IN new_status ENUM('approved','rejected'),
    IN remarks_text TEXT
)
BEGIN
    DECLARE v_id INT;

    -- Get the vendor_id linked to this approval
    SELECT vendor_id INTO v_id FROM approval_levels WHERE id = approval_id;

    -- Update the approval record
    UPDATE approval_levels
    SET status = new_status,
        remarks = remarks_text,
        action_date = CURRENT_TIMESTAMP
    WHERE id = approval_id;

    -- Handle rejection or full approval
    IF new_status = 'rejected' THEN
        -- Mark vendor as rejected
        UPDATE vendors SET status = 'rejected' WHERE id = v_id;
    ELSE
        -- If all approval levels for this vendor are now 'approved', update vendor
        IF (
            SELECT COUNT(*) 
            FROM approval_levels 
            WHERE vendor_id = v_id AND status != 'approved'
        ) = 0 THEN
            UPDATE vendors SET status = 'approved' WHERE id = v_id;
        END IF;
    END IF;
END;
//
DELIMITER ;
