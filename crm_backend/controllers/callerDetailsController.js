const callerDetailsModel = require('../models/caller_details');

exports.createCallerDetails = async (req, res) => {
    try {
        const id = await callerDetailsModel.create(req.body);
        const details = await callerDetailsModel.findById(id);
        res.status(201).json({ success: true, details });
    } catch (err) {
        console.error('Create caller_details error:', err);
        res.status(500).json({ error: 'Internal server error', details: err.message });
    }
};

exports.getAllCallerDetails = async (req, res) => {
    try {
        const details = await callerDetailsModel.findAll();
        res.json({ success: true, details });
    } catch (err) {
        console.error('Get all caller_details error:', err);
        res.status(500).json({ error: 'Internal server error' });
    }
};

exports.getCallerDetailsById = async (req, res) => {
    try {
        const details = await callerDetailsModel.findById(req.params.id);
        if (!details) {
            return res.status(404).json({ error: 'Caller details not found' });
        }
        res.json({ success: true, details });
    } catch (err) {
        console.error('Get caller_details by id error:', err);
        res.status(500).json({ error: 'Internal server error' });
    }
};

exports.getCallerDetailsByCallerId = async (req, res) => {
    try {
        const details = await callerDetailsModel.findByCallerId(req.params.caller_id);
        res.json({ success: true, details });
    } catch (err) {
        console.error('Get caller_details by caller_id error:', err);
        res.status(500).json({ error: 'Internal server error' });
    }
};

exports.updateCallerDetails = async (req, res) => {
    try {
        await callerDetailsModel.update(req.params.id, req.body);
        const details = await callerDetailsModel.findById(req.params.id);
        res.json({ success: true, details });
    } catch (err) {
        console.error('Update caller_details error:', err);
        res.status(500).json({ error: 'Internal server error' });
    }
};

exports.deleteCallerDetails = async (req, res) => {
    try {
        await callerDetailsModel.delete(req.params.id);
        res.json({ success: true, message: 'Caller details deleted' });
    } catch (err) {
        console.error('Delete caller_details error:', err);
        res.status(500).json({ error: 'Internal server error' });
    }
}; 