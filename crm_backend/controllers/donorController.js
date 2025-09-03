const express = require('express');
const router = express.Router();
const db = require('../db');

// Get all donors
router.get('/', async (req, res) => {
  try {
    const [rows] = await db.execute(
      'SELECT * FROM donors ORDER BY created_on DESC'
    );
    
    res.json({
      success: true,
      data: rows,
      message: 'Donors retrieved successfully'
    });
  } catch (error) {
    console.error('Error getting donors:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to get donors',
      error: error.message
    });
  }
});

// Create a new donor
router.post('/', async (req, res) => {
  try {
    const { donor_name, donation_date, status, images } = req.body;
    
    // Validate required fields
    if (!donor_name || !donation_date) {
      return res.status(400).json({
        success: false,
        message: 'Donor name and donation date are required'
      });
    }
    
    const [result] = await db.execute(
      'INSERT INTO donors (donor_name, donation_date, status, images) VALUES (?, ?, ?, ?)',
      [donor_name, donation_date, status || 'Not Verified', images || 'Not Sent']
    );
    
    // Get the newly created donor
    const [newDonor] = await db.execute(
      'SELECT * FROM donors WHERE id = ?',
      [result.insertId]
    );
    
    res.status(201).json({
      success: true,
      data: newDonor[0],
      message: 'Donor created successfully'
    });
  } catch (error) {
    console.error('Error creating donor:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to create donor',
      error: error.message
    });
  }
});

// Update a donor
router.put('/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const { donor_name, donation_date, status, images } = req.body;
    
    // Check if donor exists
    const [existingDonor] = await db.execute(
      'SELECT * FROM donors WHERE id = ?',
      [id]
    );
    
    if (existingDonor.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Donor not found'
      });
    }
    
    // Update donor
    await db.execute(
      'UPDATE donors SET donor_name = ?, donation_date = ?, status = ?, images = ? WHERE id = ?',
      [donor_name, donation_date, status, images, id]
    );
    
    // Get updated donor
    const [updatedDonor] = await db.execute(
      'SELECT * FROM donors WHERE id = ?',
      [id]
    );
    
    res.json({
      success: true,
      data: updatedDonor[0],
      message: 'Donor updated successfully'
    });
  } catch (error) {
    console.error('Error updating donor:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to update donor',
      error: error.message
    });
  }
});

// Delete a donor
router.delete('/:id', async (req, res) => {
  try {
    const { id } = req.params;
    
    // Check if donor exists
    const [existingDonor] = await db.execute(
      'SELECT * FROM donors WHERE id = ?',
      [id]
    );
    
    if (existingDonor.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Donor not found'
      });
    }
    
    // Delete donor
    await db.execute(
      'DELETE FROM donors WHERE id = ?',
      [id]
    );
    
    res.json({
      success: true,
      message: 'Donor deleted successfully'
    });
  } catch (error) {
    console.error('Error deleting donor:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to delete donor',
      error: error.message
    });
  }
});

// Search donors by name
router.get('/search/name', async (req, res) => {
  try {
    const { name } = req.query;
    
    if (!name) {
      return res.status(400).json({
        success: false,
        message: 'Name parameter is required'
      });
    }
    
    const [rows] = await db.execute(
      'SELECT * FROM donors WHERE donor_name LIKE ? ORDER BY created_on DESC',
      [`%${name}%`]
    );
    
    res.json({
      success: true,
      data: rows,
      message: 'Donors search completed successfully'
    });
  } catch (error) {
    console.error('Error searching donors:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to search donors',
      error: error.message
    });
  }
});

// Get donors by status
router.get('/status/:status', async (req, res) => {
  try {
    const { status } = req.params;
    
    const [rows] = await db.execute(
      'SELECT * FROM donors WHERE status = ? ORDER BY created_on DESC',
      [status]
    );
    
    res.json({
      success: true,
      data: rows,
      message: `Donors with status '${status}' retrieved successfully`
    });
  } catch (error) {
    console.error('Error getting donors by status:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to get donors by status',
      error: error.message
    });
  }
});

// Get donors by images status
router.get('/images/:imagesStatus', async (req, res) => {
  try {
    const { imagesStatus } = req.params;
    
    const [rows] = await db.execute(
      'SELECT * FROM donors WHERE images = ? ORDER BY created_on DESC',
      [imagesStatus]
    );
    
    res.json({
      success: true,
      data: rows,
      message: `Donors with images status '${imagesStatus}' retrieved successfully`
    });
  } catch (error) {
    console.error('Error getting donors by images status:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to get donors by images status',
      error: error.message
    });
  }
});

module.exports = router;
