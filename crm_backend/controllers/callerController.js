const callerModel = require('../models/caller');

exports.createCaller = async (req, res) => {
    try {
        const id = await callerModel.create(req.body);
        const caller = await callerModel.findById(id);
        res.status(201).json({ success: true, caller });
    } catch (err) {
        console.error('Create caller error:', err);
        res.status(500).json({ error: 'Internal server error', details: err.message });
    }
};

exports.getAllCallers = async (req, res) => {
    try {
        const callers = await callerModel.findAll();
        res.json({ success: true, callers });
    } catch (err) {
        console.error('Get callers error:', err);
        res.status(500).json({ error: 'Internal server error' });
    }
};

exports.getCallerById = async (req, res) => {
    try {
        const caller = await callerModel.findById(req.params.id);
        if (!caller) {
            return res.status(404).json({ error: 'Caller not found' });
        }
        res.json({ success: true, caller });
    } catch (err) {
        console.error('Get caller error:', err);
        res.status(500).json({ error: 'Internal server error' });
    }
};

exports.updateCaller = async (req, res) => {
    try {
        await callerModel.update(req.params.id, req.body);
        const caller = await callerModel.findById(req.params.id);
        res.json({ success: true, caller });
    } catch (err) {
        console.error('Update caller error:', err);
        res.status(500).json({ error: 'Internal server error' });
    }
};

exports.deleteCaller = async (req, res) => {
    try {
        const caller = await callerModel.findById(req.params.id);
        if (!caller) {
            return res.status(404).json({ error: 'Caller not found' });
        }
        await callerModel.delete(req.params.id);
        res.json({ success: true, message: 'Caller deleted' });
    } catch (err) {
        console.error('Delete caller error:', err);
        res.status(500).json({ error: 'Internal server error' });
    }
}; 