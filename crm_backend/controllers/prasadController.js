const express = require('express');
const router = express.Router();
const db = require('../db');

// Get all prasad records
router.get('/', async (req, res) => {
  try {
    const [rows] = await db.execute(
      'SELECT * FROM prasad ORDER BY created_on DESC'
    );
    
    res.json({
      success: true,
      data: rows,
      message: 'Prasad records retrieved successfully'
    });
  } catch (error) {
    console.error('Error getting prasad records:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to get prasad records',
      error: error.message
    });
  }
});

// Create a new prasad record
router.post('/', async (req, res) => {
  try {
    const { donor_name, donation_date, status, images, email } = req.body;
    
    // Validate required fields
    if (!donor_name || !donation_date) {
      return res.status(400).json({
        success: false,
        message: 'Donor name and donation date are required'
      });
    }
    
    const [result] = await db.execute(
      'INSERT INTO prasad (donor_name, donation_date, status, images, email) VALUES (?, ?, ?, ?, ?)',
      [donor_name, donation_date, status || 'Not Verified', images || 'Not Sent', email || 'No']
    );
    
    // Get the newly created prasad record
    const [newPrasad] = await db.execute(
      'SELECT * FROM prasad WHERE id = ?',
      [result.insertId]
    );
    
    res.status(201).json({
      success: true,
      data: newPrasad[0],
      message: 'Prasad record created successfully'
    });
  } catch (error) {
    console.error('Error creating prasad record:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to create prasad record',
      error: error.message
    });
  }
});

// Update a prasad record
router.put('/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const { donor_name, donation_date, status, images, email } = req.body;
    
    // Check if prasad record exists
    const [existingPrasad] = await db.execute(
      'SELECT * FROM prasad WHERE id = ?',
      [id]
    );
    
    if (existingPrasad.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Prasad record not found'
      });
    }
    
    // Update prasad record
    await db.execute(
      'UPDATE prasad SET donor_name = ?, donation_date = ?, status = ?, images = ?, email = ? WHERE id = ?',
      [donor_name, donation_date, status, images, email, id]
    );
    
    // Get updated prasad record
    const [updatedPrasad] = await db.execute(
      'SELECT * FROM prasad WHERE id = ?',
      [id]
    );
    
    res.json({
      success: true,
      data: updatedPrasad[0],
      message: 'Prasad record updated successfully'
    });
  } catch (error) {
    console.error('Error updating prasad record:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to update prasad record',
      error: error.message
    });
  }
});

// Delete a prasad record
router.delete('/:id', async (req, res) => {
  try {
    const { id } = req.params;
    
    // Check if prasad record exists
    const [existingPrasad] = await db.execute(
      'SELECT * FROM prasad WHERE id = ?',
      [id]
    );
    
    if (existingPrasad.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Prasad record not found'
      });
    }
    
    // Delete prasad record
    await db.execute(
      'DELETE FROM prasad WHERE id = ?',
      [id]
    );
    
    res.json({
      success: true,
      message: 'Prasad record deleted successfully'
    });
  } catch (error) {
    console.error('Error deleting prasad record:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to delete prasad record',
      error: error.message
    });
  }
});

// Search prasad records by name
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
      'SELECT * FROM prasad WHERE donor_name LIKE ? ORDER BY created_on DESC',
      [`%${name}%`]
    );
    
    res.json({
      success: true,
      data: rows,
      message: 'Prasad records found successfully'
    });
  } catch (error) {
    console.error('Error searching prasad records:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to search prasad records',
      error: error.message
    });
  }
});

// Get prasad records by status
router.get('/status/:status', async (req, res) => {
  try {
    const { status } = req.params;
    
    const [rows] = await db.execute(
      'SELECT * FROM prasad WHERE status = ? ORDER BY created_on DESC',
      [status]
    );
    
    res.json({
      success: true,
      data: rows,
      message: 'Prasad records retrieved successfully'
    });
  } catch (error) {
    console.error('Error getting prasad records by status:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to get prasad records by status',
      error: error.message
    });
  }
});

// Get prasad records by images status
router.get('/images/:imagesStatus', async (req, res) => {
  try {
    const { imagesStatus } = req.params;
    
    const [rows] = await db.execute(
      'SELECT * FROM prasad WHERE images = ? ORDER BY created_on DESC',
      [imagesStatus]
    );
    
    res.json({
      success: true,
      data: rows,
      message: 'Prasad records retrieved successfully'
    });
  } catch (error) {
    console.error('Error getting prasad records by images status:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to get prasad records by images status',
      error: error.message
    });
  }
});

// Get prasad records by email status
router.get('/email/:emailStatus', async (req, res) => {
  try {
    const { emailStatus } = req.params;
    
    const [rows] = await db.execute(
      'SELECT * FROM prasad WHERE email = ? ORDER BY created_on DESC',
      [emailStatus]
    );
    
    res.json({
      success: true,
      data: rows,
      message: 'Prasad records retrieved successfully'
    });
  } catch (error) {
    console.error('Error getting prasad records by email status:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to get prasad records by email status',
      error: error.message
    });
  }
});

module.exports = router;



