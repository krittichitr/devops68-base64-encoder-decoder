const express = require('express');
const app = express();

app.get('/encode', (req, res) => {
  const { text } = req.query;
  if (!text) return res.status(400).json({ error: 'Missing text parameter' });
  
  const encoded = Buffer.from(text).toString('base64');
  res.json({ input: text, encoded });
});

app.get('/decode', (req, res) => {
  const { text } = req.query;
  if (!text) return res.status(400).json({ error: 'Missing text parameter' });
  
  try {
    const decoded = Buffer.from(text, 'base64').toString('utf8');
    res.json({ input: text, decoded });
  } catch (e) {
    res.status(400).json({ error: 'Invalid Base64' });
  }
});

app.listen(3027, () => console.log('Base64 Encoder/Decoder API on port 3027'));
