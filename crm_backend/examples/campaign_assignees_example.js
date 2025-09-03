// Example usage of Campaign Assignees API
// This file shows how to assign users to campaigns

const BASE_URL = 'http://localhost:3000';
const TOKEN = 'your-jwt-token-here'; // Get this from login

// Example 1: Assign a user to a campaign
async function assignUserToCampaign() {
    try {
        const response = await fetch(`${BASE_URL}/campaign-assignees/assign`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                'Authorization': `Bearer ${TOKEN}`
            },
            body: JSON.stringify({
                campaign_id: 1,        // Campaign ID
                user_id: 2,            // User ID (from users table)
                role_in_campaign: 'caller'  // Role: caller, manager, or supervisor
            })
        });
        
        const data = await response.json();
        console.log('User assigned successfully:', data);
    } catch (error) {
        console.error('Error assigning user:', error);
    }
}

// Example 2: Assign multiple users to a campaign
async function assignMultipleUsersToCampaign() {
    const assignments = [
        { user_id: 2, role_in_campaign: 'caller' },
        { user_id: 3, role_in_campaign: 'manager' },
        { user_id: 4, role_in_campaign: 'supervisor' }
    ];
    
    for (const assignment of assignments) {
        try {
            const response = await fetch(`${BASE_URL}/campaign-assignees/assign`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                    'Authorization': `Bearer ${TOKEN}`
                },
                body: JSON.stringify({
                    campaign_id: 1,
                    ...assignment
                })
            });
            
            const data = await response.json();
            console.log(`User ${assignment.user_id} assigned as ${assignment.role_in_campaign}:`, data);
        } catch (error) {
            console.error(`Error assigning user ${assignment.user_id}:`, error);
        }
    }
}

// Example 3: Get all assignees for a campaign
async function getCampaignAssignees(campaignId) {
    try {
        const response = await fetch(`${BASE_URL}/campaign-assignees/campaign/${campaignId}`, {
            headers: {
                'Authorization': `Bearer ${TOKEN}`
            }
        });
        
        const data = await response.json();
        console.log(`Assignees for campaign ${campaignId}:`, data.assignees);
        return data.assignees;
    } catch (error) {
        console.error('Error getting campaign assignees:', error);
    }
}

// Example 4: Get all campaigns for a user
async function getUserCampaigns(userId) {
    try {
        const response = await fetch(`${BASE_URL}/campaign-assignees/user/${userId}`, {
            headers: {
                'Authorization': `Bearer ${TOKEN}`
            }
        });
        
        const data = await response.json();
        console.log(`Campaigns for user ${userId}:`, data.campaigns);
        return data.campaigns;
    } catch (error) {
        console.error('Error getting user campaigns:', error);
    }
}

// Example 5: Get all campaigns with assignee information
async function getAllCampaignsWithAssignees() {
    try {
        const response = await fetch(`${BASE_URL}/campaigns`, {
            headers: {
                'Authorization': `Bearer ${TOKEN}`
            }
        });
        
        const data = await response.json();
        console.log('All campaigns with assignees:', data.campaigns);
        
        // Show assignee count for each campaign
        data.campaigns.forEach(campaign => {
            console.log(`Campaign: ${campaign.name}`);
            console.log(`  - Total leads: ${campaign.total_leads}`);
            console.log(`  - Assignee count: ${campaign.assignee_count}`);
            console.log(`  - Assignees:`, campaign.assignees.map(a => 
                `${a.user_name} (${a.role_in_campaign})`
            ));
        });
        
        return data.campaigns;
    } catch (error) {
        console.error('Error getting campaigns:', error);
    }
}

// Example 6: Update user role in campaign
async function updateUserRole(assignmentId, newRole) {
    try {
        const response = await fetch(`${BASE_URL}/campaign-assignees/assignment/${assignmentId}`, {
            method: 'PUT',
            headers: {
                'Content-Type': 'application/json',
                'Authorization': `Bearer ${TOKEN}`
            },
            body: JSON.stringify({
                role_in_campaign: newRole
            })
        });
        
        const data = await response.json();
        console.log('Role updated successfully:', data);
    } catch (error) {
        console.error('Error updating role:', error);
    }
}

// Example 7: Remove user from campaign
async function removeUserFromCampaign(campaignId, userId) {
    try {
        const response = await fetch(`${BASE_URL}/campaign-assignees/campaign/${campaignId}/user/${userId}`, {
            method: 'DELETE',
            headers: {
                'Authorization': `Bearer ${TOKEN}`
            }
        });
        
        const data = await response.json();
        console.log('User removed from campaign:', data);
    } catch (error) {
        console.error('Error removing user from campaign:', error);
    }
}

// Example 8: Sample data setup
async function setupSampleData() {
    console.log('Setting up sample campaign assignments...');
    
    // First, create some campaigns if they don't exist
    const campaigns = [
        { name: 'Summer Sales Campaign', description: 'Summer sales drive', created_by: 1 },
        { name: 'Product Launch', description: 'New product launch campaign', created_by: 1 },
        { name: 'Customer Retention', description: 'Customer retention campaign', created_by: 1 }
    ];
    
    // Then assign users to campaigns
    const assignments = [
        // Campaign 1 assignments
        { campaign_id: 1, user_id: 2, role_in_campaign: 'caller' },
        { campaign_id: 1, user_id: 3, role_in_campaign: 'manager' },
        
        // Campaign 2 assignments
        { campaign_id: 2, user_id: 2, role_in_campaign: 'supervisor' },
        { campaign_id: 2, user_id: 4, role_in_campaign: 'caller' },
        
        // Campaign 3 assignments
        { campaign_id: 3, user_id: 3, role_in_campaign: 'manager' },
        { campaign_id: 3, user_id: 2, role_in_campaign: 'caller' }
    ];
    
    for (const assignment of assignments) {
        try {
            const response = await fetch(`${BASE_URL}/campaign-assignees/assign`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                    'Authorization': `Bearer ${TOKEN}`
                },
                body: JSON.stringify(assignment)
            });
            
            const data = await response.json();
            console.log(`Assigned user ${assignment.user_id} to campaign ${assignment.campaign_id} as ${assignment.role_in_campaign}`);
        } catch (error) {
            console.error(`Error assigning user ${assignment.user_id} to campaign ${assignment.campaign_id}:`, error);
        }
    }
}

// Export functions for use
module.exports = {
    assignUserToCampaign,
    assignMultipleUsersToCampaign,
    getCampaignAssignees,
    getUserCampaigns,
    getAllCampaignsWithAssignees,
    updateUserRole,
    removeUserFromCampaign,
    setupSampleData
};

// Run examples (uncomment to test)
// assignUserToCampaign();
// assignMultipleUsersToCampaign();
// getCampaignAssignees(1);
// getUserCampaigns(2);
// getAllCampaignsWithAssignees();
// setupSampleData(); 