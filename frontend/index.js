const express = require('express');
const app = express();
const PORT = 3000;

app.get('/', (req, res) => {
    res.send('<h1>Welcome to the NutriTrack Frontend Tier!</h1><p>The container is running perfectly.</p>');
});

app.listen(PORT, () => {
    console.log(`Frontend UI server running on http://localhost:${PORT}`);
});