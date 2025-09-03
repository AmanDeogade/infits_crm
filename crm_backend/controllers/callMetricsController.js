const callMetricsModel = require('../models/call_metrics');

exports.createCallMetrics = async (req, res) => {
    try {
        const id = await callMetricsModel.create(req.body);
        const metrics = await callMetricsModel.findById(id);
        res.status(201).json({ success: true, metrics });
    } catch (err) {
        console.error('Create call_metrics error:', err);
        res.status(500).json({ error: 'Internal server error', details: err.message });
    }
};

exports.getAllCallMetrics = async (req, res) => {
    try {
        console.log('Getting all call metrics...');
        const metrics = await callMetricsModel.findAll();
        console.log('Found metrics:', metrics.length);
        console.log('Sample metric:', metrics[0]);
        
        if (metrics.length === 0) {
            console.log('No call metrics found in database');
            return res.json({ success: true, metrics: [] });
        }
        
        res.json({ success: true, metrics });
    } catch (err) {
        console.error('Get all call_metrics error:', err);
        res.status(500).json({ error: 'Internal server error', details: err.message });
    }
};

exports.getCallMetricsById = async (req, res) => {
    try {
        const metrics = await callMetricsModel.findById(req.params.id);
        if (!metrics) {
            return res.status(404).json({ error: 'Call metrics not found' });
        }
        res.json({ success: true, metrics });
    } catch (err) {
        console.error('Get call_metrics by id error:', err);
        res.status(500).json({ error: 'Internal server error', details: err.message });
    }
};

exports.getCallMetricsByUserId = async (req, res) => {
    try {
        console.log('Getting call metrics for user_id:', req.params.user_id);
        const metrics = await callMetricsModel.findByUserId(req.params.user_id);
        console.log('Found metrics for user:', metrics.length);
        console.log('Metrics:', metrics);
        res.json({ success: true, metrics });
    } catch (err) {
        console.error('Get call_metrics by user_id error:', err);
        res.status(500).json({ error: 'Internal server error', details: err.message });
    }
};

exports.updateCallMetrics = async (req, res) => {
    try {
        await callMetricsModel.update(req.params.id, req.body);
        const metrics = await callMetricsModel.findById(req.params.id);
        res.json({ success: true, metrics });
    } catch (err) {
        console.error('Update call_metrics error:', err);
        res.status(500).json({ error: 'Internal server error', details: err.message });
    }
};

exports.deleteCallMetrics = async (req, res) => {
    try {
        await callMetricsModel.delete(req.params.id);
        res.json({ success: true, message: 'Call metrics deleted' });
    } catch (err) {
        console.error('Delete call_metrics error:', err);
        res.status(500).json({ error: 'Internal server error', details: err.message });
    }
}; 