CREATE DATABASE IF NOT EXISTS crm_database;
USE crm_database;

CREATE TABLE IF NOT EXISTS users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    initials VARCHAR(10) NOT NULL,
    role ENUM('admin', 'caller', 'marketing', 'manager') NOT NULL DEFAULT 'caller',
    permission_template_id BIGINT UNSIGNED,
    reporting_to BIGINT UNSIGNED COMMENT 'Must refer to a user with role = admin',
    phone VARCHAR(20),
    country_code VARCHAR(10) DEFAULT '+91',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS campaigns (
    id             BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name           VARCHAR(255) NOT NULL,
    description    TEXT,
    created_by     BIGINT UNSIGNED NOT NULL,
    start_date     DATE,
    end_date       DATE,
    progress_pct   DECIMAL(5,2) DEFAULT 0.00 CHECK (progress_pct <= 100.00),
    status         ENUM('DRAFT','ACTIVE','PAUSED','COMPLETED') DEFAULT 'DRAFT',
    total_leads    INT UNSIGNED DEFAULT 0,
    created_at     TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at     TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    CONSTRAINT fk_campaign_created_by
      FOREIGN KEY (created_by) REFERENCES users(id)
      ON DELETE RESTRICT
      ON UPDATE CASCADE
);

-- Campaign assignees table to track which users are assigned to which campaigns
CREATE TABLE IF NOT EXISTS campaign_assignees (
    id              BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    campaign_id     BIGINT UNSIGNED NOT NULL,
    user_id         BIGINT UNSIGNED NOT NULL,
    assigned_at     TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    assigned_by     BIGINT UNSIGNED,
    role_in_campaign ENUM('caller', 'manager', 'supervisor') DEFAULT 'caller',
    is_active       BOOLEAN DEFAULT TRUE,
    created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    CONSTRAINT fk_campaign_assignees_campaign
      FOREIGN KEY (campaign_id) REFERENCES campaigns(id)
      ON DELETE CASCADE
      ON UPDATE CASCADE,
      
    CONSTRAINT fk_campaign_assignees_user
      FOREIGN KEY (user_id) REFERENCES users(id)
      ON DELETE CASCADE
      ON UPDATE CASCADE,
      
    CONSTRAINT fk_campaign_assignees_assigned_by
      FOREIGN KEY (assigned_by) REFERENCES users(id)
      ON DELETE SET NULL
      ON UPDATE CASCADE,
      
    UNIQUE KEY unique_campaign_user (campaign_id, user_id)
);

-- Create leads table
CREATE TABLE IF NOT EXISTS leads (
    id            BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    first_name    VARCHAR(100),
    last_name     VARCHAR(100),
    email         VARCHAR(255),
    phone         VARCHAR(30),
    alt_phone     VARCHAR(30),
    address_line  TEXT,
    city          VARCHAR(100),
    state         VARCHAR(100),
    country       VARCHAR(100),
    zip           VARCHAR(20),
    rating        TINYINT,
    campaign_id   BIGINT UNSIGNED NOT NULL,
    assigned_to   BIGINT UNSIGNED,
    current_status VARCHAR(50),
    created_at    TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at    TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    CONSTRAINT fk_lead_campaign
      FOREIGN KEY (campaign_id) REFERENCES campaigns(id)
      ON DELETE CASCADE
      ON UPDATE CASCADE,
      
    CONSTRAINT fk_lead_assigned_to
      FOREIGN KEY (assigned_to) REFERENCES campaign_assignees(id)
      ON DELETE SET NULL
      ON UPDATE CASCADE
);

CREATE TABLE callers (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100),
    total_calls INT,
    connected_calls INT,
    not_connected_calls INT,
    total_duration_minutes INT,
    duration_raise_percentage FLOAT,
    first_call_time TIME,
    last_call_time TIME,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Call metrics table to track call performance and lead stages
CREATE TABLE IF NOT EXISTS call_metrics (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    total_calls INT DEFAULT 0,
    incoming_calls INT DEFAULT 0,
    outgoing_calls INT DEFAULT 0,
    missed_calls INT DEFAULT 0,
    connected_calls INT DEFAULT 0,
    attempted_calls INT DEFAULT 0,
    total_duration_seconds INT DEFAULT 0,
    stage_fresh INT DEFAULT 0,
    stage_interested INT DEFAULT 0,
    stage_committed INT DEFAULT 0,
    stage_not_interested INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    CONSTRAINT fk_call_metrics_user_id 
        FOREIGN KEY (user_id) REFERENCES callers(id) 
        ON DELETE CASCADE ON UPDATE CASCADE
);

-- Caller details table to track performance metrics
CREATE TABLE IF NOT EXISTS caller_details (
    id INT AUTO_INCREMENT PRIMARY KEY,
    caller_id INT NOT NULL,
    tasks_late INT DEFAULT 0,
    tasks_pending INT DEFAULT 0,
    tasks_done INT DEFAULT 0,
    tasks_created INT DEFAULT 0,
    whatsapp_incoming INT DEFAULT 0,
    whatsapp_outgoing INT DEFAULT 0,
    stage_fresh INT DEFAULT 0,
    stage_interested INT DEFAULT 0,
    stage_committed INT DEFAULT 0,
    stage_not_interested INT DEFAULT 0,
    stage_not_connected INT DEFAULT 0,
    stage_callback INT DEFAULT 0,
    stage_temple_visit INT DEFAULT 0,
    stage_temple_donor INT DEFAULT 0,
    stage_lost INT DEFAULT 0,
    stage_won INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    CONSTRAINT fk_caller_details_caller_id 
        FOREIGN KEY (caller_id) REFERENCES callers(id) 
        ON DELETE CASCADE ON UPDATE CASCADE
);

-- Insert sample callers data
INSERT INTO callers (name, total_calls, connected_calls, not_connected_calls, total_duration_minutes, duration_raise_percentage, first_call_time, last_call_time) VALUES 
('John Doe', 150, 120, 30, 1800, 85.5, '09:00:00', '17:00:00'),
('Jane Smith', 200, 160, 40, 2400, 78.2, '08:30:00', '16:30:00'),
('Mike Johnson', 180, 140, 40, 2100, 82.1, '09:15:00', '17:15:00');

-- Insert sample call metrics data for each caller
INSERT INTO call_metrics (user_id, total_calls, incoming_calls, outgoing_calls, missed_calls, connected_calls, attempted_calls, total_duration_seconds, stage_fresh, stage_interested, stage_committed, stage_not_interested) VALUES 
(1, 150, 25, 125, 15, 120, 135, 108000, 45, 35, 25, 15),
(2, 200, 30, 170, 20, 160, 180, 144000, 60, 50, 40, 20),
(3, 180, 20, 160, 18, 140, 162, 126000, 55, 45, 35, 18);

-- Insert sample caller details data
INSERT INTO caller_details (caller_id, tasks_late, tasks_pending, tasks_done, tasks_created, whatsapp_incoming, whatsapp_outgoing, stage_fresh, stage_interested, stage_committed, stage_not_interested, stage_not_connected, stage_callback, stage_temple_visit, stage_temple_donor, stage_lost, stage_won) VALUES 
(1, 2, 5, 45, 50, 15, 25, 45, 35, 25, 15, 30, 10, 8, 5, 12, 8),
(2, 1, 3, 60, 65, 20, 30, 60, 50, 40, 20, 40, 15, 12, 8, 15, 10),
(3, 3, 7, 52, 58, 18, 28, 55, 45, 35, 18, 35, 12, 10, 6, 18, 12);

-- Create assignee_leads table to track lead assignments
CREATE TABLE IF NOT EXISTS assignee_leads (
    id INT PRIMARY KEY AUTO_INCREMENT,
    campaign_id INT NOT NULL,
    assignee_id INT NOT NULL,
    lead_id INT NOT NULL,
    assigned_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    assigned_by INT NOT NULL,
    status ENUM('Fresh', 'Not Connected', 'Interested', 'Commited', 'Call Back', 'Not Interested', 'Won', 'Lost', 'Temple Visit', 'Temple Donor') DEFAULT 'Fresh',
    notes TEXT,
    
    -- Foreign key constraints
    FOREIGN KEY (campaign_id) REFERENCES campaigns(id) ON DELETE CASCADE,
    FOREIGN KEY (assignee_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (lead_id) REFERENCES leads(id) ON DELETE CASCADE,
    FOREIGN KEY (assigned_by) REFERENCES users(id) ON DELETE CASCADE,
    
    -- Unique constraints to ensure one lead per assignee per campaign
    UNIQUE KEY unique_lead_assignment (campaign_id, lead_id)
);

INSERT INTO users (name, email, password, initials, role, phone, country_code) VALUES 
('Admin User', 'admin@example.com', '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'AU', 'admin', '+1234567890', '+1'), -- password: password
('John Doe', 'john@example.com', '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'JD', 'caller', '+9876543210', '+91'), -- password: password
('Jane Smith', 'jane@example.com', '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'JS', 'marketing', '+1122334455', '+91'); -- password: password 