const fs = require('fs');
const path = require('path');

const DB_PATH = path.join(__dirname, 'data', 'db.json');

function ensureDbFile() {
  const dir = path.dirname(DB_PATH);
  if (!fs.existsSync(dir)) {
    fs.mkdirSync(dir, { recursive: true });
  }
  if (!fs.existsSync(DB_PATH)) {
    const initial = { users: [], calificaciones: [] };
    fs.writeFileSync(DB_PATH, JSON.stringify(initial, null, 2));
  }
}

function readDb() {
  ensureDbFile();
  const raw = fs.readFileSync(DB_PATH, 'utf-8');
  try {
    return JSON.parse(raw);
  } catch (err) {
    // Si el archivo está corrupto, se reinicia 
    const initial = { users: [], calificaciones: [] };
    fs.writeFileSync(DB_PATH, JSON.stringify(initial, null, 2));
    return initial;
  }
}

function writeDb(data) {
  fs.writeFileSync(DB_PATH, JSON.stringify(data, null, 2));
}

module.exports = { readDb, writeDb };
