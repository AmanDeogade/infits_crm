const db = require('../db');
const leadModel = require('../models/lead');
const campaignAssigneeModel = require('../models/campaign_assignee');
const assigneeLeadModel = require('../models/assignee_lead');

exports.createLead = async (req, res) => {
    try {
        const {
            first_name,
            last_name,
            email,
            phone,
            alt_phone,
            address_line,
            city,
            state,
            country,
            zip,
            rating,
            campaign_id,
            assigned_to,
            current_status
        } = req.body;
        if (!campaign_id) {
            return res.status(400).json({ error: 'campaign_id is required' });
        }
        
        // Validate assigned_to if provided (assigned_to should be user_id)
        if (assigned_to) {
            // Check if user exists
            const [users] = await db.query('SELECT * FROM users WHERE id = ?', [assigned_to]);
            if (users.length === 0) {
                return res.status(400).json({ error: 'User not found' });
            }
            
            // Check if user is already assigned to this campaign
            const assignee = await campaignAssigneeModel.findByCampaignAndUser(campaign_id, assigned_to);
            if (!assignee) {
                // User is not assigned to campaign, create assignment automatically
                try {
                    const assignedBy = req.user ? req.user.id : 1; // Should now be properly set by middleware
                    
                    await campaignAssigneeModel.create({
                        campaign_id,
                        user_id: assigned_to,
                        assigned_by: assignedBy,
                        role_in_campaign: 'caller'
                    });
                    console.log(`Auto-assigned user ${assigned_to} to campaign ${campaign_id} by user ${assignedBy}`);
                } catch (assignError) {
                    console.error('Error auto-assigning user to campaign:', assignError);
                    return res.status(500).json({ error: 'Failed to assign user to campaign' });
                }
            }
        }
        
        const id = await leadModel.create({ 
            first_name, 
            last_name, 
            email, 
            phone, 
            alt_phone, 
            address_line, 
            city, 
            state, 
            country, 
            zip, 
            rating, 
            campaign_id, 
            assigned_to,
            current_status 
        });
        
        // If lead is assigned to someone, create entry in assignee_leads table
        if (assigned_to) {
            try {
                // Get the campaign assignee record (should exist now after auto-assignment)
                const assignee = await campaignAssigneeModel.findByCampaignAndUser(campaign_id, assigned_to);
                if (assignee) {
                    // Get the logged-in user's ID from the request
                    const assignedBy = req.user ? req.user.id : 1; // Should now be properly set by middleware
                    
                    console.log('Creating assignee_lead record:', {
                        campaign_id,
                        assignee_user_id: assignee.user_id,
                        lead_id: id,
                        assigned_by: assignedBy
                    });
                    
                    await assigneeLeadModel.create(
                        campaign_id,
                        assignee.user_id, // This should be the actual user ID
                        id,
                        assignedBy,
                        `Lead assigned during creation by user ${assignedBy}`
                    );
                    
                    console.log('Assignee_lead record created successfully');
                } else {
                    console.error('Campaign assignee not found for user_id:', assigned_to);
                }
            } catch (assigneeError) {
                console.error('Error creating assignee_lead record:', assigneeError);
                // Don't fail the lead creation if assignee_lead creation fails
            }
        }
        
        const lead = await leadModel.findById(id);
        res.status(201).json({ success: true, lead });
    } catch (err) {
        console.error('Create lead error:', err);
        res.status(500).json({ error: 'Internal server error', details: err.message });
    }
};

exports.getAllLeads = async (req, res) => {
    try {
        const leads = await leadModel.findAll();
        res.json({ success: true, leads });
    } catch (err) {
        console.error('Get leads error:', err);
        res.status(500).json({ error: 'Internal server error' });
    }
};

exports.getLeadById = async (req, res) => {
    try {
        const lead = await leadModel.findById(req.params.id);
        if (!lead) {
            return res.status(404).json({ error: 'Lead not found' });
        }
        res.json({ success: true, lead });
    } catch (err) {
        console.error('Get lead error:', err);
        res.status(500).json({ error: 'Internal server error' });
    }
};

exports.updateLead = async (req, res) => {
    try {
        const { assigned_to, campaign_id } = req.body;
        
        // Validate assigned_to if provided
        if (assigned_to && campaign_id) {
            const assignee = await campaignAssigneeModel.findByCampaignAndUser(campaign_id, assigned_to);
            if (!assignee) {
                return res.status(400).json({ error: 'Invalid assignee for this campaign' });
            }
        }
        
        await leadModel.update(req.params.id, req.body);
        const lead = await leadModel.findById(req.params.id);
        res.json({ success: true, lead });
    } catch (err) {
        console.error('Update lead error:', err);
        res.status(500).json({ error: 'Internal server error' });
    }
};

exports.deleteLead = async (req, res) => {
    try {
        const lead = await leadModel.findById(req.params.id);
        if (!lead) {
            return res.status(404).json({ error: 'Lead not found' });
        }
        await leadModel.delete(req.params.id);
        res.json({ success: true, message: 'Lead deleted' });
    } catch (err) {
        console.error('Delete lead error:', err);
        res.status(500).json({ error: 'Internal server error' });
    }
};

exports.bulkCreateLeads = async (req, res) => {
    try {
        const { campaign, leads, callers } = req.body;
        console.log('=== BULK IMPORT REQUEST ===');
        console.log('Request body:', JSON.stringify(req.body, null, 2));
        
        if (!campaign || !leads || !Array.isArray(leads)) {
            return res.status(400).json({ error: 'campaign and leads array are required' });
        }
        
        // Add callers to campaign_assignees table if provided
        const assigneeIds = [];
        const campaignAssignees = []; // Store campaign assignee records for lead distribution
        
        if (callers && Array.isArray(callers) && callers.length > 0) {
            for (const callerId of callers) {
                try {
                    // Check if assignee already exists for this campaign
                    const existingAssignee = await campaignAssigneeModel.findByCampaignAndUser(campaign, callerId);
                    if (!existingAssignee) {
                        // Add caller as assignee to the campaign
                        const assigneeId = await campaignAssigneeModel.create({
                            campaign_id: campaign,
                            user_id: callerId,
                            assigned_by: req.user ? req.user.id : 1, // Use authenticated user or fallback
                            role_in_campaign: 'caller'
                        });
                        assigneeIds.push(assigneeId);
                        
                        // Get the created assignee record for lead distribution
                        const newAssignee = await campaignAssigneeModel.findById(assigneeId);
                        if (newAssignee) {
                            campaignAssignees.push(newAssignee);
                        }
                    } else {
                        assigneeIds.push(existingAssignee.id);
                        campaignAssignees.push(existingAssignee);
                    }
                } catch (err) {
                    console.error('Error adding caller to campaign:', err);
                    // Continue with lead import even if caller assignment fails
                }
            }
        }
        
        console.log('Bulk import - Total leads to process:', leads.length);
        console.log('Campaign ID:', campaign);
        console.log('Callers to add:', callers);
        console.log('Campaign assignees available for distribution:', campaignAssignees.length);
        
        // Randomly distribute leads among callers
        const leadAssignments = [];
        const inserted = [];
        const errors = [];
        
        // Create a copy of leads array for random distribution
        const leadsToProcess = [...leads];
        
        // Shuffle the leads array for random distribution
        for (let i = leadsToProcess.length - 1; i > 0; i--) {
            const j = Math.floor(Math.random() * (i + 1));
            [leadsToProcess[i], leadsToProcess[j]] = [leadsToProcess[j], leadsToProcess[i]];
        }
        
        // Distribute leads among callers
        for (let i = 0; i < leadsToProcess.length; i++) {
            const lead = leadsToProcess[i];
            const assigneeIndex = i % campaignAssignees.length; // Round-robin distribution
            const selectedAssignee = campaignAssignees[assigneeIndex];
            
            try {
                console.log('Processing lead:', { email: lead.email, phone: lead.phone });
                
                // Check for existing lead by email or phone (in any campaign)
                let duplicate = null;
                if (lead.email && lead.email.trim() !== '') {
                    duplicate = await leadModel.findByEmail(lead.email.trim());
                    if (duplicate) {
                        console.log('Duplicate found by email:', lead.email);
                    }
                }
                if (!duplicate && lead.phone && lead.phone.trim() !== '') {
                    duplicate = await leadModel.findByPhone(lead.phone.trim());
                    if (duplicate) {
                        console.log('Duplicate found by phone:', lead.phone);
                    }
                }
                if (duplicate) {
                    errors.push({ lead, error: 'Duplicate found in database (email or phone)' });
                    continue;
                }
                
                // Create lead with assignment to selected caller
                const leadData = { 
                    ...lead, 
                    campaign_id: campaign,
                    assigned_to: selectedAssignee.id // Assign to the campaign_assignee ID, not user_id
                };
                console.log('Creating lead with data:', leadData);
                const id = await leadModel.create(leadData);
                inserted.push(id);
                
                // Create assignee_lead record
                try {
                    const assignedBy = req.user ? req.user.id : 1;
                    await assigneeLeadModel.create(
                        campaign,
                        selectedAssignee.user_id, // Use user_id for assignee_lead
                        id,
                        assignedBy,
                        `Lead assigned during bulk import to caller ${selectedAssignee.user_name || selectedAssignee.user_id}`
                    );
                    
                    leadAssignments.push({
                        lead_id: id,
                        assignee_id: selectedAssignee.user_id,
                        assignee_name: selectedAssignee.user_name || `Caller ${selectedAssignee.user_id}`
                    });
                    
                    console.log(`Lead ${id} assigned to caller ${selectedAssignee.user_name || selectedAssignee.user_id}`);
                } catch (assigneeError) {
                    console.error('Error creating assignee_lead record:', assigneeError);
                    // Don't fail the lead creation if assignee_lead creation fails
                }
                
                console.log('Lead created successfully with ID:', id);
            } catch (err) {
                console.error('Error creating lead:', err);
                errors.push({ lead, error: err.message });
            }
        }
        
        console.log('=== BULK IMPORT RESULT ===');
        console.log('Inserted:', inserted.length);
        console.log('Errors:', errors.length);
        console.log('Assignees added:', assigneeIds.length);
        console.log('Lead assignments:', leadAssignments.length);
        
        res.status(201).json({ 
            success: true, 
            inserted_count: inserted.length, 
            error_count: errors.length, 
            errors,
            assignees_added: assigneeIds.length,
            assignee_ids: assigneeIds,
            lead_assignments: leadAssignments,
            distribution_summary: {
                total_leads: leads.length,
                total_callers: campaignAssignees.length,
                leads_per_caller: Math.ceil(leads.length / campaignAssignees.length)
            }
        });
    } catch (err) {
        console.error('Bulk create leads error:', err);
        res.status(500).json({ error: 'Internal server error', details: err.message });
    }
}; 

// Assign a lead to a specific assignee
exports.assignLead = async (req, res) => {
    try {
        const { lead_id, assignee_id } = req.params;
        
        const lead = await leadModel.findById(lead_id);
        if (!lead) {
            return res.status(404).json({ error: 'Lead not found' });
        }
        
        // Validate that the assignee exists for this campaign
        const assignee = await campaignAssigneeModel.findByCampaignAndUser(lead.campaign_id, assignee_id);
        if (!assignee) {
            return res.status(400).json({ error: 'Invalid assignee for this campaign' });
        }
        
        await leadModel.update(lead_id, { assigned_to: assignee_id });
        const updatedLead = await leadModel.findById(lead_id);
        res.json({ success: true, lead: updatedLead });
    } catch (err) {
        console.error('Assign lead error:', err);
        res.status(500).json({ error: 'Internal server error' });
    }
};

// Unassign a lead (set assigned_to to null)
exports.unassignLead = async (req, res) => {
    try {
        const { lead_id } = req.params;
        
        const lead = await leadModel.findById(lead_id);
        if (!lead) {
            return res.status(404).json({ error: 'Lead not found' });
        }
        
        await leadModel.update(lead_id, { assigned_to: null });
        const updatedLead = await leadModel.findById(lead_id);
        res.json({ success: true, lead: updatedLead });
    } catch (err) {
        console.error('Unassign lead error:', err);
        res.status(500).json({ error: 'Internal server error' });
    }
};

// Get leads by assignee
exports.getLeadsByAssignee = async (req, res) => {
    try {
        const { assignee_id } = req.params;
        const leads = await leadModel.findByAssignee(assignee_id);
        res.json({ success: true, leads });
    } catch (err) {
        console.error('Get leads by assignee error:', err);
        res.status(500).json({ error: 'Internal server error' });
    }
};

// Get unassigned leads for a campaign
exports.getUnassignedLeads = async (req, res) => {
    try {
        const { campaign_id } = req.params;
        const [leads] = await db.query('SELECT * FROM leads WHERE campaign_id = ? AND assigned_to IS NULL', [campaign_id]);
        res.json({ success: true, leads });
    } catch (err) {
        console.error('Get unassigned leads error:', err);
        res.status(500).json({ error: 'Internal server error' });
    }
};

// Bulk assign leads to an assignee
exports.bulkAssignLeads = async (req, res) => {
    try {
        const { lead_ids, assignee_id } = req.body;
        
        if (!lead_ids || !Array.isArray(lead_ids) || !assignee_id) {
            return res.status(400).json({ error: 'lead_ids array and assignee_id are required' });
        }
        
        const results = [];
        for (const lead_id of lead_ids) {
            try {
                const lead = await leadModel.findById(lead_id);
                if (!lead) {
                    results.push({ lead_id, success: false, error: 'Lead not found' });
                    continue;
                }
                
                // Validate assignee for this campaign
                const assignee = await campaignAssigneeModel.findByCampaignAndUser(lead.campaign_id, assignee_id);
                if (!assignee) {
                    results.push({ lead_id, success: false, error: 'Invalid assignee for this campaign' });
                    continue;
                }
                
                await leadModel.update(lead_id, { assigned_to: assignee_id });
                results.push({ lead_id, success: true });
            } catch (err) {
                results.push({ lead_id, success: false, error: err.message });
            }
        }
        
        res.json({ success: true, results });
    } catch (err) {
        console.error('Bulk assign leads error:', err);
        res.status(500).json({ error: 'Internal server error' });
    }
}; 