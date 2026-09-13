// db.js
// Base de datos muy sencilla basada en un archivo JSON en disco.
// Se eligió este enfoque (en lugar de un motor con dependencias nativas
// como sqlite3) para que "npm install" funcione sin problemas en
// cualquier computador (Windows, macOS, Linux) sin necesidad de
// compiladores adicionales. Para un proyecto académico es más que
// suficiente y mantiene el código fácil de leer.

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
    // Si el archivo está corrupto, se reinicia (solo pasaría en un entorno de pruebas)
    const initial = { users: [], calificaciones: [] };
    fs.writeFileSync(DB_PATH, JSON.stringify(initial, null, 2));
    return initial;
  }
}

function writeDb(data) {
  fs.writeFileSync(DB_PATH, JSON.stringify(data, null, 2));
}

module.exports = { readDb, writeDb };
