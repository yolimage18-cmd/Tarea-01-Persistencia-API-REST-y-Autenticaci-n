// routes/calificaciones.js
// asignatura: { studentName, subject, grade, comment }.

const express = require('express');
const { nanoid } = require('nanoid');
const { readDb, writeDb } = require('../db');
const authMiddleware = require('../middleware/auth');

const router = express.Router();

router.use(authMiddleware);

function validateGrade(grade) {
  const value = Number(grade);
  return !Number.isNaN(value) && value >= 0 && value <= 5;
}

// GET /api/calificaciones -> lista las calificaciones del usuario autenticado
router.get('/', (req, res) => {
  const db = readDb();
  const calificaciones = db.calificaciones
    .filter((c) => c.userId === req.userId)
    .sort((a, b) => new Date(b.updatedAt) - new Date(a.updatedAt));

  return res.json({ calificaciones });
});

// POST /api/calificaciones -> crea una calificación nueva
router.post('/', (req, res) => {
  const { studentName, subject, grade, comment } = req.body;

  if (!studentName || !studentName.trim()) {
    return res.status(400).json({ error: 'El nombre del estudiante es obligatorio.' });
  }
  if (!subject || !subject.trim()) {
    return res.status(400).json({ error: 'La asignatura es obligatoria.' });
  }
  if (grade === undefined || grade === null || !validateGrade(grade)) {
    return res.status(400).json({ error: 'La calificación debe ser un número entre 0.0 y 5.0.' });
  }

  const db = readDb();
  const now = new Date().toISOString();

  const calificacion = {
    id: nanoid(),
    userId: req.userId,
    studentName: studentName.trim(),
    subject: subject.trim(),
    grade: Number(grade),
    comment: comment ? String(comment) : '',
    createdAt: now,
    updatedAt: now,
  };

  db.calificaciones.push(calificacion);
  writeDb(db);

  return res.status(201).json({ calificacion });
});

// PUT /api/calificaciones/:id -> actualiza una calificación existente
router.put('/:id', (req, res) => {
  const { id } = req.params;
  const { studentName, subject, grade, comment } = req.body;

  const db = readDb();
  const calificacion = db.calificaciones.find((c) => c.id === id && c.userId === req.userId);

  if (!calificacion) {
    return res.status(404).json({ error: 'Calificación no encontrada.' });
  }

  if (studentName !== undefined) {
    if (!studentName.trim()) {
      return res.status(400).json({ error: 'El nombre del estudiante es obligatorio.' });
    }
    calificacion.studentName = studentName.trim();
  }
  if (subject !== undefined) {
    if (!subject.trim()) {
      return res.status(400).json({ error: 'La asignatura es obligatoria.' });
    }
    calificacion.subject = subject.trim();
  }
  if (grade !== undefined) {
    if (!validateGrade(grade)) {
      return res.status(400).json({ error: 'La calificación debe ser un número entre 0.0 y 5.0.' });
    }
    calificacion.grade = Number(grade);
  }
  if (comment !== undefined) {
    calificacion.comment = String(comment);
  }
  calificacion.updatedAt = new Date().toISOString();

  writeDb(db);

  return res.json({ calificacion });
});

// DELETE /api/calificaciones/:id -> elimina una calificación
router.delete('/:id', (req, res) => {
  const { id } = req.params;
  const db = readDb();

  const index = db.calificaciones.findIndex((c) => c.id === id && c.userId === req.userId);
  if (index === -1) {
    return res.status(404).json({ error: 'Calificación no encontrada.' });
  }

  db.calificaciones.splice(index, 1);
  writeDb(db);

  return res.status(204).send();
});

module.exports = router;
