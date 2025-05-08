const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');

const app = express();
app.use(express.json());
app.use(cors({
  origin: '*', // Allow all origins during development
  methods: ['GET', 'POST', 'PUT', 'DELETE']
}));

const uri = "mongodb+srv://hassan:abcd1234@cluster1.jqorgju.mongodb.net/item?retryWrites=true&w=majority&appName=Cluster1";

mongoose.connect(uri)
  .then(() => console.log("MongoDB connected successfully"))
  .catch(err => console.error("MongoDB connection error:", err));

const ItemSchema = new mongoose.Schema({ name: String });
const Item = mongoose.model('Item', ItemSchema);

// Routes with better error handling
app.get('/item', async (req, res) => {
  try {
    const items = await Item.find();
    res.json(items);
  } catch (err) {
    console.error("Error fetching items:", err);
    res.status(500).json({ error: "Failed to fetch items" });
  }
});

app.post('/item', async (req, res) => {
  try {
    const { name } = req.body;

    if (!name || typeof name !== 'string') {
      return res.status(400).json({ error: "Valid name is required" });
    }

    const item = new Item({ name: name.trim() });
    await item.save();
    res.status(201).json(item);
  } catch (err) {
    console.error("Error saving item:", err);
    res.status(500).json({ error: "Server error: " + err.message });
  }
});

const PORT = process.env.PORT || 5000;
app.listen(PORT, '0.0.0.0', () => console.log(`Server running on port ${PORT}`));
// ^ Removed the extra parenthesis here