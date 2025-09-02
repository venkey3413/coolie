const express = require('express');
const sqlite3 = require('sqlite3').verbose();
const path = require('path');
const app = express();

app.use(express.json());
app.use(express.static('.'));

// Initialize SQLite database
const db = new sqlite3.Database('resort.db');

// Create tables
db.serialize(() => {
    // Bookings table
    db.run(`CREATE TABLE IF NOT EXISTS bookings (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT NOT NULL,
        phone TEXT NOT NULL,
        checkin DATE NOT NULL,
        checkout DATE NOT NULL,
        guests INTEGER NOT NULL,
        room_type TEXT NOT NULL,
        special_requests TEXT,
        total_amount DECIMAL(10,2),
        booking_date DATETIME DEFAULT CURRENT_TIMESTAMP,
        status TEXT DEFAULT 'pending'
    )`);

    // Transactions table
    db.run(`CREATE TABLE IF NOT EXISTS transactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        booking_id INTEGER,
        amount DECIMAL(10,2) NOT NULL,
        payment_method TEXT,
        transaction_id TEXT,
        status TEXT DEFAULT 'pending',
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (booking_id) REFERENCES bookings (id)
    )`);

    // Contacts table
    db.run(`CREATE TABLE IF NOT EXISTS contacts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT NOT NULL,
        subject TEXT NOT NULL,
        message TEXT NOT NULL,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP
    )`);
});

// API Routes
app.post('/api/bookings', (req, res) => {
    const { name, email, phone, checkin, checkout, guests, roomType, requests } = req.body;
    
    // Calculate total amount
    const roomPrices = {
        'ocean-view': 299,
        'beachfront': 499,
        'presidential': 799,
        'family': 399
    };
    
    const nights = Math.ceil((new Date(checkout) - new Date(checkin)) / (1000 * 60 * 60 * 24));
    const totalAmount = nights * roomPrices[roomType];
    
    const stmt = db.prepare(`INSERT INTO bookings 
        (name, email, phone, checkin, checkout, guests, room_type, special_requests, total_amount) 
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)`);
    
    stmt.run([name, email, phone, checkin, checkout, guests, roomType, requests, totalAmount], function(err) {
        if (err) {
            res.status(500).json({ error: err.message });
            return;
        }
        res.json({ 
            bookingId: this.lastID, 
            totalAmount: totalAmount,
            message: 'Booking created successfully' 
        });
    });
});

app.post('/api/contacts', (req, res) => {
    const { name, email, subject, message } = req.body;
    
    const stmt = db.prepare(`INSERT INTO contacts (name, email, subject, message) VALUES (?, ?, ?, ?)`);
    stmt.run([name, email, subject, message], function(err) {
        if (err) {
            res.status(500).json({ error: err.message });
            return;
        }
        res.json({ id: this.lastID, message: 'Contact saved successfully' });
    });
});

app.post('/api/transactions', (req, res) => {
    const { bookingId, amount, paymentMethod, transactionId } = req.body;
    
    const stmt = db.prepare(`INSERT INTO transactions (booking_id, amount, payment_method, transaction_id, status) 
        VALUES (?, ?, ?, ?, 'completed')`);
    
    stmt.run([bookingId, amount, paymentMethod, transactionId], function(err) {
        if (err) {
            res.status(500).json({ error: err.message });
            return;
        }
        res.json({ id: this.lastID, message: 'Transaction recorded' });
    });
});

// Get bookings
app.get('/api/bookings', (req, res) => {
    db.all("SELECT * FROM bookings ORDER BY booking_date DESC", (err, rows) => {
        if (err) {
            res.status(500).json({ error: err.message });
            return;
        }
        res.json(rows);
    });
});

// Get contacts
app.get('/api/contacts', (req, res) => {
    db.all("SELECT * FROM contacts ORDER BY created_at DESC", (err, rows) => {
        if (err) {
            res.status(500).json({ error: err.message });
            return;
        }
        res.json(rows);
    });
});



const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
    console.log(`Server running on port ${PORT}`);
    console.log(`Visit: http://localhost:${PORT}`);
});