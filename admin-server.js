const express = require('express');
const sqlite3 = require('sqlite3').verbose();
const path = require('path');
const app = express();

app.use(express.json());

// Initialize SQLite database
const db = new sqlite3.Database('resort.db');

// Admin panel route
app.get('/', (req, res) => {
    res.sendFile(__dirname + '/admin.html');
});

// API Routes for admin
app.get('/api/bookings', (req, res) => {
    db.all("SELECT * FROM bookings ORDER BY booking_date DESC", (err, rows) => {
        if (err) {
            res.status(500).json({ error: err.message });
            return;
        }
        res.json(rows);
    });
});

app.get('/api/contacts', (req, res) => {
    db.all("SELECT * FROM contacts ORDER BY created_at DESC", (err, rows) => {
        if (err) {
            res.status(500).json({ error: err.message });
            return;
        }
        res.json(rows);
    });
});

app.get('/api/transactions', (req, res) => {
    db.all("SELECT * FROM transactions ORDER BY created_at DESC", (err, rows) => {
        if (err) {
            res.status(500).json({ error: err.message });
            return;
        }
        res.json(rows);
    });
});

const PORT = process.env.ADMIN_PORT || 4000;
app.listen(PORT, () => {
    console.log(`Admin Panel running on port ${PORT}`);
    console.log(`Visit: http://localhost:${PORT}`);
});